# observability-01 — Add AgentOps executor run metadata baseline

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

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

TBD

Likely candidates:

- `scripts/run-opencode-executor.sh`
- `.agentops-runs/`, if useful for understanding current artifact shape
- `docs/RUN-AUDIT.md`
- `agentops/tasks/planned/observability-01-executor-run-metadata.md`

## Write scope

TBD

Likely candidates:

- `scripts/run-opencode-executor.sh`
- `docs/RUN-AUDIT.md`

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
- Add or use `AGENTOPS_EXECUTOR_COMMAND` as a minimal no-network executor
  override so metadata capture can be verified without OpenCode, network
  access, API keys, paid model calls, or a successful model response.
- Ensure `AGENTOPS_EXECUTOR_COMMAND` is for test/verification only and does not
  change normal executor behavior when unset.
- Measure `stdout_bytes` and `stderr_bytes` from the captured local artifact
  files after executor completion.
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
- No broad mocking framework.

## Open questions

None.

Resolved:

- `task_id` should be derived from `run_id` only when unambiguous; otherwise
  leave it empty or omit it.
- Metadata stays plain key/value text for this slice.
- TSV, JSON, and event timelines are later tasks.
- `stdout_bytes` and `stderr_bytes` should be measured from captured local
  artifact files after executor completion.
- Metadata capture should be verified through `AGENTOPS_EXECUTOR_COMMAND`,
  not a dry-run flag, so the wrapper still exercises the real capture path.

Example shape:

```bash
AGENTOPS_RUN_ID=TASK-XXXX-test \
AGENTOPS_EXECUTOR_COMMAND='printf "executor ok\n"' \
scripts/run-opencode-executor.sh /tmp/test.prompt.md
```

## Verification

TBD

Likely commands:

```bash
bash -n scripts/run-opencode-executor.sh
AGENTOPS_RUN_ID=TASK-XXXX-test AGENTOPS_EXECUTOR_COMMAND='printf "executor ok\n"' scripts/run-opencode-executor.sh /tmp/test.prompt.md
git status --short --branch
git diff --stat
```

Add metadata assertions when ready, including checks for prompt size, timestamps,
duration, exit code, stdout bytes, and stderr bytes.

## Accept criteria

TBD

When ready, accept criteria should include:

- Metadata file contains the agreed executor fields.
- Prompt bytes and prompt lines are recorded.
- Start/end timestamps, duration, exit code, stdout bytes, and stderr bytes are
  recorded.
- Metadata capture can be verified through a no-network test path.
- `AGENTOPS_EXECUTOR_COMMAND` does not change normal executor behavior when
  unset.
- Existing executor exit behavior is preserved.
- Raw logs stay local and are not pasted into prompts by default.
- Verification commands pass or blocked checks are explicitly explained.
- Diff stays within write scope.

## Promotion decision

Decision: promote_to_ready

Reason:

TASK-0072 has landed, the lifecycle checker is quieter, and the observability
slice is narrow. The metadata format, no-network verification approach, byte
count source, and scope are now clear enough to write the ready task.

Next action:

Promote to the next ready `TASK-XXXX` ID, using `AGENTOPS_EXECUTOR_COMMAND` as
the minimal no-network executor override.

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

agentops/tasks/ready/TASK-XXXX-agentops-executor-run-metadata-baseline.md

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
