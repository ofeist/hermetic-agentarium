# POC Status

Status: validated

## Summary

The minimal Hermes AgentOps executor loop has been validated. Hermes/coder can act as the parent orchestrator, prepare a bounded task, invoke OpenCode through the repository wrapper, and independently review the resulting diff.

## Validated flow

1. Parent/Hermes prepares or reads a bounded task.
2. Parent creates a task-specific worktree on a task branch before executor work.
3. Parent prepares an executor prompt under `/tmp`.
4. `scripts/run-opencode-executor.sh` invokes OpenCode non-interactively.
5. OpenCode uses the requested model/provider and produces a scoped diff.
6. `scripts/review-executor-result.sh` prints repository status and diff summary.
7. Parent reviews the full diff and relevant checks.
8. Parent decides: `accept`, `revise`, `revert`, `no-op / nothing to accept`, or `blocked`.

## Validated components

- `scripts/run-opencode-executor.sh`
- `scripts/review-executor-result.sh`
- `templates/opencode-executor-task.prompt.md`
- `examples/opencode-docs-task.prompt.md`
- `docs/OPENCODE-EXECUTOR-WORKFLOW.md`
- `docs/HERMES-OPENCODE-RUN.md`
- `docs/HERMES-OPENCODE-RUNTIME.md`
- `.agentops/` task lifecycle structure
- `profiles/coder/SOUL.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`

## Key finding

Hermes/coder runs with an isolated `HOME`, so OpenCode may not see the user's normal configuration and data directories by default.

The validated fix is to pass explicit runtime homes when needed:

    OPENCODE_XDG_CONFIG_HOME=/home/splinter/.config \
    OPENCODE_XDG_DATA_HOME=/home/splinter/.local/share \
    AGENTOPS_EXECUTOR_MODEL=deepseek/deepseek-v4-pro \
    scripts/run-opencode-executor.sh /tmp/task-prompt.txt

The wrapper forwards these values as `XDG_CONFIG_HOME` and `XDG_DATA_HOME` only for the OpenCode invocation.

## Guardrails

- Executor must not commit.
- Executor must not read or touch secrets.
- Executor must stay inside read/write scope.
- Executor must not silently fallback to another model/provider.
- Parent must independently verify diffs and checks.
- Git, diffs, and tests remain the source of truth.

## Not included yet

- Automatic task state movement.
- Automatic result recording.
- Automatic PR creation.
- CI integration for AgentOps workflows.
- Multi-agent SDLC framework.
- Taskplane or larger orchestration system.

## Conclusion

The POC proves the minimal executor bridge. Further work should focus on hardening, ergonomics, and repeatability, not expanding into a large framework too early.

## Next phase

Phase 3 should focus on minimal task lifecycle operations:

- move completed tasks from `ready/` to `done/`
- write result records under `.agentops/results/`
- keep lifecycle changes small, explicit, and reviewable
