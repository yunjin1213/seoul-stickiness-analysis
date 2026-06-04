#!/usr/bin/env bash
set -euo pipefail

# Run the full reproducible pipeline inside the HDP Sandbox / Hadoop VM.
# Default stages:
#   download -> station mapping -> HDFS upload -> Spark preprocess -> Hive analysis -> local CSV export
#
# Optional controls:
#   RUN_DOWNLOAD=0     Skip public data download
#   RUN_MAPPING=0      Skip Kakao station-dong mapping generation
#   RUN_UPLOAD=0       Skip HDFS upload
#   RUN_PREPROCESS=0   Skip Spark preprocessing
#   RUN_ANALYSIS=0     Skip Hive analysis queries
#   RUN_EXPORT=0       Skip HDFS results export to results_csv
#   RUN_VISUALIZE=1    Also run local visualization after export

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

RUN_DOWNLOAD="${RUN_DOWNLOAD:-1}"
RUN_MAPPING="${RUN_MAPPING:-1}"
RUN_UPLOAD="${RUN_UPLOAD:-1}"
RUN_PREPROCESS="${RUN_PREPROCESS:-1}"
RUN_ANALYSIS="${RUN_ANALYSIS:-1}"
RUN_EXPORT="${RUN_EXPORT:-1}"
RUN_VISUALIZE="${RUN_VISUALIZE:-0}"

run_step() {
  local stage_name="$1"
  shift

  echo
  echo "============================================================"
  echo "== ${stage_name}"
  echo "============================================================"
  "$@"
}

run_optional_step() {
  local enabled="$1"
  local stage_name="$2"
  shift 2

  if [[ "${enabled}" == "1" ]]; then
    run_step "${stage_name}" "$@"
  else
    echo "[skip] ${stage_name}"
  fi
}

echo "== Full pipeline settings =="
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "DATASET_DIR=${DATASET_DIR:-<default>}"
echo "HDFS_BASE_DIR=${HDFS_BASE_DIR:-<default>}"
echo "LOCAL_RESULTS_DIR=${LOCAL_RESULTS_DIR:-<default>}"
echo "RUN_DOWNLOAD=${RUN_DOWNLOAD}"
echo "RUN_MAPPING=${RUN_MAPPING}"
echo "RUN_UPLOAD=${RUN_UPLOAD}"
echo "RUN_PREPROCESS=${RUN_PREPROCESS}"
echo "RUN_ANALYSIS=${RUN_ANALYSIS}"
echo "RUN_EXPORT=${RUN_EXPORT}"
echo "RUN_VISUALIZE=${RUN_VISUALIZE}"

run_optional_step "${RUN_DOWNLOAD}" "Download public datasets" \
  bash "${SCRIPT_DIR}/download_data.sh"

run_optional_step "${RUN_MAPPING}" "Create station-dong mapping" \
  bash "${SCRIPT_DIR}/create_station_dong_mapping.sh"

run_optional_step "${RUN_UPLOAD}" "Upload raw datasets to HDFS" \
  bash "${SCRIPT_DIR}/upload_hdfs.sh"

run_optional_step "${RUN_PREPROCESS}" "Run Spark preprocessing" \
  bash "${SCRIPT_DIR}/run_preprocess.sh"

run_optional_step "${RUN_ANALYSIS}" "Run Hive analysis queries" \
  bash "${SCRIPT_DIR}/run_analysis.sh"

run_optional_step "${RUN_EXPORT}" "Export HDFS results to local CSV" \
  bash "${SCRIPT_DIR}/export_results.sh"

if [[ "${RUN_VISUALIZE}" == "1" ]]; then
  run_step "Create local figures and summary CSVs" \
    python3 "${PROJECT_DIR}/src/visualize_results.py"
else
  echo "[skip] Create local figures and summary CSVs"
fi

echo
echo "== Pipeline done =="
echo "HDFS results: ${HDFS_BASE_DIR:-/user/${USER:-maria_dev}/seoul_stickiness}/results"
echo "Local CSV results: ${LOCAL_RESULTS_DIR:-${PROJECT_DIR}/results_csv}"
if [[ "${RUN_VISUALIZE}" == "1" ]]; then
  echo "Figures: ${PROJECT_DIR}/figures"
  echo "Summary CSVs: ${PROJECT_DIR}/summary_csv"
fi
