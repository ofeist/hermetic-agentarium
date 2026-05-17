#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <task-id-slug> <decision-note>" >&2
    echo "" >&2
    echo "Accept a completed AgentOps review task: move from review/ to done/ and create result summary." >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  task-id-slug   Task identifier matching agentops/tasks/review/<task-id-slug>.md" >&2
    echo "  decision-note  Short note explaining the accept decision" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -h, --help     Show this help message and exit" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 TASK-0055-helper-accept-task \"Accepted in TASK-0065 helper test\"" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

TASK_SLUG="$1"
DECISION_NOTE="$2"

if [[ "$TASK_SLUG" == *"/"* || "$TASK_SLUG" == *".."* ]]; then
  echo "Error: invalid task-id-slug: '$TASK_SLUG'" >&2
  exit 1
fi

REVIEW_DIR="agentops/tasks/review"
REVIEW_FILE="${REVIEW_DIR}/${TASK_SLUG}.md"
DONE_DIR="agentops/tasks/done"
DONE_FILE="${DONE_DIR}/${TASK_SLUG}.md"
RESULT_DIR="agentops/results"
RESULT_FILE="${RESULT_DIR}/${TASK_SLUG}-result.md"

if [ ! -f "$REVIEW_FILE" ]; then
  echo "Error: review task file not found: $REVIEW_FILE" >&2
  exit 1
fi

if [ -e "$DONE_FILE" ]; then
  echo "Error: done task file already exists: $DONE_FILE" >&2
  exit 1
fi

if [ -e "$RESULT_FILE" ]; then
  echo "Error: result summary already exists: $RESULT_FILE" >&2
  exit 1
fi

mkdir -p "$DONE_DIR" "$RESULT_DIR"

mv "$REVIEW_FILE" "$DONE_FILE"

# Rewrite task status from review to done for both known status styles
awk '
  /^Status: review$/ { print "Status: done"; next }
  /^## Status$/ { print; in_status=1; next }
  in_status && /^[[:space:]]*$/ { print; next }
  in_status && /^review$/ { print "done"; in_status=0; next }
  in_status && /^[^[:space:]]/ { in_status=0 }
  { print }
' "$DONE_FILE" > "$DONE_FILE.tmp" && mv "$DONE_FILE.tmp" "$DONE_FILE"

GIT_STATUS="$(git status --short --branch 2>/dev/null || echo 'N/A')"
DIFF_STAT="$(git diff --stat 2>/dev/null || echo 'N/A')"

cat > "$RESULT_FILE" <<RESULT
# ${TASK_SLUG} Result

## Decision

accept

## Decision note

${DECISION_NOTE}

## Task file

${DONE_FILE}

## Git status

\`\`\`
${GIT_STATUS}
\`\`\`

## Diff stat

\`\`\`
${DIFF_STAT}
\`\`\`

## Verification

<!-- Parent: add verification steps and output here -->

## Follow-ups

<!-- Parent: add any follow-up tasks or notes here -->

RESULT

echo "$DONE_FILE"
echo "$RESULT_FILE"
