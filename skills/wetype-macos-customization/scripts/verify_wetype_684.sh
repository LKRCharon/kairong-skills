#!/bin/bash

set -euo pipefail

bundle="${1:-}"
script_dir="$(cd "$(dirname "$0")" && pwd)"
if [[ -z "$bundle" ]]; then
    echo "usage: $0 SIGNED_684_BUNDLE" >&2
    exit 2
fi

main="$bundle/Contents/MacOS/WeType"
assets="$bundle/Contents/Resources/Assets.car"
settings_app="$bundle/Contents/MacOS/WeTypeSettings.app"
app_framework="$settings_app/Contents/Frameworks/App.framework/Versions/A/App"
assets_root="$settings_app/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets"
connect_icon="$assets_root/modules/setting/icons/icon_button_connect.png"

[[ -d "$bundle" ]] || { echo "missing bundle: $bundle" >&2; exit 1; }
[[ -f "$main" && -f "$assets" && -d "$settings_app" \
    && -f "$app_framework" && -d "$assets_root" && -f "$connect_icon" ]] || {
    echo "missing required WeType 684 files under: $bundle" >&2
    exit 1
}
[[ -f "$bundle/Contents/PlugIns/WeTypeFinderSync.appex/Contents/MacOS/WeTypeFinderSync" ]] || {
    echo "684 FinderSync extension is missing" >&2
    exit 1
}
[[ -f "$bundle/Contents/Helpers/WeTypeUpdater.app/Contents/MacOS/WeTypeUpdater" ]] || {
    echo "684 updater helper is missing" >&2
    exit 1
}
[[ -f "$bundle/Contents/Resources/BinaryDelta" ]] || {
    echo "684 BinaryDelta helper is missing" >&2
    exit 1
}

short_version=$(/usr/bin/plutil -extract CFBundleShortVersionString raw -o - "$bundle/Contents/Info.plist")
build_version=$(/usr/bin/plutil -extract CFBundleVersion raw -o - "$bundle/Contents/Info.plist")
[[ "$short_version" == "3.0.1" && "$build_version" == "684" ]] || {
    echo "expected WeType 3.0.1 (684), found $short_version ($build_version)" >&2
    exit 1
}

for executable in "$main" "$app_framework"; do
    arch_info=$(/usr/bin/lipo -info "$executable")
    [[ "$arch_info" == *arm64* && "$arch_info" == *x86_64* ]] || {
        echo "expected arm64/x86_64 universal binary: $executable: $arch_info" >&2
        exit 1
    }
done

tmp_dir=$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/wetype684-verify.XXXXXX")
trap '/bin/rm -rf "$tmp_dir"' EXIT

main_arm="$tmp_dir/main-arm64"
main_x86="$tmp_dir/main-x86_64"
app_arm="$tmp_dir/app-arm64"
app_x86="$tmp_dir/app-x86_64"
/usr/bin/lipo -thin arm64 -output "$main_arm" "$main"
/usr/bin/lipo -thin x86_64 -output "$main_x86" "$main"
/usr/bin/lipo -thin arm64 -output "$app_arm" "$app_framework"
/usr/bin/lipo -thin x86_64 -output "$app_x86" "$app_framework"

assert_idempotent() {
    local label="$1"
    local original="$2"
    local probe="$3"
    if ! /usr/bin/cmp -s "$original" "$probe"; then
        echo "$label is not fully patched for build 684" >&2
        exit 1
    fi
}

/bin/cp "$main_arm" "$tmp_dir/main-arm64-probe"
/bin/cp "$main_x86" "$tmp_dir/main-x86_64-probe"
/usr/bin/perl "$script_dir/patch_wetype_684_main.pl" arm64 "$tmp_dir/main-arm64-probe"
/usr/bin/perl "$script_dir/patch_wetype_684_main.pl" x86_64 "$tmp_dir/main-x86_64-probe"
assert_idempotent "ARM64 native layer" "$main_arm" "$tmp_dir/main-arm64-probe"
assert_idempotent "x86_64 native layer" "$main_x86" "$tmp_dir/main-x86_64-probe"

/bin/cp "$app_arm" "$tmp_dir/app-arm64-probe"
/bin/cp "$app_x86" "$tmp_dir/app-x86_64-probe"
/usr/bin/perl "$script_dir/patch_wetype_684_colors.pl" arm64 "$tmp_dir/app-arm64-probe"
/usr/bin/perl "$script_dir/patch_wetype_684_colors.pl" x86_64 "$tmp_dir/app-x86_64-probe"
assert_idempotent "ARM64 Flutter AOT layer" "$app_arm" "$tmp_dir/app-arm64-probe"
assert_idempotent "x86_64 Flutter AOT layer" "$app_x86" "$tmp_dir/app-x86_64-probe"

/bin/cp "$assets" "$tmp_dir/Assets.car"
/usr/bin/perl "$script_dir/patch_wetype_684_assets.pl" "$tmp_dir/Assets.car"
assert_idempotent "Assets.car named-color layer" "$assets" "$tmp_dir/Assets.car"

/usr/bin/perl -MFile::Find=find - "$assets_root" <<'PERL'
use strict;
use warnings;

my ($root) = @ARGV;
my %counts;
my @colors = (
    '#2AE59F', '#23C891', '#00B176', '#1AC785', '#16AC66',
    '#64D2FF', '#007AFF', '#0A84FF',
);
find({
    no_chdir => 1,
    wanted => sub {
        return unless -f $_ && /\.svg\z/;
        open my $fh, '<:raw', $File::Find::name or die "$File::Find::name: $!\n";
        local $/;
        my $data = <$fh>;
        for my $color (@colors) {
            $counts{$color} += () = $data =~ /\Q$color\E/g;
        }
    },
}, $root);

for my $old ('#2AE59F', '#23C891', '#00B176', '#1AC785', '#16AC66') {
    die "old SVG color remains: $old count=$counts{$old}\n" if ($counts{$old} // 0) != 0;
}
my %expected = (
    '#64D2FF' => 4,
    '#007AFF' => 15,
    '#0A84FF' => 2,
);
for my $target (sort keys %expected) {
    my $actual = $counts{$target} // 0;
    die "unexpected SVG target count for $target: got $actual, expected $expected{$target}\n"
        unless $actual == $expected{$target};
}
print "684 SVG palette verified\n";
PERL

icon_verifier="$tmp_dir/verify_connect_icon"
/usr/bin/clang -fobjc-arc \
    -framework Foundation -framework CoreGraphics -framework ImageIO \
    "$script_dir/verify_connect_icon.m" -o "$icon_verifier"
"$icon_verifier" "$connect_icon"

/usr/bin/codesign --verify --deep --strict --verbose=2 "$bundle"
signature_details=$(/usr/bin/codesign -d --verbose=4 "$bundle" 2>&1)
/usr/bin/grep -q '^Authority=' <<<"$signature_details" || {
    echo "refusing an ad-hoc or authority-less signature" >&2
    exit 1
}
/usr/bin/grep -q '^TeamIdentifier=' <<<"$signature_details" || {
    echo "signed bundle has no TeamIdentifier" >&2
    exit 1
}

echo "WeType 3.0.1 (684) Apple Blue bundle verified: $bundle"
