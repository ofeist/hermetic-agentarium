# TASK-0061 — Improve submit task to review helper

## Status

done

## Goal

Improve the existing submit-for-review helper so it clearly represents the transition from implementation completed / parent verified to reviewer-ready state.

The helper should continue to move a task from:

    agentops/tasks/ready/<task-id>.md

to:

    agentops/tasks/review/<task-id>.md

and print practical next steps for rendering a reviewer prompt.

## Background

TASK-0049 added `scripts/submit-agentops-task.sh` for moving ready tasks into review.

TASK-0056 added `scripts/render-review-prompt.sh`.

TASK-0058 added optional verification/context notes support to review prompt rendering.

TASK-0060 added `scripts/render-verification-notes.sh`.

We now have a working chain:

    ready task
      -> DeepSeek/OpenCode implementation
      -> parent verification
      -> verification notes
      -> GPT-5.5/coder stateless review

This task improves the transition helper so the parent/coordinator gets useful next commands after moving a task to review.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/submit-agentops-task.sh
- scripts/render-review-prompt.sh
- scripts/render-verification-notes.sh
- agentops/tasks/ready/TASK-0061-submit-task-to-review-helper.md

## Write scope

- scripts/submit-agentops-task.sh

Do not modify unrelated files.

## Requirements

Update:

    scripts/submit-agentops-task.sh

The script should:

- stay shell-only
- keep `set -euo pipefail`
- preserve existing usage:

      scripts/submit-agentops-task.sh <task-id-slug>

- keep existing `-h` / `--help` support
- preserve existing behavior:
  - validate exactly one argument
  - reject task ids containing `/` or `..`
  - fail if ready task file does not exist
  - fail if review target already exists
  - create `agentops/tasks/review/` if missing
  - move ready task file to review task file
  - print moved review file path
- after moving the task, print useful next commands:
  - render verification notes
  - render review prompt with verification notes
  - run coder reviewer one-shot
- commands should reference:
  - `scripts/render-verification-notes.sh <task-id-slug>`
  - `scripts/render-review-prompt.sh agentops/tasks/review/<task-id-slug>.md /tmp/<task-id-slug>-verification-notes.md`
  - `coder -z "$(cat /tmp/<task-id-slug>-review.prompt.md)"`
- do not invoke those commands automatically
- do not create verification notes automatically
- do not invoke coder
- do not invoke OpenCode
- do not create result summaries
- do not move to done
- do not read or print secrets

Keep this as a helper output improvement, not a workflow engine.

## Non-goals

- No lifecycle automation beyond ready -> review
- No done/closeout helper
- No result summaries
- No reviewer invocation
- No OpenCode invocation
- No automatic verification command execution
- No scanning all tasks
- No parser for task metadata

## Verification

Run:

    bash -n scripts/submit-agentops-task.sh
    scripts/submit-agentops-task.sh --help
    scripts/submit-agentops-task.sh -h

Verify normal behavior with a temporary task:

    mkdir -p agentops/tasks/ready
    cp agentops/templates/READY-TASK-TEMPLATE.md agentops/tasks/ready/TASK-9999-submit-review-next-steps.md
    scripts/submit-agentops-task.sh TASK-9999-submit-review-next-steps > /tmp/TASK-0061-submit.out
    test -f agentops/tasks/review/TASK-9999-submit-review-next-steps.md
    test ! -f agentops/tasks/ready/TASK-9999-submit-review-next-steps.md
    grep -q "render-verification-notes.sh TASK-9999-submit-review-next-steps" /tmp/TASK-0061-submit.out
    grep -q "render-review-prompt.sh agentops/tasks/review/TASK-9999-submit-review-next-steps.md" /tmp/TASK-0061-submit.out
    grep -q "coder -z" /tmp/TASK-0061-submit.out
    rm agentops/tasks/review/TASK-9999-submit-review-next-steps.md

Invalid task id should fail:

    set +e
    scripts/submit-agentops-task.sh bad/slug >/tmp/TASK-0061-badslug.out 2>/tmp/TASK-0061-badslug.err
    badslug_exit=$?
    set -e
    echo "badslug_exit=$badslug_exit"

Then run:

    git status --short --branch
    git diff --stat

Expected:

    badslug_exit=1

## Accept criteria

- Existing submit-for-review behavior still works.
- Helper still moves ready task to review task.
- Helper prints practical next commands for verification notes, review prompt, and coder review.
- Helper does not invoke reviewer automatically.
- Helper does not create result summaries.
- Helper does not move to done.
- Implementation only changes `scripts/submit-agentops-task.sh`.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
