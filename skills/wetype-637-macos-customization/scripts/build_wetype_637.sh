#!/bin/bash

set -euo pipefail

official="${1:-}"
custom="${2:-}"
script_dir="$(cd "$(dirname "$0")" && pwd)"

if [[ -z "$official" || -z "$custom" ]]; then
    echo "usage: $0 OFFICIAL_637_BUNDLE NEW_CUSTOM_BUNDLE" >&2
    exit 2
fi
if [[ "$custom" == "/Library/Input Methods/WeType.app" ]]; then
    echo "refusing to write the installed input method" >&2
    exit 2
fi
if [[ -e "$custom" ]]; then
    echo "output already exists; choose a new path: $custom" >&2
    exit 2
fi

main_source="$official/Contents/MacOS/WeType"
short_version=$(/usr/bin/plutil -extract CFBundleShortVersionString raw -o - "$official/Contents/Info.plist")
build_version=$(/usr/bin/plutil -extract CFBundleVersion raw -o - "$official/Contents/Info.plist")
if [[ "$short_version" != "2.2.1" || "$build_version" != "637" ]]; then
    echo "expected WeType 2.2.1 (637), found $short_version ($build_version)" >&2
    exit 1
fi
if [[ ! -d "$official" || ! -f "$main_source" ]]; then
    echo "missing official bundle or main executable: $official" >&2
    exit 1
fi
arch_info=$(/usr/bin/lipo -info "$main_source")
if [[ "$arch_info" != *arm64* || "$arch_info" != *x86_64* ]]; then
    echo "expected universal arm64/x86_64 main executable: $arch_info" >&2
    exit 1
fi
/usr/bin/codesign --verify --deep --strict "$official"

tmp_root=$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/wetype637-build.XXXXXX")
trap '/bin/rm -rf "$tmp_root"' EXIT
bundle="$tmp_root/WeType-637-custom.bundle"
/usr/bin/ditto "$official" "$bundle"

main="$bundle/Contents/MacOS/WeType"
app="$bundle/Contents/MacOS/WeTypeSettings.app"
app_framework="$app/Contents/Frameworks/App.framework/Versions/A/App"
assets_root="$app/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets"
connect_icon="$assets_root/modules/setting/icons/icon_button_connect.png"

main_arm="$tmp_root/main-arm64"
main_x86="$tmp_root/main-x86_64"
main_universal="$tmp_root/main-universal"
/usr/bin/lipo -thin arm64 -output "$main_arm" "$main"
/usr/bin/lipo -thin x86_64 -output "$main_x86" "$main"
/usr/bin/perl "$script_dir/patch_wetype_637_main.pl" arm64 "$main_arm"
/usr/bin/perl "$script_dir/patch_wetype_637_main.pl" x86_64 "$main_x86"
/usr/bin/lipo -create "$main_arm" "$main_x86" -output "$main_universal"
/bin/mv "$main_universal" "$main"

/usr/bin/perl "$script_dir/patch_wetype_637_svg.pl" "$assets_root"
/usr/bin/swift "$script_dir/patch_wetype_637_connect_icon.swift" "$connect_icon"

app_arm="$tmp_root/app-arm64"
app_x86="$tmp_root/app-x86_64"
app_universal="$tmp_root/app-universal"
/usr/bin/lipo -thin arm64 -output "$app_arm" "$app_framework"
/usr/bin/lipo -thin x86_64 -output "$app_x86" "$app_framework"
/usr/bin/perl "$script_dir/patch_wetype_637_colors.pl" arm64 "$app_arm"
/usr/bin/perl "$script_dir/patch_wetype_637_colors.pl" x86_64 "$app_x86"
/usr/bin/lipo "$app_framework" \
    -replace arm64 "$app_arm" \
    -replace x86_64 "$app_x86" \
    -output "$app_universal"
/bin/mv "$app_universal" "$app_framework"

/usr/bin/perl "$script_dir/patch_wetype_637_assets.pl" \
    "$bundle/Contents/Resources/Assets.car"
/usr/bin/sips -g pixelWidth -g pixelHeight -g hasAlpha "$connect_icon" >/dev/null

/bin/mkdir -p "$(dirname "$custom")"
/bin/mv "$bundle" "$custom"
echo "Built unsigned WeType 2.2.1 (637) custom bundle: $custom"
