# TASK-0075 — Document AgentOps observability workflow

## Status

planned

## Goal

Document how to inspect AgentOps run metadata and avoid token-heavy debugging.

## Background / why now

The workflow already has Hermes sessions/logs, OpenCode stats, local
`.agentops-runs/` artifacts, and AgentOps result notes. The missing piece is a
single operator-facing guide that explains when to use each signal and what not
to paste into prompts.

## Problem statement

When runs are slow or token-heavy, it is not obvious whether to inspect Hermes
sessions, Hermes logs, OpenCode stats, local run metadata, stdout/stderr logs,
or git diffs. Without guidance, users may paste large logs/diffs into model
prompts and make the problem worse.

## Smallest useful slice

Add `docs/RUN-OBSERVABILITY.md` covering:

- metadata files and local artifacts
- what should and should not go into prompts
- Hermes session/log inspection
- OpenCode stats
- recommended debugging flow
- when to inspect full logs manually

## Non-goals

- No new scripts.
- No Prometheus export.
- No Grafana dashboard.
- No raw log examples that could encourage prompt bloat.

## Open questions

- Which Hermes commands should be documented as canonical for this repo?
- Should the doc reference `/usage`, `/stats`, or both, given version-specific
  Hermes behavior?
- Should the doc wait until TASK-0073 and TASK-0074 exist?

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

- `docs/RUN-OBSERVABILITY.md`
- `docs/DOCUMENTATION-MAP.md`
- maybe `docs/DEBUGGING.md`

## Notes

Core rule:

> Full logs are for humans and local debugging. Model prompts receive only
> compact summaries unless explicitly requested.
