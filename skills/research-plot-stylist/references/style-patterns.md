# Style Patterns

Use these names and motifs to keep theme synthesis consistent.

## Common scientific themes

### benchmark-multiline
Use for paper figures comparing many methods across a shared x-axis.

Typical cues:
- 5 to 8 distinct series
- redundant color, marker, and linestyle encoding
- compact framed legend
- light dashed grid
- cleaned top and right spines
- shared visual grammar across panels

### minimalist-paper
Use for clean single-panel plots with restrained decoration.

Typical cues:
- few series
- muted but high-contrast palette
- minimal grid or no grid
- outside legend or direct labels
- no heavy annotation boxes

### ablation-compact
Use for dense result summaries where many conditions must fit in limited space.

Typical cues:
- compressed typography
- careful legend management
- small markers
- subtle grid
- strong ordering and grouping

### poster-vivid
Use for figures that need extra visual separation in presentations.

Typical cues:
- brighter accents
- larger fonts and markers
- stronger contrast
- simpler panel structure

## Naming rules

When creating a new theme name:
- describe the visual purpose rather than the exact paper source
- prefer names like `benchmark-multiline` over `style-1`
- keep names stable so they can be reused across chart types

## Adaptation rules

When applying a theme to a new chart family:
- preserve palette and typography first
- preserve spine and grid treatment second
- adapt chart-specific encodings last
- do not force line-plot markers into heatmaps or bars unless they truly apply
