# kairong-skills

Personal skill collection for aesthetic-heavy workflows in research and engineering.

This repository stores my reusable Codex skills, focused on:
- Python scientific plotting and publication-ready figure polishing
- Research slide and PPT visual storytelling
- Frontend design with strong visual direction
- LaTeX table design for academic papers

These tasks involve subjective visual judgment, so they are better captured as personal skills than generic open-source defaults.

## Design Principles

- Aesthetic first: outputs should be functional and visually intentional.
- Reproducible: script repeatable steps whenever possible.
- Progressive disclosure: keep `SKILL.md` concise and move details into `references/`, `scripts/`, and `assets/`.
- Personal taste matters: optimized for my own research and engineering workflow, not "one-size-fits-all."

## Repository Layout

```text
kairong-skills/
├── README.md
├── .gitignore
├── scripts/
│   └── new_skill.sh
├── templates/
│   └── SKILL.template.md
└── skills/
    ├── matplotlib-base-style/
    │   ├── SKILL.md
    │   ├── agents/openai.yaml
    │   ├── references/
    │   │   └── style-profile.yaml
    │   └── scripts/
    │       └── mpl_base_style.py
    ├── python-research-plot/
    │   └── SKILL.md
    ├── research-plot-stylist/
    │   ├── SKILL.md
    │   ├── agents/openai.yaml
    │   └── references/
    │       ├── style-schema.md
    │       └── style-patterns.md
    ├── cs-resume-builder/
    │   ├── SKILL.md
    │   ├── agents/openai.yaml
    │   ├── references/
    │   │   ├── input-format.md
    │   │   ├── role-emphasis.md
    │   │   ├── theme-kairong-clean-blue.md
    │   │   └── tailoring-rubric.md
    │   └── assets/
    │       ├── resume-template-kairong-clean.html
    │       └── resume-template.html
    ├── research-ppt-figure/
    │   └── SKILL.md
    ├── web-frontend-aesthetic/
    │   └── SKILL.md
    └── latex-academic-table/
        └── SKILL.md
```

## Initial Skills

### `research-plot-stylist`
Learns style from one or more scientific reference figures and generates runnable Python plotting code (mainly Matplotlib/Seaborn) with low-friction defaults.

### `matplotlib-base-style`
Stores one fully decomposed non-data matplotlib baseline (background, grid, spines, ticks, legend, export) and applies it consistently via reusable helper functions.
Current baseline profile: `lavender-minimal-s01-fc`.

### `cs-resume-builder`
Turns markdown profile and project notes into tailored Chinese and English resume HTML, with Tailwind-based styling, project selection against job descriptions, and PDF-ready output when needed.

### `python-research-plot`
General-purpose publication and presentation plotting skill for Python, with emphasis on clarity, consistency, and export quality.

### `research-ppt-figure`
For research talk visuals, method diagrams, concept figures, and slide storytelling with strong layout hierarchy.

### `web-frontend-aesthetic`
For frontend pages and prototypes where distinct visual direction and taste matter more than template-safe output.

### `latex-academic-table`
For paper tables, ablation tables, and benchmark comparisons with clean `booktabs`-style formatting and readable numeric alignment.

## Recommended Plot Workflow

For stable research plotting quality across projects:
1. Use `research-plot-stylist` to decompose reference figures into reusable style/theme rules.
2. Keep non-data defaults in `matplotlib-base-style` as one base profile.
3. Use `python-research-plot` to produce task-specific plotting code while reusing the same base profile.

## Authoring Notes

- Every skill must include `SKILL.md`.
- Add optional folders only when needed: `scripts/`, `references/`, `assets/`.
- Write frontmatter `description` so trigger conditions are explicit.
- Encode repeatable process in the skill and encode subjective preference as clear heuristics.

## Installation

### Preferred: install with `skill-installer` from GitHub

Use `skill-installer` with a GitHub URL that points to a specific skill path:

- `https://github.com/LKRCharon/kairong-skills/tree/main/skills/matplotlib-base-style`
- `https://github.com/LKRCharon/kairong-skills/tree/main/skills/research-plot-stylist`
- `https://github.com/LKRCharon/kairong-skills/tree/main/skills/python-research-plot`
- `https://github.com/LKRCharon/kairong-skills/tree/main/skills/research-ppt-figure`
- `https://github.com/LKRCharon/kairong-skills/tree/main/skills/web-frontend-aesthetic`
- `https://github.com/LKRCharon/kairong-skills/tree/main/skills/latex-academic-table`
- `https://github.com/LKRCharon/kairong-skills/tree/main/skills/cs-resume-builder`

If you run the installer script directly, both forms work:

```bash
# URL form (no extra --path needed if URL already includes /tree/<ref>/<path>)
python /path/to/install-skill-from-github.py \
  --url https://github.com/LKRCharon/kairong-skills/tree/main/skills/research-plot-stylist

# repo + path form
python /path/to/install-skill-from-github.py \
  --repo LKRCharon/kairong-skills \
  --path skills/research-plot-stylist
```

If direct download is unstable, force git mode:

```bash
python /path/to/install-skill-from-github.py \
  --url https://github.com/LKRCharon/kairong-skills/tree/main/skills/research-plot-stylist \
  --method git
```

You can install multiple skills in one command:

```bash
python /path/to/install-skill-from-github.py \
  --repo LKRCharon/kairong-skills \
  --path skills/matplotlib-base-style skills/research-plot-stylist skills/python-research-plot
```

See installable paths in `skills/INSTALL_PATHS.md`.

### Alternative: local symlink install (for development)

#### Install all skills from this repo

```bash
git clone git@github.com:LKRCharon/kairong-skills.git
cd kairong-skills
mkdir -p "$CODEX_HOME/skills"
ln -sfn "$(pwd)/skills" "$CODEX_HOME/skills/kairong-skills"
```

#### Install only `research-plot-stylist`

```bash
cd kairong-skills
mkdir -p "$CODEX_HOME/skills"
ln -sfn "$(pwd)/skills/research-plot-stylist" "$CODEX_HOME/skills/research-plot-stylist"
```

After linking, restart Codex (or open a new session) to refresh the available skill list.

## Create A New Skill

Create manually or use the scaffold script:

```bash
./scripts/new_skill.sh skill-name "Describe when this skill should be used."
```

The script generates a starter `SKILL.md` with frontmatter. Then extend it with domain-specific workflow and references.

## Next Steps

- Add real project-driven `references/` and `assets/` to each skill.
- Add more skills for posters, paper color systems, defense animations, and web landing pages.
- Gradually script high-frequency operations for lower friction.
