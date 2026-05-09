# TASK-0077 — Add Grafana dashboard draft

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

Add either dashboard JSON or documentation for a first dashboard with panels
for:

- executor duration
- prompt size
- stdout/stderr size
- executor runs over time
- model usage

Candidate questions for dashboard panels:

- Which tasks are slow?
- Are prompts growing over time?
- Which runs produce large stdout/stderr?
- Which model is used most often?
- Are failed executor runs increasing?

## Executor

Harness: TBD
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

Notes:

- Fill this in only when the task becomes ready.
- Keep model selection out of the task body unless there is a specific reason.

## Read scope

TBD

Likely candidates:

- `docs/RUN-OBSERVABILITY.md`
- `scripts/export-agentops-prometheus-metrics.sh`
- `observability/`, if it exists
- `agentops/tasks/planned/TASK-0077-grafana-dashboard-draft.md`

## Write scope

TBD

Likely candidates:

- `docs/RUN-OBSERVABILITY.md`, if documenting dashboard setup
- `observability/grafana/agentops-dashboard.json`, if storing dashboard JSON

## Requirements

TBD

When ready, this task should require:

- Add either dashboard JSON or clear dashboard documentation.
- Use metric names and labels produced by TASK-0076.
- Include panels for duration, prompt size, stdout/stderr size, runs over time,
  and model usage.
- Keep the dashboard local/dev oriented unless a shared monitoring target is
  explicitly defined.
- Avoid adding alerting in this first slice.

## Non-goals

- No complex alerting.
- No long-running exporter service.
- No production monitoring assumptions.
- No dashboard before metrics export exists.
- No changes to executor behavior.

## Open questions

- Should the repo store Grafana dashboard JSON or only documentation?
- What Prometheus labels will be available after TASK-0076?
- Should this remain local-only or target a shared observability stack?
- Where should observability assets live in this repo?

If these are resolved before promotion, write:

```text
None.
```

## Verification

TBD

Likely commands:

```bash
git status --short --branch
git diff --stat
```

If dashboard JSON is added, include a JSON validity check when ready.

## Accept criteria

TBD

When ready, accept criteria should include:

- Dashboard draft exists as documentation or JSON.
- Draft uses the metric names and labels available from TASK-0076.
- Panels cover duration, prompt size, stdout/stderr size, run count, and model
  usage.
- Scope remains local/dev unless otherwise decided.
- Verification commands pass.
- Diff stays within write scope.

## Promotion decision

Decision: keep_planned

Reason:

This depends on the Prometheus export task. It should remain planned until
metric names and labels are stable.

Next action:

Promote after TASK-0076 lands and the repo decides whether to store dashboard
JSON or documentation.

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

agentops/tasks/ready/TASK-0077-grafana-dashboard-draft.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- create/switch to an appropriate task branch
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
