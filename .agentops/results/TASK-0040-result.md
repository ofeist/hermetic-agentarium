# TASK-0040 Result — Add render-opencode-prompt helper

## Decision

accept

## Changed files

- scripts/render-opencode-prompt.sh
- docs/DEBUGGING.md
- agentops/tasks/done/TASK-0040-render-opencode-prompt-helper.md

## Verification

- bash -n scripts/render-opencode-prompt.sh
- scripts/render-opencode-prompt.sh agentops/tasks/done/TASK-0040-render-opencode-prompt-helper.md > /tmp/TASK-0040.prompt.md
- grep -q "Do not commit" /tmp/TASK-0040.prompt.md
- grep -q "TASK-0040" /tmp/TASK-0040.prompt.md

## Notes

The helper renders a ready AgentOps task into a standardized OpenCode executor prompt. It does not modify files and does not invoke OpenCode.
