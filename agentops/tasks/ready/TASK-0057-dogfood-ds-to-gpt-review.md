# TASK-0057 — Dogfood DS implementation to GPT review

## Status

ready

## Goal

Dogfood the minimal implementation-to-review chain:

    ready task
      -> OpenCode/DeepSeek implementation
      -> parent verification
      -> GPT-5.5/coder stateless review

The concrete implementation change is:

Add `-h` / `--help` support to `scripts/submit-agentops-task.sh`.

## Background

TASK-0054 added `scripts/run-ready-task.sh`.
TASK-0055 dogfooded ready task -> DeepSeek/OpenCode implementation.
TASK-0056 added `scripts/render-review-prompt.sh`.

This task tests whether a reviewer can inspect a self-contained review prompt built from the original task, current git status, diff stat, and diff.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/submit-agentops-task.sh
- scripts/run-ready-task.sh
- scripts/render-review-prompt.sh
- agentops/tasks/ready/TASK-0057-dogfood-ds-to-gpt-review.md

## Write scope

- scripts/submit-agentops-task.sh

Do not modify unrelated files.

## Requirements

- Keep the change minimal.
- Add support for:
  - `scripts/submit-agentops-task.sh -h`
  - `scripts/submit-agentops-task.sh --help`
- Help mode should print usage and exit 0.
- Missing argument should still print usage and exit non-zero.
- Preserve existing behavior for normal submit-to-review operation.
- Preserve existing validation:
  - fail if argument is missing
  - fail if task id contains `/` or `..`
  - fail if ready task file does not exist
  - fail if review target already exists
- Do not move lifecycle state as part of verification, except temporary test files that are created and removed during verification.
- Do not create result summaries.
- Do not commit.
- Do not read or print secrets.

## Non-goals

- No new docs.
- No template changes.
- No lifecycle automation beyond existing submit helper behavior.
- No changes to other scripts.
- No review packet format changes.
- No closeout helper.

## Verification

Run:

    bash -n scripts/submit-agentops-task.sh
    scripts/submit-agentops-task.sh --help
    scripts/submit-agentops-task.sh -h

Verify missing argument exits non-zero:

    set +e
    scripts/submit-agentops-task.sh >/tmp/TASK-0057-missing.out 2>/tmp/TASK-0057-missing.err
    missing_exit=$?
    set -e
    echo "missing_exit=$missing_exit"

Verify normal behavior with a temporary task:

    mkdir -p agentops/tasks/ready
    cp agentops/templates/READY-TASK-TEMPLATE.md agentops/tasks/ready/TASK-9999-submit-review-test.md
    scripts/submit-agentops-task.sh TASK-9999-submit-review-test
    test -f agentops/tasks/review/TASK-9999-submit-review-test.md
    test ! -f agentops/tasks/ready/TASK-9999-submit-review-test.md
    rm agentops/tasks/review/TASK-9999-submit-review-test.md

Then run:

    git status --short --branch
    git diff --stat

## Accept criteria

- `-h` and `--help` print usage and exit 0.
- Missing argument still exits non-zero.
- Existing submit-to-review behavior still works.
- The implementation only changes `scripts/submit-agentops-task.sh`.
- Verification commands pass or failures are clearly explained.
- Temporary test files are removed.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
