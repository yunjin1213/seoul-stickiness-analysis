CREATE DATABASE IF NOT EXISTS seoul_stickiness;
USE seoul_stickiness;

dfs -rm -r -f ${hivevar:hdfs_base_dir}/results/top_subway_inflow;
dfs -rm -r -f ${hivevar:hdfs_base_dir}/results/top_living_population;
dfs -rm -r -f ${hivevar:hdfs_base_dir}/results/top_stay_index;
dfs -rm -r -f ${hivevar:hdfs_base_dir}/results/top_consumption_index;
dfs -rm -r -f ${hivevar:hdfs_base_dir}/results/top_conversion_score;
dfs -rm -r -f ${hivevar:hdfs_base_dir}/results/time_slot_pattern;
dfs -rm -r -f ${hivevar:hdfs_base_dir}/results/dong_market_type;

WITH dong_summary AS (
  SELECT
    dong_code,
    MAX(dong_name) AS dong_name,
    AVG(subway_inflow) AS avg_subway_inflow,
    AVG(living_population) AS avg_living_population,
    AVG(stay_index) AS avg_stay_index,
    AVG(consumption_index) AS avg_consumption_index,
    AVG(conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter
  GROUP BY dong_code
),
ranked AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY avg_subway_inflow DESC) AS rank_no,
    dong_code,
    dong_name,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM dong_summary
  WHERE avg_subway_inflow IS NOT NULL
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/top_subway_inflow'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  rank_no,
  dong_code,
  dong_name,
  avg_subway_inflow,
  avg_living_population,
  avg_stay_index,
  avg_consumption_index,
  avg_conversion_score
FROM (
  SELECT
    0 AS sort_order,
    0 AS rank_sort,
    'rank' AS rank_no,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'avg_subway_inflow' AS avg_subway_inflow,
    'avg_living_population' AS avg_living_population,
    'avg_stay_index' AS avg_stay_index,
    'avg_consumption_index' AS avg_consumption_index,
    'avg_conversion_score' AS avg_conversion_score
  UNION ALL
  SELECT
    1 AS sort_order,
    rank_no AS rank_sort,
    CAST(rank_no AS STRING) AS rank_no,
    dong_code,
    dong_name,
    CAST(avg_subway_inflow AS STRING) AS avg_subway_inflow,
    CAST(avg_living_population AS STRING) AS avg_living_population,
    CAST(avg_stay_index AS STRING) AS avg_stay_index,
    CAST(avg_consumption_index AS STRING) AS avg_consumption_index,
    CAST(avg_conversion_score AS STRING) AS avg_conversion_score
  FROM ranked
  WHERE rank_no <= 20
) output_rows
ORDER BY sort_order, rank_sort;

WITH dong_summary AS (
  SELECT
    dong_code,
    MAX(dong_name) AS dong_name,
    AVG(subway_inflow) AS avg_subway_inflow,
    AVG(living_population) AS avg_living_population,
    AVG(stay_index) AS avg_stay_index,
    AVG(consumption_index) AS avg_consumption_index,
    AVG(conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter
  GROUP BY dong_code
),
ranked AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY avg_living_population DESC) AS rank_no,
    dong_code,
    dong_name,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM dong_summary
  WHERE avg_living_population IS NOT NULL
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/top_living_population'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  rank_no,
  dong_code,
  dong_name,
  avg_living_population,
  avg_subway_inflow,
  avg_stay_index,
  avg_consumption_index,
  avg_conversion_score
FROM (
  SELECT
    0 AS sort_order,
    0 AS rank_sort,
    'rank' AS rank_no,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'avg_living_population' AS avg_living_population,
    'avg_subway_inflow' AS avg_subway_inflow,
    'avg_stay_index' AS avg_stay_index,
    'avg_consumption_index' AS avg_consumption_index,
    'avg_conversion_score' AS avg_conversion_score
  UNION ALL
  SELECT
    1 AS sort_order,
    rank_no AS rank_sort,
    CAST(rank_no AS STRING) AS rank_no,
    dong_code,
    dong_name,
    CAST(avg_living_population AS STRING) AS avg_living_population,
    CAST(avg_subway_inflow AS STRING) AS avg_subway_inflow,
    CAST(avg_stay_index AS STRING) AS avg_stay_index,
    CAST(avg_consumption_index AS STRING) AS avg_consumption_index,
    CAST(avg_conversion_score AS STRING) AS avg_conversion_score
  FROM ranked
  WHERE rank_no <= 20
) output_rows
ORDER BY sort_order, rank_sort;

