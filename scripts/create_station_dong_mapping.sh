#!/usr/bin/env bash
set -euo pipefail

# Build a station-to-administrative-dong mapping from station coordinates.
# This script is intentionally separate from download_data.sh because it calls
# Kakao Local API and requires a private REST API key.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

DATASET_DIR="${DATASET_DIR:-/home/maria_dev/DataSet}"
STATION_MASTER_DIR="${DATASET_DIR}/StationMaster"
OUTPUT_DIR="${DATASET_DIR}/StationDongMapping"
OUTPUT_PATH="${OUTPUT_DIR}/station_dong_mapping.csv"
KAKAO_API_SLEEP_SECONDS="${KAKAO_API_SLEEP_SECONDS:-0.15}"
PYTHON_BIN="${PYTHON_BIN:-}"

if [[ -f "${PROJECT_DIR}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${PROJECT_DIR}/.env"
  set +a
fi

if [[ -z "${KAKAO_REST_API_KEY:-}" ]]; then
  echo "[error] KAKAO_REST_API_KEY is required." >&2
  echo "[hint] Add it to ${PROJECT_DIR}/.env or export it in the current shell." >&2
  exit 1
fi

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "[error] Required command not found: ${command_name}" >&2
    exit 1
  fi
}

if [[ -z "${PYTHON_BIN}" ]]; then
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="python3"
  elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
  else
    echo "[error] Required command not found: python3 or python" >&2
    exit 1
  fi
fi

require_command "${PYTHON_BIN}"

if ! find "${STATION_MASTER_DIR}" -maxdepth 1 -type f -name '*.csv' | grep -q .; then
  echo "[error] Station master CSV not found: ${STATION_MASTER_DIR}/*.csv" >&2
  echo "[hint] Run: bash scripts/download_data.sh" >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

echo "== Station dong mapping settings =="
echo "DATASET_DIR=${DATASET_DIR}"
echo "STATION_MASTER_DIR=${STATION_MASTER_DIR}"
echo "OUTPUT_PATH=${OUTPUT_PATH}"
echo "KAKAO_API_SLEEP_SECONDS=${KAKAO_API_SLEEP_SECONDS}"
echo "PYTHON_BIN=${PYTHON_BIN}"

"${PYTHON_BIN}" - "${STATION_MASTER_DIR}" "${OUTPUT_PATH}" "${KAKAO_API_SLEEP_SECONDS}" <<'PY'
# -*- coding: utf-8 -*-
from __future__ import print_function

import csv
import glob
import json
import os
import sys
import time

PY2 = sys.version_info[0] == 2

if PY2:
    text_type = unicode
    binary_type = str
else:
    text_type = str
    binary_type = bytes

try:
    from urllib.parse import urlencode
    from urllib.request import Request, urlopen
except ImportError:
    from urllib import urlencode
    from urllib2 import Request, urlopen


station_master_dir = sys.argv[1]
output_path = sys.argv[2]
sleep_seconds = float(sys.argv[3])
api_key = os.environ.get("KAKAO_REST_API_KEY", "")

API_URL = "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json"
SOURCE = "kakao_coord2regioncode"


def to_text(value):
    if value is None:
        return ""
    if isinstance(value, text_type):
        return value
    if isinstance(value, binary_type):
        return value.decode("utf-8")
    return text_type(value)


def to_csv_value(value):
    value = to_text(value)
    if PY2:
        return value.encode("utf-8")
    return value


def read_text(path):
    with open(path, "rb") as input_file:
        raw = input_file.read()

    for encoding in ("utf-8-sig", "utf-8", "cp949", "euc-kr"):
        try:
            return raw.decode(encoding)
        except UnicodeDecodeError:
            continue

    raise UnicodeDecodeError("csv", raw, 0, 1, "unsupported CSV encoding")


def normalize_line_name(value):
    return to_text(value).strip()


def normalize_station_name(value):
    return to_text(value).strip()


def coord_to_dong(longitude, latitude):
    query = urlencode({"x": longitude, "y": latitude})
    request = Request(
        API_URL + "?" + query,
        headers={"Authorization": "KakaoAK {0}".format(api_key)},
    )

    response = urlopen(request, timeout=15)
    try:
        payload = json.loads(response.read().decode("utf-8"))
    finally:
        response.close()

    for document in payload.get("documents", []):
        if document.get("region_type") == "H":
            code = str(document.get("code", "")).strip()
            if len(code) < 8:
                raise ValueError("invalid Kakao region code: {0}".format(code))
            return code[:8], (document.get("region_3depth_name") or "").strip()

    raise ValueError("region_type=H not found")


def main():
    seen = set()
    rows = []
    input_paths = sorted(glob.glob(os.path.join(station_master_dir, "*.csv")))

    for input_path in input_paths:
        text = read_text(input_path)
        if PY2:
            reader_input = [line.encode("utf-8") for line in text.splitlines()]
        else:
            reader_input = text.splitlines()
        reader = csv.DictReader(reader_input)

        for row in reader:
            station_name = normalize_station_name(row.get("역사명"))
            line_name = normalize_line_name(row.get("호선"))
            latitude = to_text(row.get("위도")).strip()
            longitude = to_text(row.get("경도")).strip()

            if not station_name or not line_name:
                print(
                    "[error] skip row with missing station/line in {0}".format(input_path),
                    file=sys.stderr,
                )
                continue

            key = (station_name, line_name)
            if key in seen:
                continue
            seen.add(key)

            if not latitude or not longitude:
                print(
                    "[error] skip {0}/{1}: missing coordinates".format(
                        station_name, line_name
                    ),
                    file=sys.stderr,
                )
                continue

            try:
                dong_code, dong_name = coord_to_dong(longitude, latitude)
            except Exception as exc:
                print(
                    "[error] skip {0}/{1}: {2}".format(station_name, line_name, exc),
                    file=sys.stderr,
                )
                time.sleep(sleep_seconds)
                continue

            rows.append(
                {
                    "station_name": station_name,
                    "line_name": line_name,
                    "latitude": latitude,
                    "longitude": longitude,
                    "dong_code": dong_code,
                    "dong_name": dong_name,
                    "source": SOURCE,
                }
            )
            time.sleep(sleep_seconds)

    if not rows:
        print("[error] No station dong mappings were generated.", file=sys.stderr)
        return 1

    fieldnames = [
        "station_name",
        "line_name",
        "latitude",
        "longitude",
        "dong_code",
        "dong_name",
        "source",
    ]

    if PY2:
        output_file = open(output_path, "wb")
    else:
        output_file = open(output_path, "w", newline="", encoding="utf-8")

    try:
        writer = csv.DictWriter(output_file, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(dict((key, to_csv_value(value)) for key, value in row.items()))
    finally:
        output_file.close()

    print("Generated mappings: {0}".format(len(rows)))
    print("Output: {0}".format(output_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
PY

echo "== Done =="
