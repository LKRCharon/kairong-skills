---
name: matplotlib-base-style
description: Use when you want a fully decomposed, reusable matplotlib base style profile and helper functions that separate non-data styling from plotting logic.
version: 0.1.0
---

# Matplotlib Base Style

Build and reuse one completed base style decomposition for matplotlib figures.

## Intent

This skill treats figure style as a reusable contract:
- data logic stays in plotting code
- non-data styling lives in a single base style profile
- multi-figure projects keep visual consistency by default

## What counts as base style

Only non-data styling is part of the base style:
- figure and axes background
- grid visibility and grid stroke
- grid layer order relative to data marks
- spine visibility
- tick length and label size
- y-axis locator policy
- legend frame and placement defaults
- export defaults (format, dpi, bbox)

Keep domain semantics out of base style unless explicitly requested:
- thresholds
- annotations tied to model meaning
- axis ranges specific to one task

## Workflow

1. Decompose style from a reference figure or existing plot code.
   Write style facts into `references/style-profile.yaml`.
2. Apply style through helpers in `scripts/mpl_base_style.py`.
3. Keep plotting code focused on data and chart semantics.
4. Reuse the same profile across figures to enforce consistency.

For `s01`, enforce:
- white outer canvas around the chart
- lavender plotting area
- grid rendered at the bottom layer
- export with visible white padding (`pad_inches >= 0.15`)
- filled marks/bars are fully opaque by default (`alpha=1.0`)

## Naming Convention

Use `color-style-id-author` for completed base styles:
- `color`: dominant visual cue, for example `lavender`
- `style`: design character, for example `minimal`
- `id`: stable sequence token, for example `s01`
- `author`: fixed suffix, currently `fc`

Example: `lavender-minimal-s01-fc`

## Quick Use

```python
from scripts.mpl_base_style import (
    get_base_style_profile,
    create_figure,
    apply_profile,
    style_legend,
    finalize_figure,
)

profile = get_base_style_profile()
fig, ax = create_figure(figsize=(7, 4))
apply_profile(ax, profile=profile)

# draw data...
# handles, labels = ...
style_legend(ax, handles, labels, profile=profile)
finalize_figure("plot.pdf", profile=profile)
```

## Resources

- `references/style-profile.yaml`: completed base-style decomposition.
- `scripts/mpl_base_style.py`: reusable helpers to apply the profile.
