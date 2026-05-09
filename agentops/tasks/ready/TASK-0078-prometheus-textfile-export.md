# TASK-0078 — Add Prometheus textfile export

## Status

ready

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

Suggested v1 metric family:

- `agentops_executor_runs`
- `agentops_executor_prompt_bytes`
- `agentops_executor_stdout_bytes`
- `agentops_executor_stderr_bytes`
- `agentops_executor_duration_seconds`
- `agentops_executor_metadata_files_skipped`

These should be emitted as gauges over the current exported local artifact set,
because a textfile exporter that regenerates metrics from current
`.agentops-runs/` contents does not naturally produce process counters. If old
run directories are deleted, values can go down.

Do not use standalone `_sum` or `_max` metric names unless implementing real
Prometheus histogram/summary-compatible families. Do not use `_total` for
current-artifact-set values that can decrease when `.agentops-runs/` is cleaned
up.

Avoid per-run metrics such as
`agentops_executor_prompt_bytes{run_id="TASK-0073-test"}` unless a future task
explicitly scopes that exporter to local-only debugging.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `.agentops-runs/`
- `scripts/run-opencode-executor.sh`
- `scripts/render-agentops-run-summary.sh`
- `docs/RUN-OBSERVABILITY.md`
- `agentops/tasks/ready/TASK-0078-prometheus-textfile-export.md`

## Write scope

- `scripts/export-agentops-prometheus-metrics.sh`
- `docs/RUN-OBSERVABILITY.md`, if it exists and needs export notes

## Requirements

- Add `scripts/export-agentops-prometheus-metrics.sh`.
- Read local `.agentops-runs/*/metadata.txt` files.
- Write valid Prometheus textfile collector output to an explicit output path.
- Export aggregate executor metrics from metadata.
- Emit `# HELP` lines.
- Emit `# TYPE` lines.
- Use deterministic line ordering.
- Sort metadata files before processing.
- Sort emitted metric lines deterministically.
- Write atomically by writing to a temporary file next to the requested output
  path, then renaming it to the requested output path.
- Keep labels low-cardinality by default.
- Use low-cardinality labels such as `harness`, `model`, `phase`, and
  `exit_code`.
- The `model` label is acceptable only under the assumption that local model
  cardinality stays small, roughly <=10 distinct values. If model cardinality
  grows, aggregate without `model` or make model-labeled metrics optional.
- Do not use `run_id` as a Prometheus label.
- Do not use `task_id` as a default label unless the task explicitly scopes the
  exporter to local-only debugging.
- Handle missing or partial metadata predictably.
- Skip incomplete metadata files with a clear stderr warning.
- Export `agentops_executor_metadata_files_skipped` in v1.
- Avoid exporting raw prompt text, stdout, stderr, or logs.
- Document usage if `docs/RUN-OBSERVABILITY.md` exists.

## Non-goals

- No long-running exporter service.
- No Grafana dashboard.
- No alerting.
- No token/cost metrics unless reliable fields exist in metadata.
- No raw log export.

## Open questions

None.

Resolved:

- Prometheus export should wait until local metadata from observability-01 /
  TASK-0073 is stable.
- Prometheus export is an export layer; `.agentops-runs/<run-id>/metadata.txt`
  remains the canonical local record.
- Use current-artifact-set gauge metrics, not long-lived counters.
- Do not use standalone `_sum` / `_max` metric names.
- Do not use `_total` for metrics that can decrease when `.agentops-runs/` is
  cleaned up.
- Emit `# HELP` and `# TYPE` lines.
- Use deterministic line ordering.
- Write output atomically via temp file + rename.
- Keep default labels low-cardinality: `harness`, `phase`, `model`,
  `exit_code`.
- Do not export `run_id` or `task_id` as default labels.
- Include skipped metadata visibility in v1.
- Keep run/task detail in `.agentops-runs/<run-id>/metadata.txt`.
- The generated `.prom` output path should be provided explicitly as a script
  argument.
- The script should write only to the provided output path.
- The script should not assume Node Exporter paths by default.
- Example local output paths: `.agentops-runs/agentops.prom` or
  `/tmp/agentops.prom`.
- Hardcoded system paths such as
  `/var/lib/node_exporter/textfile_collector/agentops.prom` should be
  documentation examples only, not defaults.
- The script should skip incomplete metadata files with a clear stderr warning.
- Export `agentops_executor_metadata_files_skipped` in v1 so dashboards
  can show when metadata files are ignored.
- Values are gauges over the current exported local artifact set.
- A durable ledger or append-only state would be required later if true
  monotonic counters are needed.
- Token/cost metrics remain out of scope unless reliable machine-readable
  fields exist.

## Verification

Run:

```bash
bash -n scripts/export-agentops-prometheus-metrics.sh
scripts/export-agentops-prometheus-metrics.sh --help
mkdir -p .agentops-runs/TASK-9999-prom-test
cat > .agentops-runs/TASK-9999-prom-test/metadata.txt <<'EOF'
run_id=TASK-9999-prom-test
task_id=TASK-9999
phase=executor
harness=OpenCode
model=deepseek/deepseek-v4-pro
prompt_file=/tmp/TASK-9999.prompt.md
prompt_bytes=18422
prompt_lines=412
started_at=2026-05-09T12:34:56Z
finished_at=2026-05-09T12:36:30Z
duration_seconds=94
exit_code=0
stdout_bytes=8120
stderr_bytes=0
EOF
mkdir -p .agentops-runs/TASK-9998-prom-incomplete
cat > .agentops-runs/TASK-9998-prom-incomplete/metadata.txt <<'EOF'
run_id=TASK-9998-prom-incomplete
phase=executor
harness=OpenCode
model=deepseek/deepseek-v4-pro
EOF
scripts/export-agentops-prometheus-metrics.sh /tmp/agentops-test.prom
cat /tmp/agentops-test.prom
grep -n "^# HELP" /tmp/agentops-test.prom
grep -n "^# TYPE" /tmp/agentops-test.prom
grep -n "agentops_executor_runs" /tmp/agentops-test.prom
grep -n "agentops_executor_prompt_bytes" /tmp/agentops-test.prom
grep -n "agentops_executor_duration_seconds" /tmp/agentops-test.prom
grep -n "agentops_executor_metadata_files_skipped" /tmp/agentops-test.prom
rm -rf .agentops-runs/TASK-9999-prom-test
rm -rf .agentops-runs/TASK-9998-prom-incomplete
rm -f /tmp/agentops-test.prom
git status --short --branch
git diff --stat
```

## Accept criteria

- Export script exists and is executable.
- Export output is valid Prometheus textfile format for selected metrics.
- Export output includes `# HELP` and `# TYPE` lines.
- Export output order is deterministic.
- Export writes atomically to the requested output path.
- Labels are intentionally limited and documented.
- The exporter does not create high-cardinality labels by default.
- `run_id` is not exported as a Prometheus label.
- `task_id` is not exported as a default Prometheus label.
- Raw prompt text, stdout, stderr, and logs are never exported.
- The output path is explicit and not hardcoded to a system Node Exporter
  directory.
- Missing or partial metadata behavior is clear.
- Skipped metadata files print stderr warnings and increment
  `agentops_executor_metadata_files_skipped`.
- Verification commands pass.
- Diff stays within write scope.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0078-prometheus-textfile-export.md

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

Prometheus is an export layer. `.agentops-runs/<run-id>/metadata.txt` remains
the canonical local run record.
