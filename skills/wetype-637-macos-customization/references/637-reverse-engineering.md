# WeType 2.2.1 (637) Reverse-Engineering Record

This record is for macOS WeType build 637 only. The main executable
is a universal Mach-O with arm64 and x86_64 slices. The settings UI is a
Flutter AOT framework, while the input method's candidate and voice surfaces
also contain native Swift/AppKit code.

The offsets are version-specific evidence, not a license to redistribute the
official app. Use them only with an authorized local 637 package.

## Binary Map

| Surface | File | Evidence / entry point |
| --- | --- | --- |
| Input method and native views | `Contents/MacOS/WeType` | `VModeMenuItemView.updateLayer`, `VoiceRippleView` |
| Settings Flutter UI | `Contents/MacOS/WeTypeSettings.app/Contents/Frameworks/App.framework/Versions/A/App` | arm64 and x86_64 AOT snapshots |
| Candidate named colors | `Contents/Resources/Assets.car` | named color records, including `bg03` |
| Settings icons | `WeTypeSettings.app/.../flutter_assets/assets` | SVG literals and raster PNG assets |

Use `otool -arch arm64 -tV` and `otool -arch x86_64 -tV` to confirm symbols;
use `xxd` or exact byte reads for offsets. `otool` virtual addresses are not
file offsets for a fat file; thin the slice first.

## V-menu Selected Background

ARM64 function:

```text
_$s6WeType17VModeMenuItemViewC11updateLayeryyF
VA 0x10007c59c
```

The selected color is an ASCII hex string assembled into `x0`:

```text
0x7c624: 60 04 86 d2       mov  x0, #0x3023
0x7c628: 00 46 a8 f2       movk x0, #0x4230, lsl #16
0x7c62c: 20 e6 c6 f2       movk x0, #0x3731, lsl #32
0x7c630: c0 06 e0 f2       movk x0, #0x36,   lsl #48
```

The four instructions form the ASCII bytes for `#00B176`. The exact 637
replacement for `#007AFF` is:

```text
0x7c628: 00 46 a8 f2 -> 00 e6 a6 f2
0x7c62c: 20 e6 c6 f2 -> 20 c8 c8 f2
0x7c630: c0 06 e0 f2 -> c0 08 e0 f2
```

The first instruction at `0x7c624` is an anchor and stays unchanged.

The x86_64 slice has the same selected color as one ASCII literal:

```text
#00B176 -> #007AFF
```

The current `patch_wetype_637_main.pl` applies the ARM64 instruction patch to
the arm64 thin file and the ASCII patch to the x86_64 thin file.

## Native Voice Gradient

The Flutter AOT patch does not affect this view. The native functions are:

```text
arm64:
  gradientTopColor_WZ    VA 0x10041bc38
  gradientBottomColor_WZ VA 0x10041bc58
x86_64:
  gradientTopColor_WZ    VA 0x10047e1b0
  gradientBottomColor_WZ VA 0x10047e1e0
```

Both top-color functions set red to zero in an instruction (`movi d0, #0` or
`xorps xmm0, xmm0`). The chosen compatible gradient is therefore
`#0A84FF -> #0040DD`.

### ARM64 thin-file offsets

Original values and replacement channel values are normalized doubles
(`channel / 255`), stored little-endian:

```text
Top #00D48E -> #0A84FF
0x2cdc1b0: 212/255 -> 132/255
0x2cdc1b8: 142/255 -> 255/255

Bottom #23C891 -> #0040DD
0x2cd3978:  35/255 ->   0/255
0x2cd3980: 200/255 ->  64/255
0x2cd3988: 145/255 -> 221/255
```

Relevant original bytes are:

```text
0x2cdc1b0: 9b9a9a9a9a9aea3f
0x2cdc1b8: d2d1d1d1d1d1e13f
0x2cd3978: 929191919191c13f
0x2cd3980: 191919191919e93f
0x2cd3988: 323232323232e23f
```

Target bytes are:

