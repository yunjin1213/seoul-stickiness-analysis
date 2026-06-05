#!/usr/bin/env bash
set -euo pipefail

# Merge Hive result directories from HDFS into local CSV files for visualization.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

HDFS_USER="${HDFS_USER:-${USER:-maria_dev}}"
HDFS_BASE_DIR="${HDFS_BASE_DIR:-/user/${HDFS_USER}/seoul_stickiness}"
HDFS_RESULTS_DIR="${HDFS_BASE_DIR}/results"
LOCAL_RESULTS_DIR="${LOCAL_RESULTS_DIR:-${PROJECT_DIR}/results_csv}"
RESULT_NAMES=(
  "top_subway_inflow"
  "top_living_population"
  "top_stay_index"
  "top_consumption_index"
  "top_conversion_score"
  "time_slot_pattern"
  "dong_market_type"
  "top_dong_time_profile"
  "dong_service_sales_mix"
  "top_dong_service_top5"
  "night_sales_pattern"
  "result_interpretation_support"
  "question_answer_evidence"
)

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "[error] Required command not found: ${command_name}" >&2
    exit 1
  fi
}

require_command hdfs

echo "== Export analysis results =="
echo "HDFS_RESULTS_DIR=${HDFS_RESULTS_DIR}"
echo "LOCAL_RESULTS_DIR=${LOCAL_RESULTS_DIR}"

mkdir -p "${LOCAL_RESULTS_DIR}"

for result_name in "${RESULT_NAMES[@]}"; do
  hdfs_path="${HDFS_RESULTS_DIR}/${result_name}"
  local_path="${LOCAL_RESULTS_DIR}/${result_name}.csv"

  if ! hdfs dfs -test -e "${hdfs_path}"; then
    echo "[error] Missing HDFS result: ${hdfs_path}" >&2
    echo "[hint] Run: bash scripts/run_analysis.sh" >&2
    exit 1
  fi

  echo "[getmerge] ${hdfs_path} -> ${local_path}"
  rm -f "${local_path}.tmp"
  hdfs dfs -getmerge "${hdfs_path}" "${local_path}.tmp"
  mv "${local_path}.tmp" "${local_path}"
done

python3 "${PROJECT_DIR}/scripts/create_evidence_csv.py" \
  --results-dir "${LOCAL_RESULTS_DIR}"

echo "== Exported files =="
ls -lh "${LOCAL_RESULTS_DIR}"

echo "== Done =="
