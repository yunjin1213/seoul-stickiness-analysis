#!/usr/bin/env bash
set -euo pipefail

# Reproducible data collection script for the Seoul stickiness analysis project.
# It downloads public datasets and stores them under the shared DataSet directory.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
FINAL_DIR="$(cd "${PROJECT_DIR}/.." && pwd)"
DATASET_DIR="${DATASET_DIR:-${FINAL_DIR}/DataSet}"

PEOPLE_DIR="${DATASET_DIR}/People"
SUBWAY_DIR="${DATASET_DIR}/Subway"
STATION_MASTER_DIR="${DATASET_DIR}/StationMaster"
MARKET_SALES_DIR="${DATASET_DIR}/MarketSales"
MARKET_AREA_DIR="${DATASET_DIR}/MarketArea"
DOWNLOAD_DIR="${DATASET_DIR}/_downloads"
PEOPLE_ZIP_DIR="${DOWNLOAD_DIR}/people_zips"
SUBWAY_DOWNLOAD_DIR="${DOWNLOAD_DIR}/subway"
STATION_MASTER_DOWNLOAD_DIR="${DOWNLOAD_DIR}/station_master"
MARKET_SALES_DOWNLOAD_DIR="${DOWNLOAD_DIR}/market_sales"
MARKET_AREA_DOWNLOAD_DIR="${DOWNLOAD_DIR}/market_area"

FORCE="${FORCE:-0}"

mkdir -p \
  "${PEOPLE_DIR}" \
  "${SUBWAY_DIR}" \
  "${STATION_MASTER_DIR}" \
  "${MARKET_SALES_DIR}" \
  "${MARKET_AREA_DIR}" \
  "${PEOPLE_ZIP_DIR}" \
  "${SUBWAY_DOWNLOAD_DIR}" \
  "${STATION_MASTER_DOWNLOAD_DIR}" \
  "${MARKET_SALES_DOWNLOAD_DIR}" \
  "${MARKET_AREA_DOWNLOAD_DIR}"

python_download() {
  local url="$1"
  local output_path="$2"

  if command -v python3 >/dev/null 2>&1; then
    python3 - "${url}" "${output_path}" <<'PY'
import sys
try:
    from urllib.request import Request, urlopen
except ImportError:
    from urllib2 import Request, urlopen

url = sys.argv[1]
output_path = sys.argv[2]
request = Request(url, headers={"User-Agent": "Mozilla/5.0"})
with urlopen(request, timeout=120) as response, open(output_path, "wb") as output:
    while True:
        chunk = response.read(1024 * 1024)
        if not chunk:
            break
        output.write(chunk)
PY
    return
  fi

  python - "${url}" "${output_path}" <<'PY'
import sys
try:
    from urllib.request import Request, urlopen
except ImportError:
    from urllib2 import Request, urlopen

url = sys.argv[1]
output_path = sys.argv[2]
request = Request(url, headers={"User-Agent": "Mozilla/5.0"})
response = urlopen(request, timeout=120)
try:
    output = open(output_path, "wb")
    try:
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            output.write(chunk)
    finally:
        output.close()
finally:
    response.close()
PY
}

download_if_needed() {
  local output_path="$1"
  shift
  local curl_args=("$@")
  local url="${curl_args[$((${#curl_args[@]} - 1))]}"
  local is_post=0

  if [[ -s "${output_path}" && "${FORCE}" != "1" ]]; then
    echo "[skip] ${output_path}"
    return
  fi

  for arg in "${curl_args[@]}"; do
    if [[ "${arg}" == "--request" || "${arg}" == "POST" ]]; then
      is_post=1
    fi
  done

  echo "[download] ${output_path}"
  if ! curl --fail --location --retry 3 --retry-delay 3 --user-agent "Mozilla/5.0" "${curl_args[@]}" --output "${output_path}"; then
    if [[ "${is_post}" == "1" ]]; then
      echo "[error] curl POST download failed: ${url}" >&2
      return 1
    fi

    echo "[warn] curl download failed. Trying Python downloader..." >&2
    python_download "${url}" "${output_path}"
  fi
}

unzip_if_needed() {
  local zip_path="$1"
  local target_dir="$2"
  local expected_pattern="$3"

  if find "${target_dir}" -maxdepth 1 -type f -name "${expected_pattern}" | grep -q . && [[ "${FORCE}" != "1" ]]; then
    echo "[skip] ${target_dir}/${expected_pattern}"
    return
  fi

  echo "[unzip] ${zip_path}"
  unzip -o "${zip_path}" -d "${target_dir}" >/dev/null
}

download_people_month() {
  local yyyymm="$1"
  local seq="$2"
  local zip_name="LOCAL_PEOPLE_DONG_${yyyymm}.zip"
  local csv_name="LOCAL_PEOPLE_DONG_${yyyymm}.csv"
  local zip_path="${PEOPLE_ZIP_DIR}/${zip_name}"

  if [[ -s "${PEOPLE_DIR}/${csv_name}" && "${FORCE}" != "1" ]]; then
    echo "[skip] ${PEOPLE_DIR}/${csv_name}"
    return
  fi

  download_if_needed "${zip_path}" \
    --request POST \
    --data "infId=OA-14991" \
    --data "seq=${seq}" \
    --data "infSeq=3" \
    "https://datafile.seoul.go.kr/bigfile/iot/inf/nio_download.do?&useCache=false"

  unzip_if_needed "${zip_path}" "${PEOPLE_DIR}" "${csv_name}"
}

