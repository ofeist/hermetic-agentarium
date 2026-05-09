#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: check-agentops-lifecycle.sh [OPTIONS]

Check AgentOps lifecycle consistency:
- Duplicate task IDs across task directories
- Done tasks still marked ready
- Result notes referencing missing task paths
- Done tasks without result notes (warning only)

Options:
  -h, --help  Show this help message and exit

Exit codes:
  0  No errors found (warnings OK)
  1  One or more errors found
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

ERRORS=0
WARNINGS=0

task_id_from_slug() {
    printf '%s\n' "$1" | sed -n 's/^\(TASK-[0-9][0-9]*\).*/\1/p'
}

TASK_DIRS=(
    "agentops/tasks/planned"
    "agentops/tasks/ready"
    "agentops/tasks/running"
    "agentops/tasks/review"
    "agentops/tasks/done"
)

echo "=== AgentOps lifecycle check ==="
echo ""

# ---- 1. Detect duplicate task IDs across different lifecycle directories ----
echo "-- Checking duplicate task IDs across directories"
declare -A TASK_ID_DIR
declare -A TASK_ID_SEEN_SAME_DIR
for dir in "${TASK_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    for f in "$dir"/TASK-*.md; do
        [ -f "$f" ] || continue
        task_id=$(task_id_from_slug "$(basename "$f" .md)")
        [ -n "$task_id" ] || continue
        if [ -n "${TASK_ID_DIR[$task_id]:-}" ] && [ "${TASK_ID_DIR[$task_id]}" != "$dir" ]; then
            echo "ERROR: duplicate task ID $task_id in ${TASK_ID_DIR[$task_id]} and $dir (cross-directory)"
            ERRORS=$((ERRORS + 1))
        else
            TASK_ID_DIR[$task_id]="$dir"
        fi
    done
done

# ---- 2. Done tasks still marked ready ----
echo "-- Checking done tasks for stale ready status"
for f in agentops/tasks/done/TASK-*.md; do
    [ -f "$f" ] || continue

    # Pattern A: Status: ready (single-line frontmatter style)
    if grep -q '^Status: ready$' "$f"; then
        echo "ERROR: $f has Status: ready"
        ERRORS=$((ERRORS + 1))
    fi

    # Pattern B: ## Status section whose next non-empty line is ready
    found=$(awk '
        /^## Status$/ { in_status=1; next }
        in_status && /^[[:space:]]*$/ { next }
        in_status && /^ready$/ { print "FOUND"; exit }
        in_status && /^[^[:space:]]/ { in_status=0 }
    ' "$f")
    if [ "$found" = "FOUND" ]; then
        echo "ERROR: $f has ## Status / ready"
        ERRORS=$((ERRORS + 1))
    fi
done

# ---- 3. Result notes referencing truly non-existent task files ----
echo "-- Checking result note task path references"
for rf in agentops/results/*.md; do
    [ -f "$rf" ] || continue
    while IFS= read -r line; do
        # Extract paths like agentops/tasks/<state>/TASK-NNNN-*.md
        while IFS= read -r path; do
            [ -n "$path" ] || continue
            if [ -f "$path" ]; then
                continue
            fi
            # Exact path missing, but check if the file exists anywhere under agentops/tasks/
            fname=$(basename "$path")
            if ! compgen -G "agentops/tasks/*/${fname}" > /dev/null 2>&1; then
                echo "ERROR: $rf references non-existent task file: $path"
                ERRORS=$((ERRORS + 1))
            fi
        done < <(printf '%s\n' "$line" | grep -Eo 'agentops/tasks/(planned|ready|running|review|done)/TASK-[0-9][^ )`[:space:]]*\.md' || true)
    done < "$rf"
done

# ---- 4. Done tasks without result notes (warn only) ----
echo "-- Checking done tasks for result notes"
for f in agentops/tasks/done/TASK-*.md; do
    [ -f "$f" ] || continue
    task_slug=$(basename "$f" .md)
    task_id=$(task_id_from_slug "$task_slug")
    result_found=0
    for rf in agentops/results/*.md; do
        [ -f "$rf" ] || continue
        result_slug=$(basename "$rf" .md)
        if [[ "$result_slug" == "${task_slug}-result" || "$result_slug" == "${task_id}-result" ]]; then
            result_found=1
            break
        fi
    done
    if [ "$result_found" -eq 0 ]; then
        echo "WARN: $f has no result note"
        WARNINGS=$((WARNINGS + 1))
    fi
done

echo ""
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [ "$ERRORS" -gt 0 ]; then
    exit 1
fi
exit 0
