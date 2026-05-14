# TASK-0085 — Reconcile branch-vs-worktree documentation drift

## Status

ready

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

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

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

None.

Resolved:

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
Execute through the Hermes/coder collection prompt.

## Promotion criteria

Already promoted to ready.

## Verification

```bash
git status --short --branch
git diff --stat
```

Search for stale executor-location wording:

```bash
grep -RIn "create/switch to.*task branch\|task branch before executor\|executor work on a branch\|Parent creates a task branch" \
  README.md profiles/coder/SOUL.md skills/hermetic-coding-orchestrator/SKILL.md docs agentops
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

Do not use `|| true` to mask failures.

## Accept criteria

- Change is limited to write scope.
- README, SOUL.md, FIRST-RUN, DEBUGGING, POC-STATUS, and the relevant SKILL.md prompt/executor sections no longer describe branch-only executor execution as the default.
- Executor work is consistently described as running in a task-specific worktree on a task branch.
- `main` is consistently described as the planning/control checkout.
- Branch wording remains only where it clearly refers to the Git branch inside a task worktree.
- No script files are changed.
- No new decision record is created.
- No lifecycle directory structure is changed.
- Verification commands are reported with results.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0085-reconcile-branch-worktree-docs-drift.md

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
- docs-only reconciliation
- do not change scripts
- do not change the worktree policy
- do not create a new ADR or decision record
- only replace branch-only executor-location wording with worktree-and-branch wording

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

This task replaces the older "decide branch vs worktree execution strategy"
framing. The decision has already been made. The useful work now is to remove
drift and make the documentation match the existing worktree-first execution
model.

Related: TASK-0075 (worktree policy, done) established the canonical policy.
Follow-up planned tasks cover the script side:
- `agentops/tasks/ready/TASK-0086-executor-on-main-guard.md` —
  add an on-main guard to `scripts/run-opencode-executor.sh`.
- `agentops/tasks/planned/52-workflow-07-legacy-marker-start-agentops-task.md` —
  mark `scripts/start-agentops-task.sh` as legacy/fallback in its own
  usage/runtime output.
