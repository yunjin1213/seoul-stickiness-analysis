#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build interpretation CSVs from exported analysis result CSV files."""

import argparse
import csv
from pathlib import Path


TYPE_LABELS = {
    "night_type": "야간형",
    "overall_type": "종합형",
    "consumption_type": "소비전환형",
    "inflow_type": "유입형",
    "stay_type": "체류형",
    "general_type": "일반형",
}


QUESTION_SPECS = [
    (
        "Q1",
        "subway_inflow_top_dong",
        "top_subway_inflow.csv",
        "avg_subway_inflow",
    ),
    (
        "Q2",
        "living_population_top_dong",
        "top_living_population.csv",
        "avg_living_population",
    ),
    (
        "Q3",
        "stay_index_top_dong",
        "top_stay_index.csv",
        "avg_stay_index",
    ),
    (
        "Q4",
        "consumption_index_top_dong",
        "top_consumption_index.csv",
        "avg_consumption_index",
    ),
    (
        "Q5",
        "conversion_score_top_dong",
        "top_conversion_score.csv",
        "avg_conversion_score",
    ),
]


EVIDENCE_COLUMNS = [
    "question_no",
    "question_key",
    "rank",
    "time_slot",
    "dong_code",
    "dong_name",
    "metric_name",
    "metric_value",
    "avg_subway_inflow",
    "avg_living_population",
    "avg_stay_index",
    "avg_consumption_index",
    "avg_conversion_score",
    "market_type",
    "market_type_label",
    "top_service_types",
    "dominant_time_slot",
]


SUPPORT_COLUMNS = [
    "dong_code",
    "dong_name",
    "high_metric",
    "top_service_types",
    "dominant_time_slot",
    "market_type",
    "market_type_label",
]


def read_rows(results_dir, filename):
    path = results_dir / filename
    if not path.exists() or path.stat().st_size == 0:
        return []
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def write_rows(path, fieldnames, rows):
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def get_rank(row):
    return row.get("rank") or row.get("rank_no") or ""


def get_metric(row, metric):
    return row.get(metric, "")


def build_service_lookup(rows):
    by_dong = {}
    for row in rows:
        dong_code = row.get("dong_code", "")
        service_type = row.get("service_type", "")
        if not dong_code or not service_type:
            continue
        rank_text = row.get("service_rank", "")
        try:
            rank = int(float(rank_text))
        except ValueError:
            rank = 999
        by_dong.setdefault(dong_code, []).append((rank, service_type))

    return {
        dong_code: "; ".join(
            service_type for _, service_type in sorted(items, key=lambda item: item[0])[:5]
        )
        for dong_code, items in by_dong.items()
    }


def build_type_lookup(rows):
    lookup = {}
    for row in rows:
        market_type = row.get("market_type", "")
        lookup[row.get("dong_code", "")] = {
            "market_type": market_type,
            "market_type_label": TYPE_LABELS.get(market_type, market_type),
        }
    return lookup


def build_dominant_time_lookup(rows):
    best_by_dong = {}
    for row in rows:
        dong_code = row.get("dong_code", "")
        time_slot = row.get("time_slot", "")
        if not dong_code or not time_slot:
            continue
        try:
            rank = int(float(get_rank(row)))
        except ValueError:
            continue
        current = best_by_dong.get(dong_code)
        if current is None or rank < current[0]:
            best_by_dong[dong_code] = (rank, time_slot)
    return {dong_code: time_slot for dong_code, (_, time_slot) in best_by_dong.items()}


def with_common_context(row, type_lookup, service_lookup, time_lookup):
    dong_code = row.get("dong_code", "")
    type_context = type_lookup.get(dong_code, {})
    return {
        "market_type": type_context.get("market_type", ""),
        "market_type_label": type_context.get("market_type_label", ""),
        "top_service_types": service_lookup.get(dong_code, ""),
        "dominant_time_slot": time_lookup.get(dong_code, ""),
    }


