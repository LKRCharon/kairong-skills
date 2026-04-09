---
name: python-research-plot
description: Use when tasks involve scientific plotting, publication-quality figures, experiment visualizations, or polishing charts in Python with strong attention to aesthetics, legibility, and export quality.
---

# Python Research Plot

## When to use
- Draw figures for papers, reports, posters, or academic slides.
- Refine existing Matplotlib, Seaborn, Plotly, or Pandas charts into cleaner publication-quality visuals.
- Standardize figure style across multiple experiments or subplots.

## Workflow
1. Clarify the figure's job before choosing a chart type.
   One figure should answer one question clearly.
2. Prefer deterministic Python code over manual editing.
   Use Matplotlib as the default base and bring in Seaborn only when it genuinely improves the result.
3. Establish the visual system early.
   Decide font sizes, line widths, marker sizes, tick density, and color palette before polishing details.
   If multi-figure consistency is required, use `$matplotlib-base-style` for non-data defaults.
4. Design for the final medium.
   Paper figures need print-safe sizing and grayscale robustness; slides can use stronger contrast and fewer annotations.
5. Export both editable and delivery formats when possible.
   Prefer PDF or SVG for vector output and PNG for quick review.

## Quality bar
- Titles, axes, legends, and annotations should be readable at the final display size.
- Avoid default Matplotlib styling when a more intentional style is needed.
- Use color sparingly and verify that meaning does not collapse in grayscale.
- Multi-panel figures should feel like one system, not a pile of unrelated plots.
- Final export should specify DPI or vector format intentionally, never by accident.
