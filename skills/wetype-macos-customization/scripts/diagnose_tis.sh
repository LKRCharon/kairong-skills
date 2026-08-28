#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
tmp_dir=$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/wetype657-tis.XXXXXX")
trap '/bin/rm -rf "$tmp_dir"' EXIT
/usr/bin/clang -framework Carbon "$script_dir/diagnose_tis.c" \
    -o "$tmp_dir/diagnose_tis"
"$tmp_dir/diagnose_tis"

print_processes() {
    local process_name="$1"
    local found=0
    while IFS= read -r pid; do
        [[ -n "$pid" ]] || continue
        /bin/ps -p "$pid" -o pid=,command=
        found=1
    done < <(/usr/bin/pgrep -x "$process_name" || true)
    if [[ "$found" -eq 0 ]]; then
        echo "$process_name: not running"
    fi
}

echo "--- WeType processes ---"
print_processes WeType
print_processes WeTypeSettings
print_processes WeTypeFeedback
echo "--- installed bundle ---"
/usr/bin/plutil -extract CFBundleShortVersionString raw -o - \
    "/Library/Input Methods/WeType.app/Contents/Info.plist" 2>/dev/null || true
/usr/bin/plutil -extract CFBundleVersion raw -o - \
    "/Library/Input Methods/WeType.app/Contents/Info.plist" 2>/dev/null || true
