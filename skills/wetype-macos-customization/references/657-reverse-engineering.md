# WeType 2.2.3 (657) reverse-engineering record

This record applies only to the macOS WeType package whose Info.plist reports
`CFBundleShortVersionString=2.2.3` and `CFBundleVersion=657`. The offsets below
were re-derived from an official Tencent-signed universal bundle; they are not
older offsets with only the version label changed.

## Source fingerprint and layout

Observed official SHA-256 values:

```text
Contents/MacOS/WeType
a68a92300cc38e5941f59832c516a37eb098c10c6bbe47ab3dcbe812705cf5ee

WeTypeSettings.app/.../App.framework/Versions/A/App
d0dabee3104b6d2ebc9588e10f9f8eb155da7ef31a8657b8b7353e64f8f36581

Contents/Resources/Assets.car
e0193be9725e4b6e39994a2079aeb3592de36f3f6fc3928936770fb6001d6f12

.../assets/modules/setting/icons/icon_button_connect.png
1bc6ae887c792b3357e133804c6adbe844f47d8b2bdafde76780c1c0b006c34c
```

The main executable and Flutter AOT framework are both universal `arm64` and
`x86_64` Mach-O files. Thin each file separately before applying an offset.
The main executable's `__TEXT` segment has `vmaddr=0x100000000` and
`fileoff=0`, so the referenced native constants map directly after subtracting
that base. The Flutter AOT thin files use offsets starting at zero.

| Surface | File |
| --- | --- |
| Native input method, V-menu, voice | `Contents/MacOS/WeType` |
| Settings and preview UI | `WeTypeSettings.app/.../App.framework/Versions/A/App` |
| Candidate and V-menu named colors | `Contents/Resources/Assets.car` |
| Settings vector/raster icons | `App.framework/.../flutter_assets/assets` |

## Native V-menu

ARM64 symbol and function address:

```text
_$s6WeType17VModeMenuItemViewC11updateLayeryyF
VA 0x1000f8e60
```

The selected color remains the short string `#00B176` assembled in `x0`.
The 657 thin-file patch is:

```text
0x0f8ee8  60 04 86 d2  anchor, unchanged
0x0f8eec  00 46 a8 f2  -> 00 e6 a6 f2
0x0f8ef0  20 e6 c6 f2  -> 20 c8 c8 f2
0x0f8ef4  c0 06 e0 f2  -> c0 08 e0 f2
```

The x86_64 symbol is at `0x100108cd0`. The 657 patcher guards every ASCII
literal at its thin-file offset:

| Source | Target | x86_64 offsets |
| --- | --- | --- |
| `#00B176` | `#007AFF` | `0x108d4f` |
| `#23C891` | `#007AFF` | `0x54faa0` |
| `#62c999` | `#64D2FF` | `0x1954ee`, `0x1959b6` |
| `#34C759` | `#007AFF` | `0x195514`, `0x1959dc`, `0x1965d4`, `0x196765` |

## Native voice gradient

The voice view is native code, not Flutter:

```text
arm64  gradientTopColor_WZ    VA 0x10052d3d8
arm64  gradientBottomColor_WZ VA 0x10052d3f8
x86_64 gradientTopColor_WZ    VA 0x1005a5c10
x86_64 gradientBottomColor_WZ VA 0x1005a5c40
```

Each channel below is a unique little-endian IEEE-754 double in its 657 thin
slice. Values are normalized as `channel / 255`.

| Slice | Offset | Source | Target |
| --- | ---: | ---: | ---: |
| arm64 | `0x2e28250` | top G 212 | 132 |
| arm64 | `0x2e28258` | top B 142 | 255 |
| arm64 | `0x2e24f80` | bottom R 35 | 0 |
| arm64 | `0x2e203d0` | bottom G 200 | 64 |
| arm64 | `0x2e24f88` | bottom B 145 | 221 |
| x86_64 | `0x1d7f5d8` | top G 212 | 132 |
| x86_64 | `0x1d7f5e0` | top B 142 | 255 |
| x86_64 | `0x1d7c9a0` | bottom R 35 | 0 |
| x86_64 | `0x1d77fb0` | bottom G 200 | 64 |
| x86_64 | `0x1d7c9a8` | bottom B 145 | 221 |

