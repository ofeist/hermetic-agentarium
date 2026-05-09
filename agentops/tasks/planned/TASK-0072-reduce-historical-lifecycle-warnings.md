# TASK-0072 — Reduce historical lifecycle warnings

## Status

planned

## Goal

Reduce or eliminate current lifecycle checker warnings for historical done tasks
without hiding real future drift.

## Background / why now

`scripts/check-agentops-lifecycle.sh` now exits successfully but reports
historical done tasks without result notes. These warnings are intentional for
now, but they make the checker noisier than it needs to be and could reduce
trust in future lifecycle checks.

## Problem statement

The repository has done tasks that predate consistent result-note creation.
The checker warns about them on every run. We need a clear policy for historical
warnings before making lifecycle checks part of regular task closeout or CI.

## Smallest useful slice

Decide and implement one narrow policy:

- either create concise historical result notes for the warning tasks
- or add an explicit allowlist / historical-baseline file that documents why
  those missing result notes are tolerated

## Non-goals

- No changes to task lifecycle semantics.
- No changes to executor behavior.
- No broad task renumbering.
- No dashboard or observability work.
- No deletion of historical task files.

## Open questions

- Should historical tasks get synthetic result notes, or should the checker
  support an explicit allowlist?
- If synthetic result notes are created, how much detail is enough?
- Should the checker target zero warnings for local runs, or are documented
  warnings acceptable?

## Expected output

Decision: promote_to_ready / keep_planned / blocked / discard

Reason:

Next action:

## Promotion criteria

- Smallest useful slice is clear.
- Scope and non-goals are explicit.
- Open questions are resolved or marked as blockers.
- A ready task can be written with read scope, write scope, requirements,
  verification, and accept criteria.

## Candidate ready task notes

Likely read scope:

- `scripts/check-agentops-lifecycle.sh`
- `agentops/tasks/done/`
- `agentops/results/`

Likely write scope depends on policy:

- result-note approach: `agentops/results/`
- allowlist approach: checker script plus a small lifecycle baseline file

## Notes

Current warnings are historical done tasks without result notes. They are not
currently errors.
