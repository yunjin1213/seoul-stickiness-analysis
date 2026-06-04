# -*- coding: utf-8 -*-
"""Create presentation-ready figures from Hive analysis result CSV files."""

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


MARKET_TYPE_LABELS = {
    "night_type": "야간형",
    "overall_type": "종합형",
    "consumption_type": "소비전환형",
    "inflow_type": "유입형",
    "stay_type": "체류형",
    "general_type": "일반형",
}

TIME_SLOT_ORDER = ["06_11", "11_14", "14_17", "17_21", "21_24"]

TOP_CHARTS = [
    {
        "input": "top_conversion_score.csv",
        "summary": "top_conversion_score_top10.csv",
        "figure": "top_conversion_score_top10.png",
        "metric": "avg_conversion_score",
        "title": "종합 경쟁력 TOP 10",
        "xlabel": "평균 Conversion Score",
    },
    {
        "input": "top_subway_inflow.csv",
        "summary": "top_subway_inflow_top10.csv",
        "figure": "top_subway_inflow_top10.png",
        "metric": "avg_subway_inflow",
        "title": "지하철 유입 TOP 10",
        "xlabel": "평균 지하철 하차량",
    },
    {
        "input": "top_living_population.csv",
        "summary": "top_living_population_top10.csv",
        "figure": "top_living_population_top10.png",
        "metric": "avg_living_population",
        "title": "생활인구 TOP 10",
        "xlabel": "평균 생활인구",
    },
    {
        "input": "top_stay_index.csv",
        "summary": "top_stay_index_top10.csv",
        "figure": "top_stay_index_top10.png",
        "metric": "avg_stay_index",
        "title": "Stay Index TOP 10",
        "xlabel": "지하철 유입 대비 생활인구 규모",
    },
    {
        "input": "top_consumption_index.csv",
        "summary": "top_consumption_index_top10.csv",
        "figure": "top_consumption_index_top10.png",
        "metric": "avg_consumption_index",
        "title": "Consumption Index TOP 10",
        "xlabel": "생활인구 대비 매출 규모",
    },
]


def configure_fonts() -> None:
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


def ensure_dirs(*paths: Path) -> None:
    for path in paths:
        path.mkdir(parents=True, exist_ok=True)


def read_csv(input_dir: Path, filename: str) -> pd.DataFrame:
    path = input_dir / filename
    if not path.exists():
        raise FileNotFoundError("Missing result CSV: {0}".format(path))
    return pd.read_csv(path)


def numeric_columns(df: pd.DataFrame, columns) -> pd.DataFrame:
    for column in columns:
        if column in df.columns:
            df[column] = pd.to_numeric(df[column], errors="coerce")
    return df


def dong_label(row: pd.Series) -> str:
    dong_name = str(row.get("dong_name", "")).strip()
    dong_code = str(row.get("dong_code", "")).strip()
    if dong_name and dong_name.lower() != "nan":
        return dong_name
    return dong_code


def save_horizontal_bar(
    df: pd.DataFrame,
    metric: str,
    title: str,
    xlabel: str,
    output_path: Path,
) -> None:
    plot_df = df.copy()
    plot_df["label"] = plot_df.apply(dong_label, axis=1)
    plot_df = plot_df.sort_values(metric, ascending=True)

    fig_height = max(4.5, 0.42 * len(plot_df) + 1.5)
    fig, ax = plt.subplots(figsize=(10, fig_height))
    bars = ax.barh(plot_df["label"], plot_df[metric], color="#2f6f9f")
    ax.set_title(title, fontsize=15, pad=14)
    ax.set_xlabel(xlabel)
    ax.grid(axis="x", linestyle="--", alpha=0.35)

    for bar in bars:
        width = bar.get_width()
        ax.text(
            width,
            bar.get_y() + bar.get_height() / 2,
            " {0:,.2f}".format(width),
            va="center",
            fontsize=9,
        )

    fig.tight_layout()
    fig.savefig(output_path, dpi=180)
    plt.close(fig)


