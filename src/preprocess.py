# -*- coding: utf-8 -*-
from __future__ import print_function

import argparse

from pyspark.sql import SparkSession

from preprocess_bridge import build_market_dong_bridge, build_station_dong_bridge
from preprocess_clean import (
    build_clean_market_area,
    build_clean_market_sales,
    build_clean_people,
    build_clean_station_master,
    build_clean_subway,
)
from preprocess_mart import build_aggregates, build_marts


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--hdfs-base-dir", required=True)
    args = parser.parse_args()

    spark = (
        SparkSession.builder.appName("seoul-stickiness-preprocess")
        .config("spark.sql.shuffle.partitions", "16")
        .enableHiveSupport()
        .getOrCreate()
    )
    spark.sparkContext.setLogLevel("WARN")
    spark.conf.set("spark.sql.crossJoin.enabled", "true")

    hdfs_base_dir = args.hdfs_base_dir.rstrip("/")
    print("HDFS base dir: {0}".format(hdfs_base_dir))

    clean_market_area = build_clean_market_area(spark, hdfs_base_dir)
    target_dongs = clean_market_area.select("dong_code").dropDuplicates()
    clean_people = build_clean_people(spark, hdfs_base_dir, target_dongs)
    clean_subway = build_clean_subway(spark, hdfs_base_dir)
    clean_station_master = build_clean_station_master(spark, hdfs_base_dir)
    clean_market_sales = build_clean_market_sales(spark, hdfs_base_dir)

    market_dong_bridge = build_market_dong_bridge(clean_market_area, hdfs_base_dir)
    station_dong_bridge = build_station_dong_bridge(spark, hdfs_base_dir)
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
