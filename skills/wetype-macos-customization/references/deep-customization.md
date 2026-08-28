# Deep customization method

## Choose the correct layer

The 657 package has three different code/resource layers:

1. Native Swift/AppKit/InputMethodKit code in `Contents/MacOS/WeType`.
2. Flutter AOT machine code in `WeTypeSettings.app/.../App.framework`.
3. Flutter assets and the top-level `Contents/Resources/Assets.car`.

A screen can combine more than one layer. A green settings preview does not
prove that the candidate or voice view uses the same constant.

## Discovery loop

Work from a fresh official copy and record a hash before patching:

```bash
/usr/bin/shasum -a 256 "$OFFICIAL/Contents/MacOS/WeType"
/usr/bin/file "$OFFICIAL/Contents/MacOS/WeType"
/usr/bin/lipo -thin arm64 -output /tmp/wetype-arm64 \
  "$OFFICIAL/Contents/MacOS/WeType"
/usr/bin/lipo -thin x86_64 -output /tmp/wetype-x86_64 \
  "$OFFICIAL/Contents/MacOS/WeType"
/usr/bin/strings -a /tmp/wetype-arm64 \
  | /usr/bin/grep -i -E 'green|voice|mode|gradient'
/usr/bin/otool -arch arm64 -tV "$OFFICIAL/Contents/MacOS/WeType" \
  | /usr/bin/grep -A12 -B4 'VModeMenuItemView'
```

For Flutter AOT, thin `App.framework` separately. The virtual address printed
by `otool` is not automatically a file offset in a fat Mach-O. Use the thin
file offset in the patcher and inspect the bytes with `xxd -s OFFSET`.

Use `blutter` or another Flutter AOT disassembler only when needed to map a
closure/function to a screen. Keep the disassembler output as evidence; do not
guess an offset from a screenshot.

## 657 surface map

The exact offsets and old/new bytes are in
`657-reverse-engineering.md`. The key mapping is:

| Target | 657 source | Apple Blue target |
| --- | --- | --- |
| native V-menu | ARM64 MOVK / x86 ASCII `#00B176` | `#007AFF` |
| native voice top | normalized `#00D48E` | `#0A84FF` |
| native voice bottom | normalized `#23C891` | `#0040DD` |
| ExampleBox | four AOT green stops | `#64D2FF -> #0A84FF -> #007AFF -> #0051D5` |
| buttons | separate AOT groups | `#0A84FF -> #0040DD` |
| named candidate colors | `Assets.car` records | exact `#007AFF` / `#0051D5` |
| connect icon | 60x60 RGBA `icon_button_connect.png` | non-transparent pixels `#007AFF` |

Keep the four-stop ExampleBox gradient separate from the two-stop button and
voice gradients. This is what prevented the pale flat panel regression.

## Encoding rules

### ARM64 immediates

Some short ASCII literals are assembled through `MOVZ`/`MOVK` instructions.
Patch only the immediate bits while preserving the destination register and
instruction shape. For the 657 V-menu selected color, the anchor at thin-file
offset `0xf8ee8` must remain unchanged; the following three words encode the
replacement `#007AFF`.

### x86_64 immediates and literals

x86_64 may store the same value as an ASCII literal or as an immediate in an
instruction. The 657 patcher uses the instruction start and writes the
immediate at `offset + 1` where appropriate. Do not assume ARM64 offsets match
x86_64 offsets.

### Normalized doubles

Native voice and `Assets.car` RGB values may be stored as IEEE-754 doubles:

```text
value = channel / 255
```

The bytes are little-endian on disk. Use a structured packer such as Perl's
`pack('d', $channel / 255)` and assert the exact old bytes before replacing
them. A decimal string replacement cannot reach these values.

### PNG and SVG

SVG color literals can be replaced only in the intended asset root. For PNG,
decode to RGBA, preserve every alpha byte, and recolor non-transparent pixels;
do not flatten antialiasing or replace a nearby SVG that happens to look
similar. The 657 connect icon is the example guarded by
`patch_wetype_657_connect_icon.m`.

## Adding a new patch

Use this low-level contract:

1. Name the exact version and file in the patcher output.
2. Verify the old value/count at the intended location.
3. Accept an already patched target only if the target bytes are exact.
4. Fail on any other value, short read, architecture mismatch, or resource
   dimension mismatch.
5. Keep arm64 and x86_64 code paths separate.
6. Rebuild from the official copy rather than stacking patches on a prior
   custom output.
7. Extend the verifier with the new expected value.
8. Test the actual UI surface in at least TextEdit and one target host.

Never use `codesign --sign -`, binary-wide color substitution, unguarded
offsets, or a patch that silently succeeds with an unknown old value.

## Updating beyond 657

Treat every new WeType build as a new reverse-engineering target. Re-check:

- version and architectures;
- symbol/function locations;
- thin-file offsets;
- AOT closure groups;
- resource dimensions and named-color records;
- nested bundle layout and entitlements;
- FinderSync/helper additions;
- input-source identifiers.

Do not reuse the 657 patchers on any other build without re-deriving the
offsets and updating both the reference and verifier first.
