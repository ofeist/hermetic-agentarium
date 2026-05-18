#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <task-file-path> [<verification-notes-file>]" >&2
    echo "" >&2
    echo "Render a self-contained review prompt from an AgentOps task file and the current git diff." >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  task-file-path           Path to an AgentOps task markdown file" >&2
    echo "  verification-notes-file  Optional path to parent verification / context notes" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -h, --help               Show this help message and exit" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 .agentops/tasks/ready/TASK-0056-review-prompt-renderer.md > /tmp/TASK-0056-review.prompt.md" >&2
    echo "  $0 .agentops/tasks/ready/TASK-0058-review-prompt-verification-notes.md /tmp/notes.md > /tmp/TASK-0058-review.prompt.md" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage
    exit 1
fi

TASK_FILE="$1"
VERIFICATION_FILE="${2:-}"

if [[ ! -f "$TASK_FILE" ]]; then
    echo "Error: task file not found: $TASK_FILE" >&2
    exit 1
fi

if [[ -n "$VERIFICATION_FILE" && ! -f "$VERIFICATION_FILE" ]]; then
    echo "Error: verification notes file not found: $VERIFICATION_FILE" >&2
    exit 1
fi

cat <<HEREDOC
You are the reviewer agent.

Review the implementation diff below against the task specification. You must review only — do not modify any files.

## Task

$(cat "$TASK_FILE")

## Parent verification / context notes

$(
if [[ -n "$VERIFICATION_FILE" ]]; then
    cat "$VERIFICATION_FILE"
else
    echo "No parent verification notes were provided."
fi
)

## Git status

$(git status --short --branch 2>&1)

## Diff stat

$(git diff --stat 2>&1)

## Diff

$(git diff 2>&1)

## Decision options

- accept
- revise
- blocked

## Return format

Decision:
Scope review:
Verification review:
Requested changes:
Risks / uncertainty:
HEREDOC
