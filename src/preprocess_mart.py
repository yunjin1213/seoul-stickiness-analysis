# -*- coding: utf-8 -*-
from __future__ import print_function

from pyspark.sql import functions as F
from pyspark.sql.window import Window

from preprocess_io import write_parquet


def quarter_from_date(date_col):
    month_col = F.month(F.to_date(date_col))
    quarter = (
        F.when(month_col <= 3, F.lit("Q1"))
        .when(month_col <= 6, F.lit("Q2"))
        .when(month_col <= 9, F.lit("Q3"))
        .otherwise(F.lit("Q4"))
    )
    return F.concat(F.year(F.to_date(date_col)).cast("string"), quarter)


def safe_divide(numerator, denominator):
    return F.when((denominator.isNull()) | (denominator == 0), F.lit(None)).otherwise(
        numerator / denominator
    )


def zscore(column):
    w = Window.partitionBy("quarter_code", "time_slot")
    avg_col = F.avg(column).over(w)
    std_col = F.stddev_pop(column).over(w)
    return F.when((std_col.isNull()) | (std_col == 0), F.lit(0.0)).otherwise(
        (column - avg_col) / std_col
    )


def sales_time_slot_from_hour(hour_col):
    hour_int = hour_col.cast("int")
    return (
        F.when((hour_int >= 0) & (hour_int < 6), F.lit("00_06"))
        .when((hour_int >= 6) & (hour_int < 11), F.lit("06_11"))
        .when((hour_int >= 11) & (hour_int < 14), F.lit("11_14"))
        .when((hour_int >= 14) & (hour_int < 17), F.lit("14_17"))
        .when((hour_int >= 17) & (hour_int < 21), F.lit("17_21"))
        .when((hour_int >= 21) & (hour_int < 24), F.lit("21_24"))
        .otherwise(F.lit(None))
    )


def build_aggregates(
    clean_people,
    clean_subway,
    clean_market_sales,
    market_dong_bridge,
    station_dong_bridge,
    hdfs_base_dir,
):
    dong_dim = market_dong_bridge.select("dong_code", "dong_name").dropDuplicates()

    people = (
        clean_people.join(F.broadcast(dong_dim), "dong_code", "inner")
        .withColumn("quarter_code", quarter_from_date(F.col("base_date")))
        .groupBy("base_date", "quarter_code", "dong_code", "dong_name", "time_slot")
        .agg(F.sum("living_population").alias("living_population"))
    )
    people = write_parquet(people, hdfs_base_dir + "/processed/agg/people_by_dong_time")

    subway = (
        clean_subway.where(F.col("boarding_type") == F.lit("하차"))
        .join(F.broadcast(station_dong_bridge), ["station_name", "line_name"], "inner")
        .withColumn("quarter_code", quarter_from_date(F.col("transport_date")))
        .groupBy(
            "transport_date", "quarter_code", "dong_code", "dong_name", "time_slot"
        )
        .agg(F.sum("passenger_count").alias("subway_inflow"))
    )
    subway = write_parquet(subway, hdfs_base_dir + "/processed/agg/subway_by_dong_time")

    sales = (
        clean_market_sales.join(F.broadcast(market_dong_bridge), "market_code", "inner")
        .groupBy("quarter_code", "dong_code", "dong_name", "time_slot")
        .agg(
            F.sum("sales_amount").alias("sales_amount"),
            F.sum("sales_count").alias("sales_count"),
        )
    )
    sales = write_parquet(sales, hdfs_base_dir + "/processed/agg/sales_by_dong_time")

    return people, subway, sales


def build_marts(people, subway, sales, hdfs_base_dir):
    subway_daily = subway.withColumnRenamed("transport_date", "base_date").select(
        "base_date", "dong_code", "time_slot", "subway_inflow"
    )
    daily = (
        people.join(subway_daily, ["base_date", "dong_code", "time_slot"], "inner")
        .select(
            "base_date",
            "quarter_code",
            "dong_code",
            "dong_name",
            "time_slot",
            "subway_inflow",
            "living_population",
        )
        .withColumn(
            "stay_index",
            safe_divide(F.col("living_population"), F.col("subway_inflow")),
        )
    )
    write_parquet(daily, hdfs_base_dir + "/processed/mart/analysis_mart_daily")

    people_quarter = (
        people.withColumn("sales_time_slot", sales_time_slot_from_hour(F.col("time_slot")))
        .where(F.col("sales_time_slot").isNotNull())
        .groupBy("quarter_code", "dong_code", "dong_name", "sales_time_slot")
        .agg(F.avg("living_population").alias("living_population"))
        .withColumnRenamed("sales_time_slot", "time_slot")
    )
    subway_quarter = (
        subway.withColumn("sales_time_slot", sales_time_slot_from_hour(F.col("time_slot")))
        .where(F.col("sales_time_slot").isNotNull())
        .groupBy("quarter_code", "dong_code", "dong_name", "sales_time_slot")
        .agg(F.avg("subway_inflow").alias("subway_inflow"))
        .withColumnRenamed("sales_time_slot", "time_slot")
    )
    quarter = (
        people_quarter.join(
            subway_quarter, ["quarter_code", "dong_code", "dong_name", "time_slot"], "inner"
        )
        .join(sales, ["quarter_code", "dong_code", "dong_name", "time_slot"], "inner")
        .withColumn("stay_index", safe_divide(F.col("living_population"), F.col("subway_inflow")))
        .withColumn(
            "consumption_index",
            safe_divide(F.col("sales_amount").cast("double"), F.col("living_population")),
        )
        .withColumn(
            "conversion_score",
            zscore(F.col("subway_inflow"))
            + zscore(F.col("living_population"))
            + zscore(F.col("sales_amount").cast("double")),
        )
    )
    write_parquet(quarter, hdfs_base_dir + "/processed/mart/analysis_mart_quarter")
