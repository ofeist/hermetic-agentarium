#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <task-id-slug>" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 TASK-0054-ready-task-executor-helper" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

TASK_ID_SLUG="$1"

if [[ "$TASK_ID_SLUG" == *"/"* || "$TASK_ID_SLUG" == *".."* ]]; then
    echo "Error: task-id-slug must not contain '/' or '..': $TASK_ID_SLUG" >&2
    exit 1
fi

READY_TASK_FILE="agentops/tasks/ready/$TASK_ID_SLUG.md"
PROMPT_FILE="/tmp/$TASK_ID_SLUG.prompt.md"
RENDER_SCRIPT="scripts/render-opencode-prompt.sh"
EXECUTOR_SCRIPT="scripts/run-opencode-executor.sh"
MODEL="deepseek/deepseek-chat"

if [[ ! -f "$READY_TASK_FILE" ]]; then
    echo "Error: ready task file not found: $READY_TASK_FILE" >&2
    exit 1
fi

if [[ ! -f "$RENDER_SCRIPT" ]]; then
    echo "Error: required script missing: $RENDER_SCRIPT" >&2
    exit 1
fi

if [[ ! -f "$EXECUTOR_SCRIPT" ]]; then
    echo "Error: required script missing: $EXECUTOR_SCRIPT" >&2
    exit 1
fi

echo "Rendering ready task prompt: $READY_TASK_FILE -> $PROMPT_FILE"
"$RENDER_SCRIPT" "$READY_TASK_FILE" > "$PROMPT_FILE"

echo "Running OpenCode executor for task: $TASK_ID_SLUG"
"$EXECUTOR_SCRIPT" "$PROMPT_FILE" "$MODEL" "$TASK_ID_SLUG"

echo ""
echo "Executor finished. Next verification commands:"
echo "  git status --short --branch"
echo "  git diff --stat"
