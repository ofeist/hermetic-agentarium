# TASK-0055 — Dogfood run-ready-task helper

## Status

ready

## Goal

Dogfood `scripts/run-ready-task.sh` by using it to run one tiny implementation task through OpenCode/DeepSeek.

The concrete implementation change is:

Add `-h` / `--help` support to `scripts/run-ready-task.sh`.

## Background

TASK-0054 added `scripts/run-ready-task.sh`, a helper that runs one ready task through the existing OpenCode/DeepSeek executor workflow.

This task verifies the first automated implementation link:

    ready task
      -> scripts/run-ready-task.sh
      -> render OpenCode prompt
      -> OpenCode/DeepSeek implementation
      -> local audit capture
      -> diff left for parent verification

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/run-ready-task.sh
- scripts/render-opencode-prompt.sh
- scripts/run-opencode-executor.sh
- agentops/tasks/ready/TASK-0055-dogfood-run-ready-task.md

## Write scope

- scripts/run-ready-task.sh

Do not modify unrelated files.

## Requirements

- Keep the change minimal.
- Add support for:
  - `scripts/run-ready-task.sh -h`
  - `scripts/run-ready-task.sh --help`
- Help mode should print usage and exit 0.
- Missing or invalid arguments should still print usage/error and exit non-zero.
- Preserve existing behavior for normal ready-task execution.
- Preserve existing validation:
  - fail if argument is missing
  - fail if task id contains `/` or `..`
  - fail if ready task file does not exist
  - fail if `scripts/render-opencode-prompt.sh` is missing
  - fail if `scripts/run-opencode-executor.sh` is missing
- Do not scan all ready tasks.
- Do not move lifecycle state.
- Do not submit to review.
- Do not create result summaries.
- Do not commit.
- Do not read or print secrets.

## Non-goals

- No new docs.
- No template changes.
- No lifecycle automation.
- No review prompt renderer.
- No changes to other scripts.

## Verification

Run:

    bash -n scripts/run-ready-task.sh
    scripts/run-ready-task.sh --help
    scripts/run-ready-task.sh -h
    scripts/run-ready-task.sh
    git status --short --branch
    git diff --stat

Expected:
- `--help` exits 0 and prints usage.
- `-h` exits 0 and prints usage.
- missing argument exits non-zero and prints usage.
- only `scripts/run-ready-task.sh` is modified.

## Accept criteria

- `-h` and `--help` print usage and exit 0.
- Existing ready-task execution behavior is preserved.
- The implementation only changes `scripts/run-ready-task.sh`.
- Verification commands pass or failures are clearly explained.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
