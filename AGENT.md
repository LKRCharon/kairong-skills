# AGENT.md

Operating guide for coding agents working in `kairong-skills`.

## 1. Project Positioning

This repository is a design-driven skill system for technical artifacts.
Primary goals:

- Make dense technical content clearer.
- Produce professional, publication-ready outputs.
- Preserve a consistent visual voice across figures, tables, diagrams, slides, interfaces, and resumes.

Treat this repo as a curated library, not a dump of prompts.

## 2. Non-Negotiable Principles

1. Design quality is part of correctness.
2. Prefer reproducible workflows (scripts/templates) over one-off prose.
3. Keep private references private:
   - Never commit raw third-party screenshots/PDFs/design files.
   - Commit only distilled, reusable, open-safe outputs.
4. Keep skills concise:
   - `SKILL.md` should stay focused.
   - Move heavy detail to `references/`, reusable files to `assets/`, automation to `scripts/`.

## 3. Repo Map (Quick)

- `skills/<skill-name>/SKILL.md`: skill entry point (required).
- `skills/INSTALL_PATHS.md`: installable paths and URLs.
- `templates/SKILL.template.md`: base template for new skills.
- `scripts/new_skill.sh`: scaffold generator with frontmatter.
- `README.md`: identity, capability map, workflows, install docs.
- `CHANGELOG.md`: release-facing change history.
- `analysis/`: reproducible analysis scripts and generated figures/data.

## 4. Standard Workflow For Any Task

1. Classify request:
   - Update existing skill.
   - Add new skill.
   - Adjust docs/tooling/release metadata.
2. Read local context first:
   - Target `SKILL.md`
   - `README.md` sections impacted by the change
   - `skills/INSTALL_PATHS.md` if install surface changes
3. Implement minimal coherent change set.
4. Sync linked docs/metadata.
5. Run quick validation checks.
6. Summarize assumptions and remaining risks.

## 5. When Adding A New Skill

1. Scaffold with:
   - `./scripts/new_skill.sh <skill-name> "<description>"`
2. Ensure frontmatter includes:
   - `name`
   - `description` (clear trigger condition)
   - `version` (start at `0.1.0` unless instructed otherwise)
3. Minimum `SKILL.md` sections:
   - `When to use`
   - `Workflow`
   - `Quality bar`
4. Add `references/`, `assets/`, `scripts/` only when they improve reuse.
5. Update:
   - `README.md` (atlas/workflow/layout if needed)
   - `skills/INSTALL_PATHS.md`
   - `CHANGELOG.md` (`[Unreleased]`)

## 6. When Modifying Existing Skills

1. Preserve skill intent; do not silently repurpose.
2. Bump `version` for user-visible workflow/output changes.
3. Keep trigger language explicit and testable.
4. Prefer small diffs and avoid unrelated cleanup.
5. If behavior changes, add a concise changelog entry.

## 7. Cross-File Sync Rules

- If a skill is added/renamed/removed:
  - Update `README.md` skill lists/maps.
  - Update `skills/INSTALL_PATHS.md`.
- If install or upgrade behavior changes:
  - Update both `README.md` and `skills/INSTALL_PATHS.md`.
- If scaffolding behavior changes:
  - Update `scripts/new_skill.sh` and `templates/SKILL.template.md` together.
- If release-visible behavior changes:
  - Update `CHANGELOG.md` under `[Unreleased]`.

## 8. Validation Checklist

Run what is relevant for the touched scope:

```bash
# Basic script sanity
bash -n scripts/new_skill.sh

# Confirm skill files are discoverable
rg --files skills | rg 'SKILL.md$'

# Spot-check every skill has version metadata
rg '^version:' skills/*/SKILL.md

# Review patch shape
git diff --stat
```

If analysis code or figure generation changed, run the affected script and verify output paths under `analysis/`.

## 9. What To Avoid

- Committing private or copyrighted raw reference assets.
- Expanding `SKILL.md` into long tutorials when a reference file is better.
- Mixing unrelated refactors into feature/documentation commits.
- Breaking install docs by changing paths without syncing install files.

## 10. Definition Of Done

A change is done when:

1. The target skill/docs behavior is correct and clear.
2. Linked files are synchronized (`README`, install paths, changelog as needed).
3. Versioning and release notes are consistent with user-visible impact.
4. Basic validation checks pass.
5. The diff is focused and easy to review.
