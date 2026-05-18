#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <task-file>" >&2
    echo "" >&2
    echo "Render a ready AgentOps task file into a standardized OpenCode executor prompt." >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 .agentops/tasks/ready/TASK-xxxx-description.md > /tmp/TASK-xxxx.prompt.md" >&2
}

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

TASK_FILE="$1"

if [[ ! -f "$TASK_FILE" ]]; then
    echo "Error: task file '$TASK_FILE' not found or is not a regular file" >&2
    exit 1
fi

render_task_content() {
    awk '
        /^## Model[[:space:]]*$/ {
            skip = 1
            next
        }
        skip && /^## / {
            skip = 0
        }
        !skip {
            print
        }
    ' "$TASK_FILE"
}

cat <<PROMPT_PREFIX
/agentops-coder
USING_SKILL: agentops-coder

You are an OpenCode executor. Your job is to implement the task below.

Constraints:
- Do not commit changes.
- Do not modify unrelated files.
- Do not read or print secrets (no .env, tokens, auth files, SSH keys, or private config).
- Keep changes minimal. Only touch files listed in the task write scope.
- Do not choose or change the executor model. The runner selects it outside the prompt.

Task content follows:
$(render_task_content)

Return format:
- Changed files (list each file path)
- Diff summary (brief description of each change)
- Verification output (commands run and their results)
- Uncertainty or risks (anything you are not sure about)
PROMPT_PREFIX
