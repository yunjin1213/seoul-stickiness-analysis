# -*- coding: utf-8 -*-
from __future__ import print_function

import argparse
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.window import Window


def quarter_from_date(date_col):
    month_col = F.month(F.to_date(date_col))
    quarter = (
        F.when(month_col <= 3, F.lit("Q1"))
        .when(month_col <= 6, F.lit("Q2"))
        .when(month_col <= 9, F.lit("Q3"))
        .otherwise(F.lit("Q4"))
    )
    return F.concat(F.year(F.to_date(date_col)).cast("string"), quarter)


def normalize_station_key(column):
    lowered = F.lower(F.trim(column))
    no_suffix = F.regexp_replace(lowered, "\\(.*?\\)", "")
    no_suffix = F.regexp_replace(no_suffix, "역$", "")
    no_suffix = F.regexp_replace(no_suffix, "입구$", "")
    no_suffix = F.regexp_replace(no_suffix, "\\s+", "")
    return no_suffix


def read_csv(spark, path):
    return (
        spark.read.option("header", "true")
        .option("inferSchema", "false")
        .option("multiLine", "false")
        .csv(path)
    )


def write_parquet(df, path):
    df.write.mode("overwrite").parquet(path)


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


def build_clean_people(spark, hdfs_base_dir):
    raw = read_csv(spark, hdfs_base_dir + "/raw/people")
    df = (
        raw.select(
            F.to_date(F.col("기준일ID"), "yyyyMMdd").cast("string").alias("base_date"),
            F.lpad(F.col("시간대구분").cast("string"), 2, "0").alias("time_slot"),
            F.col("행정동코드").cast("string").alias("dong_code"),
            F.col("총생활인구수").cast("double").alias("living_population"),
        )
        .where(F.col("base_date").isNotNull())
        .where(F.col("dong_code").isNotNull())
    )
    write_parquet(df, hdfs_base_dir + "/processed/clean_people")
    return df


def build_clean_subway(spark, hdfs_base_dir):
    raw = read_csv(spark, hdfs_base_dir + "/raw/subway")
    time_columns = [
        ("00_06", "06시간대이전"),
        ("06", "06-07시간대"),
        ("07", "07-08시간대"),
        ("08", "08-09시간대"),
        ("09", "09-10시간대"),
        ("10", "10-11시간대"),
        ("11", "11-12시간대"),
        ("12", "12-13시간대"),
        ("13", "13-14시간대"),
        ("14", "14-15시간대"),
        ("15", "15-16시간대"),
        ("16", "16-17시간대"),
        ("17", "17-18시간대"),
        ("18", "18-19시간대"),
        ("19", "19-20시간대"),
        ("20", "20-21시간대"),
        ("21", "21-22시간대"),
        ("22", "22-23시간대"),
        ("23", "23-24시간대"),
        ("24_after", "24시간대이후"),
    ]
    stack_args = []
    for time_slot, source_col in time_columns:
        stack_args.append("'{0}', `{1}`".format(time_slot, source_col))
    stack_expr = "stack({0}, {1}) as (time_slot, passenger_count)".format(
        len(time_columns), ", ".join(stack_args)
    )
    df = (
        raw.select(
            F.to_date(F.col("수송일자")).cast("string").alias("transport_date"),
            F.trim(F.col("호선명")).alias("line_name"),
            F.trim(F.col("역명")).alias("station_name"),
            F.trim(F.col("승하차구분")).alias("boarding_type"),
            F.trim(F.col("승객유형")).alias("passenger_type"),
            F.expr(stack_expr),
        )
        .withColumn("passenger_count", F.col("passenger_count").cast("long"))
        .where(F.col("transport_date").isNotNull())
        .where(F.col("station_name").isNotNull())
    )
    write_parquet(df, hdfs_base_dir + "/processed/clean_subway")
    return df


def build_clean_station_master(spark, hdfs_base_dir):
    raw = read_csv(spark, hdfs_base_dir + "/raw/station_master")
    df = (
        raw.select(
            F.trim(F.col("역사명")).alias("station_name"),
            F.trim(F.col("호선")).alias("line_name"),
            F.col("위도").cast("double").alias("latitude"),
            F.col("경도").cast("double").alias("longitude"),
        )
        .where(F.col("station_name").isNotNull())
        .dropDuplicates(["station_name", "line_name"])
    )
    write_parquet(df, hdfs_base_dir + "/processed/clean_station_master")
    return df


def build_clean_market_area(spark, hdfs_base_dir):
    raw = read_csv(spark, hdfs_base_dir + "/raw/market_area")
    df = (
        raw.select(
            F.col("상권_코드").cast("string").alias("market_code"),
            F.trim(F.col("상권_코드_명")).alias("market_name"),
            F.col("행정동_코드").cast("string").alias("dong_code"),
            F.trim(F.col("행정동_코드_명")).alias("dong_name"),
            F.col("영역_면적").cast("double").alias("area_size"),
            F.col("엑스좌표_값").cast("double").alias("x_coord"),
            F.col("와이좌표_값").cast("double").alias("y_coord"),
        )
        .where(F.col("market_code").isNotNull())
        .where(F.col("dong_code").isNotNull())
    )
    write_parquet(df, hdfs_base_dir + "/processed/clean_market_area")
    return df


