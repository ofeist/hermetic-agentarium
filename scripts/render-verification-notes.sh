#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <task-id-slug>" >&2
    echo "" >&2
    echo "Render parent verification / context notes markdown for a task." >&2
    echo "" >&2
    echo "The output is intended for use as the second argument to:" >&2
    echo "  scripts/render-review-prompt.sh <task-file> <verification-notes-file>" >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  task-id-slug  Task identifier matching agentops/tasks/ready/<task-id-slug>.md" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -h, --help    Show this help message and exit" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 TASK-0060-verification-notes-helper > /tmp/TASK-0060-verification-notes.md" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

TASK_ID="$1"

if [[ "$TASK_ID" == *"/"* || "$TASK_ID" == *".."* ]]; then
    echo "Error: task-id-slug must not contain '/' or '..': $TASK_ID" >&2
    exit 1
fi

READY_TASK_FILE="agentops/tasks/ready/$TASK_ID.md"

cat <<HEREDOC
# Parent verification / context notes

## Ready task

HEREDOC

if [[ -f "$READY_TASK_FILE" ]]; then
    echo "The original ready task file \`$READY_TASK_FILE\` exists. It defines the implementation scope for $TASK_ID."
    echo ""
    echo "Note: The ready task file is expected to exist and should not be treated as an implementation scope violation."
else
    echo "No matching ready task file was found at \`$READY_TASK_FILE\`."
fi

cat <<HEREDOC

## Verification commands / output

\`\`\`
# Add verification commands and their output here.
# Example:
#   bash -n scripts/render-verification-notes.sh
#   scripts/render-verification-notes.sh --help
\`\`\`

## Git status

\`\`\`
$(git status --short --branch 2>&1)
\`\`\`

## Diff stat

\`\`\`
$(git diff --stat 2>&1)
\`\`\`

## Changed files

\`\`\`
$(git diff --name-only 2>&1)
\`\`\`

## Untracked files

\`\`\`
$(
  untracked=$(git ls-files --others --exclude-standard 2>&1)
  if [[ -z "$untracked" ]]; then
    echo "No untracked files."
  else
    echo "$untracked"
  fi
)
\`\`\`
HEREDOC
