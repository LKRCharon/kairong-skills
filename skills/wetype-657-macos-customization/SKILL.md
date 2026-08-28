---
name: wetype-657-macos-customization
description: Reverse-engineer and locally customize WeType 2.2.3 build 657 on macOS, including arm64/x86_64 color and resource patches, Apple Development signing, Xcode private-key recovery, installation and input-source enablement, rollback, and cross-application troubleshooting. Use when working with a user-owned official WeType 657 bundle or diagnosing a locally modified 657 input method.
metadata:
  version: "0.2.0"
---

# WeType 657 macOS customization

This skill describes a local-test workflow for WeType 2.2.3 (build 657). It
keeps the official bundle untouched, patches a work copy, signs every nested
component from the inside out, verifies the result, and only then installs it
as a macOS input method.

The workflow is version-locked. The exact offsets in the bundled reference are
for 657 only. Stop and re-disassemble if `CFBundleVersion` is not `657` or
`CFBundleShortVersionString` is not `2.2.3`.

## Ownership and sharing boundary

- Use a legally obtained official WeType package and a machine/account the
  operator is authorized to modify.
- Share this skill, patch source, offset map, and generic scripts. Do not share
  Tencent's app binary, user dictionaries, private keys, exported `.p12`
  files, provisioning profiles, or a signed personal bundle.
- Apple Development signing is for local development/testing. It is not the
  Tencent Developer ID identity and does not grant distribution or notarization
  rights. Full original host trust requires the original signing identity.
- Do not claim that one successful TextEdit or Edge test proves every protected
  host will accept the modified input method.

## Read first

Load the references that match the task:

- `references/657-reverse-engineering.md`: exact 657 binary/resource map,
  offsets, color encodings, and architecture rules.
- `references/xcode-signing.md`: Apple Account, Xcode, certificate/private-key
  recovery, entitlements, and signing pitfalls.
- `references/installation-and-troubleshooting.md`: installation, enabling,
  TIS/LaunchServices diagnosis, cross-app failures, and rollback.
- `references/deep-customization.md`: how to add a new 657 customization while
  keeping patches guarded and reproducible.

## Canonical workflow

### 1. Prepare and identify the package

Set paths in the operator's shell. Never point a patcher at the installed app:

```bash
ROOT="/path/to/wetype-657-work"
OFFICIAL="$ROOT/WeType-official.disabled"
CUSTOM="$ROOT/WeType-657-custom.bundle"
ENTITLEMENTS="$ROOT/signing-entitlements"
BACKUPS="$ROOT/backups"
```

Check the version and bundle shape before any patch:

```bash
/usr/bin/plutil -extract CFBundleShortVersionString raw -o - \
  "$OFFICIAL/Contents/Info.plist"
/usr/bin/plutil -extract CFBundleVersion raw -o - \
  "$OFFICIAL/Contents/Info.plist"
/usr/bin/file "$OFFICIAL/Contents/MacOS/WeType"
/usr/bin/lipo -info "$OFFICIAL/Contents/MacOS/WeType"
/usr/bin/codesign --verify --deep --strict "$OFFICIAL"
```

Expect `2.2.3`, `657`, and a universal `arm64 x86_64` main executable. Keep a
separate untouched copy of the official package and record its hash.

### 2. Build from the official copy

The parameterized builder creates a fresh custom output and fails closed on
unexpected bytes:

```bash
/bin/bash scripts/build_wetype_657.sh "$OFFICIAL" "$CUSTOM"
```

The build phase needs the macOS Command Line Tools (`lipo`, Perl, and clang),
not a working Swift toolchain. The PNG patcher is compiled from Objective-C.
Full Xcode is needed only when the operator must create or recover an Apple
Development signing identity.

The builder does the following in order:

1. Check the version and reject `/Library/Input Methods/WeType.app` as input.
2. Copy the official bundle to a temporary build directory.
3. Thin the universal `WeType` executable into arm64 and x86_64 files.
4. Patch native V-menu and voice constants in each thin file, then rebuild the
   universal executable.
