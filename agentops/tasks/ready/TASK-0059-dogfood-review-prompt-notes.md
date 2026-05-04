# TASK-0059 — Dogfood review prompt verification notes

## Status

ready

## Goal

Dogfood the improved review prompt renderer by running a tiny DeepSeek implementation, parent verification, and GPT-5.5/coder stateless review with explicit verification/context notes.

Concrete implementation change:

Add `-h` / `--help` support to `scripts/start-agentops-task.sh`.

## Background

TASK-0058 improved `scripts/render-review-prompt.sh` so parent verification/context notes can be included in reviewer prompts.

This task verifies that the reviewer receives enough context to avoid false `revise` decisions caused by missing verification evidence or expected untracked task files.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/start-agentops-task.sh
- scripts/run-ready-task.sh
- scripts/render-review-prompt.sh
- agentops/tasks/ready/TASK-0059-dogfood-review-prompt-notes.md

## Write scope

- scripts/start-agentops-task.sh

Do not modify unrelated files.

## Requirements

- Keep the change minimal.
- Add support for:
  - `scripts/start-agentops-task.sh -h`
  - `scripts/start-agentops-task.sh --help`
- Help mode should print usage and exit 0.
- Missing argument should still print usage and exit non-zero.
- Preserve existing normal branch-start behavior.
- Do not commit.
- Do not read or print secrets.

## Non-goals

- No new docs.
- No template changes.
- No lifecycle automation.
- No changes to other scripts.

## Verification

Run:

    bash -n scripts/start-agentops-task.sh
    scripts/start-agentops-task.sh --help
    scripts/start-agentops-task.sh -h

Verify missing argument exits non-zero:

    set +e
    scripts/start-agentops-task.sh >/tmp/TASK-0059-missing.out 2>/tmp/TASK-0059-missing.err
    missing_exit=$?
    set -e
    echo "missing_exit=$missing_exit"

Then run:

    git status --short --branch
    git diff --stat

## Accept criteria

- `-h` and `--help` print usage and exit 0.
- Missing argument still exits non-zero.
- Existing branch-start behavior is preserved.
- The implementation only changes `scripts/start-agentops-task.sh`.
- Verification commands pass or failures are clearly explained.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
