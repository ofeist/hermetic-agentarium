# TASK-0074 — Add AgentOps run summary helper

## Status

planned

## Goal

Add a local command that summarizes one AgentOps run from metadata without
reading or pasting raw logs.

## Background / why now

After executor run metadata is expanded, users need a quick way to inspect one
run and answer basic questions: model, prompt size, duration, output size,
exit code, and artifact location.

## Problem statement

Raw `.agentops-runs/` files are useful for debugging but awkward for quick
inspection. Reading full logs also risks unnecessary context/token usage when a
compact summary would be enough.

## Smallest useful slice

Add:

```bash
scripts/render-agentops-run-summary.sh <run-id>
```

The script should read `.agentops-runs/<run-id>/metadata.txt` and print a
compact human-readable summary.

## Non-goals

- No metrics exporter.
- No dashboard.
- No log parsing beyond metadata fields.
- No model prompt integration.

## Open questions

- Should the argument be a `run_id` only, or should it also accept a task id and
  choose the latest matching run?
- Should missing metadata be an error or a partial summary?
- Should summary output be stable enough for scripts, or human-readable only?

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

- `scripts/render-agentops-run-summary.sh`
- `docs/DEBUGGING.md` or `docs/RUN-AUDIT.md`

Depends on TASK-0073 metadata fields.

## Notes

Example summary:

```text
TASK-0073

model: deepseek/deepseek-v4-pro
prompt: 18.4 KB / 412 lines
duration: 94s
stdout: 8.1 KB
stderr: 0 KB
exit code: 0
artifacts: .agentops-runs/TASK-0073/
```
