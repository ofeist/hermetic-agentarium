# TASK-0073 — Add AgentOps executor run metadata baseline

## Status

ready

## Goal

Extend local executor run metadata so AgentOps runs are observable without
increasing prompt context or token usage.

## Background

AgentOps runs can be expensive and slow because one task may involve Hermes
parent context, OpenCode executor prompts, stdout/stderr, review prompts, diffs,
verification output, and repeated review loops.

`scripts/run-opencode-executor.sh` already supports local run capture under
`.agentops-runs/<run-id>/`, but the metadata is minimal. It does not capture
prompt size, output size, or duration, which makes it hard to tell whether
token and time pressure is coming from prompt growth, executor output, or slow
model calls.

The first observability slice should measure executor-run size and timing at
the script boundary, before adding summaries, Prometheus export, or dashboards.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `scripts/run-opencode-executor.sh`
- `.agentops-runs/`, if useful for understanding current artifact shape
- `docs/RUN-AUDIT.md`
- `agentops/tasks/ready/TASK-0073-agentops-executor-run-metadata-baseline.md`

## Write scope

- `scripts/run-opencode-executor.sh`
- `docs/RUN-AUDIT.md`

## Requirements

- The execution prompt MUST start with `/hermetic-coding-orchestrator` to
  explicitly invoke the custom skill.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near the
  beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration, not by task
  prompt text.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking
  OpenCode.

Extend `.agentops-runs/<run-id>/metadata.txt` for executor runs with these
plain key/value fields:

- `run_id`
- `task_id`, if derivable from `run_id` without guessing
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

Implementation requirements:

- Keep metadata as plain key/value text for this slice.
- Derive `task_id` from `run_id` only when unambiguous; otherwise leave it
  empty or omit it.
- Capture prompt byte and line counts without pasting prompt content into
  prompts or result notes.
- Measure `stdout_bytes` and `stderr_bytes` from the captured local artifact
  files after executor completion.
- Capture start/end timestamps and duration.
- Add or use `AGENTOPS_EXECUTOR_COMMAND` as a minimal no-network executor
  override so metadata capture can be verified without OpenCode, network
  access, API keys, paid model calls, or a successful model response.
- Ensure `AGENTOPS_EXECUTOR_COMMAND` is for test/verification only and does not
  change normal executor behavior when unset.
- Preserve the executor wrapper's current behavior and exit code semantics.
- Update `docs/RUN-AUDIT.md` to document the expanded metadata fields and the
  test-only `AGENTOPS_EXECUTOR_COMMAND` verification path.
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
- No TSV, JSON, or event timeline format changes.

## Verification

Run:

```bash
bash -n scripts/run-opencode-executor.sh
scripts/run-opencode-executor.sh --help
```

Run a no-network metadata capture smoke test. Example shape:

```bash
printf 'test prompt\n' > /tmp/TASK-0073-test.prompt.md
AGENTOPS_RUN_ID=TASK-0073-test \
AGENTOPS_EXECUTOR_COMMAND='printf "executor ok\n"' \
scripts/run-opencode-executor.sh /tmp/TASK-0073-test.prompt.md
```

Verify `.agentops-runs/TASK-0073-test/metadata.txt` contains the expected
fields:

```bash
grep -E '^(run_id|phase|harness|model|prompt_file|prompt_bytes|prompt_lines|started_at|finished_at|duration_seconds|exit_code|stdout_bytes|stderr_bytes)=' .agentops-runs/TASK-0073-test/metadata.txt
```

Also run:

```bash
git status --short --branch
git diff --stat
```

## Accept criteria

- `metadata.txt` contains the agreed executor fields.
- Prompt bytes and prompt lines are recorded.
- Start/end timestamps, duration, exit code, stdout bytes, and stderr bytes are
  recorded.
- `stdout_bytes` and `stderr_bytes` are measured from captured local artifact
  files after executor completion.
- Metadata capture can be verified through `AGENTOPS_EXECUTOR_COMMAND` without
  OpenCode, network access, API keys, paid model calls, or a successful model
  response.
- `AGENTOPS_EXECUTOR_COMMAND` does not change normal executor behavior when
  unset.
- Existing executor exit behavior is preserved.
- `docs/RUN-AUDIT.md` documents the expanded metadata contract.
- Raw logs stay local and are not pasted into prompts by default.
- Verification commands pass or failures are explained.
- Diff stays within write scope.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

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
- use AGENTOPS_EXECUTOR_COMMAND as the no-network verification path
- do not add Prometheus, Grafana, token/cost estimates, or event timelines

Return:
Plan:
Implementation:
Verification:
Review:
Changed files:
Uncertainty:
```

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
