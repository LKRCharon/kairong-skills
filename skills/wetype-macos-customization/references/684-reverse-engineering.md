# WeType 3.0.1 (684) reverse-engineering record

This profile is for the WeType macOS bundle whose main `Info.plist` reports
`CFBundleShortVersionString=3.0.1` and `CFBundleVersion=684`. It was derived
from a Tencent-signed universal bundle. The offsets are specific to this build
and must not be used for another release.

The profile was reverse-engineered from the official bundle. On 2026-11-18 the
custom app was built and signed, and the 684 verifier passed. On 2026-11-19 it
was installed on the target Mac, strict signature and input-source checks
passed, and the user confirmed blue rendering. This is local evidence for this
build and machine, not a guarantee for other builds or host applications.

## Source fingerprint and layout

SHA-256 values for the inspected official bundle:

```text
Contents/MacOS/WeType
91cb8e4bf84f68d9aa81c777ed3ec3fbc0a2fec9664ad189f007d3ed6460ffa3

WeTypeSettings.app/.../App.framework/Versions/A/App
3ce7f1dea1549971a4a9c650b5bd8e62e88168cc1399b25f315650504a1036d1

Contents/Resources/Assets.car
e2795fb098fa0b8a19c942099de6c1b20802a45158803feb80ff370b26c04c6c

.../flutter_assets/assets/modules/setting/icons/icon_button_connect.png
1bc6ae887c792b3357e133804c6adbe844f47d8b2bdafde76780c1c0b006c34c
```

The native executable and Flutter AOT framework each contain `arm64` and
`x86_64` slices. Thin each file before using its offsets. Offsets below are
thin-file offsets, not universal-binary offsets or virtual addresses.

| Surface | File |
| --- | --- |
| Native V-menu and voice view | `Contents/MacOS/WeType` |
| Settings, appearance, and tool previews | `WeTypeSettings.app/.../App.framework/Versions/A/App` |
| Candidate and V-menu named colors | `Contents/Resources/Assets.car` |
| Settings SVG and PNG assets | `App.framework/.../flutter_assets/assets` |

## Native V-menu and voice

### ARM64 selected V-menu color

The `#00B176` V-menu color is assembled from MOVK fragments. The anchor is
unchanged; the next three instructions encode the color:

```text
0x10c004  60 04 86 d2  anchor, unchanged
0x10c008  00 46 a8 f2  -> 00 e6 a6 f2
0x10c00c  20 e6 c6 f2  -> 20 c8 c8 f2
0x10c010  c0 06 e0 f2  -> c0 08 e0 f2
```

### x86_64 native literals

| Source | Target | Thin-file offsets |
| --- | --- | --- |
| `#00B176` | `#007AFF` | `0x11f8af` |
| `#23C891` | `#007AFF` | `0x6fd560` |
| `#62c999` | `#64D2FF` | `0x1c1a6e`, `0x1c1f36` |
| `#34C759` | `#007AFF` | `0x1c1a94`, `0x1c1f5c`, `0x1c2b54`, `0x1c2ce5` |

### Native voice gradient

Voice colors are normalized little-endian IEEE-754 doubles, with each channel
stored as `channel / 255`. The intended gradient is `#0A84FF -> #0040DD`.

| Slice | Offset | Channel | Source | Target |
| --- | ---: | --- | ---: | ---: |
| arm64 | `0x2cfeee0` | top G | 212 | 132 |
| arm64 | `0x2cfeee8` | top B | 142 | 255 |
| arm64 | `0x2cf28c0` | bottom R | 35 | 0 |
| arm64 | `0x2cf28c8` | bottom G | 200 | 64 |
| arm64 | `0x2cf28d0` | bottom B | 145 | 221 |
| x86_64 | `0x1ff52b8` | top G | 212 | 132 |
| x86_64 | `0x1ff52c0` | top B | 142 | 255 |
| x86_64 | `0x1fe9538` | bottom R | 35 | 0 |
| x86_64 | `0x1fe9540` | bottom G | 200 | 64 |
| x86_64 | `0x1fe9548` | bottom B | 145 | 221 |

The top red channel is already zero and is not patched.

## Flutter AOT

### Static palette records

The source/target byte patterns are guarded at each offset in both thin slices.

| Record | arm64 offset | x86_64 offset | Source bytes | Target bytes |
| --- | ---: | ---: | --- | --- |
| root | `0x4eb60b` | `0x525af8` | `11110fb9c0` | `7f7501b8c0` |
| variant 1 | `0x4eb610` | `0x525afd` | `6f5002b8` | `7f7501b8` |
| variant 2 | `0x4eb61f` | `0x525b0c` | `766202b8` | `7f6317bf` |
| variant 3 | `0x4eb538` | `0x525a25` | `0e2903b8` | `7f7501b8` |
| variant 4 | `0x4eb582` | `0x525a6f` | `66585ab8` | `7f7501b8` |
| variant 5 | `0x4eb624` | `0x525b11` | `706f23bf` | `7f6317bf` |

### Instruction groups

These are instruction starts in the thin AOT slices. Full groups list red,
green, and blue offsets. Sparse groups list only green and blue. The patcher
preserves registers and instruction shape and checks every source instruction.