def build_question_answer_rows(results_dir):
    type_lookup = build_type_lookup(read_rows(results_dir, "dong_market_type.csv"))
    service_lookup = build_service_lookup(read_rows(results_dir, "dong_service_sales_mix.csv"))
    time_rows = read_rows(results_dir, "time_slot_pattern.csv")
    time_lookup = build_dominant_time_lookup(time_rows)

    output = []
    for question_no, question_key, filename, metric in QUESTION_SPECS:
        for row in read_rows(results_dir, filename):
            context = with_common_context(row, type_lookup, service_lookup, time_lookup)
            output.append(
                {
                    "question_no": question_no,
                    "question_key": question_key,
                    "rank": get_rank(row),
                    "time_slot": "",
                    "dong_code": row.get("dong_code", ""),
                    "dong_name": row.get("dong_name", ""),
                    "metric_name": metric,
                    "metric_value": get_metric(row, metric),
                    "avg_subway_inflow": row.get("avg_subway_inflow", ""),
                    "avg_living_population": row.get("avg_living_population", ""),
                    "avg_stay_index": row.get("avg_stay_index", ""),
                    "avg_consumption_index": row.get("avg_consumption_index", ""),
                    "avg_conversion_score": row.get("avg_conversion_score", ""),
                    **context,
                }
            )

    for row in time_rows:
        context = with_common_context(row, type_lookup, service_lookup, time_lookup)
        output.append(
            {
                "question_no": "Q6",
                "question_key": "time_slot_strong_pattern",
                "rank": get_rank(row),
                "time_slot": row.get("time_slot", ""),
                "dong_code": row.get("dong_code", ""),
                "dong_name": row.get("dong_name", ""),
                "metric_name": "avg_conversion_score",
                "metric_value": row.get("avg_conversion_score", ""),
                "avg_subway_inflow": row.get("avg_subway_inflow", ""),
                "avg_living_population": row.get("avg_living_population", ""),
                "avg_stay_index": row.get("avg_stay_index", ""),
                "avg_consumption_index": row.get("avg_consumption_index", ""),
                "avg_conversion_score": row.get("avg_conversion_score", ""),
                **context,
            }
        )

    for row in read_rows(results_dir, "dong_market_type.csv"):
        context = with_common_context(row, type_lookup, service_lookup, time_lookup)
        output.append(
            {
                "question_no": "Q7",
                "question_key": "dong_market_type",
                "rank": "",
                "time_slot": "",
                "dong_code": row.get("dong_code", ""),
                "dong_name": row.get("dong_name", ""),
                "metric_name": row.get("market_type", ""),
                "metric_value": row.get("avg_conversion_score", ""),
                "avg_subway_inflow": row.get("avg_subway_inflow", ""),
                "avg_living_population": row.get("avg_living_population", ""),
                "avg_stay_index": row.get("avg_stay_index", ""),
                "avg_consumption_index": row.get("avg_consumption_index", ""),
                "avg_conversion_score": row.get("avg_conversion_score", ""),
                **context,
            }
        )

    return output


def build_support_rows(results_dir, evidence_rows):
    rows = []
    for question_no, high_metric in [
        ("Q1", "subway_inflow"),
        ("Q2", "living_population"),
        ("Q3", "stay_index"),
        ("Q4", "consumption_index"),
        ("Q5", "conversion_score"),
    ]:
        candidates = [
            row
            for row in evidence_rows
            if row["question_no"] == question_no and row["rank"] == "1"
        ]
        for row in candidates:
            rows.append(
                {
                    "dong_code": row["dong_code"],
                    "dong_name": row["dong_name"],
                    "high_metric": high_metric,
                    "top_service_types": row["top_service_types"],
                    "dominant_time_slot": row["dominant_time_slot"],
                    "market_type": row["market_type"],
                    "market_type_label": row["market_type_label"],
                }
            )
    return rows


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", default="results_csv")
    args = parser.parse_args()

    results_dir = Path(args.results_dir)
    evidence_rows = build_question_answer_rows(results_dir)
    write_rows(results_dir / "question_answer_evidence.csv", EVIDENCE_COLUMNS, evidence_rows)
    write_rows(
        results_dir / "result_interpretation_support.csv",
        SUPPORT_COLUMNS,
        build_support_rows(results_dir, evidence_rows),
    )
    print("Evidence CSVs written to: {0}".format(results_dir))


if __name__ == "__main__":
    main()
