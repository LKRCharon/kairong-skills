#!/bin/bash

set -euo pipefail

source_bundle="${1:-}"
installed_bundle="${2:-/Library/Input Methods/WeType.app}"
backup_dir="${3:-}"
script_dir="$(cd "$(dirname "$0")" && pwd)"

if [[ -z "$source_bundle" ]]; then
    echo "usage: sudo $0 SIGNED_BUNDLE [INSTALLED_BUNDLE] [BACKUP_DIR]" >&2
    exit 2
fi
if [[ "$(id -u)" -ne 0 ]]; then
    echo "run from the user's Terminal with sudo" >&2
    exit 77
fi
if [[ "$installed_bundle" != "/Library/Input Methods/WeType.app" ]]; then
    echo "refusing an unexpected installed path: $installed_bundle" >&2
    exit 2
fi
if [[ -z "$backup_dir" ]]; then
    backup_dir="$(dirname "$source_bundle")/backups"
fi
if [[ ! -d "$source_bundle" ]]; then
    echo "missing signed source bundle: $source_bundle" >&2
    exit 1
fi
if [[ ! -d "$installed_bundle" ]]; then
    echo "installed bundle is missing; inspect the system before installing" >&2
    exit 1
fi

/bin/bash "$script_dir/verify_wetype_657.sh" "$source_bundle"
/bin/mkdir -p "$backup_dir"
backup_bundle="$backup_dir/WeType-installed-before-657-$(date +%Y%m%d-%H%M%S).bundle"
if [[ -e "$backup_bundle" ]]; then
    echo "refusing to overwrite backup: $backup_bundle" >&2
    exit 1
fi

/usr/bin/ditto "$installed_bundle" "$backup_bundle"
/usr/bin/codesign --verify --deep --strict "$backup_bundle"

tmp_root=$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/wetype657-install.XXXXXX")
staging="$tmp_root/WeType.app"
cleanup() {
    /bin/rm -rf "$tmp_root"
}
trap cleanup EXIT

/usr/bin/pkill -x WeType 2>/dev/null || true
/usr/bin/pkill -x WeTypeSettings 2>/dev/null || true
/usr/bin/pkill -x WeTypeFeedback 2>/dev/null || true

/usr/bin/ditto "$source_bundle" "$staging"
/usr/bin/codesign --verify --deep --strict "$staging"
/usr/sbin/chown -R root:wheel "$staging"
/bin/rm -rf "$installed_bundle"
/bin/mv "$staging" "$installed_bundle"
/usr/bin/touch "$installed_bundle"

/usr/bin/pkill -x TextInputMenuAgent 2>/dev/null || true
/usr/bin/codesign --verify --deep --strict --verbose=2 "$installed_bundle"
echo "Installed WeType 2.2.3 (657)."
echo "Verified rollback backup: $backup_bundle"
