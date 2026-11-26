# WeType 3.0.2 (689) patch profile

This profile applies to the official Tencent-signed universal macOS bundle
with `CFBundleShortVersionString=3.0.2` and `CFBundleVersion=689`. The native
and Flutter AOT patchers use 689-specific thin-file offsets.

## Source fingerprints

SHA-256 hashes from the official bundle:

| File | SHA-256 |
| --- | --- |
| `Contents/MacOS/WeType` | `14677637ee51acda609ec94d66b84a2705bad4c1a5ee09c952ac53159d2b1234` |
| Settings `App.framework/Versions/A/App` | `8239ee2cf3a5c8444e30dea287aadb0f2d5b436059ff1593cafd1fc63ad86ec5` |
| `Contents/Resources/Assets.car` | `d891ca33f0e8ef204d971e8c4e08c9fbf761c04a9d6596e43ef3fa45c8fee8f5` |
| `icon_button_connect.png` | `1bc6ae887c792b3357e133804c6adbe844f47d8b2bdafde76780c1c0b006c34c` |

## Native offsets

All offsets are relative to the extracted Mach-O slice. The selected V-menu
color remains a seven-byte Swift string. Voice channels use normalized doubles.
The top red channel is set by an instruction on ARM64 and loaded from padding
on x86_64, preserving the jump target for the color initializer.

| Surface | ARM64 offset | x86_64 offset |
| --- | --- | --- |
| V-menu selection `#D92D70` | `0x10d78c`, `0x10d790`, `0x10d794`, `0x10d798` | `0x12165f` |
| Native accent `#D92D70` | | `0x71ef60` |
| Voice light accents `#FFA9CA` | | `0x1c5a7e`, `0x1c5f46` |
| Voice solid accents `#D92D70` | | `0x1c5aa4`, `0x1c5f6c`, `0x1c6b64`, `0x1c6cf5` |
| Voice top red | `0x6e5af8` | `0x78c54b` |
| Voice top green and blue | `0x2d1fea0`, `0x2d1fea8` | `0x2019258`, `0x2019260` |
| Voice bottom red, green, and blue | `0x2d137b0`, `0x2d137b8`, `0x2d137c0` | `0x200d438`, `0x200d440`, `0x200d448` |

## Flutter and resources

The 689 patcher maps the points in the 684 AOT table to verified offsets using
these deltas. Each patch still checks its expected source bytes.

| Slice | 684 offsets in the patch table | Delta for 689 |
| --- | --- | --- |
| ARM64 | `0x20c684–0x27b51c` | `-0x1080` |
| ARM64 | `0x289590–0x2895f4` | `-0x718` |
| ARM64 | `0x294fd4–0x29e5f0` | `-0x71c` |
| ARM64 | `0x4eb538–0x4eb624` | `-0x604` |
| x86_64 | `0x28ba63–0x30b9d5` | `-0x10c0` |
| x86_64 | `0x31aa74–0x3312a0` | `-0x6c8` |
| x86_64 | `0x525a25–0x525b11` | `-0x5c5` |

The eleven named color records retain the offsets and expected RGB and alpha
values documented in [the 684 profile](684-reverse-engineering.md#assetscar).
The five SVG source counts and the original 60×60 connect icon are also
identical to 684.

## Validation

The unmodified official bundle passed deep, strict signature verification.
The native and Flutter patchers for both architectures, the named color
patcher, and the SVG patcher were applied to copies of the official files.
A second pass produced identical files. An unexpected native source byte and
a mismatched bundle profile were rejected. The official signing targets and
entitlements were compared with build 684. The patched bundle still needs
local development signing, installation, and a visual check.
