from __future__ import annotations

from pathlib import Path
import sys

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

REPO_ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = REPO_ROOT / "analysis" / "data" / "c4_attack_metrics.csv"
OUT_DIR = REPO_ROOT / "analysis" / "figures" / "s01"
OUT_DIR.mkdir(parents=True, exist_ok=True)

sys.path.insert(0, str(REPO_ROOT / "skills" / "matplotlib-base-style"))
from scripts.mpl_base_style import get_base_style_profile, apply_profile, style_legend, finalize_figure

ATTACK_COLORS = {
    "DIPPER": "#4C78A8",
    "SIRA": "#F58518",
    "RW": "#54A24B",
    "SA": "#E45756",
    "JSV": "#B279A2",
}


def main() -> None:
    df = pd.read_csv(DATA_PATH)
    df["ASR (Avg)"] = pd.to_numeric(df["ASR (Avg)"], errors="coerce")
    df["PPL_Attacked (Avg)"] = pd.to_numeric(df["PPL_Attacked (Avg)"], errors="coerce")
    df = df.dropna(subset=["Attack", "ASR (Avg)", "PPL_Attacked (Avg)"]).copy()

    summary = (
        df.groupby("Attack", as_index=False)
        .agg(
            n=("Attack", "size"),
            asr_mean=("ASR (Avg)", "mean"),
            asr_std=("ASR (Avg)", "std"),
            ppl_mean=("PPL_Attacked (Avg)", "mean"),
            ppl_std=("PPL_Attacked (Avg)", "std"),
        )
        .sort_values("asr_mean", ascending=False)
    )
    summary.to_csv(OUT_DIR / "attack_asr_ppl_summary_s01.csv", index=False)

    profile = get_base_style_profile()
    profile["export"]["format"] = "png"
    profile["export"]["dpi"] = 240
    profile["axes"]["ticks"]["labelsize"] = 11
    profile["legend"]["fontsize"] = 10

    fig, ax = plt.subplots(figsize=(9.0, 6.2))
    apply_profile(ax, profile=profile)

    for attack, sub in df.groupby("Attack"):
        color = ATTACK_COLORS.get(attack, "#4B4B4B")
        ax.scatter(
            sub["PPL_Attacked (Avg)"],
            sub["ASR (Avg)"],
            s=56,
            color=color,
            alpha=1.0,
            edgecolor="white",
            linewidth=0.6,
            zorder=3,
        )

    for _, row in summary.iterrows():
        attack = row["Attack"]
        color = ATTACK_COLORS.get(attack, "#4B4B4B")
        ax.errorbar(
            row["ppl_mean"],
            row["asr_mean"],
            xerr=row["ppl_std"] if pd.notna(row["ppl_std"]) else 0.0,
            yerr=row["asr_std"] if pd.notna(row["asr_std"]) else 0.0,
            fmt="none",
            ecolor=color,
            elinewidth=1.2,
            capsize=3,
            zorder=4,
        )
        ax.scatter(
            row["ppl_mean"],
            row["asr_mean"],
            marker="X",
            s=220,
            color=color,
            edgecolor="black",
            linewidth=0.8,
            zorder=5,
        )
        ax.text(
            row["ppl_mean"] + 0.9,
            row["asr_mean"] + 0.015,
            attack,
            fontsize=10,
            weight="bold",
            color="#1E1E1E",
            zorder=6,
        )

    median_ppl = df["PPL_Attacked (Avg)"].median()
    median_asr = df["ASR (Avg)"].median()
    ax.axvline(median_ppl, color="#7D7D7D", linestyle="--", linewidth=1.0, zorder=1)
    ax.axhline(median_asr, color="#7D7D7D", linestyle="--", linewidth=1.0, zorder=1)

    ax.set_xlabel("PPL_Attacked (lower is better)")
    ax.set_ylabel("ASR (higher is stronger)")

    handles = [
        Line2D(
            [],
            [],
            marker="o",
            linestyle="",
            markersize=8,
            color=ATTACK_COLORS.get(a, "#4B4B4B"),
            label=a,
        )
        for a in sorted(df["Attack"].unique())
    ]
    labels = [h.get_label() for h in handles]
    style_legend(
        ax,
        handles,
        labels,
        profile=profile,
        loc="lower right",
        bbox_to_anchor=(1.0, 0.02),
        fontsize=9,
    )

    out_path = OUT_DIR / "fig_asr_ppl_tradeoff_s01_current.png"
    finalize_figure(str(out_path), profile=profile)
    plt.close(fig)

    print("rows:", len(df))
    print("attacks:", sorted(df["Attack"].unique().tolist()))
    print("output:", out_path)


if __name__ == "__main__":
    main()
