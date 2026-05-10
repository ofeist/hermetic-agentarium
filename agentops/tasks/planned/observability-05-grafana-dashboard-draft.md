# observability-05 — Add Grafana dashboard draft

## Status

planned

## Goal

Create a first Grafana dashboard draft for AgentOps run observability.

## Background / why now

Once Prometheus textfile export exists, a dashboard can make run trends visible:
executor duration, prompt size, output size, result ratios, and model usage.

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
- PromQL sketch using observability-04 metric names
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

- Which tasks are slow?
- Are prompts growing over time?
- Which runs produce large stdout/stderr?
- Which model is used most often?
- Are executor runs failing?
- Is the exporter skipping metadata?

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

Likely candidates:

- `docs/RUN-OBSERVABILITY.md`
- `scripts/export-agentops-prometheus-metrics.sh`
- `observability/`, if it exists
- `agentops/tasks/planned/observability-05-grafana-dashboard-draft.md`

## Write scope

Likely candidates:

- `docs/RUN-OBSERVABILITY.md`, for a short dashboard section
- `docs/GRAFANA-AGENTOPS.md`, if the dashboard guidance deserves its own page

## Requirements

When ready, this task should require:

- Add dashboard documentation, not Grafana JSON, unless observability-04 has
  produced stable metrics and a local Grafana setup exists.
- Use metric names and labels produced by observability-04.
- Define panels by operator question, panel intent, and PromQL sketch.
- Explain that first dashboards reflect the current exported local artifact set
  unless true monotonic counters are implemented later.
- Do not use `rate()` or `increase()` in dashboard PromQL until the exporter
  emits true monotonic counters.
- Avoid wording like "runs over time" or "failed runs increasing" unless backed
  by true counters.
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

- This task waits for observability-04 so metric names and labels are real.
- First dashboard slice is documentation, not Grafana JSON.
- Dashboard panels should be specified by operator question, panel intent, and
  PromQL sketch.
- Grafana JSON is deferred until a real local Grafana setup exists.
- If JSON is later added, it must avoid instance-specific IDs and use a
  datasource variable such as `${DS_PROMETHEUS}`.
- Dashboard scope is local/dev by default.
- Dashboard guidance must use metric names and labels from observability-04.
- Dashboard guidance must respect observability-04 gauge/current-artifact-set
  semantics.
- Do not use `rate()` or `increase()` until the exporter emits true monotonic
  counters.
- Until then, dashboard panels reflect the current exported local artifact set,
  not historical event counts.
- Wording like "runs over time" or "failed runs increasing" should be avoided
  unless backed by true counters.
- Include failure/exit-code visibility and skipped metadata visibility.
- Include or suggest a `$model` variable if final metrics include a `model`
  label.

## Verification

TBD

Likely commands:

```bash
test -f docs/RUN-OBSERVABILITY.md || test -f docs/GRAFANA-AGENTOPS.md
grep -n "Grafana" docs/RUN-OBSERVABILITY.md docs/GRAFANA-AGENTOPS.md 2>/dev/null
grep -n "Question:" docs/RUN-OBSERVABILITY.md docs/GRAFANA-AGENTOPS.md 2>/dev/null
grep -n "PromQL" docs/RUN-OBSERVABILITY.md docs/GRAFANA-AGENTOPS.md 2>/dev/null
grep -n "skipped metadata" docs/RUN-OBSERVABILITY.md docs/GRAFANA-AGENTOPS.md 2>/dev/null
git status --short --branch
git diff --stat
```

After observability-04 exists, add a metric-name consistency check:

```bash
diff \
  <(grep -ho 'agentops_[a-z_]*' docs/RUN-OBSERVABILITY.md docs/GRAFANA-AGENTOPS.md 2>/dev/null | sort -u) \
  <(grep -ho 'agentops_[a-z_]*' scripts/export-agentops-prometheus-metrics.sh | sort -u)
```

Expected result: empty diff. Dashboard docs must not reference metrics that
the exporter does not emit. If dashboard docs intentionally mention future
metrics, those must be clearly marked as future/non-v1 and excluded from the
hard check or handled by a separate allowlist.

If Grafana JSON is added in a later task, include a JSON validity check and
requirements to strip dashboard UID, avoid instance-specific datasource IDs,
use a datasource variable such as `${DS_PROMETHEUS}`, and avoid committing
environment-specific settings where possible.

## Accept criteria

When ready, accept criteria should include:

- Dashboard guidance is documentation-first unless a real local Grafana setup
  exists.
- Panels are defined by operator question, panel intent, and PromQL sketch.
- Draft uses the metric names and labels available from observability-04.
- Panels cover duration, prompt size, stdout/stderr size, exported run metadata
  count, model usage, exit code / failure visibility, and skipped metadata
  visibility.
- The doc explains current-artifact-set semantics and does not overclaim true
  counter/rate behavior.
- Dashboard PromQL does not use `rate()` or `increase()` unless
  observability-04 emits true monotonic counters.
- Dashboard wording clearly says panels reflect the current exported local
  artifact set.
- Metric names referenced in dashboard docs are verified against
  `scripts/export-agentops-prometheus-metrics.sh`.
- Any future/non-v1 metric references are clearly marked and excluded from the
  hard consistency check.
- The doc includes or suggests a `$model` variable if the final metrics include
  a `model` label.
- No Grafana JSON is committed in this first slice unless explicitly re-scoped.
- Scope remains local/dev unless otherwise decided.
- Verification commands pass.
- Diff stays within write scope.

## Promotion decision

Decision: keep_planned

Reason:

This depends on the Prometheus export task. The dashboard should use real
metric names, label policy, and output shape from observability-04 instead of
guessing. The first dashboard slice should be documentation-first, not Grafana
JSON.

Next action:

Promote after observability-04 lands and metric names/labels are known.

## Promotion criteria

This task can be promoted to ready when:

- read scope is known
- write scope is known
- open questions are resolved or explicitly marked as blockers
- requirements are concrete
- verification commands are known
- accept criteria are concrete
- non-goals are clear

## Hermes/coder collection prompt

TBD until ready.

When ready, use this shape:

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-XXXX-grafana-dashboard-draft.md

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

TBD until ready.

When ready, expected executor return format:

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

This task should not start until Prometheus export exists, otherwise the
dashboard will be speculative.
