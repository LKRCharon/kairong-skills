#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <style-name> [output-dir]"
  exit 1
fi

STYLE_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUT_DIR="${2:-${SKILL_DIR}/references/style-cards}"
TEMPLATE="${SKILL_DIR}/assets/style_card_template.yaml"
OUT_FILE="${OUT_DIR}/${STYLE_NAME}.yaml"

mkdir -p "$OUT_DIR"
cp "$TEMPLATE" "$OUT_FILE"

DATE_NOW="$(date +%F)"
sed -i '' "s/^style_name: \"\"/style_name: \"${STYLE_NAME}\"/" "$OUT_FILE"
sed -i '' "s/^  created_at: \"YYYY-MM-DD\"/  created_at: \"${DATE_NOW}\"/" "$OUT_FILE"

echo "Created: $OUT_FILE"
