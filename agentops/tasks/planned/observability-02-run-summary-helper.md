# observability-02 — Add AgentOps run summary helper

## Status

planned

## Goal

Add a local command that summarizes one AgentOps run from metadata without
reading or pasting raw logs.

## Background / why now

After executor run metadata is expanded, users need a quick way to inspect one
run and answer basic questions: model, prompt size, duration, output size, exit
code, and artifact location.

This should make local debugging cheaper before introducing Prometheus or
Grafana.

## Problem statement

Raw `.agentops-runs/` files are useful for debugging but awkward for quick
inspection.

Reading full logs also risks unnecessary context/token usage when a compact
summary would be enough.

## Smallest useful slice

Add:

```bash
scripts/render-agentops-run-summary.sh <run-id>
```

The script should read `.agentops-runs/<run-id>/metadata.txt` and print a
compact human-readable summary.

Example summary:

```text
TASK-XXXX

model: deepseek/deepseek-v4-pro
prompt: 18.4 KB / 412 lines
duration: 94s
stdout: 8.1 KB
stderr: 0 KB
exit code: 0
artifacts: .agentops-runs/TASK-XXXX/
```

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

- `scripts/render-agentops-run-summary.sh`, if it already exists
- `.agentops-runs/`, for metadata shape examples if present
- `scripts/run-opencode-executor.sh`
- `agentops/tasks/planned/observability-02-run-summary-helper.md`

## Write scope

TBD

Likely candidates:

- `scripts/render-agentops-run-summary.sh`
- docs only if a short note is needed

## Requirements

TBD

When ready, this task should require:

- Add `scripts/render-agentops-run-summary.sh`.
- Read `.agentops-runs/<run-id>/metadata.txt`.
- Print a compact human-readable summary.
- Avoid reading full stdout/stderr logs.
- Fail clearly when metadata is missing.
- Keep output short enough to paste manually when needed.
- Preserve raw logs as local-only debugging artifacts.

## Non-goals

- No metrics exporter.
- No dashboard.
- No log parsing beyond metadata fields.
- No model prompt integration.
- No mutation of run artifacts.

## Open questions

- Should the argument be a `run_id` only, or should it also accept a task id and
  choose the latest matching run?
- Should missing metadata be an error or a partial summary?
- Should summary output be stable enough for scripts, or human-readable only?
- Should this depend strictly on observability-01 metadata fields?

If these are resolved before promotion, write:

```text
None.
```

## Verification

TBD

Likely commands:

```bash
bash -n scripts/render-agentops-run-summary.sh
scripts/render-agentops-run-summary.sh --help
git status --short --branch
git diff --stat
```

Add a fixture or local metadata smoke test when ready.

## Accept criteria

TBD

When ready, accept criteria should include:

- Summary helper exists and is executable.
- Helper reads metadata without reading raw logs.
- Missing metadata is handled clearly.
- Summary includes model, prompt size, duration, output size, exit code, and
  artifact path when available.
- Verification commands pass.
- Diff stays within write scope.

## Promotion decision

Decision: keep_planned

Reason:

This depends on the metadata fields from observability-01, so it should remain planned
until that metadata shape is implemented or finalized.

Next action:

Promote after observability-01 lands and the accepted metadata key names are known.

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

agentops/tasks/ready/TASK-XXXX-agentops-run-summary-helper.md

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

The helper should make observability cheap: paths, counts, duration, and outcome
are enough for routine inspection.
