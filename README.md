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
    ├── python-research-plot/
    │   └── SKILL.md
    ├── research-plot-stylist/
    │   ├── SKILL.md
    │   ├── agents/openai.yaml
    │   └── references/
    │       ├── style-schema.md
    │       └── style-patterns.md
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

### `python-research-plot`
General-purpose publication and presentation plotting skill for Python, with emphasis on clarity, consistency, and export quality.

### `research-ppt-figure`
For research talk visuals, method diagrams, concept figures, and slide storytelling with strong layout hierarchy.

### `web-frontend-aesthetic`
For frontend pages and prototypes where distinct visual direction and taste matter more than template-safe output.

### `latex-academic-table`
For paper tables, ablation tables, and benchmark comparisons with clean `booktabs`-style formatting and readable numeric alignment.

## Authoring Notes

- Every skill must include `SKILL.md`.
- Add optional folders only when needed: `scripts/`, `references/`, `assets/`.
- Write frontmatter `description` so trigger conditions are explicit.
- Encode repeatable process in the skill and encode subjective preference as clear heuristics.

## Installation

### Install all skills from this repo

```bash
git clone git@github.com:LKRCharon/kairong-skills.git
cd kairong-skills
mkdir -p "$CODEX_HOME/skills"
ln -sfn "$(pwd)/skills" "$CODEX_HOME/skills/kairong-skills"
```

### Install only `research-plot-stylist`

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
