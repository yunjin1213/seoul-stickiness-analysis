# -*- coding: utf-8 -*-
"""Create local report summaries and figures from exported result CSVs."""

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


QUESTION_LABELS = {
    "Q1": "지하철 하차 유입 TOP 10",
    "Q2": "생활인구 TOP 10",
    "Q3": "유입 대비 생활인구 TOP 10",
    "Q4": "생활인구 대비 매출 규모 TOP 10",
    "Q5": "종합 상권 경쟁력 TOP 10",
}

QUESTION_METRIC_LABELS = {
    "Q1": "평균 지하철 하차 유입",
    "Q2": "평균 생활인구",
    "Q3": "Stay Index",
    "Q4": "생활인구 대비 매출 규모",
    "Q5": "Conversion Score",
}

TYPE_ORDER = ["야간형", "종합형", "소비전환형", "유입형", "체류형", "일반형"]


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


def ensure_dirs(*paths):
    for path in paths:
        path.mkdir(parents=True, exist_ok=True)


def read_evidence(results_dir):
    path = results_dir / "question_answer_evidence.csv"
    if not path.exists():
        raise FileNotFoundError("Missing evidence CSV: {0}".format(path))
    df = pd.read_csv(path)
    numeric_columns = [
        "rank",
        "metric_value",
        "avg_subway_inflow",
        "avg_living_population",
        "avg_stay_index",
        "avg_consumption_index",
        "avg_conversion_score",
    ]
    for column in numeric_columns:
        df[column] = pd.to_numeric(df[column], errors="coerce")
    text_columns = [column for column in df.columns if column not in numeric_columns]
    df[text_columns] = df[text_columns].fillna("")
    return df


def save_question_top_summaries(df, summary_dir):
    top_rows = []
    for question_no in ["Q1", "Q2", "Q3", "Q4", "Q5"]:
        question_df = df[df["question_no"] == question_no].copy()
        question_df = question_df.sort_values("rank").head(10)
        question_df.to_csv(
            summary_dir / "{0}_top10.csv".format(question_no.lower()),
            index=False,
        )
        if not question_df.empty:
            top_rows.append(question_df.iloc[0])

    top_summary = pd.DataFrame(top_rows)
    top_summary.to_csv(summary_dir / "question_top_answers.csv", index=False)
    return top_summary


def save_time_slot_summary(df, summary_dir):
    q6 = df[df["question_no"] == "Q6"].copy()
    winners = q6[q6["rank"] == 1].sort_values("time_slot")
    winners.to_csv(summary_dir / "time_slot_winners.csv", index=False)
    return winners


def save_market_type_summary(df, summary_dir):
    q7 = df[df["question_no"] == "Q7"].copy()
    counts = (
        q7.groupby(["market_type", "market_type_label"], dropna=False)
        .size()
        .reset_index(name="dong_count")
        .sort_values("dong_count", ascending=False)
    )
    counts.to_csv(summary_dir / "market_type_counts.csv", index=False)
    return counts


def plot_horizontal_top10(question_df, question_no, figure_dir):
    plot_df = question_df.sort_values("rank").head(10).copy()
    if plot_df.empty:
        return
    plot_df = plot_df.sort_values("metric_value", ascending=True)

    fig, ax = plt.subplots(figsize=(10, 5.5))
    bars = ax.barh(plot_df["dong_name"], plot_df["metric_value"], color="#2f6f9f")
    ax.set_title(QUESTION_LABELS[question_no], fontsize=15, pad=14)
    ax.set_xlabel(QUESTION_METRIC_LABELS[question_no])
    ax.grid(axis="x", linestyle="--", alpha=0.35)

    for bar in bars:
        width = bar.get_width()
        ax.text(width, bar.get_y() + bar.get_height() / 2, " {0:,.1f}".format(width), va="center", fontsize=8)

    fig.tight_layout()
    fig.savefig(figure_dir / "{0}_top10.png".format(question_no.lower()), dpi=180)
    plt.close(fig)


def plot_time_slot_winners(winners, figure_dir):
    if winners.empty:
        return
    fig, ax = plt.subplots(figsize=(10, 5))
    bars = ax.bar(winners["time_slot"], winners["metric_value"], color="#6a8f3f")
    ax.set_title("시간대별 종합 경쟁력 1위", fontsize=15, pad=14)
    ax.set_xlabel("시간대")
    ax.set_ylabel("Conversion Score")
    ax.grid(axis="y", linestyle="--", alpha=0.35)

    for bar, label in zip(bars, winners["dong_name"]):
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


def plot_market_type_counts(counts, figure_dir):
    if counts.empty:
        return
    counts = counts.copy()
    counts["market_type_label"] = pd.Categorical(
        counts["market_type_label"], categories=TYPE_ORDER, ordered=True
    )
    counts = counts.sort_values("market_type_label")

    fig, ax = plt.subplots(figsize=(9, 5))
    bars = ax.bar(counts["market_type_label"].astype(str), counts["dong_count"], color="#9a5f7a")
    ax.set_title("행정동별 대표 상권 유형 분포", fontsize=15, pad=14)
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
    fig.savefig(figure_dir / "market_type_counts.png", dpi=180)
    plt.close(fig)


def print_console_summary(top_summary, time_winners, type_counts):
    print("== 질문별 1위 ==")
    for _, row in top_summary.iterrows():
        print(
            "{0} {1}: {2} ({3}={4:,.2f}, 유형={5}, 우세시간={6})".format(
                row["question_no"],
                row["question_key"],
                row["dong_name"],
                row["metric_name"],
                row["metric_value"],
                row.get("market_type_label", ""),
                row.get("dominant_time_slot", ""),
            )
        )

    print("\n== 시간대별 1위 ==")
    for _, row in time_winners.iterrows():
        print(
            "{0}: {1} (Conversion Score={2:,.2f}, 주요 업종={3})".format(
                row["time_slot"],
                row["dong_name"],
                row["metric_value"],
                row.get("top_service_types", ""),
            )
        )

    print("\n== 상권 유형 분포 ==")
    for _, row in type_counts.iterrows():
        print("{0}: {1}개".format(row["market_type_label"], int(row["dong_count"])))


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", default="results_csv")
    parser.add_argument("--summary-dir", default="summary_csv")
    parser.add_argument("--figure-dir", default="figures")
    parser.add_argument("--no-console", action="store_true")
    return parser.parse_args()


def main():
    args = parse_args()
    results_dir = Path(args.results_dir)
    summary_dir = Path(args.summary_dir)
    figure_dir = Path(args.figure_dir)

    configure_fonts()
    ensure_dirs(summary_dir, figure_dir)

    df = read_evidence(results_dir)
    top_summary = save_question_top_summaries(df, summary_dir)
    time_winners = save_time_slot_summary(df, summary_dir)
    type_counts = save_market_type_summary(df, summary_dir)

    for question_no in ["Q1", "Q2", "Q3", "Q4", "Q5"]:
        plot_horizontal_top10(df[df["question_no"] == question_no], question_no, figure_dir)
    plot_time_slot_winners(time_winners, figure_dir)
    plot_market_type_counts(type_counts, figure_dir)

    if not args.no_console:
        print_console_summary(top_summary, time_winners, type_counts)

    print("\nSummary CSVs written to: {0}".format(summary_dir))
    print("Figures written to: {0}".format(figure_dir))


if __name__ == "__main__":
    main()
