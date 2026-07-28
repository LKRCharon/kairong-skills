#!/bin/bash

set -euo pipefail

bundle="${1:-}"
identity="${2:-}"
entitlements="${3:-}"

if [[ -z "$bundle" || -z "$identity" || -z "$entitlements" ]]; then
    echo "usage: $0 CUSTOM_BUNDLE IDENTITY ENTITLEMENTS_DIR" >&2
    exit 2
fi
if [[ ! -d "$bundle" || ! -d "$entitlements" ]]; then
    echo "missing bundle or entitlements directory" >&2
    exit 1
fi

short_version=$(/usr/bin/plutil -extract CFBundleShortVersionString raw -o - "$bundle/Contents/Info.plist")
build_version=$(/usr/bin/plutil -extract CFBundleVersion raw -o - "$bundle/Contents/Info.plist")
if [[ "$short_version" != "2.2.1" || "$build_version" != "637" ]]; then
    echo "expected WeType 2.2.1 (637), found $short_version ($build_version)" >&2
    exit 1
fi
/usr/bin/security find-identity -v -p codesigning \
    | /usr/bin/grep -F "$identity" >/dev/null || {
    echo "identity is not a valid local codesigning identity: $identity" >&2
    echo "Run: security find-identity -v -p codesigning" >&2
    exit 1
}

sign_runtime() {
    /usr/bin/codesign --force --sign "$identity" --timestamp=none \
        --options runtime "$@"
}

sign_plain() {
    /usr/bin/codesign --force --sign "$identity" --timestamp=none "$@"
}

settings="$bundle/Contents/MacOS/WeTypeSettings.app"
feedback="$bundle/Contents/MacOS/WeTypeFeedback.app"
sparkle="$bundle/Contents/Frameworks/Sparkle.framework/Versions/B"

# Settings frameworks are leaves and must be sealed before Settings.app.
sign_plain "$settings/Contents/Frameworks/App.framework"
sign_plain "$settings/Contents/Frameworks/FlutterMacOS.framework"
sign_runtime --entitlements "$entitlements/settings.plist" "$settings"

# Feedback leaves and app.
sign_runtime "$feedback/Contents/Frameworks/libswift_Concurrency.dylib"
sign_runtime --entitlements "$entitlements/feedback.plist" "$feedback"

# Sparkle nested code, then the containing framework.
sign_runtime "$sparkle/Autoupdate"
sign_runtime "$sparkle/Updater.app"
sign_runtime "$sparkle/XPCServices/Downloader.xpc"
sign_runtime "$sparkle/XPCServices/Installer.xpc"
sign_runtime "$bundle/Contents/Frameworks/Sparkle.framework"

# Root frameworks and libraries.
sign_runtime "$bundle/Contents/Frameworks/libswift_Concurrency.dylib"
sign_runtime "$bundle/Contents/Frameworks/wcwss.framework"
sign_runtime "$bundle/Contents/Frameworks/flurry.framework"
sign_runtime "$bundle/Contents/Frameworks/WXP2PTransferDyn.framework"

# Helpers with Team-ID-prefixed application identifiers.
sign_runtime --entitlements "$entitlements/relaunch.plist" \
    "$bundle/Contents/MacOS/WeTypeRelaunch"
sign_runtime --entitlements "$entitlements/updater.plist" \
    "$bundle/Contents/MacOS/WeTypeUpdater"
sign_runtime --entitlements "$entitlements/accessibility-checker.plist" \
    "$bundle/Contents/MacOS/WeTypeAccessibilityChecker"

# Build 637 adds FinderSync.
sign_runtime --entitlements "$entitlements/finder-sync.plist" \
    "$bundle/Contents/PlugIns/WeTypeFinderSync.appex"

# Top-level app last.
sign_runtime --entitlements "$entitlements/wetype.plist" "$bundle"

/usr/bin/codesign --verify --deep --strict --verbose=2 "$bundle"
echo "Signed and verified WeType 2.2.1 (637): $bundle"
