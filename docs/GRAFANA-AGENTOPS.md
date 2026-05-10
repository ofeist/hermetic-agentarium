# Grafana AgentOps Dashboard

## Overview

This document specifies a Grafana dashboard for AgentOps executor run
observability. The dashboard consumes metrics exported by
`scripts/export-agentops-prometheus-metrics.sh` via the Prometheus textfile
collector.

### Gauge semantics — current artifact set

All metrics emitted by the exporter are **gauges** that reflect the
**currently exported local artifact set** on disk. When the exporter runs,
it reads `.agentops-runs/*/metadata.txt` and writes aggregate values for
whatever run artifacts exist at that moment.

Key implications:

* Dashboard panels show the **current contents** of `.agentops-runs/`, not a
  historical event count.
* If artifacts are cleaned up between exporter runs, metric values decrease.
* **Do not use rate or increase functions** with these metrics unless the
  exporter is later updated to emit true monotonic counters.
* Panel titles use wording like "currently on disk" or "current artifact
  set" to reflect this semantics.
* Aggregations like `sum by (phase)` are computed over the current artifact
  set, not over a time series.

### Dashboard variables

Define the following Grafana dashboard variable (type: Query, using the
Prometheus datasource) if configuring a real dashboard instance:

| Variable | Query                                      | Description         |
|----------|--------------------------------------------|---------------------|
| `$model` | `label_values(agentops_executor_runs, model)` | Executor model name |

Additional useful variables for filtering (optional):

| Variable   | Query                                        |
|------------|----------------------------------------------|
| `$phase`   | `label_values(agentops_executor_runs, phase)`  |
| `$harness` | `label_values(agentops_executor_runs, harness)`|

