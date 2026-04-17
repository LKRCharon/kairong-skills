from __future__ import annotations

from pathlib import Path
import sys

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

REPO_ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = REPO_ROOT / "analysis" / "data" / "demo_benchmark_results.csv"
OUT_DIR = REPO_ROOT / "analysis" / "figures" / "demo_s01"
OUT_DIR.mkdir(parents=True, exist_ok=True)

sys.path.insert(0, str(REPO_ROOT / "skills" / "matplotlib-base-style"))
from scripts.mpl_base_style import get_base_style_profile, apply_profile, style_legend, finalize_figure

METHOD_ORDER = ["Baseline", "PromptTune", "RetrieverX", "GuardLM", "Ours"]
TASK_ORDER = ["QA", "Summarization", "Coding", "Agent"]
METHOD_COLORS = {
    "Baseline": "#A1A1AA",
    "PromptTune": "#4C78A8",
    "RetrieverX": "#72B7B2",
    "GuardLM": "#F58518",
    "Ours": "#E45756",
}
METHOD_MARKERS = {
    "Baseline": "o",
    "PromptTune": "s",
    "RetrieverX": "D",
    "GuardLM": "^",
    "Ours": "X",
}
WEBTHINKER_PAIR = {
    "PromptTune": {"face": "#9DC3E7", "hatch": "///"},
    "Ours": {"face": "#A9A6F6", "hatch": "xxx"},
}
WEBTHINKER_LINE = {
    "performance": "#8E2C33",
    "cost": "#3F6F9F",
}


def load_data() -> pd.DataFrame:
    df = pd.read_csv(DATA_PATH)
    numeric_cols = ["quality", "latency_ms", "robustness", "budget"]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")
    df["task"] = pd.Categorical(df["task"], categories=TASK_ORDER, ordered=True)
    df["method"] = pd.Categorical(df["method"], categories=METHOD_ORDER, ordered=True)
    return df.dropna(subset=["task", "method", "quality", "latency_ms", "robustness", "budget"]).copy()


def make_profile() -> dict:
    profile = get_base_style_profile()
    profile["export"]["format"] = "png"
    profile["export"]["dpi"] = 240
    profile["axes"]["ticks"]["labelsize"] = 11
    profile["legend"]["fontsize"] = 9
    return profile


def summarize_budget0(df: pd.DataFrame) -> pd.DataFrame:
    budget0 = df[df["budget"] == 0].copy()
    summary = (
        budget0.groupby(["task", "method"], observed=True, as_index=False)
        .agg(
            quality_mean=("quality", "mean"),
            quality_std=("quality", "std"),
            latency_mean=("latency_ms", "mean"),
            latency_std=("latency_ms", "std"),
            robustness_mean=("robustness", "mean"),
        )
    )
    summary["efficiency"] = summary["quality_mean"] / summary["latency_mean"]
    return summary


def summarize_budget_curve(df: pd.DataFrame) -> pd.DataFrame:
    curve = (
        df.groupby(["budget", "method"], observed=True, as_index=False)
        .agg(
            robustness_mean=("robustness", "mean"),
            robustness_std=("robustness", "std"),
        )
    )
    return curve


def plot_grouped_quality(summary: pd.DataFrame, profile: dict) -> None:
    fig, ax = plt.subplots(figsize=(9.4, 5.8))
    apply_profile(ax, profile=profile)

    width = 0.15
    x = np.arange(len(TASK_ORDER))
    for idx, method in enumerate(METHOD_ORDER):
        sub = summary[summary["method"] == method].sort_values("task")
        offset = (idx - 2) * width
        ax.bar(
            x + offset,
            sub["quality_mean"],
            width=width,
            yerr=sub["quality_std"].fillna(0.0),
            color=METHOD_COLORS[method],
            capsize=3,
            zorder=3,
            label=method,
        )

    ax.set_xticks(x)
    ax.set_xticklabels(TASK_ORDER)
    ax.set_ylabel("Task quality")
    ax.set_ylim(50, 88)
    ax.set_title("Benchmark Quality Across Tasks", fontsize=13, pad=10)

    handles, labels = ax.get_legend_handles_labels()
    style_legend(
        ax,
        handles,
        labels,
        profile=profile,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.02),
        fontsize=8.5,
    )
    legend = ax.get_legend()
    if legend is not None:
        legend.set_ncols(3)
    finalize_figure(str(OUT_DIR / "demo_fig1_grouped_quality_s01.png"), profile=profile)
    plt.close(fig)


