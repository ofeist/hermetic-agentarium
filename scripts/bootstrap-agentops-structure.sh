#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: bootstrap-agentops-structure.sh [TARGET_DIR]

Bootstrap or validate the canonical .agentops/ lifecycle layout.

Default TARGET_DIR is the repository-root .agentops directory, resolved from this script's location.
Explicit TARGET_DIR arguments are interpreted relative to the caller's current directory unless absolute.

Creates required directories, ensures .gitkeep placeholders exist in
directories that are tracked when otherwise empty, and validates that
required template files are present.

The helper is idempotent: repeated runs succeed without side effects.

Exit codes:
  0  Bootstrap/check succeeded
  1  Required template missing or invalid target
USAGE
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

if [ "$#" -gt 0 ]; then
    TARGET="$1"
else
    TARGET="$REPO_ROOT/.agentops"
fi

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
