#!/usr/bin/env bash

# Helpers for granting HiveServer2 the minimum HDFS access needed to register
# external tables over user-owned raw and processed data directories.

HIVE_HDFS_USER="${HIVE_HDFS_USER:-hive}"
ENABLE_HDFS_ACL="${ENABLE_HDFS_ACL:-1}"

grant_hive_hdfs_acl() {
  local hdfs_path="$1"

  if [[ "${ENABLE_HDFS_ACL}" != "1" ]]; then
    echo "[skip acl] ENABLE_HDFS_ACL=${ENABLE_HDFS_ACL}"
    return 0
  fi

  if ! hdfs dfs -test -e "${hdfs_path}"; then
    echo "[skip acl] HDFS path not found: ${hdfs_path}"
    return 0
  fi

  echo "[acl] grant ${HIVE_HDFS_USER} rwx on ${hdfs_path}"
  hdfs dfs -setfacl -R -m "user:${HIVE_HDFS_USER}:rwx" "${hdfs_path}"

  if hdfs dfs -test -d "${hdfs_path}"; then
    hdfs dfs -setfacl -m "default:user:${HIVE_HDFS_USER}:rwx" "${hdfs_path}"
  fi
}
