# Local Executor Run Audit

This document defines the local audit/debug contract for Hermes/OpenCode executor runs.

The goal is to make executor runs easier to inspect without committing raw prompts, logs, or model output to the repository.

## Status

Implemented for `scripts/run-opencode-executor.sh` as optional local run capture.

Wrapper capture is opt-in. Existing two-argument usage remains supported.

## Local run directory

Local executor run artifacts should be stored under:

    .agentops-runs/<run-id>/

Examples:

    .agentops-runs/TASK-0038/
    .agentops-runs/TASK-0039-20260503-143000/
    .agentops-runs/manual-20260503-143000/

The `.agentops-runs/` directory is local-only and must remain gitignored.

## Expected files

A local run directory may contain:

    executor-prompt.md
    executor-stdout.log
    executor-stderr.log
    metadata.txt
    review-notes.md

## File meanings

- `executor-prompt.md` — copy of the prompt sent to the executor.
- `executor-stdout.log` — stdout captured from the executor process.
- `executor-stderr.log` — stderr captured from the executor process.
- `metadata.txt` — minimal run metadata.
- `review-notes.md` — optional parent review notes.

## Metadata

`metadata.txt` should stay simple and human-readable.

Executor phase fields:

    run_id=<run-id>
    task_id=<task-id-or-empty>
    phase=executor
    harness=OpenCode
    model=<model-id>
    prompt_file=<path>
    prompt_bytes=<number>
    prompt_lines=<number>
    started_at=<timestamp>
    finished_at=<timestamp>
    duration_seconds=<number>
    exit_code=<number>
    stdout_bytes=<number>
    stderr_bytes=<number>

- `task_id` is derived from `run_id` when `run_id` starts with `TASK-` followed
  by digits (e.g. `TASK-0073` from `TASK-0073` or `TASK-0073-20260503`).
  Otherwise it is empty.
- `prompt_bytes` and `prompt_lines` are measured from the prompt file without
  including prompt content in metadata or prompts.
- `duration_seconds` is computed from `started_at` and `finished_at`.
- `stdout_bytes` and `stderr_bytes` are measured from the captured local
  artifact files after executor completion.

Do not store secrets, tokens, auth file contents, or private configuration
values in metadata.

## Verification without network

For smoke testing metadata capture without OpenCode, network access, API keys,
or paid model calls, set the `AGENTOPS_EXECUTOR_COMMAND` environment variable:

```bash
AGENTOPS_EXECUTOR_COMMAND='printf "executor ok\n"' \
AGENTOPS_RUN_ID=<run-id> \
scripts/run-opencode-executor.sh <prompt-file>
```

When `AGENTOPS_EXECUTOR_COMMAND` is set, the wrapper runs the given command
instead of `opencode run`. All metadata capture (stdout, stderr, byte counts,
timestamps, exit code) proceeds as normal. This path is for test/verification
only and does not change normal executor behaviour when the variable is unset.

## Safety boundary

Raw prompts, stdout/stderr, and model responses may contain sensitive context.

Do not commit files from `.agentops-runs/`.

Do not store or copy:

- `.env` contents
- API keys
- provider tokens
- SSH keys
- OpenCode auth files
- private config dumps
- full request/response dumps that may contain secrets

If sensitive data appears in a local run log, delete the local log or redact it before sharing outside the machine.

## Committed summaries

Safe summaries belong under:

    agentops/results/TASK-xxxx-result.md

A committed result summary should include only reviewed, safe information such as:

- decision
- changed files
- verification commands
- high-level notes
- known risks or follow-ups

It should not include raw executor logs.

## Non-goals

This design does not introduce:

- JSON schema
- database
- web UI
- lifecycle automation
- committed raw logs
- Prometheus export
- Grafana dashboard
- token/cost estimates
- review decision capture
- aggregated event timeline (TSV, JSON)

## Future implementation

Future slices may add:

- review decision capture (approve/reject/rework)
- Prometheus metrics export from executor metadata
- Grafana dashboards for AgentOps observability
- token/cost estimates from model provider metadata
- aggregated event timelines for multi-run comparison

Executor metadata capture is implemented in `scripts/run-opencode-executor.sh`
as optional local run capture with the fields documented above.
