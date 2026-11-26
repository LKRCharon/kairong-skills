#!/bin/bash

wetype_3_require_profile() {
    local bundle="$1"
    local expected_build="$2"
    local expected_version short_version build_version
    case "$expected_build" in
        684) expected_version=3.0.1 ;;
        689) expected_version=3.0.2 ;;
        *)
            echo "no WeType 3 patch profile for build: $expected_build" >&2
            return 2
            ;;
    esac

    short_version=$(/usr/bin/plutil -extract CFBundleShortVersionString raw -o - "$bundle/Contents/Info.plist") || return
    build_version=$(/usr/bin/plutil -extract CFBundleVersion raw -o - "$bundle/Contents/Info.plist") || return
    if [[ "$short_version" != "$expected_version" || "$build_version" != "$expected_build" ]]; then
        echo "expected WeType $expected_version ($expected_build), found $short_version ($build_version)" >&2
        return 1
    fi
    printf '%s\n' "$short_version"
}