```text
0x2cdc1b0: 919090909090e03f
0x2cdc1b8: 000000000000f03f
0x2cd3978: 0000000000000000
0x2cd3980: 101010101010d03f
0x2cd3988: bcbbbbbbbbbbeb3f
```

### x86_64 thin-file offsets

The corresponding x86_64 constants are at different thin-file offsets:

```text
0x1c270c8: 212/255 -> 132/255   top green
0x1c270d0: 142/255 -> 255/255   top blue
0x1c1eb78:  35/255 ->   0/255   bottom red
0x1c1eb80: 200/255 ->  64/255   bottom green
0x1c1eb88: 145/255 -> 221/255   bottom blue
```

Do not patch only `App.framework`; that leaves the native voice view green.

## Settings Connect Icon

The green computer/phone icon beside "关联设备" is not
`icon_setup_multi_device.svg`. The 637 settings Flutter asset is:

```text
Contents/MacOS/WeTypeSettings.app/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/modules/setting/icons/icon_button_connect.png
```

The file is a 60x60, 8-bit RGBA PNG. Rendering the official asset shows one
opaque source color, `#00CC8D`, in 532 pixels; the remaining visible pixels
are antialiasing alpha samples. The canonical target is `#007AFF` for every
non-transparent pixel. Preserve the original alpha byte for every pixel so
the small icon keeps its antialiased edges.

The guarded patcher is:

```text
scripts/patch_wetype_637_connect_icon.swift
```

It checks the exact filename, dimensions, and green source palette before
rewriting the PNG. It is called by `scripts/build_wetype_637.sh` after
the official 637 bundle is copied. The nearby white
`icon_setup_multi_device.svg` is a different resource and must not be used as
the source for this screenshot element.

## Flutter AOT Palette

`patch_wetype_637_colors.pl` handles both thin slices. The important mapping
families are:

```text
#00D48E -> #64D2FF
#6AFFCD -> #64D2FF
#6AFF8B -> #007AFF
#23C891 -> #0A84FF
#58C823 -> #0051D5
#25CE96 -> #5AC8FA
#1FC38D -> #007AFF
#1AC785 -> #0A84FF
```

The ExampleBox and phone/tool previews use four stops, not three identical
blue stops. The prior all-`#007AFF` change made the panel look like a flat
light-blue block; the current four-level sequence is
`#64D2FF -> #0A84FF -> #007AFF -> #0051D5`.

The screenshot button families are separate AOT groups. Their previous targets
were mixed (`#64D2FF -> #007AFF` for multi-device/phone-download buttons and
`#0A84FF -> #007AFF` for common buttons). They now use the same vertical
button gradient `#0A84FF -> #0040DD`. The canonical patcher labels these groups
as `common button gradient 1/2`, `multi-device gradient 1/2`, and `phone
download gradient 1/2`; do not change the ExampleBox groups while updating
these buttons.

The button offsets are in the Flutter `App.framework` thin slices, not in the
native `Contents/MacOS/WeType` executable. The verified 637 instruction-start
groups are:

```text
arm64:
  common:          0x232c00..0x232c10, 0x232c5c..0x232c6c
  multi-device:    starts 0x238508/0x238510 and 0x238774/0x23877c;
                   ends 0x23855c..0x23856c and 0x2387c8..0x2387d8
  phone-download:  start 0x2a3450/0x2a3458; end 0x2a34a4..0x2a34b4
x86_64:
  common:          0x29adab..0x29adb9, 0x29ae04..0x29ae12
  multi-device:    starts 0x30f1cc/0x30f1d3 and 0x31b763/0x31b76a;
                   ends 0x30f21e..0x30f22c and 0x31b7b5..0x31b7c3
  phone-download:  start 0x32167c/0x321683; end 0x3216ce..0x3216dc
```

For x86_64, the patcher offsets above are instruction starts and writes the
immediate at `offset + 1`. The `0x32167c` and `0x3216ce` pair was previously
labelled as a hotword group in an intermediate note; in this 637 AOT it is the
phone-download button pair and must use `#0A84FF -> #0040DD`. The verifier must
thin `App.framework` separately from the native executable before checking
these offsets.

