# workflow-04 — Reconcile branch-vs-worktree documentation drift

## Status

planned

## Goal

Align non-canonical documentation with the already decided AgentOps
worktree-first execution policy.

The policy itself is not being decided in this task. TASK-0075 already
established the target model:

- the main checkout is the planning/control cockpit
- executor work happens in a task-specific worktree
- each task worktree uses its own task branch
- executor work must not run directly on `main`

This task only reconciles older branch-only wording that still exists in
documentation and prompts.

## Background / why now

The original branch-vs-worktree task assumed that the execution strategy still
needed to be decided. That is now obsolete.

Repository investigation found that the worktree-first policy already exists in
`skills/hermetic-coding-orchestrator/SKILL.md` under the AgentOps worktree
policy section, and related task/result history from TASK-0075 already supports
that direction.

The remaining problem is documentation drift:

- some files still say only "create/switch to a task branch"
- newer policy says "use a task-specific worktree and branch"
- `main` should remain the planning/control checkout
- executor work should not happen directly in the planning checkout

## Current policy

Branches remain the logical unit of change. Worktrees are the execution
isolation mechanism.

The intended model is:

```text
main checkout
  planning, backlog, lifecycle coordination, docs review

task worktree
  executor implementation work
  task branch checked out
  task-specific diff
  review/accept source
```

Correct wording:

```text
Run executor work in a task-specific worktree on a task branch.
```

Stale wording:

```text
Create/switch to a task branch before executor work.
```

The stale wording is not completely wrong, but it is incomplete because it
omits the task worktree execution context.

## Problem statement

AgentOps currently has mixed wording around executor execution location.

Some documentation still describes branch-only execution in the current
checkout, while the canonical policy now says executor work should happen in
task-specific worktrees.

This can confuse users and agents because "task branch" alone does not explain
whether executor work should happen in the main planning checkout or in an
isolated task worktree.

## Smallest useful slice

Docs-only reconciliation.

Update the known drifting documentation and prompt text so they consistently
describe the existing worktree-first policy.

- No script changes.
- No new decision record.
- No policy change.

## Executor

Harness: TBD (default in this repo: OpenCode).
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `README.md`
- `profiles/coder/SOUL.md`
- `docs/FIRST-RUN.md`
- `docs/DEBUGGING.md`
- `docs/POC-STATUS.md`
- `agentops/USAGE.md`

## Write scope

- `README.md`
- `profiles/coder/SOUL.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `docs/FIRST-RUN.md`
- `docs/DEBUGGING.md`
- `docs/POC-STATUS.md`

In `skills/hermetic-coding-orchestrator/SKILL.md`, only update the stale
canonical prompt / executor wording if needed. Do not rewrite the
already-canonical worktree policy section unless a small consistency edit is
required.

## Requirements

The updated documentation should make clear that:

- `main` is the planning/control checkout
- executor work should not run directly on `main`
- executor work should run in a task-specific worktree
- each task worktree should use its own task branch
- branches remain the unit of change and review
- worktrees provide execution isolation
- branch-only wording should not be used when referring to executor location
- branch wording may remain where it clearly refers to the branch inside a task worktree
- `scripts/start-agentops-worktree.sh` is the preferred helper for starting executor work
- `scripts/start-agentops-task.sh` may remain documented as a fallback if already described that way, but should not be promoted as the default

## Non-goals

- Do not change the worktree policy.
- Do not create a new ADR or decision record.
- Do not implement worktree automation.
- Do not modify `scripts/start-agentops-worktree.sh`.
- Do not modify `scripts/start-agentops-task.sh`.
- Do not modify `scripts/run-opencode-executor.sh`.
- Do not change task lifecycle directories.
- Do not add lock/run-state handling.
- Do not add stale worktree cleanup.
- Do not deprecate the branch-only helper in this task.

## Open questions

None for this slice.

Resolved assumptions:

- Worktree-first policy already exists.
- The canonical execution policy lives in `skills/hermetic-coding-orchestrator/SKILL.md`.
- This task is documentation reconciliation, not policy design.
- Script behavior changes belong in later tasks.

## Promotion decision

Decision: promote_to_ready.

Reason:
All blocker decisions are resolved. The scope is concrete docs-only
reconciliation against a canonical source that already exists. Read/write
scope, requirements, non-goals, and accept criteria are all concrete.

Next action:
Promote to ready and execute through the Hermes/coder collection prompt.

## Promotion criteria

Promote to `ready` when:

- the canonical source location is confirmed (done: `SKILL.md`)
- the read/write scope is confirmed (done)
- the wording-change rule is concrete (done: replace branch-only executor wording with worktree-and-branch wording)
- accept criteria are concrete (done)

## Verification

```bash
git status --short --branch
git diff --stat
```

Search for stale executor-location wording:

```bash
grep -RIn "create/switch to.*task branch\|task branch before executor\|executor work on a branch\|Parent creates a task branch" \
  README.md profiles/coder/SOUL.md skills/hermetic-coding-orchestrator/SKILL.md docs agentops || true
```

If no scripts are changed, script syntax checks are not required.

If any shell script is accidentally touched, run:

```bash
bash -n scripts/*.sh
```

Run lifecycle checker if available:

```bash
scripts/check-agentops-lifecycle.sh
```

## Accept criteria

- README, SOUL.md, FIRST-RUN, DEBUGGING, POC-STATUS, and the relevant SKILL.md prompt/executor sections no longer describe branch-only executor execution as the default.
- Executor work is consistently described as running in a task-specific worktree on a task branch.
- `main` is consistently described as the planning/control checkout.
- Branch wording remains only where it clearly refers to the Git branch inside a task worktree.
- No script files are changed.
- No new decision record is created.
- No lifecycle directory structure is changed.
- Verification commands are reported with results.

## Hermes/coder collection prompt

TBD during promotion.

When ready, use the canonical Hermes/coder collection prompt shape from the
planned/ready task template, with the concrete ready task path.

Suggested prompt body for promotion:

```text
Goal:
Reconcile branch-vs-worktree documentation drift with the already decided
AgentOps worktree-first policy.

Context:
TASK-0075 already established that the main checkout is the planning/control
cockpit and executor work should happen in task-specific worktrees. Each
task worktree uses its own task branch. Executor work must not run directly
on main.

Scope:
Docs-only update.

Read:
- skills/hermetic-coding-orchestrator/SKILL.md
- README.md
- profiles/coder/SOUL.md
- docs/FIRST-RUN.md
- docs/DEBUGGING.md
- docs/POC-STATUS.md
- agentops/USAGE.md

Write:
- README.md
- profiles/coder/SOUL.md
- skills/hermetic-coding-orchestrator/SKILL.md
- docs/FIRST-RUN.md
- docs/DEBUGGING.md
- docs/POC-STATUS.md

Constraints:
- Do not change scripts.
- Do not create a new ADR.
- Do not change the policy.
- Do not implement worktree automation.
- Do not change lifecycle directories.
- Only replace branch-only executor-location wording with worktree-and-branch wording.
- Keep the change minimal.

Verification:
- git status --short --branch
- git diff --stat
- grep for stale branch-only executor wording
- scripts/check-agentops-lifecycle.sh if available

Return:
- changed files
- summary of updated wording
- remaining stale wording, if any
- verification commands and results
- uncertainty
```

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

This task replaces the older "decide branch vs worktree execution strategy"
framing. The decision has already been made. The useful work now is to remove
drift and make the documentation match the existing worktree-first execution
model.
