# TASK-0076 — Add Prometheus textfile export

## Status

planned

## Goal

Export selected AgentOps run metrics in Prometheus textfile format.

## Background / why now

After local metadata and summaries are stable, the next observability layer is
machine-readable metrics for Prometheus and Grafana. The simplest export path is
Node Exporter textfile collector format.

## Problem statement

Local metadata answers one-run questions, but it does not show trends such as
prompt size growth, executor duration, output size, failure rate, or model usage
over time.

## Smallest useful slice

Add:

```bash
scripts/export-agentops-prometheus-metrics.sh <output.prom>
```

The script reads `.agentops-runs/*/metadata.txt` and writes selected metrics in
Prometheus textfile format.

## Non-goals

- No long-running exporter service.
- No Grafana dashboard.
- No alerting.
- No token/cost metrics unless reliable fields exist in metadata.

## Open questions

- Which labels are safe without creating high cardinality?
- Should `task_id` be exported as a label for local-only use, or omitted by
  default?
- Where should the generated `.prom` file live?
- Should stale or partial metadata files be skipped or exported with an error
  metric?

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

Candidate metrics:

- `agentops_executor_prompt_bytes`
- `agentops_executor_stdout_bytes`
- `agentops_executor_stderr_bytes`
- `agentops_executor_duration_seconds`
- `agentops_executor_runs_total`

Likely read/write scope:

- `scripts/export-agentops-prometheus-metrics.sh`
- `docs/RUN-OBSERVABILITY.md`

## Notes

Keep label cardinality controlled. Avoid high-cardinality labels unless this
remains local-only.
