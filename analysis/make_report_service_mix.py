#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Create a report-ready service sales mix table for key dongs."""

import argparse
import os
import tempfile
from pathlib import Path

os.environ.setdefault(
    "MPLCONFIGDIR", os.path.join(tempfile.gettempdir(), "seoul_stickiness_matplotlib")
)

import matplotlib.pyplot as plt
from matplotlib import font_manager
import pandas as pd


DEFAULT_KEY_DONGS = [
    "역삼1동",
    "잠실6동",
    "여의동",
    "서교동",
    "방배2동",
    "불광1동",
    "제기동",
    "소공동",
    "가산동",
]


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", default="results_csv")
    parser.add_argument("--summary-dir", default="summary_csv")
    parser.add_argument("--figure-dir", default="figures")
    parser.add_argument(
        "--dongs",
        nargs="*",
        default=DEFAULT_KEY_DONGS,
        help="Dong names to include in report order.",
    )
    parser.add_argument(
        "--top-n",
        type=int,
        default=5,
        help="Number of service types to summarize per dong.",
    )
    return parser.parse_args()


def configure_fonts():
    font_candidates = [
        "AppleGothic",
        "NanumGothic",
        "Malgun Gothic",
        "Noto Sans CJK KR",
        "DejaVu Sans",
    ]
    installed_fonts = {font.name for font in font_manager.fontManager.ttflist}
    for font_name in font_candidates:
        if font_name in installed_fonts:
            plt.rcParams["font.family"] = font_name
            break
    else:
        plt.rcParams["font.family"] = "DejaVu Sans"
    plt.rcParams["axes.unicode_minus"] = False


def format_service_mix(rows):
    service_parts = []
    for _, row in rows.iterrows():
        ratio = float(row["service_sales_ratio"]) * 100
        service_parts.append("{0} {1:.1f}%".format(row["service_type"], ratio))
    return ", ".join(service_parts)


def build_report_table(service_mix, dongs, top_n):
    output_rows = []
    for dong in dongs:
        top_services = (
            service_mix[service_mix["dong_name"] == dong]
            .sort_values("service_rank")
            .head(top_n)
        )
        if top_services.empty:
            output_rows.append(
                {
                    "행정동": dong,
                    "상위 업종 및 매출 비중": "",
                    "비고": "dong_service_sales_mix.csv에서 해당 행정동을 찾지 못함",
                }
            )
            continue

        output_rows.append(
            {
                "행정동": dong,
                "상위 업종 및 매출 비중": format_service_mix(top_services),
                "비고": "",
            }
        )
    return pd.DataFrame(output_rows)


def save_report_table_image(report_table, figure_path):
    display_table = report_table[["행정동", "상위 업종 및 매출 비중"]].copy()

    fig_height = max(4.8, len(display_table) * 0.48 + 1.2)
    fig, ax = plt.subplots(figsize=(12, fig_height))
    ax.axis("off")
    ax.set_title("주요 행정동별 상위 업종 매출 비중", fontsize=16, pad=16)

    table = ax.table(
        cellText=display_table.values,
        colLabels=display_table.columns,
        cellLoc="left",
        colLoc="center",
        colWidths=[0.12, 0.82],
        loc="center",
    )
    table.auto_set_font_size(False)
    table.set_fontsize(9)
    table.scale(1, 1.35)

    for (row, col), cell in table.get_celld().items():
        cell.set_edgecolor("#d0d0d0")
        if row == 0:
            cell.set_facecolor("#f0f3f5")
            cell.set_text_props(weight="bold", ha="center")
        elif col == 0:
            cell.set_text_props(weight="bold", ha="center")

    fig.tight_layout()
    fig.savefig(figure_path, dpi=180, bbox_inches="tight")
    plt.close(fig)


def main():
    args = parse_args()
    results_dir = Path(args.results_dir)
    summary_dir = Path(args.summary_dir)
    figure_dir = Path(args.figure_dir)
    input_path = results_dir / "dong_service_sales_mix.csv"
    output_path = summary_dir / "report_key_dong_service_mix.csv"
    figure_path = figure_dir / "report_key_dong_service_mix.png"

    if not input_path.exists():
        raise FileNotFoundError("Missing input CSV: {0}".format(input_path))

    service_mix = pd.read_csv(input_path)
    required_columns = {
        "dong_name",
        "service_type",
        "service_rank",
        "service_sales_ratio",
    }
    missing_columns = required_columns - set(service_mix.columns)
    if missing_columns:
        raise ValueError(
            "Missing required columns in {0}: {1}".format(
                input_path, ", ".join(sorted(missing_columns))
            )
        )

    summary_dir.mkdir(parents=True, exist_ok=True)
    figure_dir.mkdir(parents=True, exist_ok=True)
    report_table = build_report_table(service_mix, args.dongs, args.top_n)
    report_table.to_csv(output_path, index=False, encoding="utf-8-sig")
    configure_fonts()
    save_report_table_image(report_table, figure_path)

    print(report_table.to_string(index=False))
    print("\nReport service mix CSV written to: {0}".format(output_path))
    print("Report service mix figure written to: {0}".format(figure_path))


if __name__ == "__main__":
    main()
