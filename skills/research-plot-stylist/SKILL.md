---
name: research-plot-stylist
description: scientific plotting workflow for learning visual style from reference figures and generating python plotting code. use when the user wants to mimic the style of a paper figure, infer a reusable theme from one or more plot images, name or refine a plotting style, or generate matplotlib or seaborn code for line, bar, scatter, heatmap, grouped comparison, or multi-panel scientific figures with low-friction defaults.
---

# Research Plot Stylist

Generate publication-style Python plotting code with minimal user burden.

## Default behavior

Assume the user's main goal is runnable plotting code, not an analysis report.

Unless the user explicitly asks for analysis, debugging notes, or configuration details:
- inspect the provided reference figure or style name
- choose a sensible plotting library automatically
- generate code first
- keep explanations short and practical

Prefer these libraries in order:
1. `matplotlib` for paper-style control and multi-panel figures
2. `seaborn` when it simplifies statistical plots, but still return code that remains easy to customize
3. avoid interactive libraries unless the user asks for them

## Workflow

### 1. Determine the mode

Choose exactly one primary mode, while reusing outputs from earlier stages internally.

**Single-image analysis**
- Trigger when the user uploads one reference figure and wants code in a similar style.
- Extract the visual rules mentally, then go straight to code by default.
- Only surface the extracted rules if the user asks.

**Multi-image theme synthesis**
- Trigger when the user provides several reference figures and wants a common style or a named theme.
- Infer the shared visual grammar.
- If asked to save or document the theme, structure it using `references/style-schema.md`.

**Style-driven code generation**
- Trigger when the user provides data, a style name, a target chart type, or a request like “plot this in a nature-like / benchmark / minimalist style”.
- Reuse an existing named theme when possible.
- If no explicit theme is supplied, infer one from the request and choose sensible defaults.

### 2. Infer the chart specification

Before writing code, decide:
- chart type
- mapping of variables to axes, hue, groups, annotations, and panels
- whether the figure is single-panel or multi-panel
- what visual emphasis matters most: comparison, trend, distribution, uncertainty, ranking, or correlation

If the user underspecifies details, make grounded assumptions and encode them clearly in the code as editable variables.

### 3. Infer the style

Use the reference figure or style request to infer as many of these attributes as possible:
- figure layout and aspect ratio
- panel arrangement
- palette and accent colors
- line widths, marker choices, and linestyle rules
- bar edge behavior and fill opacity
- grid visibility and spine cleanup
- legend placement and number of columns
- typography scale and weight hierarchy
- tick density and numeric formatting
- annotation style
- whitespace and margins

For scientific figures, strongly prefer readability over decoration.

## Low-friction defaults

When the user does not specify a style, use these defaults:
- clean white background
- subtle grid or no grid depending on chart density
- top and right spines removed unless a boxed style is clearly implied
- moderate font sizes suitable for papers and slides
- high-contrast colors for multi-series comparisons
- marker plus linestyle redundancy when multiple lines must remain distinguishable in grayscale printing
- legends inside the axes only when there is obvious empty space

When recreating a benchmark-style multi-line figure, prefer:
- distinct colors plus distinct markers
- limited but visible linestyle variation
- compact legend with frame
- restrained dashed gridlines
- panels with matching scales when the comparison benefits from direct visual alignment

## Output rules

### Default output

Return:
1. a short one-line summary of what the code will produce
2. runnable Python code in one code block
3. a very short note on where to swap in the user's data or labels when needed

Do not prepend a long style report unless the user asks for it.

### When to include style analysis

Include a style analysis section only when the user asks to:
- explain the detected style
- compare multiple reference figures
- document or save a reusable theme
- refine a theme manually

When analysis is requested, summarize:
- composition and layout
- palette
- typography
- axis and grid treatment
- legend strategy
- chart-specific styling cues
- likely reusable theme name

### When to emit a style configuration

Emit an explicit configuration only when the user asks to create, save, tune, or inspect a named theme.

Use the structure in `references/style-schema.md` and keep the config concise. Include only fields supported by the current figure family.

## Theme handling

Treat a theme as a reusable visual contract, not merely a color palette.

A theme may include:
- palette
- typography scale
- axes and spine rules
- legend rules
- grid rules
- chart-type-specific defaults
- panel layout tendencies

When the user asks for a new named style:
1. infer common style traits from the references
2. normalize them into the schema in `references/style-schema.md`
3. name the theme descriptively and simply
4. explain where that theme works well and where it does not

## Chart family guidance

### Line plots
Prioritize line contrast, marker readability, and sensible legend compression. For dense comparisons, use redundant encodings and avoid overly saturated backgrounds.

### Bar and grouped bar plots
Keep category ordering clear. Use restrained edge styling. Prefer direct labeling or compact legends when there are only a few groups.

### Scatter plots
Use alpha, point size, and edge behavior carefully to manage overplotting. Add trend lines only when asked or clearly helpful.

### Heatmaps
Use perceptually sensible colormaps, readable annotation contrast, and careful aspect handling. Do not default to rainbow maps.

### Multi-panel figures
Keep visual grammar consistent across panels unless the user explicitly wants contrast. Align scales where comparison is the point.

## Code quality rules

Always generate code that:
- runs as a single script unless the user requests a module
- imports only what it needs
- makes key user-editable inputs easy to find near the top
- uses descriptive variable names
- avoids hard-coding data when the user already provided a table or arrays in another form
- comments only the non-obvious parts

When data is missing, provide a clearly labeled placeholder dataset that matches the requested chart type, so the structure is still runnable.

## References

Consult these files when needed:
- `references/style-schema.md` for the theme/config structure
- `references/style-patterns.md` for recurring scientific figure motifs and naming conventions
