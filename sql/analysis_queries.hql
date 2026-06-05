CREATE DATABASE IF NOT EXISTS seoul_stickiness;
USE seoul_stickiness;

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
      WHEN night_conversion_tile = 1 THEN 'night_type'
      WHEN conversion_score_tile = 1 THEN 'overall_type'
      WHEN consumption_index_tile = 1 THEN 'consumption_type'
      WHEN subway_inflow_tile = 1 AND stay_index_tile > 2 THEN 'inflow_type'
      WHEN stay_index_tile = 1 AND consumption_index_tile > 2 THEN 'stay_type'
      ELSE 'general_type'
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

WITH dong_summary AS (
  SELECT
    dong_code,
    MAX(dong_name) AS dong_name,
    AVG(conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter
  GROUP BY dong_code
),
top_dong AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY avg_conversion_score DESC) AS rank_no,
    dong_code,
    dong_name
  FROM dong_summary
  WHERE avg_conversion_score IS NOT NULL
),
profile AS (
  SELECT
    td.rank_no,
    amq.quarter_code,
    amq.dong_code,
    MAX(amq.dong_name) AS dong_name,
    amq.time_slot,
    AVG(amq.subway_inflow) AS subway_inflow,
    AVG(amq.living_population) AS living_population,
    SUM(amq.sales_amount) AS sales_amount,
    AVG(amq.stay_index) AS stay_index,
    AVG(amq.consumption_index) AS consumption_index,
    AVG(amq.conversion_score) AS conversion_score
  FROM analysis_mart_quarter amq
  INNER JOIN top_dong td
    ON amq.dong_code = td.dong_code
  WHERE td.rank_no <= 10
  GROUP BY td.rank_no, amq.quarter_code, amq.dong_code, amq.time_slot
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/top_dong_time_profile'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  rank_no,
  quarter_code,
  dong_code,
  dong_name,
  time_slot,
  subway_inflow,
  living_population,
  sales_amount,
  stay_index,
  consumption_index,
  conversion_score
FROM (
  SELECT
    0 AS sort_order,
    0 AS rank_sort,
    '0000Q0' AS quarter_sort,
    '00_00' AS time_sort,
    'rank' AS rank_no,
    'quarter_code' AS quarter_code,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'time_slot' AS time_slot,
    'subway_inflow' AS subway_inflow,
    'living_population' AS living_population,
    'sales_amount' AS sales_amount,
    'stay_index' AS stay_index,
    'consumption_index' AS consumption_index,
    'conversion_score' AS conversion_score
  UNION ALL
  SELECT
    1 AS sort_order,
    rank_no AS rank_sort,
    quarter_code AS quarter_sort,
    time_slot AS time_sort,
    CAST(rank_no AS STRING) AS rank_no,
    quarter_code,
    dong_code,
    dong_name,
    time_slot,
    CAST(subway_inflow AS STRING) AS subway_inflow,
    CAST(living_population AS STRING) AS living_population,
    CAST(sales_amount AS STRING) AS sales_amount,
    CAST(stay_index AS STRING) AS stay_index,
    CAST(consumption_index AS STRING) AS consumption_index,
    CAST(conversion_score AS STRING) AS conversion_score
  FROM profile
) output_rows
ORDER BY sort_order, rank_sort, quarter_sort, time_sort;

WITH service_sales AS (
  SELECT
    mdb.dong_code,
    MAX(mdb.dong_name) AS dong_name,
    cms.service_type,
    SUM(cms.sales_amount) AS service_sales_amount
  FROM clean_market_sales cms
  INNER JOIN market_dong_bridge mdb
    ON cms.market_code = mdb.market_code
  WHERE cms.service_type IS NOT NULL
  GROUP BY mdb.dong_code, cms.service_type
),
service_mix AS (
  SELECT
    dong_code,
    dong_name,
    service_type,
    service_sales_amount,
    SUM(service_sales_amount) OVER (PARTITION BY dong_code) AS total_sales_amount
  FROM service_sales
),
ranked AS (
  SELECT
    ROW_NUMBER() OVER (
      PARTITION BY dong_code
      ORDER BY service_sales_amount DESC
    ) AS service_rank,
    dong_code,
    dong_name,
    service_type,
    service_sales_amount,
    total_sales_amount,
    CASE
      WHEN total_sales_amount > 0
      THEN CAST(service_sales_amount AS DOUBLE) / CAST(total_sales_amount AS DOUBLE)
      ELSE NULL
    END AS service_sales_ratio
  FROM service_mix
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/dong_service_sales_mix'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  dong_code,
  dong_name,
  service_type,
  service_rank,
  service_sales_amount,
  total_sales_amount,
  service_sales_ratio
FROM (
  SELECT
    0 AS sort_order,
    '00000000' AS dong_sort,
    0 AS rank_sort,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'service_type' AS service_type,
    'service_rank' AS service_rank,
    'service_sales_amount' AS service_sales_amount,
    'total_sales_amount' AS total_sales_amount,
    'service_sales_ratio' AS service_sales_ratio
  UNION ALL
  SELECT
    1 AS sort_order,
    dong_code AS dong_sort,
    service_rank AS rank_sort,
    dong_code,
    dong_name,
    service_type,
    CAST(service_rank AS STRING) AS service_rank,
    CAST(service_sales_amount AS STRING) AS service_sales_amount,
    CAST(total_sales_amount AS STRING) AS total_sales_amount,
    CAST(service_sales_ratio AS STRING) AS service_sales_ratio
  FROM ranked
  WHERE service_rank <= 10
) output_rows
ORDER BY sort_order, dong_sort, rank_sort;

WITH dong_summary AS (
  SELECT
    dong_code,
    AVG(conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter
  GROUP BY dong_code
),
top_conversion_dong AS (
  SELECT
    dong_code
  FROM (
    SELECT
      ROW_NUMBER() OVER (ORDER BY avg_conversion_score DESC) AS rank_no,
      dong_code
    FROM dong_summary
    WHERE avg_conversion_score IS NOT NULL
  ) ranked
  WHERE rank_no <= 10
),
target_dong AS (
  SELECT '11680640' AS dong_code
  UNION ALL SELECT '11440660' AS dong_code
  UNION ALL SELECT '11560540' AS dong_code
  UNION ALL SELECT '11230545' AS dong_code
  UNION ALL SELECT dong_code FROM top_conversion_dong
),
service_sales AS (
  SELECT
    mdb.dong_code,
    MAX(mdb.dong_name) AS dong_name,
    cms.service_type,
    SUM(cms.sales_amount) AS sales_amount
  FROM clean_market_sales cms
  INNER JOIN market_dong_bridge mdb
    ON cms.market_code = mdb.market_code
  INNER JOIN (
    SELECT DISTINCT dong_code FROM target_dong
  ) td
    ON mdb.dong_code = td.dong_code
  WHERE cms.service_type IS NOT NULL
  GROUP BY mdb.dong_code, cms.service_type
),
ranked AS (
  SELECT
    ROW_NUMBER() OVER (
      PARTITION BY dong_code
      ORDER BY sales_amount DESC
    ) AS service_rank,
    dong_code,
    dong_name,
    service_type,
    sales_amount
  FROM service_sales
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/top_dong_service_top5'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  dong_code,
  dong_name,
  service_type,
  sales_amount,
  service_rank
FROM (
  SELECT
    0 AS sort_order,
    '00000000' AS dong_sort,
    0 AS rank_sort,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'service_type' AS service_type,
    'sales_amount' AS sales_amount,
    'service_rank' AS service_rank
  UNION ALL
  SELECT
    1 AS sort_order,
    dong_code AS dong_sort,
    service_rank AS rank_sort,
    dong_code,
    dong_name,
    service_type,
    CAST(sales_amount AS STRING) AS sales_amount,
    CAST(service_rank AS STRING) AS service_rank
  FROM ranked
  WHERE service_rank <= 5
) output_rows
ORDER BY sort_order, dong_sort, rank_sort;

WITH dong_time_sales AS (
  SELECT
    dong_code,
    MAX(dong_name) AS dong_name,
    time_slot,
    SUM(sales_amount) AS time_slot_sales_amount
  FROM analysis_mart_quarter
  GROUP BY dong_code, time_slot
),
night_sales AS (
  SELECT
    dong_code,
    MAX(dong_name) AS dong_name,
    SUM(time_slot_sales_amount) AS total_sales_amount,
    SUM(
      CASE
        WHEN time_slot = '21_24' THEN time_slot_sales_amount
        ELSE 0
      END
    ) AS night_sales_amount
  FROM dong_time_sales
  GROUP BY dong_code
),
ranked AS (
  SELECT
    ROW_NUMBER() OVER (
      ORDER BY
        CASE
          WHEN total_sales_amount > 0
          THEN CAST(night_sales_amount AS DOUBLE) / CAST(total_sales_amount AS DOUBLE)
          ELSE NULL
        END DESC,
        total_sales_amount DESC
    ) AS rank_no,
    dong_code,
    dong_name,
    total_sales_amount,
    night_sales_amount,
    CASE
      WHEN total_sales_amount > 0
      THEN CAST(night_sales_amount AS DOUBLE) / CAST(total_sales_amount AS DOUBLE)
      ELSE NULL
    END AS night_sales_ratio
  FROM night_sales
  WHERE total_sales_amount > 0
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/night_sales_pattern'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  rank_no,
  dong_code,
  dong_name,
  total_sales_amount,
  night_sales_amount,
  night_sales_ratio
FROM (
  SELECT
    0 AS sort_order,
    0 AS rank_sort,
    'rank' AS rank_no,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'total_sales_amount' AS total_sales_amount,
    'night_sales_amount' AS night_sales_amount,
    'night_sales_ratio' AS night_sales_ratio
  UNION ALL
  SELECT
    1 AS sort_order,
    rank_no AS rank_sort,
    CAST(rank_no AS STRING) AS rank_no,
    dong_code,
    dong_name,
    CAST(total_sales_amount AS STRING) AS total_sales_amount,
    CAST(night_sales_amount AS STRING) AS night_sales_amount,
    CAST(night_sales_ratio AS STRING) AS night_sales_ratio
  FROM ranked
  WHERE rank_no <= 50
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
top_subway AS (
  SELECT
    1 AS metric_order,
    'subway_inflow' AS high_metric,
    dong_code,
    dong_name
  FROM (
    SELECT
      ROW_NUMBER() OVER (ORDER BY avg_subway_inflow DESC) AS rank_no,
      dong_code,
      dong_name
    FROM dong_summary
    WHERE avg_subway_inflow IS NOT NULL
  ) ranked
  WHERE rank_no = 1
),
top_living AS (
  SELECT
    2 AS metric_order,
    'living_population' AS high_metric,
    dong_code,
    dong_name
  FROM (
    SELECT
      ROW_NUMBER() OVER (ORDER BY avg_living_population DESC) AS rank_no,
      dong_code,
      dong_name
    FROM dong_summary
    WHERE avg_living_population IS NOT NULL
  ) ranked
  WHERE rank_no = 1
),
top_stay AS (
  SELECT
    3 AS metric_order,
    'stay_index' AS high_metric,
    dong_code,
    dong_name
  FROM (
    SELECT
      ROW_NUMBER() OVER (ORDER BY avg_stay_index DESC) AS rank_no,
      dong_code,
      dong_name
    FROM dong_summary
    WHERE avg_stay_index IS NOT NULL
  ) ranked
  WHERE rank_no = 1
),
top_consumption AS (
  SELECT
    4 AS metric_order,
    'consumption_index' AS high_metric,
    dong_code,
    dong_name
  FROM (
    SELECT
      ROW_NUMBER() OVER (ORDER BY avg_consumption_index DESC) AS rank_no,
      dong_code,
      dong_name
    FROM dong_summary
    WHERE avg_consumption_index IS NOT NULL
  ) ranked
  WHERE rank_no = 1
),
top_conversion AS (
  SELECT
    5 AS metric_order,
    'conversion_score' AS high_metric,
    dong_code,
    dong_name
  FROM (
    SELECT
      ROW_NUMBER() OVER (ORDER BY avg_conversion_score DESC) AS rank_no,
      dong_code,
      dong_name
    FROM dong_summary
    WHERE avg_conversion_score IS NOT NULL
  ) ranked
  WHERE rank_no = 1
),
target_dong AS (
  SELECT * FROM top_subway
  UNION ALL SELECT * FROM top_living
  UNION ALL SELECT * FROM top_stay
  UNION ALL SELECT * FROM top_consumption
  UNION ALL SELECT * FROM top_conversion
),
market_names AS (
  SELECT
    td.dong_code,
    concat_ws('; ', sort_array(collect_set(mdb.market_name))) AS market_names
  FROM (
    SELECT DISTINCT dong_code FROM target_dong
  ) td
  LEFT JOIN market_dong_bridge mdb
    ON td.dong_code = mdb.dong_code
  WHERE mdb.market_name IS NOT NULL
  GROUP BY td.dong_code
),
service_sales AS (
  SELECT
    mdb.dong_code,
    cms.service_type,
    SUM(cms.sales_amount) AS sales_amount
  FROM clean_market_sales cms
  INNER JOIN market_dong_bridge mdb
    ON cms.market_code = mdb.market_code
  INNER JOIN (
    SELECT DISTINCT dong_code FROM target_dong
  ) td
    ON mdb.dong_code = td.dong_code
  WHERE cms.service_type IS NOT NULL
  GROUP BY mdb.dong_code, cms.service_type
),
ranked_service AS (
  SELECT
    ROW_NUMBER() OVER (
      PARTITION BY dong_code
      ORDER BY sales_amount DESC
    ) AS service_rank,
    dong_code,
    service_type
  FROM service_sales
),
top_service_types AS (
  SELECT
    dong_code,
    concat_ws('; ', collect_list(service_type)) AS top_service_types
  FROM (
    SELECT
      dong_code,
      service_type,
      service_rank
    FROM ranked_service
    WHERE service_rank <= 5
    DISTRIBUTE BY dong_code
    SORT BY dong_code, service_rank
  ) sorted_services
  GROUP BY dong_code
),
time_summary AS (
  SELECT
    amq.dong_code,
    amq.time_slot,
    AVG(amq.conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter amq
  INNER JOIN (
    SELECT DISTINCT dong_code FROM target_dong
  ) td
    ON amq.dong_code = td.dong_code
  GROUP BY amq.dong_code, amq.time_slot
),
ranked_time AS (
  SELECT
    ROW_NUMBER() OVER (
      PARTITION BY dong_code
      ORDER BY avg_conversion_score DESC
    ) AS time_rank,
    dong_code,
    time_slot
  FROM time_summary
  WHERE avg_conversion_score IS NOT NULL
),
dominant_time AS (
  SELECT
    dong_code,
    time_slot AS dominant_time_slot
  FROM ranked_time
  WHERE time_rank = 1
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/result_interpretation_support'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  dong_code,
  dong_name,
  high_metric,
  market_names,
  top_service_types,
  dominant_time_slot
FROM (
  SELECT
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'high_metric' AS high_metric,
    'market_names' AS market_names,
    'top_service_types' AS top_service_types,
    'dominant_time_slot' AS dominant_time_slot
  UNION ALL
  SELECT
    td.dong_code,
    td.dong_name,
    td.high_metric,
    COALESCE(mn.market_names, '') AS market_names,
    COALESCE(tst.top_service_types, '') AS top_service_types,
    COALESCE(dt.dominant_time_slot, '') AS dominant_time_slot
  FROM target_dong td
  LEFT JOIN market_names mn
    ON td.dong_code = mn.dong_code
  LEFT JOIN top_service_types tst
    ON td.dong_code = tst.dong_code
  LEFT JOIN dominant_time dt
    ON td.dong_code = dt.dong_code
) output_rows;

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
market_tiles AS (
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
market_type AS (
  SELECT
    dong_code,
    dong_name,
    CASE
      WHEN night_conversion_tile = 1 THEN 'night_type'
      WHEN conversion_score_tile = 1 THEN 'overall_type'
      WHEN consumption_index_tile = 1 THEN 'consumption_type'
      WHEN subway_inflow_tile = 1 AND stay_index_tile > 2 THEN 'inflow_type'
      WHEN stay_index_tile = 1 AND consumption_index_tile > 2 THEN 'stay_type'
      ELSE 'general_type'
    END AS market_type,
    subway_inflow_tile,
    stay_index_tile,
    consumption_index_tile,
    conversion_score_tile,
    night_conversion_tile
  FROM market_tiles
),
market_names AS (
  SELECT
    dong_code,
    concat_ws('; ', sort_array(collect_set(market_name))) AS market_names
  FROM market_dong_bridge
  WHERE market_name IS NOT NULL
  GROUP BY dong_code
),
service_sales AS (
  SELECT
    mdb.dong_code,
    cms.service_type,
    SUM(cms.sales_amount) AS sales_amount
  FROM clean_market_sales cms
  INNER JOIN market_dong_bridge mdb
    ON cms.market_code = mdb.market_code
  WHERE cms.service_type IS NOT NULL
  GROUP BY mdb.dong_code, cms.service_type
),
ranked_service AS (
  SELECT
    ROW_NUMBER() OVER (
      PARTITION BY dong_code
      ORDER BY sales_amount DESC
    ) AS service_rank,
    dong_code,
    service_type
  FROM service_sales
),
top_service_types AS (
  SELECT
    dong_code,
    concat_ws('; ', collect_list(service_type)) AS top_service_types
  FROM (
    SELECT
      dong_code,
      service_type,
      service_rank
    FROM ranked_service
    WHERE service_rank <= 5
    DISTRIBUTE BY dong_code
    SORT BY dong_code, service_rank
  ) sorted_services
  GROUP BY dong_code
),
time_summary AS (
  SELECT
    dong_code,
    time_slot,
    AVG(conversion_score) AS avg_conversion_score
  FROM analysis_mart_quarter
  GROUP BY dong_code, time_slot
),
ranked_time AS (
  SELECT
    ROW_NUMBER() OVER (
      PARTITION BY dong_code
      ORDER BY avg_conversion_score DESC
    ) AS time_rank,
    dong_code,
    time_slot
  FROM time_summary
  WHERE avg_conversion_score IS NOT NULL
),
dominant_time AS (
  SELECT
    dong_code,
    time_slot AS dominant_time_slot
  FROM ranked_time
  WHERE time_rank = 1
),
q1 AS (
  SELECT
    'Q1' AS question_no,
    'subway_inflow_top_dong' AS question_key,
    ROW_NUMBER() OVER (ORDER BY avg_subway_inflow DESC) AS rank_no,
    '' AS time_slot,
    dong_code,
    dong_name,
    'avg_subway_inflow' AS metric_name,
    avg_subway_inflow AS metric_value,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM dong_summary
  WHERE avg_subway_inflow IS NOT NULL
),
q2 AS (
  SELECT
    'Q2' AS question_no,
    'living_population_top_dong' AS question_key,
    ROW_NUMBER() OVER (ORDER BY avg_living_population DESC) AS rank_no,
    '' AS time_slot,
    dong_code,
    dong_name,
    'avg_living_population' AS metric_name,
    avg_living_population AS metric_value,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM dong_summary
  WHERE avg_living_population IS NOT NULL
),
q3 AS (
  SELECT
    'Q3' AS question_no,
    'stay_index_top_dong' AS question_key,
    ROW_NUMBER() OVER (ORDER BY avg_stay_index DESC) AS rank_no,
    '' AS time_slot,
    dong_code,
    dong_name,
    'avg_stay_index' AS metric_name,
    avg_stay_index AS metric_value,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM dong_summary
  WHERE avg_stay_index IS NOT NULL
),
q4 AS (
  SELECT
    'Q4' AS question_no,
    'consumption_index_top_dong' AS question_key,
    ROW_NUMBER() OVER (ORDER BY avg_consumption_index DESC) AS rank_no,
    '' AS time_slot,
    dong_code,
    dong_name,
    'avg_consumption_index' AS metric_name,
    avg_consumption_index AS metric_value,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM dong_summary
  WHERE avg_consumption_index IS NOT NULL
),
q5 AS (
  SELECT
    'Q5' AS question_no,
    'conversion_score_top_dong' AS question_key,
    ROW_NUMBER() OVER (ORDER BY avg_conversion_score DESC) AS rank_no,
    '' AS time_slot,
    dong_code,
    dong_name,
    'avg_conversion_score' AS metric_name,
    avg_conversion_score AS metric_value,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM dong_summary
  WHERE avg_conversion_score IS NOT NULL
),
q6_time_summary AS (
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
q6 AS (
  SELECT
    'Q6' AS question_no,
    'time_slot_strong_pattern' AS question_key,
    ROW_NUMBER() OVER (
      PARTITION BY time_slot
      ORDER BY avg_conversion_score DESC
    ) AS rank_no,
    time_slot,
    dong_code,
    dong_name,
    'avg_conversion_score' AS metric_name,
    avg_conversion_score AS metric_value,
    avg_subway_inflow,
    avg_living_population,
    avg_stay_index,
    avg_consumption_index,
    avg_conversion_score
  FROM q6_time_summary
  WHERE avg_conversion_score IS NOT NULL
),
q7 AS (
  SELECT
    'Q7' AS question_no,
    'dong_market_type' AS question_key,
    ROW_NUMBER() OVER (ORDER BY ds.avg_conversion_score DESC) AS rank_no,
    '' AS time_slot,
    ds.dong_code,
    ds.dong_name,
    mt.market_type AS metric_name,
    ds.avg_conversion_score AS metric_value,
    ds.avg_subway_inflow,
    ds.avg_living_population,
    ds.avg_stay_index,
    ds.avg_consumption_index,
    ds.avg_conversion_score
  FROM dong_summary ds
  INNER JOIN market_type mt
    ON ds.dong_code = mt.dong_code
),
question_rows AS (
  SELECT * FROM q1 WHERE rank_no <= 20
  UNION ALL SELECT * FROM q2 WHERE rank_no <= 20
  UNION ALL SELECT * FROM q3 WHERE rank_no <= 20
  UNION ALL SELECT * FROM q4 WHERE rank_no <= 20
  UNION ALL SELECT * FROM q5 WHERE rank_no <= 20
  UNION ALL SELECT * FROM q6 WHERE rank_no <= 10
  UNION ALL SELECT * FROM q7
)
INSERT OVERWRITE DIRECTORY '${hivevar:hdfs_base_dir}/results/question_answer_evidence'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT
  question_no,
  question_key,
  rank_no,
  time_slot,
  dong_code,
  dong_name,
  metric_name,
  metric_value,
  avg_subway_inflow,
  avg_living_population,
  avg_stay_index,
  avg_consumption_index,
  avg_conversion_score,
  market_type,
  market_names,
  top_service_types,
  dominant_time_slot
FROM (
  SELECT
    'question_no' AS question_no,
    'question_key' AS question_key,
    'rank' AS rank_no,
    'time_slot' AS time_slot,
    'dong_code' AS dong_code,
    'dong_name' AS dong_name,
    'metric_name' AS metric_name,
    'metric_value' AS metric_value,
    'avg_subway_inflow' AS avg_subway_inflow,
    'avg_living_population' AS avg_living_population,
    'avg_stay_index' AS avg_stay_index,
    'avg_consumption_index' AS avg_consumption_index,
    'avg_conversion_score' AS avg_conversion_score,
    'market_type' AS market_type,
    'market_names' AS market_names,
    'top_service_types' AS top_service_types,
    'dominant_time_slot' AS dominant_time_slot
  UNION ALL
  SELECT
    qr.question_no,
    qr.question_key,
    CAST(qr.rank_no AS STRING) AS rank_no,
    qr.time_slot,
    qr.dong_code,
    qr.dong_name,
    qr.metric_name,
    CAST(qr.metric_value AS STRING) AS metric_value,
    CAST(qr.avg_subway_inflow AS STRING) AS avg_subway_inflow,
    CAST(qr.avg_living_population AS STRING) AS avg_living_population,
    CAST(qr.avg_stay_index AS STRING) AS avg_stay_index,
    CAST(qr.avg_consumption_index AS STRING) AS avg_consumption_index,
    CAST(qr.avg_conversion_score AS STRING) AS avg_conversion_score,
    COALESCE(mt.market_type, '') AS market_type,
    COALESCE(mn.market_names, '') AS market_names,
    COALESCE(tst.top_service_types, '') AS top_service_types,
    COALESCE(dt.dominant_time_slot, '') AS dominant_time_slot
  FROM question_rows qr
  LEFT JOIN market_type mt
    ON qr.dong_code = mt.dong_code
  LEFT JOIN market_names mn
    ON qr.dong_code = mn.dong_code
  LEFT JOIN top_service_types tst
    ON qr.dong_code = tst.dong_code
  LEFT JOIN dominant_time dt
    ON qr.dong_code = dt.dong_code
) output_rows;
