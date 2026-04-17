# Demo Plot Iteration Notes

This demo exercises the plotting workflow with deterministic mock benchmark data.

## What was tested

- grouped bar chart for cross-task comparison
- tradeoff scatter for quality vs latency
- multi-line robustness curve with uncertainty bands

## First-pass findings

- `s01` works well as a clean non-data base style, especially for scatter and line charts.
- Tall legends become wasteful once the figure has 5 methods.
- Direct labels on sparse scatter plots need explicit axis margin planning.
- Uncertainty bands need to stay light enough that the main lines remain dominant.

## Changes applied after review

- moved grouped-bar and line-chart legends to compact top legends
- widened scatter limits slightly to protect right-side labels
- reduced uncertainty band opacity
- added these heuristics back into plotting skill docs

## Next iteration ideas

- add a benchmark-style theme layer on top of `s01` for categorical plots
- test grayscale robustness explicitly
- add one multi-panel figure to exercise panel alignment and shared legend rules