def plot_webthinker_pattern_bar(summary: pd.DataFrame, profile: dict) -> None:
    fig, ax = plt.subplots(figsize=(5.4, 4.6))
    apply_profile(ax, profile=profile)

    focus = summary[
        summary["method"].isin(["PromptTune", "Ours"]) & summary["task"].isin(["QA", "Coding"])
    ].copy()
    focus["task"] = pd.Categorical(focus["task"].astype(str), categories=["QA", "Coding"], ordered=True)
    focus = focus.sort_values(["task", "method"])

    x = np.arange(2)
    width = 0.28
    methods = ["PromptTune", "Ours"]

    for idx, method in enumerate(methods):
        sub = focus[focus["method"] == method].sort_values("task")
        xpos = x + (idx - 0.5) * width
        face = WEBTHINKER_PAIR[method]["face"]
        hatch = WEBTHINKER_PAIR[method]["hatch"]

        ax.bar(
            xpos,
            sub["quality_mean"],
            width=width,
            color=face,
            edgecolor="#8B8B95",
            linewidth=0.8,
            zorder=3,
        )
        # White hatch overlay to mimic the paper-style patterned fill.
        ax.bar(
            xpos,
            sub["quality_mean"],
            width=width,
            color="none",
            edgecolor="white",
            linewidth=0.0,
            hatch=hatch,
            zorder=4,
        )
        ax.errorbar(
            xpos,
            sub["quality_mean"],
            yerr=sub["quality_std"].fillna(0.0),
            fmt="none",
            ecolor="#222222",
            elinewidth=1.0,
            capsize=3,
            zorder=5,
        )
        for px, py in zip(xpos, sub["quality_mean"]):
            ax.text(px, py + 0.55, f"{py:.1f}", ha="center", va="bottom", fontsize=9, color="#1E1E1E")

    ax.set_xticks(x)
    ax.set_xticklabels(["QA", "Coding"])
    ax.set_ylabel("Quality")
    ax.set_ylim(64, 85.5)
    ax.set_title("Patterned Pairwise Comparison", fontsize=12.5, pad=10)

    handles = [
        plt.Rectangle((0, 0), 1, 1, facecolor=WEBTHINKER_PAIR[m]["face"], edgecolor="white", hatch=WEBTHINKER_PAIR[m]["hatch"])
        for m in methods
    ]
    style_legend(
        ax,
        handles,
        methods,
        profile=profile,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.02),
        fontsize=8.5,
    )
    finalize_figure(str(OUT_DIR / "demo_fig4_webthinker_pattern_bar_s01.png"), profile=profile)
    plt.close(fig)


def plot_tradeoff_scatter(summary: pd.DataFrame, profile: dict) -> None:
    fig, ax = plt.subplots(figsize=(8.8, 6.1))
    apply_profile(ax, profile=profile)

    method_summary = (
        summary.groupby("method", observed=True, as_index=False)
        .agg(
            quality_mean=("quality_mean", "mean"),
            latency_mean=("latency_mean", "mean"),
            robustness_mean=("robustness_mean", "mean"),
        )
        .sort_values("quality_mean", ascending=False)
    )

    for _, row in method_summary.iterrows():
        method = row["method"]
        ax.scatter(
            row["latency_mean"],
            row["quality_mean"],
            s=220,
            color=METHOD_COLORS[method],
            marker=METHOD_MARKERS[method],
            edgecolor="white",
            linewidth=0.9,
            zorder=4,
        )
        ax.text(
            row["latency_mean"] + 18,
            row["quality_mean"] + 0.15,
            method,
            fontsize=9.5,
            color="#222222",
            weight="bold" if method == "Ours" else "normal",
        )

    ax.axvline(method_summary["latency_mean"].median(), color="#777777", linestyle="--", linewidth=1.0, zorder=1)
    ax.axhline(method_summary["quality_mean"].median(), color="#777777", linestyle="--", linewidth=1.0, zorder=1)
    ax.annotate(
        "Preferred region",
        xy=(930, 79.6),
        xytext=(1080, 75.3),
        arrowprops=dict(arrowstyle="->", linewidth=1.1, color="#333333"),
        fontsize=9.5,
        color="#222222",
    )
    ax.set_xlabel("Latency (ms, lower is better)")
    ax.set_ylabel("Average quality")
    ax.set_title("Quality-Latency Tradeoff by Method", fontsize=13, pad=10)
    ax.set_xlim(892, 1160)
    ax.set_ylim(64.2, 79.4)

    finalize_figure(str(OUT_DIR / "demo_fig2_tradeoff_scatter_s01.png"), profile=profile)
    plt.close(fig)


