#!/bin/bash

set -euo pipefail

bundle="${1:-}"
script_dir="$(cd "$(dirname "$0")" && pwd)"
if [[ -z "$bundle" ]]; then
    echo "usage: $0 SIGNED_637_BUNDLE" >&2
    exit 2
fi
main="$bundle/Contents/MacOS/WeType"
assets="$bundle/Contents/Resources/Assets.car"
settings_app="$bundle/Contents/MacOS/WeTypeSettings.app"
app_framework="$settings_app/Contents/Frameworks/App.framework/Versions/A/App"
connect_icon="$settings_app/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/modules/setting/icons/icon_button_connect.png"

[[ -d "$bundle" ]] || { echo "missing bundle: $bundle" >&2; exit 1; }
[[ -f "$main" && -f "$assets" && -d "$settings_app" && -f "$app_framework" && -f "$connect_icon" ]] || {
    echo "missing required WeType 637 files under: $bundle" >&2
    exit 1
}

short_version=$(/usr/bin/plutil -extract CFBundleShortVersionString raw -o - "$bundle/Contents/Info.plist")
build_version=$(/usr/bin/plutil -extract CFBundleVersion raw -o - "$bundle/Contents/Info.plist")
[[ "$short_version" == "2.2.1" && "$build_version" == "637" ]] || {
    echo "expected WeType 2.2.1 (637), found $short_version ($build_version)" >&2
    exit 1
}

arch_info=$(/usr/bin/lipo -info "$main")
[[ "$arch_info" == *arm64* && "$arch_info" == *x86_64* ]] || {
    echo "main executable is not the expected arm64/x86_64 universal binary: $arch_info" >&2
    exit 1
}

tmp_dir=$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/wetype637-verify.XXXXXX")
trap '/bin/rm -rf "$tmp_dir"' EXIT
arm="$tmp_dir/arm64"
x86="$tmp_dir/x86_64"
app_arm="$tmp_dir/app-arm64"
app_x86="$tmp_dir/app-x86_64"
/usr/bin/lipo -thin arm64 -output "$arm" "$main"
/usr/bin/lipo -thin x86_64 -output "$x86" "$main"
/usr/bin/lipo -thin arm64 -output "$app_arm" "$app_framework"
/usr/bin/lipo -thin x86_64 -output "$app_x86" "$app_framework"

/usr/bin/perl - "$arm" "$x86" "$app_arm" "$app_x86" <<'PERL'
use strict;
use warnings;

my ($arm_path, $x86_path, $app_arm_path, $app_x86_path) = @ARGV;

sub read_file {
    my ($path) = @_;
    open my $fh, '<:raw', $path or die "$path: $!\n";
    local $/;
    return <$fh>;
}

sub expect_hex {
    my ($data, $offset, $expected, $label) = @_;
    my $actual = unpack('H*', substr($data, $offset, length(pack('H*', $expected))));
    die sprintf("%s at 0x%x: got %s, expected %s\n", $label, $offset, $actual, $expected)
        unless lc($actual) eq lc($expected);
}

sub expect_double {
    my ($data, $offset, $value, $label) = @_;
    my $expected = unpack('H*', pack('d', $value / 255));
    expect_hex($data, $offset, $expected, $label);
}

sub expect_arm_movz {
    my ($data, $offset, $imm16, $shift, $label) = @_;
    my $actual = unpack('V', substr($data, $offset, 4));
    my $reg = $actual & 0x1f;
    my $expected = 0xd2800000
        | (($shift / 16) << 21)
        | (($imm16 & 0xffff) << 5)
        | $reg;
    die sprintf("%s at 0x%x: got %08x, expected %08x\n",
        $label, $offset, $actual, $expected)
        unless $actual == $expected;
}

sub expect_arm_sparse_group {
    my ($data, $g_offset, $b_offset, $g, $b, $label) = @_;
    expect_arm_movz($data, $g_offset, $g, 0, "$label green");
    expect_arm_movz($data, $b_offset, $b, 0, "$label blue");
}

sub expect_x86_color_group {
    my ($data, $r_offset, $g_offset, $b_offset, $r, $g, $b, $label) = @_;
    expect_hex($data, $r_offset + 1, unpack('H*', pack('V', $r << 16)), "$label red");
    expect_hex($data, $g_offset + 1, unpack('H*', pack('V', $g << 8)), "$label green");
    expect_hex($data, $b_offset + 1, unpack('H*', pack('V', $b)), "$label blue");
}

sub expect_x86_sparse_group {
    my ($data, $g_offset, $b_offset, $g, $b, $label) = @_;
    expect_hex($data, $g_offset + 1, unpack('H*', pack('V', $g << 8)), "$label green");
    expect_hex($data, $b_offset + 1, unpack('H*', pack('V', $b)), "$label blue");
}

my $arm = read_file($arm_path);
my $x86 = read_file($x86_path);
my $app_arm = read_file($app_arm_path);
my $app_x86 = read_file($app_x86_path);