WITH dong_summary AS (
  SELECT
    dong_code,
    MAX(dong_name) AS dong_name,
    AVG(subway_inflow) AS avg_subway_inflow,
    AVG(living_population) AS avg_living_population,
    AVG(stay_index) AS avg_stay_index,
    AVG(consumption_index) AS avg_consumption_index,
    AVG(conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter
  GROUP BY dong_code
),
ranked AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY avg_stay_index DESC) AS rank_no,
    dong_code,
    dong_name,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM dong_summary
  WHERE avg_stay_index IS NOT NULL
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/top_stay_index'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  rank_no,
  dong_code,
  dong_name,
  avg_stay_index,
  avg_subway_inflow,
  avg_living_population,
  avg_consumption_index,
  avg_conversion_score
FROM (
  SELECT
    0 AS sort_order,
    0 AS rank_sort,
    'rank' AS rank_no,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'avg_stay_index' AS avg_stay_index,
    'avg_subway_inflow' AS avg_subway_inflow,
    'avg_living_population' AS avg_living_population,
    'avg_consumption_index' AS avg_consumption_index,
    'avg_conversion_score' AS avg_conversion_score
  UNION ALL
  SELECT
    1 AS sort_order,
    rank_no AS rank_sort,
    CAST(rank_no AS STRING) AS rank_no,
    dong_code,
    dong_name,
    CAST(avg_stay_index AS STRING) AS avg_stay_index,
    CAST(avg_subway_inflow AS STRING) AS avg_subway_inflow,
    CAST(avg_living_population AS STRING) AS avg_living_population,
    CAST(avg_consumption_index AS STRING) AS avg_consumption_index,
    CAST(avg_conversion_score AS STRING) AS avg_conversion_score
  FROM ranked
  WHERE rank_no <= 20
) output_rows
ORDER BY sort_order, rank_sort;

WITH dong_summary AS (
  SELECT
    dong_code,
    MAX(dong_name) AS dong_name,
    AVG(subway_inflow) AS avg_subway_inflow,
    AVG(living_population) AS avg_living_population,
    AVG(stay_index) AS avg_stay_index,
    AVG(consumption_index) AS avg_consumption_index,
    AVG(conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter
  GROUP BY dong_code
),
ranked AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY avg_consumption_index DESC) AS rank_no,
    dong_code,
    dong_name,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM dong_summary
  WHERE avg_consumption_index IS NOT NULL
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/top_consumption_index'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  rank_no,
  dong_code,
  dong_name,
  avg_consumption_index,
  avg_subway_inflow,
  avg_living_population,
  avg_stay_index,
  avg_conversion_score
FROM (
  SELECT
    0 AS sort_order,
    0 AS rank_sort,
    'rank' AS rank_no,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'avg_consumption_index' AS avg_consumption_index,
    'avg_subway_inflow' AS avg_subway_inflow,
    'avg_living_population' AS avg_living_population,
    'avg_stay_index' AS avg_stay_index,
    'avg_conversion_score' AS avg_conversion_score
  UNION ALL
  SELECT
    1 AS sort_order,
    rank_no AS rank_sort,
    CAST(rank_no AS STRING) AS rank_no,
    dong_code,
    dong_name,
    CAST(avg_consumption_index AS STRING) AS avg_consumption_index,
    CAST(avg_subway_inflow AS STRING) AS avg_subway_inflow,
    CAST(avg_living_population AS STRING) AS avg_living_population,
    CAST(avg_stay_index AS STRING) AS avg_stay_index,
    CAST(avg_conversion_score AS STRING) AS avg_conversion_score
  FROM ranked
  WHERE rank_no <= 20
) output_rows
ORDER BY sort_order, rank_sort;

WITH dong_summary AS (
  SELECT
    dong_code,
    MAX(dong_name) AS dong_name,
    AVG(subway_inflow) AS avg_subway_inflow,
    AVG(living_population) AS avg_living_population,
    AVG(stay_index) AS avg_stay_index,
    AVG(consumption_index) AS avg_consumption_index,
    AVG(conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter
  GROUP BY dong_code
),
ranked AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY avg_conversion_score DESC) AS rank_no,
    dong_code,
    dong_name,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM dong_summary
  WHERE avg_conversion_score IS NOT NULL
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/top_conversion_score'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  rank_no,
  dong_code,
  dong_name,
  avg_conversion_score,
  avg_subway_inflow,
  avg_living_population,
  avg_stay_index,
  avg_consumption_index