Each panel PromQL below uses `$model` filtering. If no Grafana variables are
configured, use the fallback queries listed under
[Fallback PromQL without dashboard variables](#fallback-promql-without-dashboard-variables).

## Panels

### Question: Which exported task metadata is slow?

Intent: Display executor run duration for each label group (harness, phase,
model, exit_code) in the current artifact set, ordered by highest duration
first, so operators can identify which runs took the longest.

PromQL:
agentops_executor_duration_seconds{model=~"$model"}

Panel type suggestion: Table or bar gauge, sorted descending by value.

Interpretation: Higher values indicate runs with longer wall-clock execution
time. Since these are gauges over the current artifact set, the values
represent the sum of durations across all runs sharing the same labels. This
is not a rate or a trend — it is the aggregate for whatever artifacts exist
on disk at the time of export.

### Question: Are prompt sizes large while artifacts remain on disk?

Intent: Surface prompt byte totals per label group so operators can spot
unexpectedly large prompts that may indicate context pressure.

PromQL:
agentops_executor_prompt_bytes{model=~"$model"}

Panel type suggestion: Bar gauge or table, sorted descending by value.

Interpretation: Large prompt bytes may indicate that full diffs, raw logs,
or large file contents were included in the executor prompt. Compare against
typical prompt sizes for the same task phase. The displayed value is the sum
of prompt bytes across runs sharing the same labels in the current artifact
set.

### Question: Which runs produce large stdout?

Intent: Surface stdout byte totals per label group so operators can identify
runs where the executor produced large output.

PromQL:
agentops_executor_stdout_bytes{model=~"$model"}

Panel type suggestion: Bar gauge or table, sorted descending by value.

Interpretation: Large stdout may indicate that the executor echoed
substantial context or produced verbose output. This value is the sum across
runs sharing the same labels in the current artifact set.

### Question: Which runs produce stderr?

Intent: Surface stderr byte totals per label group so operators can identify
runs with error output or tool warnings.

PromQL:
agentops_executor_stderr_bytes{model=~"$model"}

Panel type suggestion: Bar gauge or table, sorted descending by value.

Interpretation: Non-zero stderr suggests tool errors, warnings, or
process-level failures. Combine this panel with the exit-code panel to
diagnose executor failures. This value is the sum across runs sharing
the same labels in the current artifact set.

### Question: How many executor run metadata entries are currently on disk?

Intent: Show the count of executor runs in the current artifact set, broken
down by task phase, so operators can see how many runs exist and which
phases produced them.

PromQL:
sum(agentops_executor_runs{model=~"$model"}) by (phase)

Panel type suggestion: Bar gauge or stat.

Interpretation: This shows the number of completed executor runs whose
metadata files currently exist on disk in `.agentops-runs/`. It reflects
the current content of the artifact directory, not an accumulated total.

### Question: Which model is used most often?

Intent: Show executor run count by model to understand model usage
distribution across the current artifact set.

PromQL:
sum(agentops_executor_runs) by (model)

Panel type suggestion: Pie chart or bar gauge.

Interpretation: This panel shows how many runs were executed with each model
in the current on-disk artifact set. Use the `$model` variable to filter to
a single model; without it, the panel shows all models side by side.

### Question: Are executor runs failing?

Intent: Highlight runs with non-zero exit codes so operators can quickly see
executor failures in the current artifact set.

PromQL:
agentops_executor_runs{exit_code!="0", model=~"$model"}

Panel type suggestion: Table, with exit_code as a dimension.

Interpretation: Non-zero exit codes indicate executor process failure (e.g.,
model not found, wrapper not executable, OpenCode not on PATH). The value
shows how many runs currently on disk exited with each non-zero code. This
is **not** a failure rate over time — it reflects only the runs whose
artifacts are present in `.agentops-runs/`.

### Question: Is the exporter skipping metadata?

Intent: Alert operators when the exporter skipped metadata files due to
incomplete or invalid data, indicating corrupt or incomplete run artifacts.

PromQL:
agentops_executor_metadata_files_skipped

Panel type suggestion: Stat or single value.

Interpretation: Non-zero values indicate that some `metadata.txt` files in
`.agentops-runs/` were missing required fields or contained invalid numeric
values. Investigate the affected run artifacts. This metric has no labels;
it is a single aggregated count from the most recent exporter invocation.

## Fallback PromQL without dashboard variables

If the `$model` (and optional `$phase`, `$harness`) dashboard variables are
not configured, use these simplified queries:

| Panel                       | Fallback PromQL                              |
|-----------------------------|----------------------------------------------|
| Executor duration           | `agentops_executor_duration_seconds`          |
| Prompt size                 | `agentops_executor_prompt_bytes`              |
| Stdout size                 | `agentops_executor_stdout_bytes`              |
| Stderr size                 | `agentops_executor_stderr_bytes`              |
| Run metadata count          | `sum(agentops_executor_runs) by (phase)`      |
| Model usage                 | `sum(agentops_executor_runs) by (model)`      |
| Exit code / failures        | `agentops_executor_runs{exit_code!="0"}`     |
| Skipped metadata            | `agentops_executor_metadata_files_skipped`    |

## Caveats

1. **Current artifact set only**: All panels display the snapshot written
   by the most recent invocation of
   `scripts/export-agentops-prometheus-metrics.sh`. If the script has not
   been exported recently, the dashboard may show stale or empty data.

2. **No rate or increase functions**: These metrics are gauges, not monotonic
   counters. Using rate or increase functions would produce meaningless
   results. If true cumulative counters are needed, the exporter must be
   updated to emit monotonic counter metrics (separate `_total` names).

3. **Aggregation over label groups**: When multiple runs share the same
   `harness`, `phase`, `model`, and `exit_code`, the exporter sums their
   values into a single gauge. The dashboard cannot distinguish individual
   runs within the same label group without changes to the exporter.

4. **No `run_id` or `task_id` labels**: The exporter deliberately omits
   high-cardinality labels such as `run_id` and `task_id`. Dashboard panels
   cannot filter or group by individual run identifiers.

5. **Local/dev scope**: This dashboard is designed for local development
   observability. It assumes a local Prometheus instance scraping a
   textfile collector directory. It does not assume shared monitoring
   infrastructure, long-running exporter services, or production deployment.

## Cross-references

* `docs/RUN-OBSERVABILITY.md` — operator guide for inspecting run metadata
  and observability signals.
* `scripts/export-agentops-prometheus-metrics.sh` — Prometheus textfile
  exporter that produces the metrics consumed by this dashboard.
