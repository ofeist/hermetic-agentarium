# TASK-0073 — Add AgentOps executor run metadata baseline

## Status

planned

## Goal

Extend local executor run metadata so AgentOps runs are observable without
increasing prompt context or token usage.

## Background / why now

AgentOps runs can be expensive and slow because one task may involve Hermes
parent context, OpenCode executor prompts, stdout/stderr, review prompts, diffs,
verification output, and repeated review loops.

The first observability slice should measure executor-run size and timing at
the script boundary, before adding summaries, Prometheus export, or dashboards.

## Problem statement

`scripts/run-opencode-executor.sh` already supports local run capture under
`.agentops-runs/<run-id>/`, but the metadata is minimal.

It does not capture prompt size, output size, or duration, which makes it hard
to tell whether token and time pressure is coming from prompt growth, executor
output, or slow model calls.

## Smallest useful slice

Extend `.agentops-runs/<run-id>/metadata.txt` for executor runs with enough
structured key/value fields to understand one executor invocation.

Target fields:

- `run_id`
- `task_id`, if derivable without guessing
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

- `scripts/run-opencode-executor.sh`
- existing files under `.agentops-runs/`, if present
- `agentops/IDEAS.md`
- `agentops/tasks/planned/TASK-0073-agentops-executor-run-metadata-baseline.md`

## Write scope

TBD

Likely candidates:

- `scripts/run-opencode-executor.sh`
- docs only if a short note is needed

## Requirements

TBD

When ready, this task should require:

- Capture executor metadata locally in `.agentops-runs/<run-id>/metadata.txt`.
- Use plain key/value metadata unless the ready task explicitly chooses another
  format.
- Capture prompt byte and line counts without pasting prompt content into
  prompts or result notes.
- Capture stdout/stderr byte counts from local artifacts.
- Capture start/end timestamps and duration.
- Preserve the executor wrapper's current behavior and exit code semantics.
- Avoid adding observability content to model prompts by default.
- Keep raw logs local.

## Non-goals

- No `events.tsv`.
- No review decision capture.
- No Prometheus export.
- No Grafana dashboard.
- No token/cost estimates.
- No prompt expansion.
- No unrelated executor behavior changes.

## Open questions

- Should `task_id` be derived from `run_id`, prompt filename, or left empty
  unless unambiguous?
- Should byte counts be measured before or after tee capture?
- Should metadata stay plain key/value text or move to TSV/JSON in a later
  task?
- Is there a reliable no-network dry path for verifying metadata capture?

If these are resolved before promotion, write:

```text
None.
```

## Verification

TBD

Likely commands:

```bash
bash -n scripts/run-opencode-executor.sh
git status --short --branch
git diff --stat
```

Add a task-specific smoke check when ready. Prefer a no-network dry path if the
script supports one; otherwise require the executor dependency and model access
to be available or explicitly report that verification is blocked.

## Accept criteria

TBD

When ready, accept criteria should include:

- Metadata file contains the agreed executor fields.
- Prompt bytes and prompt lines are recorded.
- Start/end timestamps, duration, exit code, stdout bytes, and stderr bytes are
  recorded.
- Existing executor exit behavior is preserved.
- Raw logs stay local and are not pasted into prompts by default.
- Verification commands pass or blocked checks are explicitly explained.
- Diff stays within write scope.

## Promotion decision

Decision: keep_planned

Reason:

This is the first observability implementation slice, but TASK-0072 should land
first so lifecycle checker output is less noisy before observability metadata is
made more visible.

Next action:

Promote after TASK-0072 is complete and the no-network verification path is
decided.

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

agentops/tasks/ready/TASK-0073-agentops-executor-run-metadata-baseline.md

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

Core principle: observe to local files first; do not paste full observability
logs into model prompts by default.
