---
name: latex-academic-table
description: Use when tasks involve creating, cleaning up, or optimizing LaTeX tables for papers, ablation studies, benchmark comparisons, or appendix material with attention to readability and publication style.
version: 0.1.0
---

# LaTeX Academic Table

## When to use
- Build tables for papers, reports, rebuttals, or appendices.
- Refactor messy LaTeX tabular environments into cleaner academic tables.
- Improve alignment, spacing, and readability in result tables or ablation summaries.
- Render `analysis/*.csv` outputs from `$analyze-results` into camera-ready LaTeX.

## Workflow
1. Start from the story the table tells.
   Decide whether the table compares methods, highlights gains, or summarizes settings.
2. Prefer academic table conventions.
   Use `booktabs`, avoid vertical rules, and keep visual weight on data rather than grid lines.
3. Align numbers intentionally.
   Use decimal alignment or fixed precision so comparisons are effortless.
4. Compress complexity before shrinking font size.
   Reorder columns, merge headers, or split tables before resorting to tiny text.
5. Validate in the final document context.
   Wide tables, caption length, and notes should be checked in the actual LaTeX layout.
6. Keep figure/table workflow aligned.
   Ensure generated table files match `$paper-figure` naming (`figures/TABLE_*.tex`).

## Quality bar
- The strongest comparison should be visually obvious.
- Header hierarchy should be readable without excessive lines or shading.
- Numeric precision should be consistent across comparable entries.
- Captions and notes should explain abbreviations and metrics succinctly.
- The table should feel publication-ready, not like a spreadsheet pasted into LaTeX.
