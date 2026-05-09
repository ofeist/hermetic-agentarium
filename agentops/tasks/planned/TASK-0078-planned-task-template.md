# TASK-0078 — Add planned task template

## Status

planned

## Goal

Add a lightweight planned-task template so ideas can be promoted into planned
tasks without pretending they are executor-ready.

## Background / why now

The repo has a ready-task template, but no planned-task template. As the task
queue grows, planned tasks need a consistent format for goals, open questions,
smallest useful slice, and promotion criteria before becoming ready tasks.

## Problem statement

Without a planned-task template, planning artifacts may either stay as loose
IDEAS entries or prematurely become ready tasks with incomplete scope and
verification details.

## Smallest useful slice

Add `agentops/templates/PLANNED-TASK-TEMPLATE.md` with this structure:

```markdown
# TASK-xxxx — Short planned task title

## Status

planned

## Goal

## Background / why now

## Problem statement

## Smallest useful slice

## Non-goals

## Open questions

## Expected output

Decision: promote_to_ready / keep_planned / blocked / discard

Reason:

Next action:

## Promotion criteria

- Smallest useful slice is clear.
- Scope and non-goals are explicit.
- Open questions are resolved or marked as blockers.
- A ready task can be written with read scope, write scope, requirements, verification, and accept criteria.

## Candidate ready task notes

## Notes
```

## Non-goals

- No changes to ready-task template.
- No lifecycle automation.
- No new promotion helper.

## Open questions

- Should planned tasks include task IDs immediately, or only when promoted from
  ideas?
- Should there be a helper for creating planned tasks later?

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

Likely read/write scope:

- `agentops/templates/PLANNED-TASK-TEMPLATE.md`
- `agentops/USAGE.md`

## Notes

This should be the last planned task in the current planning batch.