The result is `#0A84FF -> #0040DD`; top red remains zero in the native
instruction and is intentionally not patched.

## Flutter AOT static palette

The following exact snapshot records moved in 657. The patcher asserts both
the offset and source bytes:

| Record | arm64 | x86_64 | Source bytes | Target bytes |
| --- | ---: | ---: | --- | --- |
| root | `0x4e336d` | `0x51d84f` | `11110fb9c0` | `7f7501b8c0` |
| variant 1 | `0x4e3372` | `0x51d854` | `6f5002b8` | `7f7501b8` |
| variant 2 | `0x4e3385` | `0x51d867` | `766202b8` | `7f6317bf` |
| variant 3 | `0x4e329e` | `0x51d780` | `0e2903b8` | `7f7501b8` |
| variant 4 | `0x4e32e4` | `0x51d7c6` | `66585ab8` | `7f7501b8` |
| variant 5 | `0x4e338a` | `0x51d86c` | `706f23bf` | `7f6317bf` |

In 657 the toolbar accent formerly emitted as a separate `#1AC785` immediate
triplet is loaded from the object pool. There is therefore no guarded direct
instruction patch for that triplet; static palette variant 4 is the relevant
657 patch point.

## Flutter AOT instruction groups

Offsets below are instruction starts in thin files. Full RGB groups list three
offsets; sparse groups list G/B offsets. The complete old/new channel guards
are implemented in `scripts/patch_wetype_657_colors.pl`.

| Surface | arm64 groups | x86_64 groups |
| --- | --- | --- |
| Common button | `24ae30/38/40`, `24ae8c/94/9c` | `2cfb6b/72/79`, `2cfbc4/cb/d2` |
| Input settings accent | `24d444/4c/54` | `2d24ea/f1/f8` |
| Device gradient 1 | start `2507e0/e8`, end `250834/3c/44` | start `3172bc/c3`, end `31730e/15/1c` |
| Device gradient 2 | start `250a4c/54`, end `250aa0/a8/b0` | start `323853/5a`, end `3238a5/ac/b3` |
| Device branch preload | `250a10/14` | `2d5eba/bf` |
| Device/settings accents | `251000/08/10`, `30212c/34`, `302180/88/90` | `2d5ce4/eb/f2`, `2d5f4f/56/5d`, `2d6510/17/1e` |
| About accent | `2e5d2c/34/3c` | debug counterpart `3053fb/402/409` |
| Appearance stop 1 | `2e8a44/4c/54` | `3083fa/401/408` |
| Appearance stop 2 | `2e8aa4/ac/b4` | `308457/45e/465` |
| Appearance stop 3 | `2e8b18/20/28` | `3084cc/d3/da` |
| Appearance stop 4 | `2e8b7c/84/8c` | `30852e/35/3c` |
| Hotword start/accent | `2f68dc/e4`, `2f6930/38/40` | settings start/accent groups `2d5c92/99`, `2d5efd/f04` |
| Phone preview stops 1-4 | `3072cc/d4/dc`, `307328/30/38`, `307394/9c/a4`, `3073f8/400/408` | `328f48/4f/56`, `328fa2/a9/b0`, `329010/17/1e`, `329072/79/80` |
| Phone download | start `30791c/24`, end `307970/78/80` | start `3295f4/fb`, end `329646/4d/54` |
| Toolbar stops 1-4 | `30b0dc/e4/ec`, `30b13c/44/4c`, `30b1b0/b8/c0`, `30b214/1c/24` | `32d222/29/30`, `32d27f/86/8d`, `32d2f4/fb/302`, `32d356/5d/64` |

