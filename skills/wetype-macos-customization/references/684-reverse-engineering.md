# WeType 3.0.1 (684) reverse-engineering record

This profile is for the WeType macOS bundle whose main `Info.plist` reports
`CFBundleShortVersionString=3.0.1` and `CFBundleVersion=684`. It was derived
from a Tencent-signed universal bundle. The offsets are specific to this build
and must not be used for another release.

The profile was reverse-engineered from the official bundle. On 2026-11-18 the
previous blue build was signed and its 684 verifier passed. On 2026-11-19 it
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

The `#00B176` V-menu color is assembled from MOVK fragments. The four instructions encode the selected color:

```text
0x10c004  60 04 86 d2  -> 60 84 88 d2
0x10c008  00 46 a8 f2  -> 20 47 a6 f2
0x10c00c  20 e6 c6 f2  -> 80 e8 c6 f2
0x10c010  c0 06 e0 f2  -> 00 06 e0 f2
```

### x86_64 native literals

| Source | Target | Thin-file offsets |
| --- | --- | --- |
| `#00B176` | `#D92D70` | `0x11f8af` |
| `#23C891` | `#D92D70` | `0x6fd560` |
| `#62c999` | `#FFA9CA` | `0x1c1a6e`, `0x1c1f36` |
| `#34C759` | `#D92D70` | `0x1c1a94`, `0x1c1f5c`, `0x1c2b54`, `0x1c2ce5` |

### Native voice gradient

Voice colors are normalized little-endian IEEE-754 doubles, with each channel
stored as `channel / 255`. The rose-pink gradient is `#FF6D9C -> #A91650`.

| Slice | Offset | Channel | Source | Target |
| --- | ---: | --- | ---: | ---: |
| arm64 | `0x2cfeee0` | top G | 212 | 109 |
| arm64 | `0x2cfeee8` | top B | 142 | 156 |
| arm64 | `0x2cf28c0` | bottom R | 35 | 169 |
| arm64 | `0x2cf28c8` | bottom G | 200 | 22 |
| arm64 | `0x2cf28d0` | bottom B | 145 | 80 |
| x86_64 | `0x1ff52b8` | top G | 212 | 109 |
| x86_64 | `0x1ff52c0` | top B | 142 | 156 |
| x86_64 | `0x1fe9538` | bottom R | 35 | 169 |
| x86_64 | `0x1fe9540` | bottom G | 200 | 22 |
| x86_64 | `0x1fe9548` | bottom B | 145 | 80 |

The source top-red register is zero. The arm64 patch loads 1.0 at
`0x6c757c`, and the x86_64 patch loads 1.0 from inline alignment padding
at `0x76adbb` before jumping to the same initializer.

## Flutter AOT

### Static palette records

The source/target byte patterns are guarded at each offset in both thin slices.

| Record | arm64 offset | x86_64 offset | Source bytes | Target bytes |
| --- | ---: | ---: | --- | --- |
| root | `0x4eb60b` | `0x525af8` | `11110fb9c0` | `705a64bec0` |
| variant 1 | `0x4eb610` | `0x525afd` | `6f5002b8` | `705a64be` |
| variant 2 | `0x4eb61f` | `0x525b0c` | `766202b8` | `75617fbf` |
| variant 3 | `0x4eb538` | `0x525a25` | `0e2903b8` | `705a64be` |
| variant 4 | `0x4eb582` | `0x525a6f` | `66585ab8` | `705a64be` |
| variant 5 | `0x4eb624` | `0x525b11` | `706f23bf` | `75617fbf` |

### Instruction groups

These are instruction starts in the thin AOT slices. Full groups list red,
green, and blue offsets. Sparse groups list only green and blue. The patcher
preserves registers and instruction shape and checks every source instruction.