def plot_webthinker_dual_axis_panels() -> None:
    panel_specs = [
        {
            "title": "Layers $L$",
            "x": [2, 4, 6, 8],
            "performance": [89.5, 92.3, 92.5, 93.1],
            "cost": [0.55, 1.05, 1.82, 2.06],
            "perf_band": [0.9, 1.0, 0.9, 1.5],
            "cost_band": [0.12, 0.10, 0.16, 0.11],
        },
        {
            "title": "Penalty $\\lambda$",
            "x": [0.001, 0.005, 0.01, 0.05, 0.1],
            "xlabels": ["1e-3", "5e-3", "1e-2", "5e-2", "1e-1"],
            "performance": [93.0, 92.8, 91.7, 90.2, 89.4],
            "cost": [1.18, 1.16, 1.10, 0.94, 0.92],
            "perf_band": [0.8, 0.7, 1.1, 1.0, 0.9],
            "cost_band": [0.10, 0.11, 0.16, 0.13, 0.20],
        },
        {
            "title": "Samples $K$",
            "x": [2, 4, 6, 8],
            "performance": [89.5, 92.3, 91.2, 92.5],
            "cost": [1.02, 1.03, 1.02, 1.08],
            "perf_band": [1.1, 1.0, 0.7, 0.5],
            "cost_band": [0.10, 0.11, 0.10, 0.12],
        },
    ]

    fig, axes = plt.subplots(1, 3, figsize=(13.8, 4.9), sharey=False)

    for ax, spec in zip(axes, panel_specs):
        ax2 = ax.twinx()
        local_profile = get_base_style_profile()
        local_profile["figure"]["face_color"] = "#FFFFFF"
        local_profile["axes"]["face_color"] = "#FFFFFF"
        local_profile["axes"]["grid"]["enabled"] = False
        local_profile["axes"]["spines"]["hide"] = []
        local_profile["axes"]["ticks"]["labelsize"] = 10
        local_profile["legend"]["fontsize"] = 9
        apply_profile(ax, profile=local_profile, ax2=ax2)

        for spine in ax.spines.values():
            spine.set_visible(True)
            spine.set_color("#A8A8A8")
            spine.set_linewidth(0.8)
        for side, spine in ax2.spines.items():
            spine.set_visible(side == "right")
            if side == "right":
                spine.set_color("#A8A8A8")
                spine.set_linewidth(0.8)

        if "xlabels" in spec:
            x = np.arange(len(spec["x"]), dtype=float)
        else:
            x = np.array(spec["x"], dtype=float)
        perf = np.array(spec["performance"], dtype=float)
        cost = np.array(spec["cost"], dtype=float)
        perf_band = np.array(spec["perf_band"], dtype=float)
        cost_band = np.array(spec["cost_band"], dtype=float)

        ax.fill_between(x, perf - perf_band, perf + perf_band, color=WEBTHINKER_LINE["performance"], alpha=0.16, zorder=1)
        ax2.fill_between(x, cost - cost_band, cost + cost_band, color=WEBTHINKER_LINE["cost"], alpha=0.16, zorder=1)

        perf_line = ax.plot(
            x,
            perf,
            color=WEBTHINKER_LINE["performance"],
            marker="*",
            markersize=12,
            linewidth=1.8,
            zorder=4,
            label="Performance (Left Axis)",
        )[0]
        cost_line = ax2.plot(
            x,
            cost,
            color=WEBTHINKER_LINE["cost"],
            marker="s",
            markersize=7,
            linewidth=1.8,
            zorder=4,
            label="Cost per query (Right Axis)",
        )[0]

        handles = [perf_line, cost_line]
        labels = [h.get_label() for h in handles]
        style_legend(
            ax,
            handles,
            labels,
            profile=local_profile,
            loc="upper left",
            bbox_to_anchor=(0.02, 0.98),
            fontsize=8.5,
        )
        legend = ax.get_legend()
        if legend is not None and legend.get_frame() is not None:
            legend.get_frame().set_edgecolor("#D0D0D0")
            legend.get_frame().set_linewidth(0.8)

        if "xlabels" in spec:
            ax.set_xticks(x)
            ax.set_xticklabels(spec["xlabels"])
        else:
            ax.set_xticks(x)
        ax.set_title(spec["title"], fontsize=12, pad=8)
        ax.set_ylim(88, 95.4)
        ax2.set_ylim(0.6, 2.3)
        ax.tick_params(axis="both", labelsize=10, colors="#222222")
        ax2.tick_params(axis="y", labelsize=9, colors="#222222")

    finalize_figure(str(OUT_DIR / "demo_fig5_webthinker_dual_axis_panels.png"), profile={"figure": {"face_color": "#FFFFFF"}, "export": {"format": "png", "dpi": 240, "bbox_inches": "tight", "pad_inches": 0.18, "tight_layout": True}})
    plt.close(fig)


