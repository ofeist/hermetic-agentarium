# TASK-0023 Result — Hermes OpenCode Runtime Check

Decision: accept

## Summary

Hermes/coder successfully executed an AgentOps ready task by acting as the parent orchestrator, creating a task branch, preparing a temporary executor prompt, invoking OpenCode through the repository wrapper, and independently reviewing the resulting diff.

## Executor

- Harness: OpenCode
- Model: deepseek/deepseek-chat
- Fallback allowed: false

## Runtime note

Hermes/coder runs with an isolated `HOME`, so OpenCode runtime configuration may need to be passed explicitly.

Validated runtime variables:

- `OPENCODE_XDG_CONFIG_HOME`
- `OPENCODE_XDG_DATA_HOME`

The wrapper forwards these values to OpenCode as `XDG_CONFIG_HOME` and `XDG_DATA_HOME` for the executor invocation.

## Changed files

- `docs/HERMES-OPENCODE-RUNTIME.md`

## Verification

Parent verification included:

- `scripts/review-executor-result.sh`
- `git diff -- docs/HERMES-OPENCODE-RUNTIME.md`
- `git diff --cached --stat`
- `git diff --cached -- docs/HERMES-OPENCODE-RUNTIME.md`

Result:

- 1 new file
- 9 insertions
- no unrelated files changed

## Notes

This task validated the Hermes cockpit to OpenCode executor handoff with explicit runtime environment handling and no silent model fallback.
