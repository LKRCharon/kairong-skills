# Style Card Schema

Use this schema for distilled, reusable style knowledge.

## Required fields
- `style_name`: short, stable identifier
- `source_type`: one of `paper_figure | diagram | slides | frontend | mixed`
- `usage_domain`: list of target domains
- `layout`: composition and spacing signals
- `typography`: hierarchy and ratio signals
- `color`: palette role constraints
- `shape`: line, radius, marker preferences
- `impression`: 2-5 adjectives describing tone
- `dos`: concrete rules to follow
- `donts`: concrete rules to avoid

## Optional fields
- `metadata`: author/date/version
- `annotation`: caption style, label density, callout pattern
- `bar`: fill pairing, hatch usage, edge treatment, direct-label strategy
- `line`: marker pairing, band opacity, dual-axis treatment
- `legend`: placement, frame contrast, icon scale, spacing
- `export`: preferred size, dpi, file formats
- `notes`: short rationale

## Minimal YAML example
```yaml
style_name: clean-academic-scatter-v1
source_type: paper_figure
usage_domain:
  - research_plot
layout:
  density: medium
  whitespace: tight
  alignment: grid
typography:
  title_weight: semibold
  label_size_ratio: 1.15
  tick_size_ratio: 0.9
color:
  palette_type: muted
  accent_count: 1
  contrast: medium
shape:
  corner_radius: low
  line_width: thin
  marker_style: restrained
impression:
  - formal
  - clean
  - publication-ready
dos:
  - keep legends compact
  - keep background white
donts:
  - avoid decorative gradients
  - avoid oversized titles
```
