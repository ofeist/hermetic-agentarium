# TASK-0060 — Add verification notes helper

## Status

done

## Goal

Add a small helper that renders parent verification/context notes for reviewer prompts.

The helper should reduce manual work when preparing the optional second argument for:

    scripts/render-review-prompt.sh <task-file> <verification-notes-file>

## Background

TASK-0058 added optional verification/context notes support to `scripts/render-review-prompt.sh`.

TASK-0059 dogfooded the improved reviewer prompt and proved that GPT-5.5/coder can accept a stateless review packet when parent verification/context notes are included.

In TASK-0059, the parent manually wrote `/tmp/TASK-0059-verification-notes.md`. This task adds a helper to scaffold that content.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/render-review-prompt.sh
- scripts/run-ready-task.sh
- agentops/tasks/ready/TASK-0060-verification-notes-helper.md

## Write scope

- scripts/render-verification-notes.sh

Do not modify unrelated files.

## Requirements

Create:

    scripts/render-verification-notes.sh

The script should:

- be shell-only
- use `set -euo pipefail`
- accept exactly one argument: task id slug
- support `-h` and `--help`
- fail if task id contains `/` or `..`
- print markdown notes to stdout
- not modify files
- not create `/tmp` files itself
- not invoke Hermes/coder
- not invoke OpenCode
- not read or print secrets
- include:
  - title: `# Parent verification / context notes`
  - note that `agentops/tasks/ready/<task-id>.md` is the original ready task file if it exists
  - note that the ready task file is expected and should not be treated as an implementation scope violation
  - placeholder for verification commands/output
  - current `git status --short --branch`
  - current `git diff --stat`
  - current changed file list from `git diff --name-only`
- if the ready task file does not exist:
  - do not fail
  - include a note that no matching ready task file was found

Keep the helper simple. Do not infer accept/revise/blocked decisions.

## Non-goals

- No lifecycle state changes
- No submit-to-review
- No done/closeout helper
- No result summaries
- No reviewer invocation
- No automatic verification command execution
- No OpenCode invocation
- No Hermes invocation
- No parser for task metadata

## Verification

Run:

    bash -n scripts/render-verification-notes.sh
    scripts/render-verification-notes.sh --help
    scripts/render-verification-notes.sh -h

Render notes:

    scripts/render-verification-notes.sh TASK-0060-verification-notes-helper > /tmp/TASK-0060-verification-notes.md
    grep -q "Parent verification / context notes" /tmp/TASK-0060-verification-notes.md
    grep -q "TASK-0060-verification-notes-helper" /tmp/TASK-0060-verification-notes.md
    grep -q "git status --short --branch" /tmp/TASK-0060-verification-notes.md
    grep -q "git diff --stat" /tmp/TASK-0060-verification-notes.md

Invalid task id should fail:

    set +e
    scripts/render-verification-notes.sh bad/slug >/tmp/TASK-0060-badslug.out 2>/tmp/TASK-0060-badslug.err
    badslug_exit=$?
    set -e
    echo "badslug_exit=$badslug_exit"

Then run:

    git status --short --branch
    git diff --stat

Expected:

    badslug_exit=1

## Accept criteria

- `scripts/render-verification-notes.sh` exists and is executable.
- Helper prints markdown to stdout.
- Helper does not modify files.
- Helper supports `-h` and `--help`.
- Helper rejects unsafe task ids.
- Helper includes ready task context when matching ready task exists.
- Helper includes git status, diff stat, and changed files.
- The implementation only changes `scripts/render-verification-notes.sh`.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
