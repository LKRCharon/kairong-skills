---
name: analyze-results
description: Use when you need to analyze experiment results from CSV/JSON, compute comparisons and deltas, rank methods, and prepare clean outputs for plotting and LaTeX tables.
version: 0.1.0
---

# Analyze Results

Analyze experiment results and produce plot-ready and table-ready artifacts.

## When to use
- Compare multiple models, attacks, ablations, or settings.
- Build a reliable baseline-vs-variant summary before plotting.
- Convert noisy raw logs into ranked conclusions with reproducible tables.

## Inputs
- One or more result files: CSV / JSON / JSONL.
- Optional primary metric direction (`higher_better` or `lower_better`).
- Optional grouping keys (for example: dataset, model, attack, watermark).

## Workflow
1. Normalize the schema.
   Align column names, coerce numeric columns, and report missing values explicitly.
2. Build comparison views.
   Create grouped summaries (mean, std, count) and delta-vs-baseline columns.
3. Rank and stress-check.
   Rank by primary metric, then check whether ranking changes under secondary metrics.
4. Output reproducible artifacts.
   Save machine-friendly CSVs plus a concise markdown report.
5. Prepare downstream handoff.
   Mark which tables feed `$paper-figure` and which can be rendered by `$latex-academic-table`.

## Recommended outputs
- `analysis/tables/summary.csv`
- `analysis/tables/ranking.csv`
- `analysis/tables/delta_vs_baseline.csv`
- `analysis/ANALYSIS_REPORT.md`

## Quality bar
- Every claim has exact numbers and a source table row.
- Baseline definition is explicit and stable.
- Mean and variance are both shown when multiple runs exist.
- Missing or invalid rows are listed, not silently dropped.
- Result files are directly reusable by plotting and LaTeX workflows.

## Integration
- Use `$paper-figure` after this skill to generate publication plots.
- Use `$latex-academic-table` to convert summary outputs into camera-ready tables.
