CREATE DATABASE IF NOT EXISTS seoul_stickiness;
USE seoul_stickiness;

DROP TABLE IF EXISTS clean_people;
CREATE EXTERNAL TABLE clean_people (
  base_date STRING,
  time_slot STRING,
  dong_code STRING,
  living_population DOUBLE
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/clean_people';

DROP TABLE IF EXISTS clean_subway;
CREATE EXTERNAL TABLE clean_subway (
  transport_date STRING,
  line_name STRING,
  station_name STRING,
  boarding_type STRING,
  passenger_type STRING,
  time_slot STRING,
  passenger_count BIGINT
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/clean_subway';

DROP TABLE IF EXISTS clean_station_master;
CREATE EXTERNAL TABLE clean_station_master (
  station_name STRING,
  line_name STRING,
  latitude DOUBLE,
  longitude DOUBLE
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/clean_station_master';

DROP TABLE IF EXISTS clean_market_area;
CREATE EXTERNAL TABLE clean_market_area (
  market_code STRING,
  market_name STRING,
  dong_code STRING,
  dong_name STRING,
  area_size DOUBLE,
  x_coord DOUBLE,
  y_coord DOUBLE
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/clean_market_area';

DROP TABLE IF EXISTS clean_market_sales;
CREATE EXTERNAL TABLE clean_market_sales (
  quarter_code STRING,
  market_code STRING,
  market_name STRING,
  service_type STRING,
  time_slot STRING,
  sales_amount BIGINT,
  sales_count BIGINT
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/clean_market_sales';

DROP TABLE IF EXISTS market_dong_bridge;
CREATE EXTERNAL TABLE market_dong_bridge (
  market_code STRING,
  market_name STRING,
  dong_code STRING,
  dong_name STRING
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/bridge/market_dong_bridge';

DROP TABLE IF EXISTS station_dong_bridge;
CREATE EXTERNAL TABLE station_dong_bridge (
  station_name STRING,
  line_name STRING,
  dong_code STRING,
  dong_name STRING,
  source STRING
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/bridge/station_dong_bridge';

DROP TABLE IF EXISTS people_by_dong_time;
CREATE EXTERNAL TABLE people_by_dong_time (
  base_date STRING,
  quarter_code STRING,
  dong_code STRING,
  dong_name STRING,
  time_slot STRING,
  living_population DOUBLE
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/agg/people_by_dong_time';

DROP TABLE IF EXISTS subway_by_dong_time;
CREATE EXTERNAL TABLE subway_by_dong_time (
  transport_date STRING,
  quarter_code STRING,
  dong_code STRING,
  dong_name STRING,
  time_slot STRING,
  subway_inflow BIGINT
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/agg/subway_by_dong_time';

DROP TABLE IF EXISTS sales_by_dong_time;
CREATE EXTERNAL TABLE sales_by_dong_time (
  quarter_code STRING,
  dong_code STRING,
  dong_name STRING,
  time_slot STRING,
  sales_amount BIGINT,
  sales_count BIGINT
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/agg/sales_by_dong_time';

DROP TABLE IF EXISTS analysis_mart_daily;
CREATE EXTERNAL TABLE analysis_mart_daily (
  base_date STRING,
  quarter_code STRING,
  dong_code STRING,
  dong_name STRING,
  time_slot STRING,
  subway_inflow BIGINT,
  living_population DOUBLE,
  stay_index DOUBLE
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/mart/analysis_mart_daily';

DROP TABLE IF EXISTS analysis_mart_quarter;
CREATE EXTERNAL TABLE analysis_mart_quarter (
  quarter_code STRING,
  dong_code STRING,
  dong_name STRING,
  time_slot STRING,
  subway_inflow DOUBLE,
  living_population DOUBLE,
  sales_amount BIGINT,
  sales_count BIGINT,
  stay_index DOUBLE,
  consumption_index DOUBLE,
  conversion_score DOUBLE
)
STORED AS PARQUET
LOCATION '${hivevar:hdfs_base_dir}/processed/mart/analysis_mart_quarter';
