#!/usr/bin/env bash
set -euo pipefail

# Run Hive analysis queries and show a small preview of each result dataset.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/hdfs_permissions.sh"

HDFS_USER="${HDFS_USER:-${USER:-maria_dev}}"
HDFS_BASE_DIR="${HDFS_BASE_DIR:-/user/${HDFS_USER}/seoul_stickiness}"
HDFS_RESULTS_DIR="${HDFS_BASE_DIR}/results"
RESULT_NAMES=(
  "top_subway_inflow"
  "top_living_population"
  "top_stay_index"
  "top_consumption_index"
  "top_conversion_score"
  "time_slot_pattern"
  "dong_market_type"
)

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "[error] Required command not found: ${command_name}" >&2
    exit 1
  fi
}

print_result_head() {
  local result_name="$1"
  local result_path="${HDFS_RESULTS_DIR}/${result_name}"

  echo
  echo "== ${result_name} =="
  echo "path: ${result_path}"
  hdfs dfs -ls "${result_path}" || true
  echo "-- head --"
  hdfs dfs -cat "${result_path}"/* 2>/dev/null | head -n 5 || true
}

require_command hive
require_command hdfs

echo "== Analysis settings =="
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "HDFS_BASE_DIR=${HDFS_BASE_DIR}"
echo "HIVE_HDFS_USER=${HIVE_HDFS_USER}"

echo "== Prepare result directories =="
hdfs dfs -mkdir -p "${HDFS_RESULTS_DIR}"
for result_name in "${RESULT_NAMES[@]}"; do
  hdfs dfs -rm -r -f "${HDFS_RESULTS_DIR}/${result_name}" >/dev/null 2>&1 || true
done
grant_hive_hdfs_acl "${HDFS_RESULTS_DIR}"

echo "== Run Hive analysis queries =="
hive \
  --hivevar hdfs_base_dir="${HDFS_BASE_DIR}" \
  -f "${PROJECT_DIR}/sql/analysis_queries.hql"

echo "== Result directories =="
hdfs dfs -ls "${HDFS_RESULTS_DIR}" || true

for result_name in "${RESULT_NAMES[@]}"; do
  print_result_head "${result_name}"
done

echo
echo "== Done =="
