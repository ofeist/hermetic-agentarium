# workflow-02 — Decide branch vs worktree execution strategy

## Status

planned

## Goal

Clarify the default AgentOps execution strategy: whether tasks should run in branches inside one checkout, separate git worktrees, or a documented hybrid.

## Background / why now

The workflow currently emphasizes task branches and not running executor work directly on `main`. There is also an open concern that worktrees may complicate merging into `main`, especially for larger repositories or parallel agent work.

Before adding more automation, the repository should document the default strategy so helper scripts do not encode inconsistent assumptions.

## Problem statement

AgentOps needs one default rule for where executor work happens.

Branches are simpler for most users. Worktrees may help with parallelism, but they add operational complexity and can confuse merge/review flow. The workflow should pick a default and explain when exceptions are allowed.

## Rough scope

- Inspect current docs and helper scripts for assumptions about branches/worktrees.
- Document the default execution strategy.
- Recommend branch-first unless there is a strong reason for worktrees.
- Define when worktrees are allowed, for example parallel long-running tasks or isolated experiments.
- List merge/review implications.
- Identify any helper scripts that would need later changes.

## Open questions

- Should worktree support be deferred entirely until branch workflow is stable?
- Should helper scripts refuse to run on `main` but not create worktrees automatically?
- Should there be a future `start-agentops-task.sh --worktree` option?

## Non-goals

- Do not implement full worktree automation in this slice.
- Do not change existing task lifecycle directories unless necessary.
- Do not introduce a scheduler.
- Do not change model/provider configuration.

## Promotion criteria

Promote to `ready` when the desired output is narrowed to a docs-only decision record or a small docs+script guard change.

## Suggested ready-task execution fields

### Read scope

- `README.md`
- AgentOps workflow docs
- `scripts/start-agentops-task.sh`
- `scripts/run-opencode-executor.sh`
- lifecycle helper scripts

### Write scope

- one workflow doc or decision record
- optional small helper-script messaging update

### Verification

```bash
git status --short --branch
bash -n scripts/*.sh
git diff --stat
```

## Notes

Priority: high. This should come before adding heavier automation, because automation will otherwise bake in the wrong execution model.
