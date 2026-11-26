# Changelog

All notable changes to this repository should be documented in this file.

The format follows a lightweight Keep a Changelog style. Repository tags should use the `vX.Y.Z` format and match the published release notes when available.

## [Unreleased]

### Added

- Added `wetype-macos-customization`, a stable macOS skill for patching, signing, verifying, installing, and rolling back a user-owned WeType bundle with versioned compatibility profiles.
- Added an Apple Blue profile for WeType 3.0.1 build 684, with version-guarded native, Flutter AOT, `Assets.car`, SVG, and connect-icon patchers. The build, signature, installation, input-source checks, and blue rendering were confirmed on one Mac.
- Added a `System and App Customization` group to the skill atlas for system-level tracks whose deliverable is a working local build rather than a visual artifact.

### Changed

- Upgraded `wetype-macos-customization` to v0.3.4 with a rose-pink profile for WeType 3.0.2 build 689. The 3.x build, signing, and verification scripts take the exact expected build.
- Upgraded `wetype-macos-customization` to v0.3.3 and switched the default theme to rose pink for builds 657 and 684, covering candidate selection, voice, settings previews, and icons.
- Upgraded `wetype-macos-customization` to v0.3.2 with a recovery path for Control-Space failures while WeType remains listed: inspect shortcut bindings and TIS state, remove/re-add the single WeType source, select it through TIS, then check both switch directions. The recovery was exercised on the installed 684 bundle; physical-keyboard confirmation remains with the user.
- Upgraded `wetype-macos-customization` to v0.3.1 after exercising the 684 build: corrected the SVG source count to 12 `#23C891` values, clarified FileProvider `com.apple.FinderInfo` signature failures, generalized the entitlement-generator status message, and confirmed local installation and blue rendering.
- Updated `wetype-macos-customization` to v0.2.1 with the validated macOS input-source recovery sequence for WeType missing from the menu despite enabled TIS registration. Distinguishes registry flags, menu visibility, and physical shortcut/input verification; documents remove/add/select recovery while preserving the installed blue bundle and dictionaries.
- Upgraded `wetype-macos-customization` to v0.3.0 while preserving its fully validated 657 profile; the installer now selects the 657 or 684 verifier by bundle version.
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