| Surface / source color | arm64 offsets | x86_64 offsets | Apple Blue target |
| --- | --- | --- | --- |
| Common button gradient 1 `#25CE96` | `20c684/68c/694` | `28ba63/6a/71` | `#0A84FF` |
| Common button gradient 2 `#1FC38D` | `20c6e0/6e8/6f0` | `28babc/c3/ca` | `#0040DD` |
| Input settings accent `#23C891` | `20ec98/a0/a8` | `28e3ea/f1/f8` | `#007AFF` |
| Device gradient 1 start `#00D48E` | `212e74/7c` | `292a5a/61` | `#0A84FF` |
| Device gradient 1 end `#23C891` | `212ec8/d0/d8` | `292aac/b3/ba` | `#0040DD` |
| Device gradient 2 start `#00D48E` | `2130e0/e8` | `292cc5/cc` | `#0A84FF` |
| Device gradient 2 end `#23C891` | `213134/13c/144` | `292d17/1e/25` | `#0040DD` |
| Device accent `#23C891` | `213694/69c/6a4` | `2932d8/df/e6` | `#007AFF` |
| About/debug accent `#23C891` | `2785e8/f0/f8` | `3087bb/c2/c9` | `#007AFF` |
| Appearance stop 1 `#6AFFCD` | `27b3d4/dc/e4` | `30b893/89a/8a1` | `#64D2FF` |
| Appearance stop 2 `#23C891` | `27b434/3c/44` | `30b8f0/f7/fe` | `#0A84FF` |
| Appearance stop 3 `#6AFF8B` | `27b4a8/b0/b8` | `30b965/6c/73` | `#007AFF` |
| Appearance stop 4 `#58C823` | `27b50c/14/1c` | `30b9c7/9ce/9d5` | `#0051D5` |
| Hotword gradient start `#00D48E` | `289590/98` | `31aa74/7b` | `#64D2FF` |
| Hotword accent `#23C891` | `2895e4/ec/f4` | `31aac6/cd/d4` | `#007AFF` |
| Multi-device accent `#23C891` | `295028/30/38` | `327291/98/29f` | `#007AFF` |
| Multi-device gradient start `#00D48E` | `294fd4/dc` | `32723f/46` | `#64D2FF` |
| Phone preview stops 1-4 | `29a494/9c/4a4`, `29a4f0/f8/500`, `29a55c/564/56c`, `29a5c0/c8/d0` | `32cc80/87/8e`, `32ccda/e1/e8`, `32cd48/4f/56`, `32cdaa/b1/b8` | `#5AC8FA`, `#0A84FF`, `#007AFF`, `#0051D5` |
| Phone download start `#00D48E` | `29aae4/ec` | `32d32c/33` | `#0A84FF` |
| Phone download end `#23C891` | `29ab38/40/48` | `32d37e/85/8c` | `#0040DD` |
| Toolbar preview stops 1-4 | `29e4a8/b0/b8`, `29e508/10/18`, `29e57c/84/8c`, `29e5e0/e8/f0` | `33115e/65/6c`, `3311bb/c2/c9`, `331230/37/3e`, `331292/99/2a0` | `#5AC8FA`, `#0A84FF`, `#007AFF`, `#0051D5` |

The 657 branch-preload pair has no matching `#00D48E` group in the 684 slices
and is not included in this profile. Do not add it back without locating a
684-specific source instruction.

## SVG and PNG assets

The 684 Flutter SVG tree has these exact source counts:

```text
#2AE59F: 4  -> #64D2FF
#23C891: 12 -> #007AFF
#00B176: 2  -> #007AFF
#16AC66: 1  -> #007AFF
#1AC785: 2  -> #0A84FF
```

`icon_button_connect.png` remains 60x60 RGBA and its SHA-256 matches the
657-profile asset. The existing alpha-preserving ImageIO patch method applies
to this identified asset.

## Assets.car

`assetutil --info` associates each named color and appearance with the source
RGBA values below. The guarded offsets point to the first normalized double;
the patcher changes RGB and preserves alpha.

| Name / appearance | Offset | Source RGB | Target RGB |
| --- | ---: | --- | --- |
| bg03 default | `0x6ab3f4` | `0,177,118` | `0,122,255` |
| bg03 Aqua | `0x73a7a4` | `0,177,118` | `0,122,255` |
| bg03 DarkAqua | `0x7389f4` | `0,168,111` | `0,122,255` |
| bc16 default | `0x6ab784` | `22,172,102` | `0,122,255` |
| bc16 Aqua | `0x73a674` | `22,172,102` | `0,122,255` |
| bc16 DarkAqua | `0x738eb4` | `0,212,142` | `0,81,213` |
| bg02 default | `0x6abfd4` | `232,247,240` | `234,243,255` |
| bg02 Aqua | `0x73a544` | `232,247,240` | `234,243,255` |
| bg04 default | `0x6ac494` | `35,200,145` | `0,122,255` |
| bg04 DarkAqua | `0x739a94` | `35,200,145` | `0,122,255` |
| bg04 Aqua | `0x73b844` | `35,200,145` | `0,122,255` |

## Signing layout and validation status

The inspected 684 bundle contains the same signing target paths used by the
657 signing workflow, including Settings, Feedback, Sparkle, root frameworks,
`BinaryDelta`, the updater helper, and FinderSync. The 684 local-signing pass
and deep signature verification succeeded with an Apple Development identity.

The 684 patch map was applied to a separate copy of the Tencent-signed bundle.
The unsigned build completed, the Apple Development signing pass completed, and
`verify_wetype_684.sh` passed, including idempotence checks for both
architectures, named colors, SVG counts, the connect icon, nested code, and the
deep signature. The installed bundle passed strict signature and input-source
checks, and the user confirmed that the local rendering is blue.
