# workflow-07 — Mark branch-only helper as legacy/fallback

## Status

planned

## Goal

Make `scripts/start-agentops-task.sh` visibly non-default. Add help/usage text
and runtime messaging that flag it as legacy/fallback and point users to
`scripts/start-agentops-worktree.sh`.

## Background / why now

`skills/hermetic-coding-orchestrator/SKILL.md` already calls
`scripts/start-agentops-task.sh` a "Fallback" when worktree is not desired,
with `scripts/start-agentops-worktree.sh` as the "Preferred" helper.

But the script itself does not say so:

- its `usage()` text has no fallback/legacy marker
- its run-time output does not suggest the worktree helper
- it still performs `git checkout main` in the current checkout, which can turn the main planning cockpit into a task-branch checkout if invoked from main

That is a UX gap. Operators reading only the script's help do not know it is
the legacy path.

## Problem statement

The branch-only helper's self-description does not match the project's
documented policy. New operators may pick it as the default.

## Smallest useful slice

Docs-and-messaging update only:

- add a "legacy / fallback" line to `usage()`
- print a one-line hint at startup recommending `scripts/start-agentops-worktree.sh`
- do not change branch behavior in this slice
- do not delete or block the helper

## Executor

Harness: TBD (default in this repo: OpenCode).
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- `scripts/start-agentops-task.sh`
- `scripts/start-agentops-worktree.sh` (to confirm reference command)
- `skills/hermetic-coding-orchestrator/SKILL.md` (to confirm canonical wording)
- `agentops/USAGE.md`

## Write scope

- `scripts/start-agentops-task.sh`
- minimal docs update only if needed to refer to the legacy/fallback marker

## Requirements

The helper should:

- continue to function exactly as it does today
- print a "legacy / fallback" marker in its usage/help output
- print a one-line runtime hint at startup recommending `scripts/start-agentops-worktree.sh`
- not auto-switch to the worktree helper
- not refuse to run

## Non-goals

- Do not change branch creation behavior.
- Do not remove the helper.
- Do not add hard refusal.
- Do not auto-invoke the worktree helper.
- Do not modify `scripts/start-agentops-worktree.sh`.
- Do not modify `scripts/run-opencode-executor.sh`.

## Open questions

- Exact wording of the legacy/fallback marker.
- Whether the runtime hint goes to stdout or stderr (matters for CI parsing).
- Whether to also update SKILL.md/USAGE.md to point at the same marker wording, or treat that as a separate doc-alignment task.

## Promotion decision

Decision: keep_planned.

Reason:
Wording for the legacy/fallback marker and the runtime hint, plus the
stdout-vs-stderr placement decision, need to be locked first.

Next action:
Lock the messaging wording and stdout/stderr placement, then promote.

## Promotion criteria

Promote to `ready` when:

- legacy/fallback marker wording is agreed
- runtime hint wording is agreed
- stdout vs stderr placement is decided
- whether to also touch SKILL.md/USAGE.md is decided

## Verification

```bash
git status --short --branch
bash -n scripts/start-agentops-task.sh
scripts/start-agentops-task.sh --help
git diff --stat
```

When promoted, verify the messaging:

```bash
# usage text contains legacy/fallback marker
scripts/start-agentops-task.sh --help 2>&1 | grep -i 'legacy\|fallback'

# runtime hint references the worktree helper
# (exact stream and timing depend on the stdout-vs-stderr decision)
```

Do not use `|| true` to mask failures.

## Accept criteria

TBD during promotion.

## Hermes/coder collection prompt

TBD during promotion.

When ready, use the canonical Hermes/coder collection prompt shape from the
planned/ready task template, with the concrete ready task path.

## Return format

TBD during promotion.

When ready, use the standard AgentOps return format:

```text
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
```

## Notes

This is the messaging-only first slice. Heavier changes — hard refusal,
behavior change, or removal of the helper — belong in later tasks once the
policy markers are in place.

Related: TASK-0075 (worktree policy, done), TASK-0085 (docs drift
reconciliation), and the executor-on-main guard task (workflow-06) are the
parallel pieces of the worktree-first enforcement story.
