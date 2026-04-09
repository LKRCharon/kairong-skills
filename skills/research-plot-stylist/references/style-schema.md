# Style Schema

Use this schema only when the user explicitly wants to inspect, create, save, or tune a reusable theme.

## Minimal schema

```yaml
name: benchmark-multiline
intent: comparison-heavy scientific figure
suitable_for:
  - line
  - multi-panel
palette:
  series:
    - "#4C78A8"
    - "#F58518"
    - "#54A24B"
    - "#E45756"
    - "#B279A2"
    - "#FF9DA6"
markers: ["o", "s", "^", "D", "v", "X"]
linestyles: ["-", "--", "-.", ":", "-", "--"]
figure:
  width: 6.8
  height: 2.8
  dpi: 300
axes:
  despine_top: true
  despine_right: true
  grid: dashed-light
  tick_label_size: 9
  axis_label_size: 10
legend:
  location: lower right
  ncol: 2
  frame: true
notes:
  - use redundant encodings for grayscale readability
```
```

## Field guidance

### `name`
Short lowercase hyphenated theme name.

### `intent`
One sentence describing the visual purpose, such as comparison-heavy benchmark, minimalist methods figure, or dense ablation summary.

### `suitable_for`
List the chart families this theme fits well.

### `palette`
Use named subfields only when needed. Typical subfields:
- `series`
- `positive_negative`
- `sequential`
- `diverging`
- `accent`

### `markers` and `linestyles`
Include when multi-series line plots are likely. Omit when irrelevant.

### `figure`
Record only stable defaults such as width, height, dpi, constrained layout preference, or panel spacing tendencies.

### `axes`
Useful fields include:
- spine cleanup
- grid treatment
- tick label size
- axis label size
- tick rotation
- numeric formatting tendency

### `legend`
Useful fields include:
- location
- ncol
- frame
- fontsize
- inside_or_outside

### `notes`
Store brief, high-value rules that matter across figures.

## Authoring rules

- Keep the config short.
- Only include details that should persist across many figures.
- Do not add fields just because they exist.
- If a style is specific to one chart family, say so explicitly.

## Optional base-style block

Use `base_style` only when the user wants a fully decomposed, reusable matplotlib baseline.
This block should align with `$matplotlib-base-style` (`skills/matplotlib-base-style/references/style-profile.yaml`).

```yaml
base_style:
  name: "lavender-minimal-s01-fc"
  style_id: "s01"
  author: "fc"
  figure:
    face_color: "#FFFFFF"
  axes:
    face_color: "#E7E7F0"
    grid:
      enabled: true
      color: "white"
      linestyle: "-"
      linewidth: 1.5
      axisbelow: true
      zorder: 0
    spines:
      hide: ["top", "right", "left", "bottom"]
    ticks:
      length: 0
      labelsize: 14
    locator:
      y_nbins: 6
      prune: "upper"
  legend:
    loc: "upper left"
    bbox_to_anchor: [-0.005, 1.0]
    ncol: 1
    fontsize: 16
    frameon: true
    facecolor: "white"
    edgecolor: "none"
    framealpha: 0.8
    labelspacing: 0.4
  export:
    format: "pdf"
    dpi: 300
    bbox_inches: "tight"
    pad_inches: 0.18
    tight_layout: true
```

Mapping rule:
- keep `base_style` for non-data defaults only
- keep chart semantics (`palette`, `markers`, `linestyles`, chart-specific choices) in the main theme fields
- base-style naming should follow `color-style-id-author`, e.g. `lavender-minimal-s01-fc`
- for s01-like clean style, use white outer canvas + grid at bottom
