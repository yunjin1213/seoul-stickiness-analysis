CREATE DATABASE IF NOT EXISTS seoul_stickiness;
USE seoul_stickiness;

DROP TABLE IF EXISTS raw_people;
CREATE EXTERNAL TABLE raw_people (
  `기준일ID` STRING,
  `시간대구분` STRING,
  `행정동코드` STRING,
  `총생활인구수` STRING,
  `남자0세부터9세생활인구수` STRING,
  `남자10세부터14세생활인구수` STRING,
  `남자15세부터19세생활인구수` STRING,
  `남자20세부터24세생활인구수` STRING,
  `남자25세부터29세생활인구수` STRING,
  `남자30세부터34세생활인구수` STRING,
  `남자35세부터39세생활인구수` STRING,
  `남자40세부터44세생활인구수` STRING,
  `남자45세부터49세생활인구수` STRING,
  `남자50세부터54세생활인구수` STRING,
  `남자55세부터59세생활인구수` STRING,
  `남자60세부터64세생활인구수` STRING,
  `남자65세부터69세생활인구수` STRING,
  `남자70세이상생활인구수` STRING,
  `여자0세부터9세생활인구수` STRING,
  `여자10세부터14세생활인구수` STRING,
  `여자15세부터19세생활인구수` STRING,
  `여자20세부터24세생활인구수` STRING,
  `여자25세부터29세생활인구수` STRING,
  `여자30세부터34세생활인구수` STRING,
  `여자35세부터39세생활인구수` STRING,
  `여자40세부터44세생활인구수` STRING,
  `여자45세부터49세생활인구수` STRING,
  `여자50세부터54세생활인구수` STRING,
  `여자55세부터59세생활인구수` STRING,
  `여자60세부터64세생활인구수` STRING,
  `여자65세부터69세생활인구수` STRING,
  `여자70세이상생활인구수` STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hivevar:hdfs_base_dir}/raw/people'
TBLPROPERTIES ('skip.header.line.count'='1');

DROP TABLE IF EXISTS raw_subway;
CREATE EXTERNAL TABLE raw_subway (
  `연번` STRING,
  `수송일자` STRING,
  `호선명` STRING,
  `역번호` STRING,
  `역명` STRING,
  `승하차구분` STRING,
  `승객유형` STRING,
  `06시간대이전` STRING,
  `06-07시간대` STRING,
  `07-08시간대` STRING,
  `08-09시간대` STRING,
  `09-10시간대` STRING,
  `10-11시간대` STRING,
  `11-12시간대` STRING,
  `12-13시간대` STRING,
  `13-14시간대` STRING,
  `14-15시간대` STRING,
  `15-16시간대` STRING,
  `16-17시간대` STRING,
  `17-18시간대` STRING,
  `18-19시간대` STRING,
  `19-20시간대` STRING,
  `20-21시간대` STRING,
  `21-22시간대` STRING,
  `22-23시간대` STRING,
  `23-24시간대` STRING,
  `24시간대이후` STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hivevar:hdfs_base_dir}/raw/subway'
TBLPROPERTIES ('skip.header.line.count'='1');

DROP TABLE IF EXISTS raw_station_master;
CREATE EXTERNAL TABLE raw_station_master (
  `역사_ID` STRING,
  `역사명` STRING,
  `호선` STRING,
  `위도` STRING,
  `경도` STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hivevar:hdfs_base_dir}/raw/station_master'
TBLPROPERTIES ('skip.header.line.count'='1');

DROP TABLE IF EXISTS raw_market_sales;
CREATE EXTERNAL TABLE raw_market_sales (
  `기준_년분기_코드` STRING,
  `상권_구분_코드` STRING,
  `상권_구분_코드_명` STRING,
  `상권_코드` STRING,
  `상권_코드_명` STRING,
  `서비스_업종_코드` STRING,
  `서비스_업종_코드_명` STRING,
  `당월_매출_금액` STRING,
  `당월_매출_건수` STRING,
  `주중_매출_금액` STRING,
  `주말_매출_금액` STRING,
  `월요일_매출_금액` STRING,
  `화요일_매출_금액` STRING,
  `수요일_매출_금액` STRING,
  `목요일_매출_금액` STRING,
  `금요일_매출_금액` STRING,
  `토요일_매출_금액` STRING,
  `일요일_매출_금액` STRING,
  `시간대_00~06_매출_금액` STRING,
  `시간대_06~11_매출_금액` STRING,
  `시간대_11~14_매출_금액` STRING,
  `시간대_14~17_매출_금액` STRING,
  `시간대_17~21_매출_금액` STRING,
  `시간대_21~24_매출_금액` STRING,
  `남성_매출_금액` STRING,
  `여성_매출_금액` STRING,
  `연령대_10_매출_금액` STRING,
  `연령대_20_매출_금액` STRING,
  `연령대_30_매출_금액` STRING,
  `연령대_40_매출_금액` STRING,
  `연령대_50_매출_금액` STRING,
  `연령대_60_이상_매출_금액` STRING,
  `주중_매출_건수` STRING,
  `주말_매출_건수` STRING,
  `월요일_매출_건수` STRING,
  `화요일_매출_건수` STRING,
  `수요일_매출_건수` STRING,
  `목요일_매출_건수` STRING,
  `금요일_매출_건수` STRING,
  `토요일_매출_건수` STRING,
  `일요일_매출_건수` STRING,
  `시간대_건수~06_매출_건수` STRING,
  `시간대_건수~11_매출_건수` STRING,
  `시간대_건수~14_매출_건수` STRING,
  `시간대_건수~17_매출_건수` STRING,
  `시간대_건수~21_매출_건수` STRING,
  `시간대_건수~24_매출_건수` STRING,
  `남성_매출_건수` STRING,
  `여성_매출_건수` STRING,
  `연령대_10_매출_건수` STRING,
  `연령대_20_매출_건수` STRING,
  `연령대_30_매출_건수` STRING,
  `연령대_40_매출_건수` STRING,
  `연령대_50_매출_건수` STRING,
  `연령대_60_이상_매출_건수` STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hivevar:hdfs_base_dir}/raw/market_sales'
TBLPROPERTIES ('skip.header.line.count'='1');

DROP TABLE IF EXISTS raw_market_area;
CREATE EXTERNAL TABLE raw_market_area (
  `상권_구분_코드` STRING,
  `상권_구분_코드_명` STRING,
  `상권_코드` STRING,
  `상권_코드_명` STRING,
  `엑스좌표_값` STRING,
  `와이좌표_값` STRING,
  `자치구_코드` STRING,
  `자치구_코드_명` STRING,
  `행정동_코드` STRING,
  `행정동_코드_명` STRING,
  `영역_면적` STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hivevar:hdfs_base_dir}/raw/market_area'
TBLPROPERTIES ('skip.header.line.count'='1');