V5 and V6 were user-confirmed correct in the current 637 package. Do not add
new changes there unless a new regression is reported.

## Assets.car Candidate Records

The top-level `Contents/Resources/Assets.car` contains named color records.
The `bg03` variants were changed to exact `#007AFF`; the dark selected state
uses `#0051D5` where the source record was the darker green accent. The
`patch_wetype_637_assets.pl` script is the canonical exact-byte implementation.

Important record offsets in the 637 file:

```text
0x20218c, 0x202194       bg03 light record
0x28e59c, 0x28e5a4       bg03 light record 2
0x28c6bc, 0x28c6c4       bg03 dark record
0x201f24                 bc16 light selected state
0x28f044                 bc16 Aqua selected state
0x28c914                 bc16 dark selected state
0x202fc4                 bg02 light V-menu background
0x28f504                 bg02 Aqua V-menu background
0x2030f4, 0x28d9b4,
0x28eb84                 bg04 accents
```

The 637 patch must use IEEE-754 little-endian doubles. An earlier attempt
produced `#0076FF` in one resource; verify all three channels and use exact
`#007AFF` values instead.

## Signing and Input-source Boundaries

The signer must discover a usable identity on the current Mac with
`security find-identity -v -p codesigning`. Do not copy a personal certificate
name, SHA-1, Team ID, or private key into a shared package. The certificate and
private key must be paired in the operator's login keychain.

```text
Apple Development: <operator account>
identity SHA-1: <operator identity SHA-1>
TeamIdentifier: <operator Team ID>
```

Sign from inner to outer: Flutter/Swift leaves, Sparkle XPC and helpers,
frameworks, helper executables, `WeTypeFinderSync.appex`, Settings/Feedback
apps, then the top-level WeType app. Restore the stored entitlements and adapt
helper application identifiers to the current Team ID as the existing signing
script does.

This is not Tencent's original Developer ID identity (`88L2Q4487U`). Personal
Apple Development signing is suitable for local testing, but can change trust
behavior in protected or special hosts. A prior ad-hoc signature caused input
to work in some apps but fail in others.

Input-source diagnosis:

- `scripts/diagnose_tis.swift` should show the normal parent record and exactly one
  `com.tencent.inputmethod.wetype.pinyin` mode.
- Duplicate rows are fixed reliably through System Settings > Keyboard > Input
  Sources > Edit, one row at a time. Direct protected preference edits were
  rejected or reverted on this Mac.
- TextEdit and Microsoft Edge were confirmed to accept Chinese input after the
  duplicate cleanup. Other protected hosts need separate trust diagnostics.
- Do not interpret an absent lazy-started WeType process as stale cache. Check
  `pgrep -ax WeType` together with TIS state.

## Canonical Artifacts and Rollback

Use these versioned skill artifacts instead of recreating the patch logic:

```text
scripts/build_wetype_637.sh
scripts/patch_wetype_637_main.pl
scripts/patch_wetype_637_colors.pl
scripts/patch_wetype_637_assets.pl
scripts/patch_wetype_637_svg.pl
scripts/patch_wetype_637_connect_icon.swift
scripts/sign_wetype_637.sh
scripts/install_wetype.sh
scripts/diagnose_tis.swift
```

The verifier must compare the rebuilt critical files and record the dated
backup printed by the installer. Never place an actual installed bundle or
personal backup path in the shareable skill.

Rollback only after confirming the backup path:

```bash
sudo /bin/rm -rf '/Library/Input Methods/WeType.app'
sudo /usr/bin/ditto '/path/to/verified-backup.bundle' '/Library/Input Methods/WeType.app'
sudo /usr/sbin/chown -R root:wheel '/Library/Input Methods/WeType.app'
sudo /usr/bin/codesign --verify --deep --strict '/Library/Input Methods/WeType.app'
```

Never use a guessed backup, and never remove user dictionaries or caches as a
first response to an input failure.
