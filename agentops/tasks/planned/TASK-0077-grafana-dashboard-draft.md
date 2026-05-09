# TASK-0077 — Add Grafana dashboard draft

## Status

planned

## Goal

Create a first Grafana dashboard draft for AgentOps run observability.

## Background / why now

Once Prometheus textfile export exists, a dashboard can make run trends visible:
executor duration, prompt size, output size, result ratios, and model usage.

## Problem statement

Metrics are useful but not ergonomic for day-to-day workflow review without a
dashboard that answers the main operational questions.

## Smallest useful slice

Add either dashboard JSON or documentation for a first dashboard with panels for:

- executor duration
- prompt size
- stdout/stderr size
- executor runs over time
- model usage

## Non-goals

- No complex alerting.
- No long-running exporter service.
- No production monitoring assumptions.
- No dashboard before metrics export exists.

## Open questions

- Should the repo store Grafana dashboard JSON or only documentation?
- What Prometheus labels will be available after TASK-0076?
- Should this remain local-only or target a shared observability stack?

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
- maybe `observability/grafana/agentops-dashboard.json`

## Notes

Candidate questions for dashboard panels:

- Which tasks are slow?
- Are prompts growing over time?
- Which runs produce large stdout/stderr?
- Which model is used most often?
- Are failed executor runs increasing?