def create_top_charts(input_dir: Path, figure_dir: Path, summary_dir: Path) -> None:
    numeric_fields = [
        "rank",
        "avg_subway_inflow",
        "avg_living_population",
        "avg_stay_index",
        "avg_consumption_index",
        "avg_conversion_score",
    ]

    for chart in TOP_CHARTS:
        df = read_csv(input_dir, chart["input"])
        df = numeric_columns(df, numeric_fields)
        top10 = df.sort_values("rank").head(10)
        top10.to_csv(summary_dir / chart["summary"], index=False)
        save_horizontal_bar(
            top10,
            chart["metric"],
            chart["title"],
            chart["xlabel"],
            figure_dir / chart["figure"],
        )


def create_time_slot_winners(input_dir: Path, figure_dir: Path, summary_dir: Path) -> None:
    df = read_csv(input_dir, "time_slot_pattern.csv")
    df = numeric_columns(
        df,
        [
            "rank",
            "avg_conversion_score",
            "avg_subway_inflow",
            "avg_living_population",
            "avg_stay_index",
            "avg_consumption_index",
        ],
    )
    winners = df[df["rank"] == 1].copy()
    winners["time_slot"] = pd.Categorical(
        winners["time_slot"], categories=TIME_SLOT_ORDER, ordered=True
    )
    winners = winners.sort_values("time_slot")
    winners["market_label"] = winners.apply(dong_label, axis=1)
    winners.to_csv(summary_dir / "time_slot_winners.csv", index=False)

    fig, ax = plt.subplots(figsize=(10, 5))
    bars = ax.bar(
        winners["time_slot"].astype(str),
        winners["avg_conversion_score"],
        color="#6a8f3f",
    )
    ax.set_title("시간대별 1위 행정동", fontsize=15, pad=14)
    ax.set_xlabel("시간대")
    ax.set_ylabel("평균 Conversion Score")
    ax.grid(axis="y", linestyle="--", alpha=0.35)

    for bar, label in zip(bars, winners["market_label"]):
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height(),
            label,
            ha="center",
            va="bottom",
            fontsize=9,
        )

    fig.tight_layout()
    fig.savefig(figure_dir / "time_slot_winners.png", dpi=180)
    plt.close(fig)


def create_market_type_distribution(
    input_dir: Path,
    figure_dir: Path,
    summary_dir: Path,
) -> None:
    df = read_csv(input_dir, "dong_market_type.csv")
    df["market_type_label"] = df["market_type"].map(MARKET_TYPE_LABELS).fillna(
        df["market_type"]
    )
    counts = (
        df.groupby(["market_type", "market_type_label"])
        .size()
        .reset_index(name="dong_count")
        .sort_values("dong_count", ascending=False)
    )
    counts.to_csv(summary_dir / "market_type_counts.csv", index=False)

    fig, ax = plt.subplots(figsize=(9, 5))
    bars = ax.bar(counts["market_type_label"], counts["dong_count"], color="#9a5f7a")
    ax.set_title("행정동 상권 유형 분포", fontsize=15, pad=14)
    ax.set_xlabel("상권 유형")
    ax.set_ylabel("행정동 수")
    ax.grid(axis="y", linestyle="--", alpha=0.35)

    for bar in bars:
        height = bar.get_height()
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            height,
            "{0}".format(int(height)),
            ha="center",
            va="bottom",
            fontsize=9,
        )

    fig.tight_layout()
    fig.savefig(figure_dir / "market_type_distribution.png", dpi=180)
    plt.close(fig)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Visualize Seoul stickiness Hive analysis results."
    )
    parser.add_argument("--input-dir", default="results_csv", help="Input CSV directory.")
    parser.add_argument("--figure-dir", default="figures", help="Output figure directory.")
    parser.add_argument(
        "--summary-dir", default="summary_csv", help="Output summary CSV directory."
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    input_dir = Path(args.input_dir)
    figure_dir = Path(args.figure_dir)
    summary_dir = Path(args.summary_dir)

    configure_fonts()
    ensure_dirs(figure_dir, summary_dir)

    create_top_charts(input_dir, figure_dir, summary_dir)
    create_time_slot_winners(input_dir, figure_dir, summary_dir)
    create_market_type_distribution(input_dir, figure_dir, summary_dir)

    print("Figures written to: {0}".format(figure_dir))
    print("Summary CSVs written to: {0}".format(summary_dir))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
