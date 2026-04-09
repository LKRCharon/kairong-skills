---
name: paper-figure
description: Use when you need publication-quality, data-driven paper figures and LaTeX-ready figure/table snippets from analyzed CSV/JSON results.
---

# Paper Figure

Generate publication-quality figures from structured experiment results.

## When to use
- Produce final figures for paper sections, rebuttal, or appendix.
- Convert analysis outputs into reproducible plotting scripts plus PDF/PNG figures.
- Keep visual style consistent across multiple figures in the same paper.

## Core integration contract
- Use `$analyze-results` first when raw data is noisy or not yet aggregated.
- Use `$research-plot-stylist` to infer chart family and visual grammar.
- Use `$matplotlib-base-style` (`s01`) for non-data defaults and export consistency.
- Use `$python-research-plot` for final plotting code quality checks.
- Use `$latex-academic-table` for camera-ready table rendering.

## Workflow
1. Build a figure plan.
   Record ID, chart type, message, data source, and priority.
2. Create per-figure scripts.
   One script per figure (`gen_fig_<id>.py`) for easy reruns.
3. Enforce style consistency.
   Apply the same base profile and typography contract across all figures.
4. Generate LaTeX include snippets.
   Save snippets for direct insertion into paper sections.
5. Validate publication readiness.
   Check readability, grayscale robustness, and caption clarity.

## Recommended outputs
- `figures/gen_fig_*.py`
- `figures/*.pdf` (primary)
- `figures/*.png` (preview)
- `figures/latex_includes.tex`
- `figures/TABLE_*.tex` (when tables are generated)

## Quality bar
- Every figure is reproducible from script + data file.
- Figure styling is consistent across all panels.
- No chart title inside image for paper mode (title goes in caption).
- Axis labels are publication-friendly (not raw variable names).
- Legends never hide key signals.
- Figure and table captions are self-contained.

## References
- `references/figure-plan-template.md`
- `references/latex-snippet-template.tex`
