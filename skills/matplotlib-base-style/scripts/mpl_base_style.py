"""Reusable base-style helpers for matplotlib charts."""

from __future__ import annotations

from copy import deepcopy
from typing import Iterable, Mapping, Sequence

import matplotlib.pyplot as plt
import matplotlib.ticker as mticker

BASE_STYLE_PROFILE = {
    "name": "lavender-minimal-s01-fc",
    "style_id": "s01",
    "author": "fc",
    "figure": {
        # Keep a white outer canvas so exported figures have a clean frame.
        "face_color": "#FFFFFF",
    },
    "axes": {
        "face_color": "#E7E7F0",
        "grid": {
            "enabled": True,
            "color": "white",
            "linestyle": "-",
            "linewidth": 1.5,
            "axisbelow": True,
            "zorder": 0,
        },
        "spines": {
            "hide": ["top", "right", "left", "bottom"],
        },
        "ticks": {
            "length": 0,
            "labelsize": 14,
        },
        "locator": {
            "y_nbins": 6,
            "prune": "upper",
        },
    },
    "legend": {
        "loc": "upper left",
        "bbox_to_anchor": (-0.005, 1.00),
        "ncol": 1,
        "fontsize": 16,
        "frameon": True,
        "facecolor": "white",
        "edgecolor": "none",
        "framealpha": 0.8,
        "labelspacing": 0.4,
    },
    "export": {
        "format": "pdf",
        "dpi": 300,
        "bbox_inches": "tight",
        "pad_inches": 0.18,
        "tight_layout": True,
    },
}


def get_base_style_profile() -> dict:
    """Return a mutable copy of the default base-style profile."""
    return deepcopy(BASE_STYLE_PROFILE)


def create_figure(figsize: tuple[float, float] = (7, 4)):
    """Create a figure/axes pair with the requested figure size."""
    return plt.subplots(figsize=figsize)


def hide_spines(*axes, hide: Sequence[str] | None = None) -> None:
    """Hide selected spines on one or more axes."""
    hide = tuple(hide or ("top", "right", "left", "bottom"))
    for axis in axes:
        if axis is None:
            continue
        for spine_name, spine in axis.spines.items():
            if spine_name in hide:
                spine.set_visible(False)


def _as_mapping(profile: Mapping | None) -> Mapping:
    return profile or BASE_STYLE_PROFILE


def apply_base_style(
    ax,
    ax2=None,
    *,
    figure_face_color: str,
    face_color: str,
    grid_enabled: bool,
    grid_color: str,
    grid_linestyle: str,
    grid_linewidth: float,
    grid_axisbelow: bool,
    grid_zorder: float,
    hide_spines_list: Sequence[str],
    tick_length: float,
    tick_labelsize: float,
    y_nbins: int,
    prune: str,
) -> None:
    """Apply base non-data style settings to one or two axes."""
    # White outer frame around the plot area.
    ax.figure.patch.set_facecolor(figure_face_color)
    ax.set_facecolor(face_color)
    # Ensure grid is rendered below data artists.
    ax.set_axisbelow(grid_axisbelow)
    if grid_enabled:
        ax.grid(
            True,
            color=grid_color,
            linestyle=grid_linestyle,
            linewidth=grid_linewidth,
            zorder=grid_zorder,
        )

    hide_spines(ax, ax2, hide=hide_spines_list)

    ax.tick_params(axis="both", which="both", length=tick_length, labelsize=tick_labelsize)
    ax.yaxis.set_major_locator(mticker.MaxNLocator(nbins=y_nbins, prune=prune))

    if ax2 is not None:
        ax2.set_axisbelow(grid_axisbelow)
        ax2.tick_params(axis="y", which="both", length=tick_length, labelsize=tick_labelsize)
        ax2.yaxis.set_major_locator(mticker.MaxNLocator(nbins=y_nbins, prune=prune))


def apply_profile(ax, *, profile: Mapping | None = None, ax2=None) -> None:
    """Apply a style profile directly to one or two axes."""
    profile = _as_mapping(profile)
    figure_cfg = profile.get("figure", {})
    axes_cfg = profile.get("axes", {})
    grid_cfg = axes_cfg.get("grid", {})
    ticks_cfg = axes_cfg.get("ticks", {})
    locator_cfg = axes_cfg.get("locator", {})
    spines_cfg = axes_cfg.get("spines", {})

    apply_base_style(
        ax,
        ax2=ax2,
        figure_face_color=figure_cfg.get("face_color", "#FFFFFF"),
        face_color=axes_cfg.get("face_color", "#E7E7F0"),
        grid_enabled=grid_cfg.get("enabled", True),
        grid_color=grid_cfg.get("color", "white"),
        grid_linestyle=grid_cfg.get("linestyle", "-"),
        grid_linewidth=grid_cfg.get("linewidth", 1.5),
        grid_axisbelow=grid_cfg.get("axisbelow", True),
        grid_zorder=grid_cfg.get("zorder", 0),
        hide_spines_list=spines_cfg.get("hide", ("top", "right", "left", "bottom")),
        tick_length=ticks_cfg.get("length", 0),
        tick_labelsize=ticks_cfg.get("labelsize", 14),
        y_nbins=locator_cfg.get("y_nbins", 6),
        prune=locator_cfg.get("prune", "upper"),
    )


def style_legend(
    ax,
    handles: Sequence,
    labels: Sequence[str],
    *,
    profile: Mapping | None = None,
    loc: str | None = None,
    bbox_to_anchor: tuple[float, float] | None = None,
    fontsize: float | None = None,
) -> None:
    """Apply legend style from profile with optional local overrides."""
    profile = _as_mapping(profile)
    legend_cfg = profile.get("legend", {})

    ax.legend(
        handles,
        labels,
        loc=loc if loc is not None else legend_cfg.get("loc", "upper left"),
        bbox_to_anchor=(
            bbox_to_anchor
            if bbox_to_anchor is not None
            else tuple(legend_cfg.get("bbox_to_anchor", (-0.005, 1.00)))
        ),
        ncol=legend_cfg.get("ncol", 1),
        fontsize=fontsize if fontsize is not None else legend_cfg.get("fontsize", 16),
        frameon=legend_cfg.get("frameon", True),
        facecolor=legend_cfg.get("facecolor", "white"),
        edgecolor=legend_cfg.get("edgecolor", "none"),
        framealpha=legend_cfg.get("framealpha", 0.8),
        labelspacing=legend_cfg.get("labelspacing", 0.4),
    )


def merge_handles_labels(*line_groups: Iterable):
    """Return merged (handles, labels) tuple for legend creation."""
    handles = []
    for group in line_groups:
        handles.extend(group)
    labels = [line.get_label() for line in handles]
    return handles, labels


def finalize_figure(
    output_path: str | None = None,
    *,
    profile: Mapping | None = None,
    dpi: int | None = None,
) -> None:
    """Apply export settings and optionally save with consistent defaults."""
    profile = _as_mapping(profile)
    export_cfg = profile.get("export", {})

    if export_cfg.get("tight_layout", True):
        plt.tight_layout()

    if output_path:
        out_format = export_cfg.get("format", "pdf")
        save_dpi = dpi if dpi is not None else export_cfg.get("dpi", 300)
        bbox_inches = export_cfg.get("bbox_inches", "tight")
        pad_inches = export_cfg.get("pad_inches", 0.1)
        fig_face_color = profile.get("figure", {}).get("face_color", "#FFFFFF")
        plt.savefig(
            output_path,
            format=out_format,
            bbox_inches=bbox_inches,
            pad_inches=pad_inches,
            dpi=save_dpi,
            facecolor=fig_face_color,
        )
