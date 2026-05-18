# TASK-0079 — Add Grafana dashboard draft

## Status

done

## Goal

Create a first Grafana dashboard draft for AgentOps run observability.

## Background / why now

Once the Prometheus textfile export task (TASK-0078, IDEAS slug
observability-04) exists, a dashboard can make executor duration, prompt size,
output size, result ratios, and model usage visible while run artifacts remain
on disk.

This is intentionally later than the local metadata and export tasks because
the dashboard should reflect real metric names and labels.

## Problem statement

Metrics are useful but not ergonomic for day-to-day workflow review without a
dashboard that answers the main operational questions.

## Smallest useful slice

Add a docs-first Grafana dashboard specification.

The spec should define dashboard panels by:

- operator question
- panel title/type
- PromQL sketch using Prometheus textfile export task (TASK-0078, IDEAS slug
  observability-04) metric names
- intended interpretation
- caveats around current-artifact-set gauge semantics

Do not add Grafana JSON in this first slice.

Candidate panels should cover:

- executor duration
- prompt size
- stdout/stderr size
- exported executor run metadata count
- model usage
- exit code / failure visibility
- skipped metadata files

Candidate questions for dashboard panels:

- Which exported task metadata is slow?
- Are prompt sizes growing while artifacts remain on disk?
- Which runs produce large stdout/stderr?
- Which model is used most often?
- Are executor runs failing?
- Is the exporter skipping metadata?

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `docs/RUN-OBSERVABILITY.md`
- `docs/GRAFANA-AGENTOPS.md`, if it exists
- `scripts/export-agentops-prometheus-metrics.sh`
- `observability/`, if it exists
- `agentops/tasks/ready/TASK-0079-grafana-dashboard-draft.md`

## Write scope

- `docs/GRAFANA-AGENTOPS.md`
- `docs/RUN-OBSERVABILITY.md`, only for a short cross-link if needed

## Requirements

- Add dashboard documentation, not Grafana JSON, unless the Prometheus textfile
  export task (TASK-0078, IDEAS slug observability-04) has produced stable
  metrics and a local Grafana setup exists.
- Put the main dashboard specification in `docs/GRAFANA-AGENTOPS.md`.
- Add only a short cross-link in `docs/RUN-OBSERVABILITY.md` if needed.
- Use metric names and labels produced by the Prometheus textfile export task
  (TASK-0078, IDEAS slug observability-04).
- Define panels by operator question, panel intent, and PromQL sketch.
- Explain that first dashboards reflect the current exported local artifact set
  unless true monotonic counters are implemented later.
- Do not use `rate()` or `increase()` in dashboard PromQL until the exporter
  emits true monotonic counters.
- Avoid wording like "runs over time" or "failed runs increasing" unless backed
  by true counters.
- Use panel titles like "Currently exported executor run metadata" or
  "Executor run metadata currently on disk" instead of "Total runs".
- V1 dashboard docs must only reference metrics emitted by the exporter.
- Future metric ideas must not use `agentops_...` metric names. Describe them
  in prose only, or add them later after the exporter emits them.
- Each panel block must use these literal line prefixes so verification can
  check structure:
  - `### Question:`
  - `Intent:`
  - `PromQL:`
- Include panels for:
  - executor duration
  - prompt size
  - stdout/stderr size
  - exported executor run metadata count
  - model usage
  - exit code / failure visibility
  - skipped metadata files
- Include or suggest a `$model` dashboard variable if final metrics include a
  `model` label.
- Provide fallback PromQL without `model`, for example
  `sum(agentops_executor_prompt_bytes)`, if the exporter does not emit a
  `model` label.
- If the exporter does not emit a `model` label, omit the model-usage panel and
  add a short note explaining that model breakdown is unavailable.
- Keep the dashboard local/dev oriented unless a shared monitoring target is
  explicitly defined.
- Avoid adding alerting in this first slice.

## Non-goals

- No complex alerting.
- No long-running exporter service.
- No production monitoring assumptions.
- No dashboard before metrics export exists.
- No Grafana JSON in the first slice unless explicitly re-scoped.
- No changes to executor behavior.

## Open questions

None.

Resolved:

- This task waits for the Prometheus textfile export task (TASK-0078, IDEAS
  slug observability-04) so metric names and labels are real.
- First dashboard slice is documentation, not Grafana JSON.
- The main dashboard specification lives in `docs/GRAFANA-AGENTOPS.md`.
- `docs/RUN-OBSERVABILITY.md` gets only a short cross-link if needed.
- Dashboard panels should be specified by operator question, panel intent, and
  PromQL sketch.
- Grafana JSON is deferred until a real local Grafana setup exists.
- If JSON is later added, it must avoid instance-specific IDs and use a
  datasource variable such as `${DS_PROMETHEUS}`.
- Dashboard scope is local/dev by default.
- Dashboard guidance must use metric names and labels from the Prometheus
  textfile export task (TASK-0078, IDEAS slug observability-04).
- Dashboard guidance must respect Prometheus textfile export task (TASK-0078,
  IDEAS slug observability-04) gauge/current-artifact-set semantics.
