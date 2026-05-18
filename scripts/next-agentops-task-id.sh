#!/usr/bin/env bash
set -euo pipefail

LIFECYCLE_DIRS=(
    ".agentops/tasks/planned"
    ".agentops/tasks/ready"
    ".agentops/tasks/running"
    ".agentops/tasks/review"
    ".agentops/tasks/done"
)

MAX_ID=0

for dir in "${LIFECYCLE_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        echo "Error: lifecycle directory missing: $dir" >&2
        exit 1
    fi
    if [[ ! -r "$dir" ]]; then
        echo "Error: lifecycle directory unreadable: $dir" >&2
        exit 1
    fi

    for f in "$dir"/TASK-*.md; do
        [[ -f "$f" ]] || continue
        base=$(basename "$f" .md)
        if [[ "$base" =~ ^TASK-([0-9]{4})- ]]; then
            num=${BASH_REMATCH[1]}
            num=$((10#$num))
            if (( num > MAX_ID )); then
                MAX_ID=$num
            fi
        fi
    done
done

NEXT=$((MAX_ID + 1))
printf 'TASK-%04d\n' "$NEXT"
