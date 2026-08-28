#!/bin/bash

set -euo pipefail

output_dir="${1:-}"
team_id="${2:-}"

if [[ -z "$output_dir" || -z "$team_id" || ! "$team_id" =~ ^[A-Z0-9]{10}$ ]]; then
    echo "usage: $0 ENTITLEMENTS_DIR TEAM_ID" >&2
    exit 2
fi

/bin/mkdir -p "$output_dir"

cat > "$output_dir/wetype.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
    <key>com.apple.security.device.audio-input</key>
    <true/>
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
</dict>
</plist>
PLIST

cat > "$output_dir/settings.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>com.apple.security.device.audio-input</key>
    <true/>
</dict>
</plist>
PLIST

cat > "$output_dir/feedback.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
</dict>
</plist>
PLIST

cat > "$output_dir/finder-sync.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
</dict>
</plist>
PLIST

for helper in relaunch accessibility-checker; do
    case "$helper" in
        relaunch) identifier="WeTypeRelaunch" ;;
        accessibility-checker) identifier="WeTypeAccessibilityChecker" ;;
    esac
    cat > "$output_dir/$helper.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.application-identifier</key>
    <string>${team_id}.com.tencent.${identifier}</string>
</dict>
</plist>
PLIST
done

for file in "$output_dir"/*.plist; do
    /usr/bin/plutil -lint "$file" >/dev/null
done

echo "Created 657 local-test entitlements in $output_dir"