- Do not use `rate()` or `increase()` until the exporter emits true monotonic
  counters.
- Until then, dashboard panels reflect the current exported local artifact set,
  not historical event counts.
- Wording like "runs over time" or "failed runs increasing" should be avoided
  unless backed by true counters.
- V1 dashboard docs must only reference metrics emitted by the exporter.
- Future metric ideas must not use `agentops_...` metric names. Describe them
  in prose only, or add them later after the exporter emits them.
- Include failure/exit-code visibility and skipped metadata visibility.
- Include or suggest a `$model` variable if final metrics include a `model`
  label.
- Provide fallback PromQL without `model` when the exporter does not emit a
  `model` label.
- If the exporter does not emit a `model` label, omit the model-usage panel and
  add a short note explaining that model breakdown is unavailable.

## Verification

Run:

```bash
test -f docs/GRAFANA-AGENTOPS.md
grep -n "Grafana" docs/GRAFANA-AGENTOPS.md
grep -n "^PromQL:" docs/GRAFANA-AGENTOPS.md
grep -n "skipped metadata" docs/GRAFANA-AGENTOPS.md
! grep -nE 'rate\(|increase\(' docs/GRAFANA-AGENTOPS.md
! grep -nE 'agentops_[a-z_]*_total' docs/GRAFANA-AGENTOPS.md
git status --short --branch
git diff --stat
```

Verify the panel structure:

```bash
question_count="$(grep -c '^### Question:' docs/GRAFANA-AGENTOPS.md)"
intent_count="$(grep -c '^Intent:' docs/GRAFANA-AGENTOPS.md)"
promql_count="$(grep -c '^PromQL:' docs/GRAFANA-AGENTOPS.md)"
test "$question_count" -gt 0
test "$question_count" = "$intent_count"
test "$question_count" = "$promql_count"
```

After the Prometheus textfile export task (TASK-0078, IDEAS slug
observability-04) exists, add a metric-name consistency check:

```bash
diff \
  <(grep -ho 'agentops_[a-z_]*' docs/GRAFANA-AGENTOPS.md | sort -u) \
  <(grep -ho 'agentops_[a-z_]*' scripts/export-agentops-prometheus-metrics.sh | sort -u)
```

Expected result: empty diff. Dashboard docs must not reference metrics that
the exporter does not emit. Future metric ideas must not use `agentops_...`
metric names unless those metrics are emitted by the exporter.

If Grafana JSON is added in a later task, include a JSON validity check and
requirements to strip dashboard UID, avoid instance-specific datasource IDs,
use a datasource variable such as `${DS_PROMETHEUS}`, and avoid committing
environment-specific settings where possible.

## Accept criteria

- Dashboard guidance is documentation-first unless a real local Grafana setup
  exists.
- Panels are defined by operator question, panel intent, and PromQL sketch.
- Main dashboard spec lives in `docs/GRAFANA-AGENTOPS.md`.
- `docs/RUN-OBSERVABILITY.md` gets only a short cross-link if needed.
- Draft uses the metric names and labels available from the Prometheus textfile
  export task (TASK-0078, IDEAS slug observability-04).
- Panels cover duration, prompt size, stdout/stderr size, exported run metadata
  count, model usage, exit code / failure visibility, and skipped metadata
  visibility.
- The doc explains current-artifact-set semantics and does not overclaim true
  counter/rate behavior.
- Dashboard PromQL does not use `rate()` or `increase()` unless the Prometheus
  textfile export task (TASK-0078, IDEAS slug observability-04) emits true
  monotonic counters.
- Dashboard wording clearly says panels reflect the current exported local
  artifact set.
- Metric names referenced in dashboard docs are verified against
  `scripts/export-agentops-prometheus-metrics.sh`.
- V1 dashboard docs reference only metrics emitted by the exporter.
- Future metric ideas do not use `agentops_...` metric names unless those
  metrics are emitted by the exporter.
- The doc includes or suggests a `$model` variable if the final metrics include
  a `model` label.
- The doc provides fallback PromQL without `model` if the exporter does not
  emit a `model` label.
- If the exporter does not emit a `model` label, the model-usage panel is
  omitted with a note instead of replaced by a meaningless scalar.
- Each panel block uses the literal prefixes `### Question:`, `Intent:`, and
  `PromQL:`.
- Panel structure verification requires at least one panel and equal counts of
  question, intent, and PromQL blocks.
- No Grafana JSON is committed in this first slice unless explicitly re-scoped.
- Scope remains local/dev unless otherwise decided.
- Verification commands pass.
- Diff stays within write scope.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0079-grafana-dashboard-draft.md

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
```

## Return format

Expected executor return format:

```text
Plan:
...

Implementation:
...

Verification:
...

Review:
accept / revise / revert / no-op / blocked

Changed files:
...

Uncertainty:
...
```

## Notes

This task should not start until the Prometheus textfile export task
(TASK-0078, IDEAS slug observability-04) exists, otherwise the dashboard will
be speculative.
