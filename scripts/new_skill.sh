#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <skill-name> <description>"
  exit 1
fi

skill_name="$1"
shift
description="$*"
skill_dir="skills/${skill_name}"
skill_file="${skill_dir}/SKILL.md"

if [ -e "${skill_dir}" ]; then
  echo "Skill already exists: ${skill_dir}"
  exit 1
fi

mkdir -p "${skill_dir}"

cat > "${skill_file}" <<EOF
---
name: ${skill_name}
description: ${description}
---

# ${skill_name}

## When to use
- Describe the situations that should trigger this skill.

## Workflow
1. Clarify the output format, audience, and constraints.
2. Prefer deterministic tools or scripts when quality depends on repeatability.
3. Save final artifacts in stable, descriptive paths.

## Quality bar
- State the visual, structural, or correctness standards here.
EOF

echo "Created ${skill_file}"
