# TASK-0091 — Fix accept helper to update done task status

## Status

ready

## Goal

Ensure accepted tasks are visibly closed out by rewriting moved task status from
`review` to `done` during review -> done lifecycle transition.

## Background / why now

Recent closeouts (TASK-0084, TASK-0085, TASK-0086) repeated the same drift:
task files were moved to `agentops/tasks/done/` but internal `## Status`
remained `review`.

This creates avoidable lifecycle inconsistency and requires follow-up fix
commits after closeout.

## Problem statement

`scripts/accept-agentops-task.sh` currently closes lifecycle location but does
not reliably rewrite the moved task file's status to `done` for the
`## Status` style used in task files.

## Smallest useful slice

Update `scripts/accept-agentops-task.sh` so accepted tasks moved from
`agentops/tasks/review/` to `agentops/tasks/done/` have internal status updated
from `review` to `done`, and verify with a minimal fixture.

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `scripts/accept-agentops-task.sh`
- `scripts/check-agentops-lifecycle.sh`
- `agentops/tasks/review/`
- `agentops/tasks/done/`
- prior task result notes for TASK-0084/TASK-0085/TASK-0086

## Write scope

- `scripts/accept-agentops-task.sh`
- minimal shell test/fixture script only if needed
- task/result lifecycle files only when running the closeout flow itself

## Requirements

TBD

When ready, this section should contain concrete implementation requirements.

Possible planning notes:

- Accept helper should rewrite moved task file status from `review` to `done`.
- Handle both status styles if present:
  - `Status: review` -> `Status: done`
  - `## Status` followed by `review` -> `done`
- Keep review->done move behavior unchanged.
- Keep result-note behavior unchanged except where needed for consistency.

## Non-goals

- No unrelated refactors.
- No broad lifecycle changes.
- No dashboard/observability/infra work unless this task is specifically about that.
- No changes outside write scope unless verification proves it is necessary.

## Open questions

None.

## Promotion decision

Decision: promote_to_ready

Reason:
The defect pattern is clear, scope is narrow, and required verification is
explicit.

Next action:
Promote to ready and implement helper status rewrite plus fixture verification.

## Promotion criteria

This task can be promoted to ready when:

- read scope is known
- write scope is known
- open questions are resolved or explicitly marked as blockers
- requirements are concrete
- verification commands are known
- accept criteria are concrete
- non-goals are clear

## Verification

```bash
git status --short --branch
git diff --stat
```

Add task-specific checks below this base set.

Required task-specific checks when ready:

- create temp review task fixture
- run accept helper
- assert file moved to `agentops/tasks/done/`
- assert internal status is `done`
- run `scripts/check-agentops-lifecycle.sh`

## Accept criteria

Default accept criteria. Replace or extend during promotion if the task needs
more specific checks.

- Change is limited to write scope.
- Verification commands pass.
- Existing behavior is preserved unless explicitly changed.
- The new behavior is documented or covered by a check.

## Hermes/coder collection prompt

Synchronized copy policy:
- This block is an ergonomics copy of the canonical prompt in
  `skills/hermetic-coding-orchestrator/SKILL.md`
  (`### Canonical ready task invocation prompt`).
- Keep wording aligned with the canonical SKILL prompt and rendered helper output
  (`scripts/render-collection-prompt.sh`).
- Replace `TASK-xxxx-short-slug.md` with the actual ready task path.

```text
/hermetic-coding-orchestrator

Execute AgentOps ready task:

agentops/tasks/ready/TASK-0091-accept-helper-done-status.md

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

Return:
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:

Also note: task-specific paths, verification commands, or constraints can be added below this prompt when needed
```

## Return format

```text
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
```

## Notes

Origin: IDEAS entry "Fix accept helper to update done task status".

Assign a TASK-XXXX ID only when promoting to `ready/`.
