# TASK-0081 — Refine review handoff helper

## Status

review

## Goal

Make the transition from executor/coder completion to human/parent review explicit, mechanical, and lifecycle-consistent.

## Background / why now

Current AgentOps workflow already treats executor output as untrusted and requires parent verification before acceptance. The gap is the handoff moment: after a coder/executor finishes, the task should visibly leave `ready/` and enter `review/`, with a safe artifact trail for what happened.

A baseline helper already exists: `scripts/submit-agentops-task.sh`.

It already:

- moves `agentops/tasks/ready/<slug>.md` to `agentops/tasks/review/<slug>.md`
- refuses to overwrite an existing review file
- prints next-step instructions
- does not commit
- does not mark the task done

The real gap is lifecycle consistency after the move:

- the moved markdown file can still say `## Status` = `ready`
- no matching safe result/review artifact is created or preserved under `agentops/results/`

Without this, completed-but-unreviewed work can be confused with still-ready work, and lifecycle drift becomes likely.

## Problem statement

AgentOps needs the existing review-handoff helper to preserve its current move-and-handoff behavior while also updating the task's internal lifecycle state and, if scoped in, creating or preserving a safe review/result artifact.

The helper must not pretend the work is accepted or done.

## Smallest useful slice

Refine `scripts/submit-agentops-task.sh` to update the moved file's `## Status` from `ready` to `review`, while preserving the existing move, collision-protection, next-step-printing, no-done, and no-commit behavior.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `scripts/submit-agentops-task.sh`
- `scripts/render-verification-notes.sh` if present
- `scripts/agentops-tmp-dir.sh` if present
- `agentops/tasks/ready/`
- `agentops/tasks/review/`
- `agentops/results/`
- existing lifecycle helper scripts
- AgentOps workflow documentation

## Write scope

- `scripts/submit-agentops-task.sh`
- one minimal test or fixture-style shell check, if the repository already has a suitable pattern
- minimal docs update if current docs describe handoff behavior
- `agentops/results/` behavior only if explicitly scoped in before promotion

## Requirements

- Refine the existing `scripts/submit-agentops-task.sh`; do not add a parallel helper unless inspection proves the existing helper is unsuitable.
- Preserve current behavior:
  - move `agentops/tasks/ready/<slug>.md` to `agentops/tasks/review/<slug>.md`
  - refuse to overwrite an existing review file
  - print next-step review instructions
  - do not mark the task `done`
  - do not commit
- Add missing lifecycle consistency behavior:
  - update the moved task file's `## Status` field from `ready` to `review`
  - preserve or create a matching safe review/result artifact under `agentops/results/` if scoped in during promotion
- Avoid competing helper behavior:
  - do not duplicate the existing ready-to-review move logic in a new script unless there is a clear reason
  - do not create a second review checklist artifact if an existing verification-notes flow should own that responsibility

## Non-goals

- Do not implement automatic acceptance.
- Do not mark tasks `done`.
- Do not merge branches.
- Do not push.
- Do not read or commit raw `.agentops-runs/` logs.
- Do not solve the whole lifecycle state machine in this slice.
- Do not add commit support in this slice.

## Open questions

None.

Resolved:
- Run-id binding: no for this slice. Keep `submit-agentops-task.sh` decoupled
  from local raw run logs.
- Result/review artifact: defer for this task. Do not add new artifact creation
  behavior in `submit-agentops-task.sh`; keep existing review-note workflow.

## Verification

```bash
git status --short --branch
bash -n scripts/*.sh
git diff --stat
```

Add a small tmpdir-based lifecycle fixture test, preferably using `scripts/agentops-tmp-dir.sh` if suitable:

```text
prepare fake agentops/tasks/ready/TEST-X.md
run the review handoff helper
assert file moved to agentops/tasks/review/TEST-X.md
assert in-file ## Status changed from ready to review
assert existing review-file collision behavior is preserved
assert result/review artifact behavior matches the promoted scope
```

## Accept criteria

- `scripts/submit-agentops-task.sh` still moves only `ready/ -> review/`.
- Existing review-file collision protection remains intact.
- The moved task file status is rewritten from `ready` to `review`.
- The helper still does not mark task `done` and does not commit.
- Changes stay within write scope.

## Promotion decision

Decision: promote_to_ready.

Reason:
Open questions are now resolved with a minimal scope: no run-id coupling and no
new artifact behavior in this slice.

Next action:
Implement and verify status rewrite behavior in `scripts/submit-agentops-task.sh`.

## Promotion criteria

Promote to `ready` when the following are decided:

- confirm no parallel helper is created unless the existing helper is proven unsuitable
- allowed files
- run-id binding: yes / no / defer
- result/review artifact behavior: yes / no / defer
- expected lifecycle behavior after handoff
- fixture-style verification expectations

## Hermes/coder collection prompt

/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0081-review-handoff-helper.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
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
Review:
Changed files:
Uncertainty:

## Return format

Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:

## Notes

This protects the core lifecycle boundary between executor output and trusted review.

The important implementation constraint is to refine the existing helper rather than re-implementing review handoff from scratch.
