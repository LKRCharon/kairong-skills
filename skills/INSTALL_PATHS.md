# Installable Skill Paths

This repo is organized so `skill-installer` can install each skill directly from GitHub path URLs.

## Repo

- `LKRCharon/kairong-skills`

## Skills

1. `matplotlib-base-style`
Path: `skills/matplotlib-base-style`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/matplotlib-base-style`

2. `research-plot-stylist`
Path: `skills/research-plot-stylist`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/research-plot-stylist`

3. `python-research-plot`
Path: `skills/python-research-plot`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/python-research-plot`

4. `research-ppt-figure`
Path: `skills/research-ppt-figure`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/research-ppt-figure`

5. `web-frontend-aesthetic`
Path: `skills/web-frontend-aesthetic`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/web-frontend-aesthetic`

6. `latex-academic-table`
Path: `skills/latex-academic-table`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/latex-academic-table`

7. `cs-resume-builder`
Path: `skills/cs-resume-builder`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/cs-resume-builder`

## Bulk install example

```bash
python /path/to/install-skill-from-github.py \
  --repo LKRCharon/kairong-skills \
  --path skills/matplotlib-base-style skills/research-plot-stylist skills/python-research-plot skills/research-ppt-figure skills/web-frontend-aesthetic skills/latex-academic-table skills/cs-resume-builder
```

If download mode is unstable in your network, add:

```bash
--method git
```
