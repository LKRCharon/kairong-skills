#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
/usr/bin/swift "$script_dir/diagnose_tis.swift"
echo "--- WeType processes ---"
/usr/bin/pgrep -ax WeType || true
/usr/bin/pgrep -ax WeTypeSettings || true
/usr/bin/pgrep -ax WeTypeFeedback || true
echo "--- installed bundle ---"
/usr/bin/plutil -extract CFBundleShortVersionString raw -o - \
    "/Library/Input Methods/WeType.app/Contents/Info.plist" 2>/dev/null || true
/usr/bin/plutil -extract CFBundleVersion raw -o - \
    "/Library/Input Methods/WeType.app/Contents/Info.plist" 2>/dev/null || true