def build_clean_market_sales(spark, hdfs_base_dir):
    raw = read_csv(spark, hdfs_base_dir + "/raw/market_sales")
    stack_expr = """
        stack(
          6,
          '00_06', `시간대_00~06_매출_금액`, `시간대_건수~06_매출_건수`,
          '06_11', `시간대_06~11_매출_금액`, `시간대_건수~11_매출_건수`,
          '11_14', `시간대_11~14_매출_금액`, `시간대_건수~14_매출_건수`,
          '14_17', `시간대_14~17_매출_금액`, `시간대_건수~17_매출_건수`,
          '17_21', `시간대_17~21_매출_금액`, `시간대_건수~21_매출_건수`,
          '21_24', `시간대_21~24_매출_금액`, `시간대_건수~24_매출_건수`
        ) as (time_slot, sales_amount, sales_count)
    """
    quarter_raw = F.col("기준_년분기_코드").cast("string")
    df = (
        raw.select(
            F.concat(
                F.substring(quarter_raw, 1, 4),
                F.lit("Q"),
                F.substring(quarter_raw, 5, 1),
            ).alias("quarter_code"),
            F.col("상권_코드").cast("string").alias("market_code"),
            F.trim(F.col("상권_코드_명")).alias("market_name"),
            F.trim(F.col("서비스_업종_코드_명")).alias("service_type"),
            F.expr(stack_expr),
        )
        .withColumn("sales_amount", F.col("sales_amount").cast("long"))
        .withColumn("sales_count", F.col("sales_count").cast("long"))
        .where(F.col("quarter_code").isNotNull())
        .where(F.col("market_code").isNotNull())
    )
    write_parquet(df, hdfs_base_dir + "/processed/clean_market_sales")
    return df


def build_market_dong_bridge(clean_market_area, hdfs_base_dir):
    df = clean_market_area.select(
        "market_code", "market_name", "dong_code", "dong_name"
    ).dropDuplicates()
    write_parquet(df, hdfs_base_dir + "/processed/bridge/market_dong_bridge")
    return df


def build_station_dong_bridge(clean_station_master, clean_market_area, hdfs_base_dir):
    station = clean_station_master.withColumn(
        "station_key", normalize_station_key(F.col("station_name"))
    ).where(F.length(F.col("station_key")) >= 2)
    market = clean_market_area.withColumn(
        "market_key",
        F.regexp_replace(F.lower(F.trim(F.col("market_name"))), "\\s+", ""),
    )
    matched = (
        station.crossJoin(market)
        .where(F.expr("instr(market_key, station_key) > 0"))
        .select(
            station.station_name,
            station.line_name,
            market.dong_code,
            market.dong_name,
        )
        .dropDuplicates()
    )
    write_parquet(matched, hdfs_base_dir + "/processed/bridge/station_dong_bridge")
    return matched


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
        clean_people.join(dong_dim, "dong_code", "inner")
        .withColumn("quarter_code", quarter_from_date(F.col("base_date")))
        .groupBy("base_date", "quarter_code", "dong_code", "dong_name", "time_slot")
        .agg(F.sum("living_population").alias("living_population"))
    )
    write_parquet(people, hdfs_base_dir + "/processed/agg/people_by_dong_time")

    subway = (
        clean_subway.where(F.col("boarding_type") == F.lit("하차"))
        .join(station_dong_bridge, ["station_name", "line_name"], "inner")
        .withColumn("quarter_code", quarter_from_date(F.col("transport_date")))
        .groupBy(
            "transport_date", "quarter_code", "dong_code", "dong_name", "time_slot"
        )
        .agg(F.sum("passenger_count").alias("subway_inflow"))
    )
    write_parquet(subway, hdfs_base_dir + "/processed/agg/subway_by_dong_time")

    sales = (
        clean_market_sales.join(market_dong_bridge, "market_code", "inner")
        .groupBy("quarter_code", "dong_code", "dong_name", "time_slot")
        .agg(
            F.sum("sales_amount").alias("sales_amount"),
            F.sum("sales_count").alias("sales_count"),
        )
    )
    write_parquet(sales, hdfs_base_dir + "/processed/agg/sales_by_dong_time")

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


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--hdfs-base-dir", required=True)
    args = parser.parse_args()

    spark = (
        SparkSession.builder.appName("seoul-stickiness-preprocess")
        .enableHiveSupport()
        .getOrCreate()
    )
    spark.sparkContext.setLogLevel("WARN")
    spark.conf.set("spark.sql.crossJoin.enabled", "true")

    hdfs_base_dir = args.hdfs_base_dir.rstrip("/")
    print("HDFS base dir: {0}".format(hdfs_base_dir))

    clean_people = build_clean_people(spark, hdfs_base_dir)
    clean_subway = build_clean_subway(spark, hdfs_base_dir)
    clean_station_master = build_clean_station_master(spark, hdfs_base_dir)
    clean_market_area = build_clean_market_area(spark, hdfs_base_dir)
    clean_market_sales = build_clean_market_sales(spark, hdfs_base_dir)

    market_dong_bridge = build_market_dong_bridge(clean_market_area, hdfs_base_dir)
    station_dong_bridge = build_station_dong_bridge(
        clean_station_master, clean_market_area, hdfs_base_dir
    )
    people, subway, sales = build_aggregates(
        clean_people,
        clean_subway,
        clean_market_sales,
        market_dong_bridge,
        station_dong_bridge,
        hdfs_base_dir,
    )
    build_marts(people, subway, sales, hdfs_base_dir)

    spark.stop()


if __name__ == "__main__":
    main()