5. Patch the Flutter AOT `App.framework` arm64 and x86_64 slices separately.
6. Patch SVG and PNG settings assets.
7. Patch named colors in `Assets.car`.
8. Run resource/version checks and emit the custom bundle only at the end.

Do not use broad `sed`, `perl -pi`, or string replacement across a Mach-O file.
Every binary patch must assert the expected old bytes, accept the exact target
bytes when rerun, and identify the architecture and thin-file offset.

### 3. Create or recover a local signing identity

Check the identity and its private key:

```bash
/usr/bin/security find-identity -v -p codesigning
/usr/bin/security find-certificate -a -p -c "Apple Development" \
  | /usr/bin/openssl x509 -noout -subject -nameopt RFC2253 \
  2>/dev/null || true
```

If `/Applications/Xcode.app` is absent, install Xcode and sign in under Xcode >
Settings > Accounts before attempting identity recovery. Point `xcode-select`
at the full Xcode developer directory after installation; Command Line Tools
alone cannot perform the automatic-signing recovery build.

Use the full identity name or SHA-1 printed by `find-identity`, not the short
code in parentheses in the certificate display. Read the Team ID from Xcode's
team selector or the `TeamIdentifier` of an automatically signed sample app.
If the certificate appears in Keychain but `find-identity` reports zero valid
identities, the private key is missing or not paired. Follow
`references/xcode-signing.md`; the verified recovery path is a minimal
automatically signed macOS Xcode project built with
`xcodebuild -allowProvisioningUpdates`.

Create generic entitlements using the operator's Team ID:

```bash
/bin/bash scripts/create_entitlements.sh "$ENTITLEMENTS" "$TEAM_ID"
```

Do not copy another person's Team ID into a new signature. Do not sign with
`codesign --sign -`; ad-hoc signatures commonly make input work in one host but
fail in another and discard the original trust boundary.

### 4. Sign inside out

Sign with the operator's identity:

```bash
/bin/bash scripts/sign_wetype_657.sh \
  "$CUSTOM" "$IDENTITY" "$ENTITLEMENTS"
```

The script signs Settings and Feedback subtrees, Sparkle leaves and framework,
root frameworks, `BinaryDelta`, helper executables and apps, FinderSync, and
the top-level WeType app last. Use `--timestamp=none` for local testing and
preserve the appropriate entitlements for each nested target.

### 5. Verify before installation

```bash
/bin/bash scripts/verify_wetype_657.sh "$CUSTOM"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$CUSTOM"
/usr/bin/codesign -d --verbose=4 "$CUSTOM" 2>&1 \
  | /usr/bin/grep -E 'Authority|TeamIdentifier|Identifier'
```

Verification must cover version, both main architectures, native voice/V-menu
bytes, both Flutter slices, `Assets.car`, the connect icon, FinderSync, and a
valid deep signature. A successful build is not yet an installed result.

### 6. Install and enable from Terminal

Install only the verified custom bundle, using the user's Terminal:

```bash
sudo /bin/bash scripts/install_wetype.sh \
  "$CUSTOM" "/Library/Input Methods/WeType.app" "$BACKUPS"
```

The installer refuses non-root execution, verifies the source, creates a dated
backup of the installed bundle, stages the new bundle, verifies the staged
copy, restores `root:wheel`, replaces the app, and restarts input-method
related processes. It does not require a full computer reboot.

Then enable/select WeType in System Settings > Keyboard > Input Sources. Leave
exactly one WeType Pinyin row. Run `scripts/diagnose_tis.sh` to inspect the
registry; the System Settings editor is the reliable way to remove duplicates.

### 7. Test in layers

Test in this order:

1. TextEdit: select WeType Pinyin and type Chinese.
2. Microsoft Edge: test a normal web text field.
3. The user's real target host, especially if it is protected, sandboxed, or
   uses a special text field.
4. Settings, candidate/V menu, voice window, appearance previews, and any
   newly patched asset.

Record which host, input source, process, signature, and surface failed. Do
not infer a global fix from a single successful host.

