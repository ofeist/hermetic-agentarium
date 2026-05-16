# TASK-0087 — Mark branch-only helper as legacy/fallback

## Status

done

## Goal

Make `scripts/start-agentops-task.sh` visibly non-default. Add help/usage text
and a runtime hint that flag it as legacy/fallback and point users to
`scripts/start-agentops-worktree.sh`.

## Background / why now

`skills/hermetic-coding-orchestrator/SKILL.md` already calls
`scripts/start-agentops-task.sh` a "Fallback" when worktree is not desired,
with `scripts/start-agentops-worktree.sh` as the "Preferred" helper.

But the script itself does not say so:

- its `usage()` text has no fallback/legacy marker
- its run-time output does not suggest the worktree helper
- it still performs `git checkout main` in the current checkout, which can
  turn the main planning cockpit into a task-branch checkout if invoked from
  main

That is a UX gap. Operators reading only the script's help do not know it is
the legacy path.

## Problem statement

The branch-only helper's self-description does not match the project's
documented policy. New operators may pick it as the default.

## Smallest useful slice

Messaging-only update to `scripts/start-agentops-task.sh`:

- add the locked "legacy/fallback" marker to `usage()`
- print the locked runtime hint to stderr at startup
- do not change branch behavior in this slice
- do not delete or block the helper
- do not auto-forward to the worktree helper

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `scripts/start-agentops-task.sh`
- `scripts/start-agentops-worktree.sh` (to confirm reference command)
- `skills/hermetic-coding-orchestrator/SKILL.md` (to confirm canonical wording)
- `agentops/USAGE.md`

## Write scope

- `scripts/start-agentops-task.sh`

Default write scope is the script only. Do not edit
`skills/hermetic-coding-orchestrator/SKILL.md` or `agentops/USAGE.md` in this
slice unless inspection proves a tiny reference update is strictly necessary
to keep wording consistent. If such an edit is needed, keep it to one line.

## Requirements

The helper should:

- continue to function exactly as it does today (no behavior change)
- print the locked legacy/fallback marker in its `usage()`/help output
- print the locked runtime hint to stderr at startup
- not auto-switch to the worktree helper
- not refuse to run
- not change branch creation logic

Locked usage/help marker (printed wherever the script currently prints its
usage, on the same stream it already uses):

```text
Legacy/fallback helper: starts executor work in the current checkout.
Preferred helper: scripts/start-agentops-worktree.sh
```

Locked runtime hint (printed to stderr at startup, before the helper does
real work):

```text
Hint: start-agentops-task.sh is the legacy/fallback path. Prefer scripts/start-agentops-worktree.sh for executor work.
```

Locked semantics:

- usage/help stream: keep whatever stream the script currently uses for usage
- runtime hint stream: stderr (advisory/diagnostic; must not pollute stdout)
- placement of runtime hint: at startup, before any branch-mutating action
- docs scope: only edit SKILL.md/USAGE.md if inspection shows a strictly
  necessary one-line reference update; default is script-only

Workflow requirements:

- The execution prompt MUST start with `/hermetic-coding-orchestrator` to
  explicitly invoke the custom skill.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near the
  beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration, not by task
  prompt text.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking
  OpenCode.

## Non-goals

- Do not change branch creation behavior.
- Do not remove the helper.
- Do not add hard refusal.
- Do not auto-invoke the worktree helper.
- Do not modify `scripts/start-agentops-worktree.sh`.
- Do not modify `scripts/run-opencode-executor.sh`.
- Do not edit `skills/hermetic-coding-orchestrator/SKILL.md` or
  `agentops/USAGE.md` unless a strictly necessary one-line reference update
  is required to keep wording consistent.
- Do not rewrite the script's usage text beyond inserting the locked marker.

## Open questions

None.

Resolved:

- Usage/help marker wording: locked above.
- Runtime hint wording: locked above.
- Runtime hint stream: stderr.
- Usage/help stream: whichever stream the script currently uses.
- Docs scope: script only by default; SKILL.md/USAGE.md only if strictly
  needed.
- Behavior: unchanged (no refusal, no auto-forward, no branch logic change).

## Promotion decision

Decision: promote_to_ready.

Reason:
Marker wording, hint wording, stream placement, docs scope, and behavior
guardrails are all locked. Read/write scope is concrete and narrow.

Next action:
Promote to ready and execute through the Hermes/coder collection prompt
*after* TASK-0086 lands. Execution order is TASK-0085 → TASK-0086 → TASK-0087.

## Promotion criteria

Already promoted to ready.

## Verification

Planned-stage / non-destructive validation only:

```bash
git status --short --branch
bash -n scripts/start-agentops-task.sh
git diff --stat
```

Inspect the script source first to confirm where `usage()` is printed and
where startup happens, *before* invoking the script with side effects.

Once the change is in place, verify the messaging with a non-destructive
check that captures both stdout and stderr together:

```bash
# usage text contains legacy/fallback marker
scripts/start-agentops-task.sh --help 2>&1 | grep -i 'legacy\|fallback'
```

Do not invoke the helper without `--help` (or an equivalent safe path) just
to observe the runtime hint, because the helper performs `git checkout main`
and branch creation in the current checkout. If the runtime hint must be
exercised live, do it inside a disposable task worktree, not in the main
planning checkout.

Do not use `|| true` to mask failures.

## Accept criteria

- Change is limited to write scope.
- `scripts/start-agentops-task.sh --help` output contains the locked
  legacy/fallback marker.
- The script prints the locked runtime hint to stderr at startup, before any
  branch-mutating action.
- The helper's existing behavior is unchanged (no refusal, no auto-forward,
  no branch logic change).
- `scripts/start-agentops-worktree.sh` is not modified.
- `scripts/run-opencode-executor.sh` is not modified.
- `skills/hermetic-coding-orchestrator/SKILL.md` and `agentops/USAGE.md` are
  only modified if strictly necessary, and at most one line each.
- Verification commands pass.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0087-legacy-marker-start-agentops-task.md

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

Scope:
- modify only scripts/start-agentops-task.sh (script-only by default)
- add the locked legacy/fallback marker to the usage/help output
- print the locked runtime hint to stderr at startup, before any branch-mutating action
- do not change branch creation behavior
- do not add refusal or auto-forwarding
- do not modify scripts/start-agentops-worktree.sh or scripts/run-opencode-executor.sh
- do not edit SKILL.md or agentops/USAGE.md unless a strictly necessary one-line reference update is required
- inspect the script first; verify with `scripts/start-agentops-task.sh --help 2>&1 | grep -i 'legacy\|fallback'`
- do not run the helper without --help just to observe the hint; it mutates branches in the current checkout

Return:
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
```

## Return format

Expected executor return format:

```text
Plan:
...

Implementation:
...

Verification:
...

Review:
accept / revise / revert / no-op / blocked

Changed files:
...

Uncertainty:
...
```

## Notes

This is the messaging-only first slice. Heavier changes — hard refusal,
behavior change, or removal of the helper — belong in later tasks once the
policy markers are in place.

Related: TASK-0075 (worktree policy, done), TASK-0085 (docs drift
reconciliation, ready), and TASK-0086 (executor-on-main guard, ready) are the
parallel pieces of the worktree-first enforcement story. Execution order is
TASK-0085 → TASK-0086 → TASK-0087.
