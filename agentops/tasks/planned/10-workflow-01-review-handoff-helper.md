# workflow-01 — Add review handoff helper

## Status

planned

## Goal

Make the transition from executor/coder completion to human/parent review explicit and mechanical.

## Background / why now

Current AgentOps workflow already treats executor output as untrusted and requires parent verification before acceptance. The gap is the handoff moment: after a coder/executor finishes, the task should visibly leave `ready/` and enter `review/`, with a safe artifact trail for what happened.

Without this, completed-but-unreviewed work can be confused with still-ready work, and lifecycle drift becomes likely.

## Problem statement

AgentOps needs a small helper or documented command that moves a completed ready task into review state after executor work finishes, without pretending the work is accepted or done.

The helper should not commit by default. Committing after handoff may be useful later, but should remain optional and explicit.

## Rough scope

- Add or refine a helper such as `scripts/submit-agentops-task.sh` or equivalent review-handoff script.
- Move task file from `agentops/tasks/ready/` to `agentops/tasks/review/`.
- Update task status from `ready` to `review`.
- Preserve or create a matching safe result/summary artifact under `agentops/results/` when appropriate.
- Print next-step instructions for parent review.
- Do not mark the task `done`.
- Do not commit unless explicitly requested.

## Open questions

- Should the helper require a run id from `.agentops-runs/<run-id>/`?
- Should the helper create a minimal review checklist automatically?
- Should optional commit support live in this helper or in a separate follow-up helper?

## Non-goals

- Do not implement automatic acceptance.
- Do not merge branches.
- Do not push.
- Do not read or commit raw `.agentops-runs/` logs.
- Do not solve the whole lifecycle state machine in this slice.

## Promotion criteria

Promote to `ready` when the exact helper name, allowed files, and expected lifecycle behavior are decided.

## Suggested ready-task execution fields

### Read scope

- `agentops/tasks/ready/`
- `agentops/tasks/review/`
- `agentops/results/`
- existing lifecycle helper scripts
- AgentOps workflow documentation

### Write scope

- one lifecycle helper script
- minimal docs update
- minimal tests or shell syntax checks if present

### Verification

```bash
git status --short --branch
bash -n scripts/*.sh
git diff --stat
```

Add a small dry-run/manual test if the repository already has fixtures for task lifecycle scripts.

## Notes

Priority: highest. This protects the core lifecycle boundary between executor output and trusted review.
