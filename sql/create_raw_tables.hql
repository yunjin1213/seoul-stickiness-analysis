CREATE DATABASE IF NOT EXISTS seoul_stickiness;
USE seoul_stickiness;

-- Raw tables intentionally use ASCII column names.
-- Some Hive CLI environments corrupt Korean identifiers into "????",
-- which can produce duplicate-column errors before Spark preprocessing runs.

DROP TABLE IF EXISTS raw_people;
CREATE EXTERNAL TABLE raw_people (
  base_date_id STRING,
  hour_code STRING,
  dong_code STRING,
  total_living_population STRING,
  male_0_9 STRING,
  male_10_14 STRING,
  male_15_19 STRING,
  male_20_24 STRING,
  male_25_29 STRING,
  male_30_34 STRING,
  male_35_39 STRING,
  male_40_44 STRING,
  male_45_49 STRING,
  male_50_54 STRING,
  male_55_59 STRING,
  male_60_64 STRING,
  male_65_69 STRING,
  male_70_over STRING,
  female_0_9 STRING,
  female_10_14 STRING,
  female_15_19 STRING,
  female_20_24 STRING,
  female_25_29 STRING,
  female_30_34 STRING,
  female_35_39 STRING,
  female_40_44 STRING,
  female_45_49 STRING,
  female_50_54 STRING,
  female_55_59 STRING,
  female_60_64 STRING,
  female_65_69 STRING,
  female_70_over STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hivevar:hdfs_base_dir}/raw/people'
TBLPROPERTIES ('skip.header.line.count'='1');

DROP TABLE IF EXISTS raw_subway;
CREATE EXTERNAL TABLE raw_subway (
  row_no STRING,
  transport_date STRING,
  line_name STRING,
  station_no STRING,
  station_name STRING,
  boarding_type STRING,
  passenger_type STRING,
  count_before_06 STRING,
  count_06_07 STRING,
  count_07_08 STRING,
  count_08_09 STRING,
  count_09_10 STRING,
  count_10_11 STRING,
  count_11_12 STRING,
  count_12_13 STRING,
  count_13_14 STRING,
  count_14_15 STRING,
  count_15_16 STRING,
  count_16_17 STRING,
  count_17_18 STRING,
  count_18_19 STRING,
  count_19_20 STRING,
  count_20_21 STRING,
  count_21_22 STRING,
  count_22_23 STRING,
  count_23_24 STRING,
  count_after_24 STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hivevar:hdfs_base_dir}/raw/subway'
TBLPROPERTIES ('skip.header.line.count'='1');

DROP TABLE IF EXISTS raw_station_master;
CREATE EXTERNAL TABLE raw_station_master (
  station_id STRING,
  station_name STRING,
  line_name STRING,
  latitude STRING,
  longitude STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hivevar:hdfs_base_dir}/raw/station_master'
TBLPROPERTIES ('skip.header.line.count'='1');

DROP TABLE IF EXISTS raw_market_sales;
CREATE EXTERNAL TABLE raw_market_sales (
  quarter_code_raw STRING,
  market_type_code STRING,
  market_type_name STRING,
  market_code STRING,
  market_name STRING,
  service_code STRING,
  service_type STRING,
  monthly_sales_amount STRING,
  monthly_sales_count STRING,
  weekday_sales_amount STRING,
  weekend_sales_amount STRING,
  monday_sales_amount STRING,
  tuesday_sales_amount STRING,
  wednesday_sales_amount STRING,
  thursday_sales_amount STRING,
  friday_sales_amount STRING,
  saturday_sales_amount STRING,
  sunday_sales_amount STRING,
  sales_amount_00_06 STRING,
  sales_amount_06_11 STRING,
  sales_amount_11_14 STRING,
  sales_amount_14_17 STRING,
  sales_amount_17_21 STRING,
  sales_amount_21_24 STRING,
  male_sales_amount STRING,
  female_sales_amount STRING,
  age_10_sales_amount STRING,
  age_20_sales_amount STRING,
  age_30_sales_amount STRING,
  age_40_sales_amount STRING,
  age_50_sales_amount STRING,
  age_60_over_sales_amount STRING,
  weekday_sales_count STRING,
  weekend_sales_count STRING,
  monday_sales_count STRING,
  tuesday_sales_count STRING,
  wednesday_sales_count STRING,
  thursday_sales_count STRING,
  friday_sales_count STRING,
  saturday_sales_count STRING,
  sunday_sales_count STRING,
  sales_count_00_06 STRING,
  sales_count_06_11 STRING,
  sales_count_11_14 STRING,
  sales_count_14_17 STRING,
  sales_count_17_21 STRING,
  sales_count_21_24 STRING,
  male_sales_count STRING,
  female_sales_count STRING,
  age_10_sales_count STRING,
  age_20_sales_count STRING,
  age_30_sales_count STRING,
  age_40_sales_count STRING,
  age_50_sales_count STRING,
  age_60_over_sales_count STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hivevar:hdfs_base_dir}/raw/market_sales'
TBLPROPERTIES ('skip.header.line.count'='1');

DROP TABLE IF EXISTS raw_market_area;
CREATE EXTERNAL TABLE raw_market_area (
  market_type_code STRING,
  market_type_name STRING,
  market_code STRING,
  market_name STRING,
  x_coord STRING,
  y_coord STRING,
  district_code STRING,
  district_name STRING,
  dong_code STRING,
  dong_name STRING,
  area_size STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hivevar:hdfs_base_dir}/raw/market_area'
TBLPROPERTIES ('skip.header.line.count'='1');
