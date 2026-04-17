# Private Library Layout (Local, Not in Git)

Recommended local directory for raw references:

```text
design-references-local/
├── raw/
│   ├── papers/
│   │   ├── charts/
│   │   ├── layouts/
│   │   ├── color/
│   │   ├── typography/
│   │   └── diagrams/
│   ├── websites/
│   │   ├── charts/
│   │   ├── layouts/
│   │   ├── color/
│   │   ├── typography/
│   │   └── diagrams/
│   ├── slides/
│   │   ├── charts/
│   │   ├── layouts/
│   │   ├── color/
│   │   ├── typography/
│   │   └── diagrams/
│   └── ui/
│       ├── charts/
│       ├── layouts/
│       ├── color/
│       ├── typography/
│       └── diagrams/
├── extracted/
│   ├── style-cards/
│   ├── briefs/
│   ├── palettes/
│   └── layout-notes/
└── index.yaml
```

Use this for private accumulation.
Only move distilled, open-safe outputs into the git repo.

Suggested location for this repo:

```text
<repo-root>/design-references-local/
```

This folder should be git-ignored so you can keep screenshots, PDFs, slide decks, and working notes locally without pushing them to GitHub.

Suggested indexing pattern:

- Put every raw file under `raw/<source>/<use>/`
- Register it in `design-references-local/index.yaml`
- Add 1-3 `use` tags in the index when one asset is useful across multiple purposes
