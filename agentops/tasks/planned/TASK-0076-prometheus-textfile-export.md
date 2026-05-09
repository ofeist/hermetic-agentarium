# TASK-0076 — Add Prometheus textfile export

## Status

planned

## Goal

Export selected AgentOps run metrics in Prometheus textfile format.

## Background / why now

After local metadata and summaries are stable, the next observability layer is
machine-readable metrics for Prometheus and Grafana.

The simplest export path is Node Exporter textfile collector format because it
does not require a long-running AgentOps service.

## Problem statement

Local metadata answers one-run questions, but it does not show trends such as
prompt size growth, executor duration, output size, failure rate, or model usage
over time.

## Smallest useful slice

Add:

```bash
scripts/export-agentops-prometheus-metrics.sh <output.prom>
```

The script should read `.agentops-runs/*/metadata.txt` and write selected
metrics in Prometheus textfile format.

Candidate metrics:

- `agentops_executor_prompt_bytes`
- `agentops_executor_stdout_bytes`
- `agentops_executor_stderr_bytes`
- `agentops_executor_duration_seconds`
- `agentops_executor_runs_total`

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

- `.agentops-runs/`
- `scripts/run-opencode-executor.sh`
- `scripts/render-agentops-run-summary.sh`
- `docs/RUN-OBSERVABILITY.md`
- `agentops/tasks/planned/TASK-0076-prometheus-textfile-export.md`

## Write scope

TBD

Likely candidates:

- `scripts/export-agentops-prometheus-metrics.sh`
- `docs/RUN-OBSERVABILITY.md`, if it exists and needs export notes

## Requirements

TBD

When ready, this task should require:

- Add `scripts/export-agentops-prometheus-metrics.sh`.
- Read local `.agentops-runs/*/metadata.txt` files.
- Write valid Prometheus textfile collector output.
- Keep labels low-cardinality by default.
- Handle missing or partial metadata predictably.
- Avoid exporting raw prompt text or logs.
- Document usage if `docs/RUN-OBSERVABILITY.md` exists.

## Non-goals

- No long-running exporter service.
- No Grafana dashboard.
- No alerting.
- No token/cost metrics unless reliable fields exist in metadata.
- No raw log export.

## Open questions

- Which labels are safe without creating high cardinality?
- Should `task_id` be exported as a label for local-only use, or omitted by
  default?
- Where should the generated `.prom` file live?
- Should stale or partial metadata files be skipped or exported with an error
  metric?
- Should this wait for TASK-0073 and TASK-0074 to land?

If these are resolved before promotion, write:

```text
None.
```

## Verification

TBD

Likely commands:

```bash
bash -n scripts/export-agentops-prometheus-metrics.sh
scripts/export-agentops-prometheus-metrics.sh --help
git status --short --branch
git diff --stat
```

Add a fixture-based export smoke test when ready.

## Accept criteria

TBD

When ready, accept criteria should include:

- Export script exists and is executable.
- Export output is valid Prometheus textfile format for selected metrics.
- Labels are intentionally limited and documented.
- Raw logs and prompt bodies are not exported.
- Missing or partial metadata behavior is clear.
- Verification commands pass.
- Diff stays within write scope.

## Promotion decision

Decision: keep_planned

Reason:

This should wait until local metadata is stable; otherwise the exporter will
codify fields too early.

Next action:

Promote after TASK-0073 has landed and the metric label policy is decided.

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

agentops/tasks/ready/TASK-0076-prometheus-textfile-export.md

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

Keep label cardinality controlled. Avoid high-cardinality labels unless this
remains explicitly local-only.
