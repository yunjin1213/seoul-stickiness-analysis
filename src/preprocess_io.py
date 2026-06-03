# -*- coding: utf-8 -*-
from __future__ import print_function


def read_csv(spark, path):
    return (
        spark.read.option("header", "true")
        .option("inferSchema", "false")
        .option("multiLine", "false")
        .csv(path)
    )


def write_parquet(df, path):
    df.write.mode("overwrite").parquet(path)
    return df.sql_ctx.read.parquet(path)


def hdfs_path_exists(spark, path):
    hadoop_conf = spark._jsc.hadoopConfiguration()
    fs = spark._jvm.org.apache.hadoop.fs.FileSystem.get(hadoop_conf)
    return fs.exists(spark._jvm.org.apache.hadoop.fs.Path(path))
