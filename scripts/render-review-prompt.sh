#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <task-file-path>" >&2
    echo "" >&2
    echo "Render a self-contained review prompt from an AgentOps task file and the current git diff." >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  task-file-path    Path to an AgentOps task markdown file" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -h, --help        Show this help message and exit" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 agentops/tasks/ready/TASK-0056-review-prompt-renderer.md > /tmp/TASK-0056-review.prompt.md" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

TASK_FILE="$1"

if [[ ! -f "$TASK_FILE" ]]; then
    echo "Error: task file not found: $TASK_FILE" >&2
    exit 1
fi

cat <<HEREDOC
You are the reviewer agent.

Review the implementation diff below against the task specification. You must review only — do not modify any files.

## Task

$(cat "$TASK_FILE")

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
