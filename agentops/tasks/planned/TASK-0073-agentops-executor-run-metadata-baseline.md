# TASK-0073 — Add AgentOps executor run metadata baseline

## Status

planned

## Goal

Extend local executor run metadata so AgentOps runs are observable without
increasing prompt context or token usage.

## Background / why now

AgentOps runs can be expensive and slow because one task may involve Hermes
parent context, OpenCode executor prompts, stdout/stderr, review prompts, diffs,
verification output, and repeated review loops. The first observability slice
should measure executor-run size and timing at the script boundary.

## Problem statement

`scripts/run-opencode-executor.sh` already supports local run capture under
`.agentops-runs/<run-id>/`, but the metadata is minimal. It does not capture
prompt size, output size, or duration, which makes it hard to tell whether
token and time pressure is coming from prompt growth, executor output, or slow
model calls.

## Smallest useful slice

Extend `.agentops-runs/<run-id>/metadata.txt` for executor runs with:

- `run_id`
- `task_id`, if derivable
- `phase=executor`
- `harness=OpenCode`
- `model`
- `prompt_file`
- `prompt_bytes`
- `prompt_lines`
- `started_at`
- `finished_at`
- `duration_seconds`
- `exit_code`
- `stdout_bytes`
- `stderr_bytes`

## Non-goals

- No `events.tsv`.
- No review decision capture.
- No Prometheus export.
- No Grafana dashboard.
- No token/cost estimates.
- No prompt expansion.

## Open questions

- Should `task_id` be derived from `run_id`, prompt filename, or left empty
  unless unambiguous?
- Should byte counts be measured before or after tee capture?
- Should the metadata format remain plain key/value text or become TSV/JSON in
  a later task?

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

- `scripts/run-opencode-executor.sh`
- `docs/RUN-AUDIT.md`

Verification should include a no-network dry path if possible, or a small prompt
run only if local OpenCode/provider access is available.

## Notes

Core principle: observe to local files first; do not paste full observability
logs into model prompts by default.
