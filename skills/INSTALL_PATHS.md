# Installable Skill Paths

This repo is organized so `skill-installer` can install each skill directly from GitHub path URLs.

## Repo

- `LKRCharon/kairong-skills`

## Skills

1. `analyze-results`
Path: `skills/analyze-results`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/analyze-results`

2. `paper-figure`
Path: `skills/paper-figure`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/paper-figure`

3. `research-plot-stylist`
Path: `skills/research-plot-stylist`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/research-plot-stylist`

4. `matplotlib-base-style`
Path: `skills/matplotlib-base-style`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/matplotlib-base-style`

5. `python-research-plot`
Path: `skills/python-research-plot`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/python-research-plot`

6. `latex-academic-table`
Path: `skills/latex-academic-table`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/latex-academic-table`

7. `mermaid-diagram`
Path: `skills/mermaid-diagram`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/mermaid-diagram`

8. `paper-illustration`
Path: `skills/paper-illustration`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/paper-illustration`

9. `research-ppt-figure`
Path: `skills/research-ppt-figure`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/research-ppt-figure`

10. `web-frontend-aesthetic`
Path: `skills/web-frontend-aesthetic`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/web-frontend-aesthetic`

11. `cs-resume-builder`
Path: `skills/cs-resume-builder`
URL: `https://github.com/LKRCharon/kairong-skills/tree/main/skills/cs-resume-builder`

## Bulk install example

```bash
python /path/to/install-skill-from-github.py \
  --repo LKRCharon/kairong-skills \
  --path skills/analyze-results skills/paper-figure skills/research-plot-stylist skills/matplotlib-base-style skills/python-research-plot skills/latex-academic-table skills/mermaid-diagram skills/paper-illustration
```

If download mode is unstable in your network, add:

```bash
--method git
```
