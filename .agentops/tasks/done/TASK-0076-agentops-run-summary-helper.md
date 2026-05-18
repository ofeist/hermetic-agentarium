# TASK-0076 — Add AgentOps run summary helper

## Status

done

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
run: TASK-XXXX-summary-test
task: TASK-XXXX

model: deepseek/deepseek-v4-pro
prompt: 18.4 KB / 412 lines
duration: 94s
stdout: 8.1 KB
stderr: 0 KB
exit code: 0
artifacts: .agentops-runs/TASK-XXXX-summary-test/
```

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `scripts/run-opencode-executor.sh`
- `.agentops-runs/`, if useful for metadata examples
- `agentops/tasks/ready/TASK-0076-agentops-run-summary-helper.md`

## Write scope

- `scripts/render-agentops-run-summary.sh`
- `docs/RUN-AUDIT.md`, only if a short usage note is needed

## Requirements

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

None.

Resolved:

- First version accepts only a `run_id`.
- Choosing the latest run for a task ID is a later feature.
- Missing `metadata.txt` is an error with a clear message.
- Missing optional fields produce `unknown`, not failure.
- Output is human-readable only, not a stable machine interface.
- The helper depends on the metadata fields from observability-01 / TASK-0073.

## Verification

Run:

```bash
bash -n scripts/render-agentops-run-summary.sh
scripts/render-agentops-run-summary.sh --help
mkdir -p .agentops-runs/TASK-9999-summary-test
cat > .agentops-runs/TASK-9999-summary-test/metadata.txt <<'EOF'
run_id=TASK-9999-summary-test
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
scripts/render-agentops-run-summary.sh TASK-9999-summary-test
rm -rf .agentops-runs/TASK-9999-summary-test
git status --short --branch
git diff --stat
```

The helper should read only `metadata.txt` during the smoke test, not
stdout/stderr logs.

## Accept criteria

- Summary helper exists and is executable.
- Helper reads metadata without reading raw logs.
- Missing metadata is handled clearly.
- Summary includes model, prompt size, duration, output size, exit code, and
  artifact path when available.
- Verification commands pass.
- Diff stays within write scope.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0076-agentops-run-summary-helper.md

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

The helper should make observability cheap: paths, counts, duration, and outcome
are enough for routine inspection.
