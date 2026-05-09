# worktree-01 — Add AgentOps worktree policy and helper

## Status

planned

## Goal

Make the AgentOps worktree model explicit: keep the `main` worktree as the
planning cockpit, and run executor work in task-specific git worktrees.

## Background / why now

The current helper, `scripts/start-agentops-task.sh`, creates a task branch in
the current worktree. That was useful early on, but it makes it too easy for the
planning worktree to become the executor worktree.

Recent TASK-0072/TASK-0073 work showed that task branches and task worktrees are
safer when they are clearly separated from the planning cockpit.

## Problem statement

The repo does not yet have a durable worktree policy or a helper that makes the
desired workflow easy.

Without this, agents may:

- run OpenCode executor work directly on `main`
- switch the planning worktree away from `main`
- edit the same task file from the planning worktree and task worktree at the
  same time
- forget to update the main worktree after a task branch is merged

## Smallest useful slice

Document the worktree policy and add a small helper:

```bash
scripts/start-agentops-worktree.sh TASK-0073
```

The policy should say:

- `main` worktree is the planning cockpit.
- Executor work must happen in a task-specific git worktree.
- One task worktree should map to one task branch.
- Do not run OpenCode executor work directly on `main`.
- Do not edit the same task file from the planning worktree and task worktree
  at the same time.
- After a task branch is merged, update the main worktree with `git pull`.

The helper should create or prepare a task-specific worktree and branch without
switching the main planning worktree away from `main`.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

TBD

Likely candidates:

- `scripts/start-agentops-task.sh`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/USAGE.md`
- `docs/DEBUGGING.md`
- `docs/FIRST-RUN.md`
- `agentops/tasks/planned/worktree-01-agentops-worktree-policy.md`

## Write scope

TBD

Likely candidates:

- `scripts/start-agentops-worktree.sh`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/USAGE.md`
- docs only if needed to remove stale "executor starts on main" guidance

## Requirements

TBD

When ready, this task should require:

- Add `scripts/start-agentops-worktree.sh`.
- Document that the main worktree is the planning cockpit.
- Document that executor work must happen in a task-specific git worktree.
- Ensure one task worktree maps to one task branch.
- Ensure the helper does not switch the main planning worktree away from
  `main`.
- Ensure the helper refuses to proceed if the main planning worktree is dirty,
  unless the ready task explicitly chooses a safer alternative.
- Ensure the helper fetches/pulls `main` before creating the task worktree.
- Ensure the helper creates a task branch named from the task slug, for example
  `task-0073-agentops-executor-run-metadata-baseline`.
- Ensure the helper creates a predictable local worktree path.
- Ensure the helper is idempotent enough to report an existing branch/worktree
  clearly instead of overwriting it.
- Update the orchestrator skill so future Hermes/coder runs prefer the worktree
  helper over running executor work in the main worktree.
- Update or remove stale documentation that implies executor work should start
  directly on `main`.

## Non-goals

- No broad lifecycle redesign.
- No automatic merge/accept/push behavior.
- No executor behavior changes.
- No deletion of existing task worktrees.
- No destructive cleanup.
- No replacement for the review prompt flow.
- No changes to model selection.

## Open questions

- Should task worktrees live next to the repo root, for example
  `../hermetic-agentarium-task-0073`, or under a configurable root?
- Should the helper accept only `TASK-XXXX...` slugs, or also accept a full
  ready task path and derive the slug?
- Should an existing branch be treated as blocked, or should the helper attach a
  worktree to it when safe?
- Should `scripts/start-agentops-task.sh` remain as a branch-only helper or be
  deprecated in docs?

If these are resolved before promotion, write:

```text
None.
```

## Verification

TBD

Likely commands:

```bash
bash -n scripts/start-agentops-worktree.sh
scripts/start-agentops-worktree.sh --help
git status --short --branch
git diff --stat
```

Add a non-destructive smoke test when ready. If the helper creates a temporary
test worktree, verification must remove only that temporary worktree and branch.

## Accept criteria

TBD

When ready, accept criteria should include:

- The worktree policy is documented in the agreed durable location.
- `scripts/start-agentops-worktree.sh` exists and is executable.
- The helper creates a task-specific branch and worktree without switching the
  main worktree away from `main`.
- The helper refuses or reports clearly on dirty main worktree, existing branch,
  or existing worktree cases.
- The orchestrator skill tells future agents not to run executor work directly
  on `main`.
- Stale docs that imply executor work starts directly on `main` are corrected or
  called out.
- Verification commands pass.
- Diff stays within write scope.

## Promotion decision

Decision: keep_planned

Reason:

The workflow need is clear, but the helper behavior needs one more design
decision: where task worktrees should live and how to handle existing
branches/worktrees.

Next action:

Resolve the worktree path and existing-branch behavior, then promote this to the
next ready `TASK-XXXX` ID.

## Promotion criteria

This task can be promoted to ready when:

- read scope is known
- write scope is known
- open questions are resolved or explicitly marked as blockers
- requirements are concrete
- verification commands are known
- accept criteria are concrete
- non-goals are clear

## Hermes/coder collection prompt

TBD until ready.

When ready, use this shape:

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-XXXX-agentops-worktree-policy.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- create/switch to an appropriate task branch
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME, OPENCODE_XDG_DATA_HOME, and AGENTOPS_EXECUTOR_MODEL
- use the runner-configured executor model
- do not silently fallback to another model
- do not commit
- independently verify the result

Return:
Plan:
Implementation:
Verification:
Review:
Changed files:
Uncertainty:
```

## Return format

TBD until ready.

When ready, expected executor return format:

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

This should become a workflow guardrail before many more executor tasks are run.
The policy belongs in the repo because chat reminders are not durable.
