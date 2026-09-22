# Changelog

All notable changes to this repository should be documented in this file.

The format follows a lightweight Keep a Changelog style. Repository tags should use the `vX.Y.Z` format and match the published release notes when available.

## [Unreleased]

### Added

- Added `wetype-macos-customization`, a stable macOS skill for patching, signing, verifying, installing, and rolling back a user-owned WeType bundle with versioned compatibility profiles.
- Added a `System and App Customization` group to the skill atlas for system-level tracks whose deliverable is a working local build rather than a visual artifact.

### Changed

- Updated `wetype-macos-customization` to v0.2.1 with the validated macOS input-source recovery sequence for WeType missing from the menu despite enabled TIS registration. Distinguishes registry flags, menu visibility, and physical shortcut/input verification; documents remove/add/select recovery while preserving the installed blue bundle and dictionaries.
- Upgraded `anti-ai-writing-style` to v0.2.0 with writer-sample calibration, claim-integrity checks, false-positive safeguards, context-sensitive return modes, and newer cross-language AI-writing patterns.
- Added the WeType 2.2.3 build 657 Apple Blue profile to `wetype-macos-customization` v0.2.0; later builds reuse the same skill and require profile compatibility checks.
- Re-derived the native arm64/x86_64, Flutter AOT, `Assets.car`, SVG, and PNG patch map for build 657 instead of carrying forward older offsets.
- Replaced Swift-only PNG and TIS diagnostics with Command Line Tools-compatible Objective-C and C utilities, and updated nested signing and verification for the 657 updater app, FinderSync extension, and `BinaryDelta` helper.
- Validated Xcode automatic-signing recovery, end-to-end Apple Development signing, local installation, and Apple Blue candidate rendering for the patched 657 bundle.

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
