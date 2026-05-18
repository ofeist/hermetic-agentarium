#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <ready-task-path>" >&2
    echo "" >&2
    echo "Render the canonical Hermes/coder collection prompt for a ready AgentOps task." >&2
    echo "" >&2
    echo "The task path must be under .agentops/tasks/ready/." >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 .agentops/tasks/ready/TASK-0083-hermes-coder-collection-prompt-helper.md" >&2
}

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

TASK_PATH="$1"
READY_DIR=".agentops/tasks/ready"

if [[ ! -f "$TASK_PATH" ]]; then
    echo "Error: task file '$TASK_PATH' not found or is not a regular file" >&2
    exit 1
fi

RESOLVED_TASK_PATH="$(realpath "$TASK_PATH")"
RESOLVED_READY_DIR="$(realpath "$READY_DIR")"

case "$RESOLVED_TASK_PATH" in
    "$RESOLVED_READY_DIR"/*) ;;
    *)
        echo "Error: task path must be under .agentops/tasks/ready/" >&2
        exit 1
        ;;
esac

cat <<COLLECTION_PROMPT
/agentops-coder

Execute AgentOps ready task:

${TASK_PATH}

Use the Hermes/OpenCode executor workflow from your profile/skill.

Workflow requirements:
- use or create a task-specific worktree and branch
- do not switch the main planning worktree away from main
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME, OPENCODE_XDG_DATA_HOME, and AGENTOPS_EXECUTOR_MODEL
- use the runner-configured executor model
- do not silently fallback to another model
- do not commit
- independently verify the result

Return:
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
COLLECTION_PROMPT
