#!/usr/bin/env bash
set -euo pipefail

# Run Hive table registration and Spark preprocessing inside the HDP Sandbox.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/hdfs_permissions.sh"

HDFS_USER="${HDFS_USER:-${USER:-maria_dev}}"
HDFS_BASE_DIR="${HDFS_BASE_DIR:-/user/${HDFS_USER}/seoul_stickiness}"
HDFS_RAW_DIR="${HDFS_BASE_DIR}/raw"
HDFS_PROCESSED_DIR="${HDFS_BASE_DIR}/processed"
PYSPARK_PYTHON="${PYSPARK_PYTHON:-python3.6}"

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "[error] Required command not found: ${command_name}" >&2
    exit 1
  fi
}

require_command hive
require_command spark-submit

echo "== Preprocess settings =="
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "HDFS_BASE_DIR=${HDFS_BASE_DIR}"
echo "HIVE_HDFS_USER=${HIVE_HDFS_USER}"
echo "PYSPARK_PYTHON=${PYSPARK_PYTHON}"

echo "== Grant Hive ACLs for raw tables =="
grant_hive_hdfs_acl "${HDFS_BASE_DIR}"
grant_hive_hdfs_acl "${HDFS_RAW_DIR}"

echo "== Create raw Hive external tables =="
hive \
  --hivevar hdfs_base_dir="${HDFS_BASE_DIR}" \
  -f "${PROJECT_DIR}/sql/create_raw_tables.hql"

echo "== Run Spark preprocessing =="
PYSPARK_PYTHON="${PYSPARK_PYTHON}" spark-submit \
  "${PROJECT_DIR}/src/preprocess.py" \
  --hdfs-base-dir "${HDFS_BASE_DIR}"

echo "== Grant Hive ACLs for processed tables =="
grant_hive_hdfs_acl "${HDFS_PROCESSED_DIR}"

echo "== Create processed Hive external tables =="
hive \
  --hivevar hdfs_base_dir="${HDFS_BASE_DIR}" \
  -f "${PROJECT_DIR}/sql/create_processed_tables.hql"

echo "== Processed outputs =="
hdfs dfs -ls -R "${HDFS_BASE_DIR}/processed" | head -n 80 || true

echo "== Done =="
