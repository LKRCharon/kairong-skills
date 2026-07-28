# Changelog

All notable changes to this repository should be documented in this file.

The format follows a lightweight Keep a Changelog style. Repository tags should use the `vX.Y.Z` format and match the published release notes when available.

## [Unreleased]

### Added

- Added `wetype-637-macos-customization`, a macOS skill for patching, signing, verifying, installing, and rolling back a user-owned WeType 2.2.1 build 637 bundle.
- Added a `System and App Customization` group to the skill atlas for system-level tracks whose deliverable is a working local build rather than a visual artifact.

## [0.2.0] - 2026-05-19

### Added

- Added `anti-ai-writing-style`, a bilingual skill for detecting and rewriting Chinese and English prose that sounds machine-generated.

## [0.1.0] - 2026-04-16

### Added

- Added explicit `version: 0.1.0` metadata to every installable `SKILL.md`.
- Added version-aware scaffolding to `scripts/new_skill.sh` and `templates/SKILL.template.md`.
- Added installation guidance that separates install, update, and upgrade flows.
- Added repository-level release guidance recommending pinned tags or releases instead of tracking `main` for stable installs.

### Documentation

- Clarified that `skill-installer` installs selected skill paths rather than synchronizing the whole repository by default.
- Documented update behavior for reinstallation and local symlink workflows.