download_subway_file() {
  local output_name="$1"
  local url="$2"
  local output_path="${SUBWAY_DOWNLOAD_DIR}/${output_name}"

  download_if_needed "${output_path}" "${url}"

  case "${output_name}" in
    *.zip)
      unzip_if_needed "${output_path}" "${SUBWAY_DIR}" "*.csv"
      ;;
    *.csv)
      local target_path="${SUBWAY_DIR}/${output_name}"
      if [[ -s "${target_path}" && "${FORCE}" != "1" ]]; then
        echo "[skip] ${target_path}"
      else
        echo "[copy] ${target_path}"
        cp "${output_path}" "${target_path}"
      fi
      ;;
  esac
}

download_station_master() {
  local output_path="${STATION_MASTER_DOWNLOAD_DIR}/seoul_station_master.csv"
  local target_path="${STATION_MASTER_DIR}/seoul_station_master.csv"

  download_if_needed "${output_path}" \
    --request POST \
    --data "srvType=S" \
    --data "infId=OA-21232" \
    --data "serviceKind=1" \
    --data "pageNo=1" \
    --data "gridTotalCnt=784" \
    --data "ssUserId=SAMPLE_VIEW" \
    --data "strWhere=" \
    --data "strOrderby=BLDN_ID+DESC" \
    --data "filterCol=필터선택" \
    --data "txtFilter=" \
    "https://datafile.seoul.go.kr/bigfile/iot/sheet/csv/download.do"

  if [[ -s "${target_path}" && "${FORCE}" != "1" ]]; then
    echo "[skip] ${target_path}"
  else
    echo "[copy] ${target_path}"
    cp "${output_path}" "${target_path}"
  fi
}

download_market_sales_2025() {
  local zip_path="${MARKET_SALES_DOWNLOAD_DIR}/seoul_market_sales_2025.zip"

  download_if_needed "${zip_path}" \
    --request POST \
    --data "infId=OA-15572" \
    --data "seqNo=" \
    --data "seq=51" \
    --data "infSeq=3" \
    "https://datafile.seoul.go.kr/bigfile/iot/inf/nio_download.do?&useCache=false"

  unzip_if_needed "${zip_path}" "${MARKET_SALES_DIR}" "*.csv"
}

download_market_area() {
  local output_path="${MARKET_AREA_DOWNLOAD_DIR}/seoul_market_area.csv"
  local target_path="${MARKET_AREA_DIR}/seoul_market_area.csv"

  download_if_needed "${output_path}" \
    --request POST \
    --data "srvType=S" \
    --data "infId=OA-15560" \
    --data "serviceKind=1" \
    --data "pageNo=1" \
    --data "gridTotalCnt=1650" \
    --data "ssUserId=SAMPLE_VIEW" \
    --data "strWhere=" \
    --data "strOrderby=" \
    --data "filterCol=" \
    --data "txtFilter=" \
    "https://datafile.seoul.go.kr/bigfile/iot/sheet/csv/download.do"

  if [[ -s "${target_path}" && "${FORCE}" != "1" ]]; then
    echo "[skip] ${target_path}"
  else
    echo "[copy] ${target_path}"
    cp "${output_path}" "${target_path}"
  fi
}

echo "== Download Seoul living population data =="
for month in 01 02 03 04 05 06 07 08 09 10 11 12; do
  download_people_month "2025${month}" "25${month}"
done

echo "== Download Seoul Metro daily ridership data =="
download_subway_file \
  "seoul_metro_passenger_type_20250630.csv" \
  "https://www.data.go.kr/cmm/cmm/fileDownload.do?atchFileId=FILE_000000003590585&fileDetailSn=1"

download_subway_file \
  "seoul_metro_passenger_type_20251231.csv" \
  "https://www.data.go.kr/cmm/cmm/fileDownload.do?atchFileId=FILE_000000003594728&fileDetailSn=1&dataNm=%EC%84%9C%EC%9A%B8%EA%B5%90%ED%86%B5%EA%B3%B5%EC%82%AC_1_8%ED%98%B8%EC%84%A0%20%EC%97%AD%EB%B3%84%20%EC%9D%BC%EB%B3%84%20%EC%8B%9C%EA%B0%84%EB%8C%80%EB%B3%84%20%EC%8A%B9%EA%B0%9D%EC%9C%A0%ED%98%95%EB%B3%84%20%EC%8A%B9%ED%95%98%EC%B0%A8%EC%9D%B8%EC%9B%90_20251231"

echo "== Download Seoul station master data =="
download_station_master

echo "== Download Seoul commercial district sales data =="
download_market_sales_2025

echo "== Download Seoul commercial district area data =="
download_market_area

echo "== Validate collected data size =="
total_bytes="$(find "${DATASET_DIR}" -type f \( -name '*.csv' -o -name '*.zip' \) -exec wc -c {} + | awk '$2 != "total" {sum += $1} END {print sum + 0}')"
total_mb="$(awk "BEGIN {printf \"%.2f\", ${total_bytes} / 1024 / 1024}")"

echo "Collected data size: ${total_mb} MB"

if awk "BEGIN {exit !(${total_bytes} >= 100 * 1024 * 1024)}"; then
  echo "[ok] Data size requirement satisfied: >= 100 MB"
else
  echo "[error] Data size requirement not satisfied: < 100 MB" >&2
  exit 1
fi

echo "== Done =="
echo "People data: ${PEOPLE_DIR}"
echo "Subway data: ${SUBWAY_DIR}"
echo "Station master data: ${STATION_MASTER_DIR}"
echo "Market sales data: ${MARKET_SALES_DIR}"
echo "Market area data: ${MARKET_AREA_DIR}"
