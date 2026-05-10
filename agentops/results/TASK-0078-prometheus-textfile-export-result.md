# TASK-0078-prometheus-textfile-export Result

## Decision

accept

## Decision note

Accepted after parent review; Prometheus textfile exporter is in scope, verification passed, and no blockers were found.

## Task file

agentops/tasks/done/TASK-0078-prometheus-textfile-export.md

## Summary

TASK-0078 added a Prometheus textfile exporter over local AgentOps run
metadata.

Changed files:

- `scripts/export-agentops-prometheus-metrics.sh`
  - New executable exporter.
  - Reads `.agentops-runs/*/metadata.txt`.
  - Writes valid Prometheus textfile collector output to an explicit output
    path.
  - Emits `# HELP` and `# TYPE` lines.
  - Emits current-artifact-set gauge metrics:
    `agentops_executor_runs`, `agentops_executor_prompt_bytes`,
    `agentops_executor_stdout_bytes`, `agentops_executor_stderr_bytes`,
    `agentops_executor_duration_seconds`, and
    `agentops_executor_metadata_files_skipped`.
  - Uses low-cardinality labels: `harness`, `phase`, `model`, and `exit_code`.
  - Does not export `run_id` or `task_id` as labels.
  - Skips incomplete metadata files with stderr warnings and increments
    `agentops_executor_metadata_files_skipped`.
  - Writes atomically via temp file then rename.
- `docs/RUN-OBSERVABILITY.md`
  - Documents local Prometheus textfile export usage.
  - States the exporter emits aggregate metadata-derived gauges for the current
    local artifact set.
  - Notes that raw prompts, stdout, stderr, logs, `run_id`, and `task_id`
    labels are not exported.
- `agentops/tasks/done/TASK-0078-prometheus-textfile-export.md`
  - Moved from ready to done by the AgentOps lifecycle helpers.
- `agentops/results/TASK-0078-prometheus-textfile-export-result.md`
  - Records this acceptance decision and verification evidence.

## Verification

Parent review verified:

```text
bash -n scripts/export-agentops-prometheus-metrics.sh
scripts/export-agentops-prometheus-metrics.sh --help
fixture export with one valid metadata file and one incomplete metadata file
git diff --check
scripts/check-agentops-lifecycle.sh
```

Fixture output included:

```text
# HELP agentops_executor_runs Number of executor runs in the current artifact set.
# TYPE agentops_executor_runs gauge
agentops_executor_runs{harness="OpenCode",phase="executor",model="deepseek/deepseek-v4-pro",exit_code="0"} 1
agentops_executor_prompt_bytes{harness="OpenCode",phase="executor",model="deepseek/deepseek-v4-pro",exit_code="0"} 18422
agentops_executor_stdout_bytes{harness="OpenCode",phase="executor",model="deepseek/deepseek-v4-pro",exit_code="0"} 8120
agentops_executor_stderr_bytes{harness="OpenCode",phase="executor",model="deepseek/deepseek-v4-pro",exit_code="0"} 0
agentops_executor_duration_seconds{harness="OpenCode",phase="executor",model="deepseek/deepseek-v4-pro",exit_code="0"} 94
agentops_executor_metadata_files_skipped 3
```

The skip count was `3` because the task worktree contained two older incomplete
executor metadata files plus the synthetic incomplete fixture. This matches the
expected exporter behavior.

Results:

```text
script executable mode: 775
git diff --check -> exit 0
scripts/check-agentops-lifecycle.sh -> Errors: 0, Warnings: 0
```

Parent verdict:

```text
accept
```

## Follow-ups

None required for TASK-0078.
