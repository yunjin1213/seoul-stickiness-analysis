# -*- coding: utf-8 -*-
from __future__ import print_function

from pyspark.sql import functions as F

from preprocess_io import read_csv, write_parquet


def build_clean_people(spark, hdfs_base_dir, target_dongs):
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
        .join(F.broadcast(target_dongs), "dong_code", "inner")
    )
    return write_parquet(df, hdfs_base_dir + "/processed/clean_people")


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
        .where(F.col("boarding_type") == F.lit("하차"))
    )
    return write_parquet(df, hdfs_base_dir + "/processed/clean_subway")


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
    return write_parquet(df, hdfs_base_dir + "/processed/clean_station_master")


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
    return write_parquet(df, hdfs_base_dir + "/processed/clean_market_area")


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
    return write_parquet(df, hdfs_base_dir + "/processed/clean_market_sales")