def plot_robustness_curve(curve: pd.DataFrame, profile: dict) -> None:
    fig, ax = plt.subplots(figsize=(9.0, 5.9))
    apply_profile(ax, profile=profile)

    for method in METHOD_ORDER:
        sub = curve[curve["method"] == method].sort_values("budget")
        x = sub["budget"].to_numpy()
        y = sub["robustness_mean"].to_numpy()
        yerr = sub["robustness_std"].fillna(0.0).to_numpy()
        color = METHOD_COLORS[method]

        ax.plot(
            x,
            y,
            color=color,
            marker=METHOD_MARKERS[method],
            linewidth=2.0 if method == "Ours" else 1.6,
            markersize=6.5,
            zorder=4 if method == "Ours" else 3,
            label=method,
        )
        ax.fill_between(
            x,
            y - yerr,
            y + yerr,
            color=color,
            alpha=0.10,
            zorder=2,
        )

    ax.set_xlabel("Perturbation budget")
    ax.set_ylabel("Robustness")
    ax.set_ylim(0.28, 0.90)
    ax.set_xticks([0, 1, 2, 3])
    ax.set_title("Robustness Improves with Larger Budget", fontsize=13, pad=10)
    handles, labels = ax.get_legend_handles_labels()
    style_legend(
        ax,
        handles,
        labels,
        profile=profile,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.02),
        fontsize=8.5,
    )
    legend = ax.get_legend()
    if legend is not None:
        legend.set_ncols(3)
    finalize_figure(str(OUT_DIR / "demo_fig3_robustness_curve_s01.png"), profile=profile)
    plt.close(fig)


def main() -> None:
    df = load_data()
    profile = make_profile()

    summary = summarize_budget0(df)
    curve = summarize_budget_curve(df)

    summary.to_csv(OUT_DIR / "demo_budget0_summary.csv", index=False)
    curve.to_csv(OUT_DIR / "demo_budget_curve_summary.csv", index=False)

    plot_grouped_quality(summary, profile)
    plot_tradeoff_scatter(summary, profile)
    plot_robustness_curve(curve, profile)
    plot_webthinker_pattern_bar(summary, profile)
    plot_webthinker_dual_axis_panels()

    print("rows:", len(df))
    print("tasks:", TASK_ORDER)
    print("methods:", METHOD_ORDER)
    print("output_dir:", OUT_DIR)


if __name__ == "__main__":
    main()
