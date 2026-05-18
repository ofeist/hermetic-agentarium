#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: bootstrap-agentops-structure.sh [TARGET_DIR]

Bootstrap or validate the canonical .agentops/ lifecycle layout.

Default TARGET_DIR is .agentops (relative to repository root).

Creates required directories, ensures .gitkeep placeholders exist in
directories that are tracked when otherwise empty, and validates that
required template files are present.

The helper is idempotent: repeated runs succeed without side effects.

Exit codes:
  0  Bootstrap/check succeeded
  1  Required template missing or invalid target
USAGE
}

TARGET="${1:-.agentops}"

if [ -e "$TARGET" ] && [ ! -d "$TARGET" ]; then
    echo "ERROR: target path exists but is not a directory: $TARGET"
    exit 1
fi

DIRS=(
    "$TARGET/tasks/planned"
    "$TARGET/tasks/ready"
    "$TARGET/tasks/running"
    "$TARGET/tasks/review"
    "$TARGET/tasks/done"
    "$TARGET/results"
    "$TARGET/templates"
    "$TARGET/lifecycle"
)

GITKEEP_DIRS=(
    "$TARGET/tasks/planned"
    "$TARGET/tasks/ready"
    "$TARGET/tasks/running"
    "$TARGET/tasks/review"
    "$TARGET/tasks/done"
    "$TARGET/results"
)

REQUIRED_TEMPLATES=(
    "$TARGET/templates/PLANNED-TASK-TEMPLATE.md"
    "$TARGET/templates/READY-TASK-TEMPLATE.md"
)

for dir in "${DIRS[@]}"; do
    mkdir -p "$dir"
done

for dir in "${GITKEEP_DIRS[@]}"; do
    touch "$dir/.gitkeep"
done

errors=0
for tmpl in "${REQUIRED_TEMPLATES[@]}"; do
    if [ ! -f "$tmpl" ]; then
        echo "ERROR: required template missing: $tmpl"
        errors=1
    fi
done

if [ "$errors" -ne 0 ]; then
    exit 1
fi

echo "AgentOps structure bootstrapped: $TARGET"
