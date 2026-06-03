# -*- coding: utf-8 -*-
from __future__ import print_function

from pyspark.sql import functions as F

from preprocess_io import hdfs_path_exists, read_csv, write_parquet


def build_market_dong_bridge(clean_market_area, hdfs_base_dir):
    df = clean_market_area.select(
        "market_code", "market_name", "dong_code", "dong_name"
    ).dropDuplicates()
    return write_parquet(df, hdfs_base_dir + "/processed/bridge/market_dong_bridge")


def build_station_dong_bridge(spark, hdfs_base_dir):
    mapping_path = hdfs_base_dir + "/raw/station_dong_mapping"
    if not hdfs_path_exists(spark, mapping_path):
        raise RuntimeError(
            "Missing station dong mapping: {0}. "
            "Run scripts/create_station_dong_mapping.sh and scripts/upload_hdfs.sh first.".format(
                mapping_path
            )
        )

    raw = read_csv(spark, mapping_path)
    df = (
        raw.select(
            F.trim(F.col("station_name")).alias("station_name"),
            F.trim(F.col("line_name")).alias("line_name"),
            F.col("dong_code").cast("string").alias("dong_code"),
            F.trim(F.col("dong_name")).alias("dong_name"),
            F.trim(F.col("source")).alias("source"),
        )
        .where(F.col("station_name").isNotNull())
        .where(F.col("line_name").isNotNull())
        .where(F.col("dong_code").isNotNull())
        .dropDuplicates()
    )
    return write_parquet(df, hdfs_base_dir + "/processed/bridge/station_dong_bridge")
