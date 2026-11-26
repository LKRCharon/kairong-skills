#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
exec /bin/bash "$script_dir/verify_wetype_3.sh" 684 "$@"
