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

## Smallest useful slice

Create a docs-only decision record that states the default execution strategy, recommends branch-first unless there is a strong reason for worktrees, and defines when worktrees are allowed.

## Executor

Harness: TBD.
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- `README.md`
- AgentOps workflow documentation
- `profiles/coder/SOUL.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `scripts/start-agentops-task.sh`
- `scripts/run-opencode-executor.sh`
- lifecycle helper scripts

## Write scope

- one workflow doc or decision record
- optional small helper-script messaging update only if needed

## Requirements

The decision record should:

- inspect current docs and helper scripts for assumptions about branches/worktrees
- document the default execution strategy
- recommend branch-first unless there is a strong reason for worktrees
- define when worktrees are allowed, for example parallel long-running tasks or isolated experiments
- explain merge/review implications
- identify any helper scripts that would need later changes
- avoid implementing full worktree automation in this slice

## Non-goals

- Do not implement full worktree automation in this slice.
- Do not change existing task lifecycle directories unless necessary.
- Do not introduce a scheduler.
- Do not change model/provider configuration.
- Do not make helper scripts create worktrees automatically unless explicitly promoted that way.

## Open questions

- Should worktree support be deferred entirely until branch workflow is stable?
- Should helper scripts refuse to run on `main` but not create worktrees automatically?
- Should there be a future `start-agentops-task.sh --worktree` option?

## Verification

```bash
git status --short --branch
bash -n scripts/*.sh
git diff --stat
```

If the slice remains docs-only, syntax checks are only needed for scripts that are touched.

## Accept criteria

TBD during promotion.

## Promotion decision

Decision: keep_planned.

Reason:
The desired output is not yet narrowed to a pure docs-only decision record or a small docs-plus-script guard change.

Next action:
Choose the exact target document and decide whether script messaging changes are in scope.

## Promotion criteria

Promote to `ready` when:

- the target output is narrowed to a docs-only decision record or a small docs-plus-script guard change
- the target file is chosen
- the default strategy wording is agreed at a high level
- read/write scope is confirmed

## Hermes/coder collection prompt

TBD during promotion.

## Return format

TBD during promotion.

## Notes

This should come before adding heavier automation, because automation will otherwise bake in the wrong execution model.
