#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <task-file> <reviewer-feedback-file>" >&2
    echo "" >&2
    echo "Render a focused revision prompt from an AgentOps task file and reviewer feedback." >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  task-file              Path to an AgentOps task markdown file" >&2
    echo "  reviewer-feedback-file Path to a file containing reviewer feedback" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -h, --help             Show this help message and exit" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 agentops/tasks/ready/TASK-0067-revision-prompt-renderer.md /tmp/reviewer-feedback.md > /tmp/revision.prompt.md" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -ne 2 ]]; then
    usage
    exit 1
fi

TASK_FILE="$1"
REVIEWER_FEEDBACK_FILE="$2"

if [[ ! -f "$TASK_FILE" ]]; then
    echo "Error: task file not found: $TASK_FILE" >&2
    exit 1
fi

if [[ ! -f "$REVIEWER_FEEDBACK_FILE" ]]; then
    echo "Error: reviewer feedback file not found: $REVIEWER_FEEDBACK_FILE" >&2
    exit 1
fi

cat <<HEREDOC
You are the implementation revision agent.

Your task is to fix only the reviewer-requested changes. Do not broaden the scope of the task. Do not modify files that are not related to the requested changes.

## Original task

$(cat "$TASK_FILE")

## Reviewer feedback

$(cat "$REVIEWER_FEEDBACK_FILE")

## Git status

$(git status --short --branch 2>&1)

## Diff stat

$(git diff --stat 2>&1)

## Diff

$(git diff 2>&1)

## Required return format

- Changed files
- Diff summary
- Verification output
- Remaining uncertainty
HEREDOC
