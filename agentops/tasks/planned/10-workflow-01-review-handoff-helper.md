# workflow-01 — Refine review handoff helper

## Status

planned

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

## Rough scope

- Refine existing `scripts/submit-agentops-task.sh`; do not add a parallel helper unless inspection proves the existing helper is unsuitable.
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

## Decide before promotion

- Run-id binding: yes / no / defer
  - If yes, define how `.agentops-runs/<run-id>/` maps to the task and result artifact.
  - If no, keep `submit-agentops-task.sh` decoupled from local raw run logs.

- Result/review artifact: yes / no / defer
  - If yes, define whether this is a minimal result stub, a review checklist, or output from an existing verification-notes helper.
  - Avoid creating a competing artifact unless intentionally separate.

- Commit support: defer
  - Commit behavior is out of scope for this slice.
  - The helper must not commit.

## Non-goals

- Do not implement automatic acceptance.
- Do not mark tasks `done`.
- Do not merge branches.
- Do not push.
- Do not read or commit raw `.agentops-runs/` logs.
- Do not solve the whole lifecycle state machine in this slice.
- Do not add commit support in this slice.

## Promotion criteria

Promote to `ready` when the following are decided:

- exact helper name: likely `scripts/submit-agentops-task.sh`
- allowed files
- run-id binding: yes / no / defer
- result/review artifact behavior: yes / no / defer
- expected lifecycle behavior after handoff
- fixture-style verification expectations

## Suggested ready-task execution fields

### Read scope

- `scripts/submit-agentops-task.sh`
- `scripts/render-verification-notes.sh` if present
- `scripts/agentops-tmp-dir.sh` if present
- `agentops/tasks/ready/`
- `agentops/tasks/review/`
- `agentops/results/`
- existing lifecycle helper scripts
- AgentOps workflow documentation

### Write scope

- `scripts/submit-agentops-task.sh`
- one minimal test or fixture-style shell check, if the repository already has a suitable pattern
- minimal docs update if current docs describe handoff behavior
- `agentops/results/` behavior only if explicitly scoped in before promotion

### Verification

```bash
git status --short --branch
bash -n scripts/*.sh
git diff --stat
```

When promoted, add a small tmpdir-based lifecycle fixture test, preferably using `scripts/agentops-tmp-dir.sh` if suitable:

```text
prepare fake agentops/tasks/ready/TEST-X.md
run the review handoff helper
assert file moved to agentops/tasks/review/TEST-X.md
assert in-file ## Status changed from ready to review
assert existing review-file collision behavior is preserved
assert result/review artifact behavior matches the promoted scope
```

## Notes

This protects the core lifecycle boundary between executor output and trusted review.

The important implementation constraint is to refine the existing helper rather than re-implementing review handoff from scratch.