| Surface / source color | arm64 offsets | x86_64 offsets | Rose-pink target |
| --- | --- | --- | --- |
| Common button gradient 1 `#25CE96` | `20c684/68c/694` | `28ba63/6a/71` | `#F46D9C` |
| Common button gradient 2 `#1FC38D` | `20c6e0/6e8/6f0` | `28babc/c3/ca` | `#A91650` |
| Input settings accent `#23C891` | `20ec98/a0/a8` | `28e3ea/f1/f8` | `#D92D70` |
| Device gradient 1 start `#00D48E` | `212e74/7c` | `292a5a/61` | `#F46D9C` |
| Device gradient 1 end `#23C891` | `212ec8/d0/d8` | `292aac/b3/ba` | `#A91650` |
| Device gradient 2 start `#00D48E` | `2130e0/e8` | `292cc5/cc` | `#F46D9C` |
| Device gradient 2 end `#23C891` | `213134/13c/144` | `292d17/1e/25` | `#A91650` |
| Device accent `#23C891` | `213694/69c/6a4` | `2932d8/df/e6` | `#D92D70` |
| About/debug accent `#23C891` | `2785e8/f0/f8` | `3087bb/c2/c9` | `#D92D70` |
| Appearance stop 1 `#6AFFCD` | `27b3d4/dc/e4` | `30b893/89a/8a1` | `#FFA9CA` |
| Appearance stop 2 `#23C891` | `27b434/3c/44` | `30b8f0/f7/fe` | `#F46D9C` |
| Appearance stop 3 `#6AFF8B` | `27b4a8/b0/b8` | `30b965/6c/73` | `#D92D70` |
| Appearance stop 4 `#58C823` | `27b50c/14/1c` | `30b9c7/9ce/9d5` | `#B71D56` |
| Hotword gradient start `#00D48E` | `289590/98` | `31aa74/7b` | `#FFA9CA` |
| Hotword accent `#23C891` | `2895e4/ec/f4` | `31aac6/cd/d4` | `#D92D70` |
| Multi-device accent `#23C891` | `295028/30/38` | `327291/98/29f` | `#D92D70` |
| Multi-device gradient start `#00D48E` | `294fd4/dc` | `32723f/46` | `#FFA9CA` |
| Phone preview stops 1-4 | `29a494/9c/4a4`, `29a4f0/f8/500`, `29a55c/564/56c`, `29a5c0/c8/d0` | `32cc80/87/8e`, `32ccda/e1/e8`, `32cd48/4f/56`, `32cdaa/b1/b8` | `#FF9FC4`, `#F46D9C`, `#D92D70`, `#B71D56` |
| Phone download start `#00D48E` | `29aae4/ec` | `32d32c/33` | `#F46D9C` |
| Phone download end `#23C891` | `29ab38/40/48` | `32d37e/85/8c` | `#A91650` |
| Toolbar preview stops 1-4 | `29e4a8/b0/b8`, `29e508/10/18`, `29e57c/84/8c`, `29e5e0/e8/f0` | `33115e/65/6c`, `3311bb/c2/c9`, `331230/37/3e`, `331292/99/2a0` | `#FF9FC4`, `#F46D9C`, `#D92D70`, `#B71D56` |

The 657 branch-preload pair has no matching `#00D48E` group in the 684 slices
and is not included in this profile. Do not add it back without locating a
684-specific source instruction.

## SVG and PNG assets

The 684 Flutter SVG tree has these exact source counts:

```text
#2AE59F: 4  -> #FFA9CA
#23C891: 12 -> #D92D70
#00B176: 2  -> #D92D70
#16AC66: 1  -> #D92D70
#1AC785: 2  -> #F46D9C
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
| bg03 default | `0x6ab3f4` | `0,177,118` | `217,45,112` |
| bg03 Aqua | `0x73a7a4` | `0,177,118` | `217,45,112` |
| bg03 DarkAqua | `0x7389f4` | `0,168,111` | `217,45,112` |
| bc16 default | `0x6ab784` | `22,172,102` | `217,45,112` |
| bc16 Aqua | `0x73a674` | `22,172,102` | `217,45,112` |
| bc16 DarkAqua | `0x738eb4` | `0,212,142` | `183,29,86` |
| bg02 default | `0x6abfd4` | `232,247,240` | `255,240,245` |
| bg02 Aqua | `0x73a544` | `232,247,240` | `255,240,245` |
| bg04 default | `0x6ac494` | `35,200,145` | `217,45,112` |
| bg04 DarkAqua | `0x739a94` | `35,200,145` | `217,45,112` |
| bg04 Aqua | `0x73b844` | `35,200,145` | `217,45,112` |

## Signing layout and validation status

The inspected 684 bundle contains the same signing target paths used by the
657 signing workflow, including Settings, Feedback, Sparkle, root frameworks,
`BinaryDelta`, the updater helper, and FinderSync. The 684 local-signing pass
and deep signature verification succeeded with an Apple Development identity.

The previous blue 684 patch map was applied to a separate copy of the Tencent-signed bundle.
The unsigned build completed, the Apple Development signing pass completed, and
`verify_wetype_684.sh` passed, including idempotence checks for both
architectures, named colors, SVG counts, the connect icon, nested code, and the
deep signature. The installed bundle passed strict signature and input-source
checks, and the user confirmed that the local rendering is blue.