expect_hex($arm, 0x7c628, '00e6a6f2', 'ARM64 V-menu immediate 1');
expect_hex($arm, 0x7c62c, '20c8c8f2', 'ARM64 V-menu immediate 2');
expect_hex($arm, 0x7c630, 'c008e0f2', 'ARM64 V-menu immediate 3');

for my $item (
    [0x2cdc1b0, 132, 'ARM64 voice top green'],
    [0x2cdc1b8, 255, 'ARM64 voice top blue'],
    [0x2cd3978, 0,   'ARM64 voice bottom red'],
    [0x2cd3980, 64,  'ARM64 voice bottom green'],
    [0x2cd3988, 221, 'ARM64 voice bottom blue'],
) {
    expect_double($arm, $item->[0], $item->[1], $item->[2]);
}

for my $item (
    [0x1c270c8, 132, 'x86_64 voice top green'],
    [0x1c270d0, 255, 'x86_64 voice top blue'],
    [0x1c1eb78, 0,   'x86_64 voice bottom red'],
    [0x1c1eb80, 64,  'x86_64 voice bottom green'],
    [0x1c1eb88, 221, 'x86_64 voice bottom blue'],
) {
    expect_double($x86, $item->[0], $item->[1], $item->[2]);
}

# The screenshot button families are separate AOT color groups. Verify both
# ends of each gradient so a future patch cannot silently flatten or leave one
# of these buttons green.
for my $item (
    [0x232c00, 0x232c08, 0x232c10, 0x000a, 0x8400, 0x00ff, 'ARM64 common button gradient 1'],
    [0x232c5c, 0x232c64, 0x232c6c, 0x0000, 0x4000, 0x00dd, 'ARM64 common button gradient 2'],
    [0x23855c, 0x238564, 0x23856c, 0x0000, 0x4000, 0x00dd, 'ARM64 multi-device gradient 1 end'],
    [0x2387c8, 0x2387d0, 0x2387d8, 0x0000, 0x4000, 0x00dd, 'ARM64 multi-device gradient 2 end'],
    [0x2a34a4, 0x2a34ac, 0x2a34b4, 0x0000, 0x4000, 0x00dd, 'ARM64 phone download gradient 2 end'],
) {
    my ($r_offset, $g_offset, $b_offset, $r, $g, $blue, $label) = @$item;
    expect_arm_movz($app_arm, $r_offset, $r, 16, "$label red");
    expect_arm_movz($app_arm, $g_offset, $g, 0, "$label green");
    expect_arm_movz($app_arm, $b_offset, $blue, 0, "$label blue");
}

for my $item (
    [0x238508, 0x238510, 0x8400, 0x00ff, 'ARM64 multi-device gradient 1 start'],
    [0x238774, 0x23877c, 0x8400, 0x00ff, 'ARM64 multi-device gradient 2 start'],
    [0x2a3450, 0x2a3458, 0x8400, 0x00ff, 'ARM64 phone download gradient 1 start'],
) {
    expect_arm_sparse_group($app_arm, @$item);
}

for my $item (
    [0x29adab, 0x29adb2, 0x29adb9, 0x0a, 0x84, 0xff, 'x86_64 common button gradient 1'],
    [0x29ae04, 0x29ae0b, 0x29ae12, 0x00, 0x40, 0xdd, 'x86_64 common button gradient 2'],
    [0x30f21e, 0x30f225, 0x30f22c, 0x00, 0x40, 0xdd, 'x86_64 multi-device gradient 1 end'],
    [0x31b7b5, 0x31b7bc, 0x31b7c3, 0x00, 0x40, 0xdd, 'x86_64 multi-device gradient 2 end'],
    [0x3216ce, 0x3216d5, 0x3216dc, 0x00, 0x40, 0xdd, 'x86_64 phone download gradient 2 end'],
) {
    expect_x86_color_group($app_x86, @$item);
}

for my $item (
    [0x30f1cc, 0x30f1d3, 0x84, 0xff, 'x86_64 multi-device gradient 1 start'],
    [0x31b763, 0x31b76a, 0x84, 0xff, 'x86_64 multi-device gradient 2 start'],
    [0x32167c, 0x321683, 0x84, 0xff, 'x86_64 phone download gradient 1 start'],
) {
    expect_x86_sparse_group($app_x86, @$item);
}

print "Flutter 637 button gradients verified: #0A84FF -> #0040DD\n";

for my $old ('#00B176', '#23C891', '#62c999', '#34C759') {
    die "old native literal remains in x86_64: $old\n" if index($x86, $old) >= 0;
}

print "native 637 color bytes verified\n";
PERL

/usr/bin/codesign --verify --deep --strict "$bundle"
/usr/bin/swift "$script_dir/verify_connect_icon.swift" "$connect_icon"
[[ -f "$bundle/Contents/PlugIns/WeTypeFinderSync.appex/Contents/MacOS/WeTypeFinderSync" ]] || {
    echo "637 FinderSync extension is missing" >&2
    exit 1
}

echo "WeType 2.2.1 (637) Apple Blue bundle verified: $bundle"