## Deep customization routing

Start with the surface map rather than guessing where a green pixel came from:

| Surface | Layer | Correct method |
| --- | --- | --- |
| Candidate selected background | native ARM64/x86_64 plus `Assets.car` | patch main thin slices and named color records |
| Native voice ripple | `Contents/MacOS/WeType` | patch normalized floating-point channel constants in both slices |
| Appearance `ExampleBox` | Flutter `App.framework` AOT | patch four instruction groups per architecture |
| Common/multi-device/phone buttons | Flutter `App.framework` AOT | patch their separate start/end groups |
| Settings SVG icon | Flutter assets | guarded literal replacement |
| Settings connect computer/phone icon | Flutter PNG asset | preserve alpha, recolor non-transparent pixels |
| Other settings pages | inspect owning Flutter/native layer first | do not inherit an older build's offsets or verification claims |

For any new surface:

1. Capture the exact screen and identify which child app/window owns it.
2. Search text/color strings in resources first.
3. Inspect both architectures with `otool`, `strings`, and `xxd`.
4. Thin the relevant universal file before using virtual addresses or offsets.
5. Confirm the old bytes or literal occur at the intended count.
6. Patch one layer at a time and preserve gradient hierarchy.
7. Rebuild, sign, verify, and test the actual host.
8. Add the finding to the reference before sharing the skill.

Use Apple Blue as a hierarchy, not a flat replacement. The binary-verified
target palette is:

```text
ExampleBox:       #64D2FF -> #0A84FF -> #007AFF -> #0051D5
Buttons:          #0A84FF -> #0040DD
Native voice:     #0A84FF -> #0040DD
Solid icon/accent:#007AFF
```

For AOT channels, ARM64 values are often `MOVZ` fragments and x86_64 values
may be immediates or ASCII. For native voice and `Assets.car`, colors are
normalized `channel / 255` IEEE-754 little-endian doubles. Do not convert a
fat-file virtual address directly into a file offset.

## Bug triage

Use `references/installation-and-troubleshooting.md` and follow this split:

- Build fails with an unexpected byte: likely wrong version, wrong slice, or
  an already patched/unrelated package. Stop; do not force the patch.
- Signature fails: inspect the first failing nested path, check the identity has
  a private key, restore entitlements, and sign inside out. Never add `--deep`
  to the signing operation as a shortcut.
- Settings is blue but candidates are green: candidate rendering is native or
  `Assets.car`; patching Flutter alone cannot fix it.
- Candidate is blue in TextEdit but another app cannot type: first inspect TIS
  duplicates, the process paths reported by `diagnose_tis.sh`, LaunchServices
  paths, and host trust. Do not delete dictionaries or caches first.
- WeType is absent from `pgrep`: it may be lazy-started. Absence alone is not
  evidence of a stale process.
- Voice remains green: the native `VoiceRippleView` constants were missed;
  App.framework changes do not reach that view.
- A gradient becomes a flat pale blue block: several stops were flattened;
  restore the four-stop or two-stop hierarchy above.
- A post-reboot failure appears: verify TIS registration, enabled/selected
  input sources, installed version, and signature before changing data.

Rollback only to a dated backup that was verified before replacement:

```bash
sudo /bin/rm -rf "/Library/Input Methods/WeType.app"
sudo /usr/bin/ditto "/path/to/verified-backup.bundle" \
  "/Library/Input Methods/WeType.app"
sudo /usr/sbin/chown -R root:wheel "/Library/Input Methods/WeType.app"
sudo /usr/bin/codesign --verify --deep --strict \
  "/Library/Input Methods/WeType.app"
```

## What the shareable package excludes

The package must not contain `WeType.app`, `.bundle` outputs, dictionaries,
Application Support data, Keychain exports, private keys, personal Team IDs,
or machine-specific absolute paths. Before sharing, run a search for email
addresses, SHA-1 identities, `/Users/`, `/Library/Input Methods/`, and private
certificate material; only generic examples should remain.