The intended hierarchy is:

```text
Appearance: #64D2FF -> #0A84FF -> #007AFF -> #0051D5
Phone/tools: #5AC8FA -> #0A84FF -> #007AFF -> #0051D5
Buttons:    #0A84FF -> #0040DD
```

All source instruction patterns in these palette families were accounted for
in both slices. The 657 patcher is idempotent: exact target instructions are
accepted, while any third byte pattern fails closed.

## SVG and connect icon

The 657 Flutter asset tree has exact source counts:

```text
#2AE59F: 4 -> #64D2FF
#23C891: 11 -> #007AFF
#00B176: 2 -> #007AFF
#1AC785: 2 -> #0A84FF
```

`icon_button_connect.png` remains a 60x60 RGBA PNG with 532 opaque green
pixels. `patch_wetype_657_connect_icon.m` decodes it through ImageIO, checks
the source palette, recolors every non-transparent pixel to premultiplied
`#007AFF`, and preserves alpha samples. It is compiled with clang so the build
does not depend on a working Swift command-line module cache.

## Assets.car named colors

`assetutil --info` was used to match name, appearance, and RGB tuple before
recording these exact tuple starts:

| Name / appearance | Offset | Source | Target |
| --- | ---: | --- | --- |
| bg03 default | `0x21eb44` | `0,177,118` | `0,122,255` |
| bg03 DarkAqua | `0x2a7684` | `0,168,111` | `0,122,255` |
| bg03 Aqua | `0x2a98f4` | `0,177,118` | `0,122,255` |
| bc16 default | `0x21eed4` | `22,172,102` | `0,122,255` |
| bc16 DarkAqua | `0x2a8264` | `0,212,142` | `0,81,213` |
| bc16 Aqua | `0x2aa144` | `22,172,102` | `0,122,255` |
| bg02 default | `0x21f394` | `232,247,240` | `234,243,255` |
| bg02 Aqua | `0x2aa4d4` | `232,247,240` | `234,243,255` |
| bg04 default | `0x21fbe4` | `35,200,145` | `0,122,255` |
| bg04 DarkAqua | `0x2a8ab4` | `35,200,145` | `0,122,255` |
| bg04 Aqua | `0x2aae54` | `35,200,145` | `0,122,255` |

Each record is four normalized doubles. Only RGB is changed; alpha remains 1.

## Build 657 signing layout

The nested code layout still uses Sparkle B, Flutter App/FlutterMacOS
frameworks, Feedback, FinderSync, and the root frameworks. Two paths matter for
657 signing correctness:

- The updater is `Contents/Helpers/WeTypeUpdater.app`; there is no
  `Contents/MacOS/WeTypeUpdater` executable.
- The updater app has no custom entitlement blob in the official 657 package;
  sign it with hardened runtime without injecting an application identifier.
- `Contents/Resources/BinaryDelta` is a signed executable leaf and is included
  in the inside-out local signing pass.

Sign Settings frameworks and app, Feedback runtime and app, Sparkle leaves and
framework, root frameworks/libraries, BinaryDelta, relaunch/accessibility
helpers, the updater app, FinderSync, and the top-level app last. Preserve the
known entitlements with the operator's own Team ID. Do not use ad-hoc signing.

## Canonical artifacts

```text
scripts/build_wetype_657.sh
scripts/patch_wetype_657_main.pl
scripts/patch_wetype_657_colors.pl
scripts/patch_wetype_657_assets.pl
scripts/patch_wetype_657_svg.pl
scripts/patch_wetype_657_connect_icon.m
scripts/sign_wetype_657.sh
scripts/verify_wetype_657.sh
scripts/install_wetype.sh
scripts/diagnose_tis.sh
```

The verifier thins both Mach-O files, reruns all binary patchers on temporary
copies, and requires byte-for-byte idempotence. It also verifies SVG counts,
the PNG palette, named colors, nested 657 components, a non-ad-hoc authority,
and the deep signature.
