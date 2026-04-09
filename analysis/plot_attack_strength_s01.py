from __future__ import annotations

from pathlib import Path
import sys

import numpy as np
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


def minmax(series: pd.Series) -> pd.Series:
    s = pd.to_numeric(series, errors="coerce")
    smin, smax = s.min(), s.max()
    if pd.isna(smin) or pd.isna(smax) or np.isclose(smax, smin):
        return pd.Series(np.full(len(s), 0.5), index=s.index)
    return (s - smin) / (smax - smin)


def model_short(name: str) -> str:
    if "Qwen" in name:
        return "Qwen2.5-7B"
    if "Llama" in name:
        return "Llama-3.1-8B"
    if "Mistral" in name:
        return "Mistral-7B"
    return name


def main() -> None:
    df = pd.read_csv(DATA_PATH)

    numeric_cols = [
        "ASR (Avg)",
        "TPR_Before (Avg)",
        "TPR_After (Avg)",
        "PPL_Attacked (Avg)",
        "BERTScore (Avg)",
        "BLEU (Avg)",
    ]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    df = df.dropna(subset=["ASR (Avg)", "TPR_After (Avg)", "PPL_Attacked (Avg)"]).copy()
    df["Model_Short"] = df["Model"].map(model_short)

    # Strength dimensions: ASR↑, bypass↑(=1-TPR_After), fluency-preserving↑(=low PPL)
    df["ASR_norm"] = minmax(df["ASR (Avg)"])
    df["Bypass"] = 1 - df["TPR_After (Avg)"]
    df["PPL_good"] = 1 - minmax(df["PPL_Attacked (Avg)"])
    df["Attack_Strength_Index"] = 0.50 * df["ASR_norm"] + 0.35 * df["Bypass"] + 0.15 * df["PPL_good"]

    attack_summary = (
        df.groupby("Attack", as_index=False)
        .agg(
            n=("Attack", "size"),
            ASR_mean=("ASR (Avg)", "mean"),
            TPR_After_mean=("TPR_After (Avg)", "mean"),
            PPL_mean=("PPL_Attacked (Avg)", "mean"),
            ASI_mean=("Attack_Strength_Index", "mean"),
            ASI_std=("Attack_Strength_Index", "std"),
        )
        .sort_values("ASI_mean", ascending=False)
    )
    attack_summary.to_csv(OUT_DIR / "attack_summary_s01.csv", index=False)

    top_configs = (
        df[["Attack", "Model_Short", "Watermark", "ASR (Avg)", "TPR_After (Avg)", "PPL_Attacked (Avg)", "Attack_Strength_Index"]]
        .sort_values("Attack_Strength_Index", ascending=False)
        .head(10)
    )
    top_configs.to_csv(OUT_DIR / "top10_configs_by_asi_s01.csv", index=False)

    profile = get_base_style_profile()
    profile["export"]["format"] = "png"
    profile["export"]["dpi"] = 220
    profile["axes"]["ticks"]["labelsize"] = 11
    profile["legend"]["fontsize"] = 10

    # Figure 1: ASR vs PPL tradeoff
    fig, ax = plt.subplots(figsize=(8.8, 6.2))
    fig.patch.set_facecolor(profile["figure"]["face_color"])
    apply_profile(ax, profile=profile)

    for attack, sub in df.groupby("Attack"):
        ax.scatter(
            sub["PPL_Attacked (Avg)"],
            sub["ASR (Avg)"],
            s=55,
            alpha=1.0,
            color=ATTACK_COLORS.get(attack, "#444444"),
            edgecolor="white",
            linewidth=0.5,
            zorder=3,
        )

    centroids = df.groupby("Attack", as_index=False).agg(
        ppl=("PPL_Attacked (Avg)", "mean"),
        asr=("ASR (Avg)", "mean"),
    )
    for _, row in centroids.iterrows():
        atk = row["Attack"]
        ax.scatter(row["ppl"], row["asr"], s=220, marker="X", color=ATTACK_COLORS.get(atk, "#111111"), edgecolor="black", linewidth=0.8, zorder=4)
        ax.text(row["ppl"] + 0.9, row["asr"] + 0.015, atk, fontsize=10, weight="bold")

    ax.set_title("Attack Tradeoff: ASR vs Attacked PPL (c4)", fontsize=14, pad=10)
    ax.set_xlabel("PPL_Attacked (lower is better)")
    ax.set_ylabel("ASR (higher is stronger)")
    ax.axvline(df["PPL_Attacked (Avg)"].median(), color="#888", linestyle="--", linewidth=1.0)
    ax.axhline(df["ASR (Avg)"].median(), color="#888", linestyle="--", linewidth=1.0)
    ax.annotate(
        "Stronger + better quality region",
        xy=(df["PPL_Attacked (Avg)"].quantile(0.12), df["ASR (Avg)"].quantile(0.90)),
        xytext=(df["PPL_Attacked (Avg)"].quantile(0.42), df["ASR (Avg)"].quantile(0.75)),
        arrowprops=dict(arrowstyle="->", linewidth=1.2, color="#333"),
        fontsize=10,
        color="#222",
    )

    handles = [
        Line2D([], [], marker="o", linestyle="", markersize=8, color=ATTACK_COLORS.get(a, "#444"), label=a)
        for a in sorted(df["Attack"].unique())
    ]
    labels = [h.get_label() for h in handles]
    style_legend(ax, handles, labels, profile=profile, loc="lower right", bbox_to_anchor=(1.0, 0.02), fontsize=9)
    finalize_figure(str(OUT_DIR / "fig1_asr_ppl_tradeoff_s01.png"), profile=profile)
    plt.close(fig)

    # Figure 2: attack strength index ranking
    fig, ax = plt.subplots(figsize=(8.6, 5.8))
    fig.patch.set_facecolor(profile["figure"]["face_color"])
    apply_profile(ax, profile=profile)

    xs = np.arange(len(attack_summary))
    colors = [ATTACK_COLORS.get(a, "#666") for a in attack_summary["Attack"]]
    ax.bar(xs, attack_summary["ASI_mean"], yerr=attack_summary["ASI_std"].fillna(0.0), color=colors, alpha=1.0, capsize=4)
    ax.set_xticks(xs)
    ax.set_xticklabels(attack_summary["Attack"], fontsize=11)
    ax.set_ylabel("Attack Strength Index (higher is stronger)")
    ax.set_title("Attack Strength Ranking (ASI = 0.50*ASR + 0.35*(1-TPR_After) + 0.15*low-PPL)", fontsize=12, pad=10)

    for i, v in enumerate(attack_summary["ASI_mean"]):
        ax.text(i, v + 0.012, f"{v:.3f}", ha="center", va="bottom", fontsize=9)

    finalize_figure(str(OUT_DIR / "fig2_attack_strength_index_s01.png"), profile=profile)
    plt.close(fig)

    # Figure 3: normalized component profile by attack
    comp = attack_summary.copy()
    comp["ASR_strength"] = minmax(comp["ASR_mean"])
    comp["Bypass_strength"] = minmax(1 - comp["TPR_After_mean"])
    comp["Fluency_strength"] = minmax(1 - minmax(comp["PPL_mean"]))

    fig, ax = plt.subplots(figsize=(9.2, 5.9))
    fig.patch.set_facecolor(profile["figure"]["face_color"])
    apply_profile(ax, profile=profile)

    w = 0.22
    x = np.arange(len(comp))
    ax.bar(x - w, comp["ASR_strength"], width=w, label="ASR strength", color="#2E6FBB", alpha=1.0)
    ax.bar(x, comp["Bypass_strength"], width=w, label="Bypass strength (1-TPR_After)", color="#E07A3F", alpha=1.0)
    ax.bar(x + w, comp["Fluency_strength"], width=w, label="Fluency strength (low PPL)", color="#3A9D5D", alpha=1.0)

    ax.set_xticks(x)
    ax.set_xticklabels(comp["Attack"], fontsize=11)
    ax.set_ylim(0, 1.05)
    ax.set_ylabel("Normalized strength (0-1)")
    ax.set_title("Strength Components by Attack", fontsize=13, pad=10)

    handles, labels = ax.get_legend_handles_labels()
    style_legend(ax, handles, labels, profile=profile, loc="upper right", bbox_to_anchor=(1.0, 1.0), fontsize=9)
    finalize_figure(str(OUT_DIR / "fig3_strength_components_s01.png"), profile=profile)
    plt.close(fig)

    print("rows:", len(df))
    print("attacks:", sorted(df["Attack"].unique().tolist()))
    print("best_attack_by_ASI:", attack_summary.iloc[0]["Attack"], round(float(attack_summary.iloc[0]["ASI_mean"]), 4))
    print("worst_attack_by_ASI:", attack_summary.iloc[-1]["Attack"], round(float(attack_summary.iloc[-1]["ASI_mean"]), 4))
    print("output_dir:", OUT_DIR)


if __name__ == "__main__":
    main()