FROM (
  SELECT
    0 AS sort_order,
    0 AS rank_sort,
    'rank' AS rank_no,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'avg_conversion_score' AS avg_conversion_score,
    'avg_subway_inflow' AS avg_subway_inflow,
    'avg_living_population' AS avg_living_population,
    'avg_stay_index' AS avg_stay_index,
    'avg_consumption_index' AS avg_consumption_index
  UNION ALL
  SELECT
    1 AS sort_order,
    rank_no AS rank_sort,
    CAST(rank_no AS STRING) AS rank_no,
    dong_code,
    dong_name,
    CAST(avg_conversion_score AS STRING) AS avg_conversion_score,
    CAST(avg_subway_inflow AS STRING) AS avg_subway_inflow,
    CAST(avg_living_population AS STRING) AS avg_living_population,
    CAST(avg_stay_index AS STRING) AS avg_stay_index,
    CAST(avg_consumption_index AS STRING) AS avg_consumption_index
  FROM ranked
  WHERE rank_no <= 20
) output_rows
ORDER BY sort_order, rank_sort;

WITH time_summary AS (
  SELECT
    time_slot,
    dong_code,
    MAX(dong_name) AS dong_name,
    AVG(subway_inflow) AS avg_subway_inflow,
    AVG(living_population) AS avg_living_population,
    AVG(stay_index) AS avg_stay_index,
    AVG(consumption_index) AS avg_consumption_index,
    AVG(conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter
  GROUP BY time_slot, dong_code
),
ranked AS (
  SELECT
    ROW_NUMBER() OVER (
      PARTITION BY time_slot
      ORDER BY avg_conversion_score DESC
    ) AS rank_no,
    time_slot,
    dong_code,
    dong_name,
    avg_conversion_score,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index
  FROM time_summary
  WHERE avg_conversion_score IS NOT NULL
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/time_slot_pattern'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  time_slot,
  rank_no,
  dong_code,
  dong_name,
  avg_conversion_score,
  avg_subway_inflow,
  avg_living_population,
  avg_stay_index,
  avg_consumption_index
FROM (
  SELECT
    0 AS sort_order,
    '00_00' AS time_sort,
    0 AS rank_sort,
    'time_slot' AS time_slot,
    'rank' AS rank_no,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'avg_conversion_score' AS avg_conversion_score,
    'avg_subway_inflow' AS avg_subway_inflow,
    'avg_living_population' AS avg_living_population,
    'avg_stay_index' AS avg_stay_index,
    'avg_consumption_index' AS avg_consumption_index
  UNION ALL
  SELECT
    1 AS sort_order,
    time_slot AS time_sort,
    rank_no AS rank_sort,
    time_slot,
    CAST(rank_no AS STRING) AS rank_no,
    dong_code,
    dong_name,
    CAST(avg_conversion_score AS STRING) AS avg_conversion_score,
    CAST(avg_subway_inflow AS STRING) AS avg_subway_inflow,
    CAST(avg_living_population AS STRING) AS avg_living_population,
    CAST(avg_stay_index AS STRING) AS avg_stay_index,
    CAST(avg_consumption_index AS STRING) AS avg_consumption_index
  FROM ranked
  WHERE rank_no <= 20
) output_rows
ORDER BY sort_order, time_sort, rank_sort;

WITH dong_summary AS (
  SELECT
    dong_code,
    MAX(dong_name) AS dong_name,
    AVG(subway_inflow) AS avg_subway_inflow,
    AVG(living_population) AS avg_living_population,
    AVG(stay_index) AS avg_stay_index,
    AVG(consumption_index) AS avg_consumption_index,
    AVG(conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter
  GROUP BY dong_code
),
night_summary AS (
  SELECT
    dong_code,
    AVG(conversion_score) AS night_conversion_score
  FROM analysis_mart_quarter
  WHERE time_slot = '21_24'
  GROUP BY dong_code
),
ranked AS (
  SELECT
    ds.dong_code,
    ds.dong_name,
    ds.avg_subway_inflow,
    ds.avg_living_population,
    ds.avg_stay_index,
    ds.avg_consumption_index,
    ds.avg_conversion_score,
    ns.night_conversion_score,
    NTILE(5) OVER (
      ORDER BY CASE WHEN ds.avg_subway_inflow IS NULL THEN 1 ELSE 0 END,
               ds.avg_subway_inflow DESC
    ) AS subway_inflow_tile,
    NTILE(5) OVER (
      ORDER BY CASE WHEN ds.avg_stay_index IS NULL THEN 1 ELSE 0 END,
               ds.avg_stay_index DESC
    ) AS stay_index_tile,
    NTILE(5) OVER (
      ORDER BY CASE WHEN ds.avg_consumption_index IS NULL THEN 1 ELSE 0 END,
               ds.avg_consumption_index DESC
    ) AS consumption_index_tile,
    NTILE(5) OVER (
      ORDER BY CASE WHEN ds.avg_conversion_score IS NULL THEN 1 ELSE 0 END,
               ds.avg_conversion_score DESC
    ) AS conversion_score_tile,
    NTILE(5) OVER (
      ORDER BY CASE WHEN ns.night_conversion_score IS NULL THEN 1 ELSE 0 END,
               ns.night_conversion_score DESC
    ) AS night_conversion_tile
  FROM dong_summary ds
  LEFT JOIN night_summary ns
    ON ds.dong_code = ns.dong_code
),
typed AS (
  SELECT
    dong_code,
    dong_name,
    CASE
      WHEN night_conversion_tile = 1 THEN '야간형'
      WHEN conversion_score_tile = 1 THEN '종합형'
      WHEN consumption_index_tile = 1 THEN '소비전환형'
      WHEN subway_inflow_tile = 1 AND stay_index_tile > 2 THEN '유입형'
      WHEN stay_index_tile = 1 AND consumption_index_tile > 2 THEN '체류형'
      ELSE '일반형'
    END AS market_type,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score,
    night_conversion_score,
    subway_inflow_tile,
    stay_index_tile,
    consumption_index_tile,
    conversion_score_tile,
    night_conversion_tile
  FROM ranked
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/dong_market_type'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  dong_code,
  dong_name,
  market_type,
  avg_subway_inflow,
  avg_living_population,
  avg_stay_index,
  avg_consumption_index,
  avg_conversion_score,
  night_conversion_score,
  subway_inflow_tile,
  stay_index_tile,
  consumption_index_tile,
  conversion_score_tile,
  night_conversion_tile
FROM (
  SELECT
    0 AS sort_order,
    '0' AS type_sort,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'market_type' AS market_type,
    'avg_subway_inflow' AS avg_subway_inflow,
    'avg_living_population' AS avg_living_population,
    'avg_stay_index' AS avg_stay_index,
    'avg_consumption_index' AS avg_consumption_index,
    'avg_conversion_score' AS avg_conversion_score,
    'night_conversion_score' AS night_conversion_score,
    'subway_inflow_tile' AS subway_inflow_tile,
    'stay_index_tile' AS stay_index_tile,
    'consumption_index_tile' AS consumption_index_tile,
    'conversion_score_tile' AS conversion_score_tile,
    'night_conversion_tile' AS night_conversion_tile
  UNION ALL
  SELECT
    1 AS sort_order,
    market_type AS type_sort,
    dong_code,
    dong_name,
    market_type,
    CAST(avg_subway_inflow AS STRING) AS avg_subway_inflow,
    CAST(avg_living_population AS STRING) AS avg_living_population,
    CAST(avg_stay_index AS STRING) AS avg_stay_index,
    CAST(avg_consumption_index AS STRING) AS avg_consumption_index,
    CAST(avg_conversion_score AS STRING) AS avg_conversion_score,
    CAST(night_conversion_score AS STRING) AS night_conversion_score,
    CAST(subway_inflow_tile AS STRING) AS subway_inflow_tile,
    CAST(stay_index_tile AS STRING) AS stay_index_tile,
    CAST(consumption_index_tile AS STRING) AS consumption_index_tile,
    CAST(conversion_score_tile AS STRING) AS conversion_score_tile,
    CAST(night_conversion_tile AS STRING) AS night_conversion_tile
  FROM typed
) output_rows
ORDER BY sort_order, type_sort, dong_code;
