# TASK-0066 — Add revision task helper

## Status

ready

## Goal

Add `scripts/revise-agentops-task.sh`, a small AgentOps lifecycle helper that creates a new ready revision task from an existing reviewed task when the reviewer decision is `revise`.

## Background

Current AgentOps workflow includes helpers for ready task execution, review submission, and accepted-task closeout. When review returns `revise`, the parent currently needs a safe, repeatable way to create a follow-up ready task without deleting, moving, or overwriting the original reviewed task.

This task adds the revision counterpart to the accept closeout helper:

    review/done/ready source task
      -> new ready revision task

Use the existing helper conventions in `scripts/`: shell-only, small surface area, slug validation, clear help output, conflict checks, and no commits/pushes.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- `scripts/accept-agentops-task.sh`
- `scripts/submit-agentops-task.sh`
- `scripts/new-ready-task.sh`
- `agentops/templates/READY-TASK-TEMPLATE.md`
- `agentops/tasks/ready/`
- `agentops/tasks/review/`
- `agentops/tasks/done/`
- `agentops/tasks/ready/TASK-0066-add-revision-task-helper.md`

## Write scope

- `scripts/revise-agentops-task.sh`

Do not modify unrelated files.

## Requirements

Create:

    scripts/revise-agentops-task.sh

The script should:

- be shell-only
- use `set -euo pipefail`
- be executable
- support useful `-h` and `--help`
- make `-h` and `--help` exit `0`
- make missing or invalid arguments exit non-zero
- accept a source task id slug or a source task path
- prefer locating the source task in this order when a slug is provided:
  1. `agentops/tasks/review/<source>.md`
  2. `agentops/tasks/done/<source>.md`
  3. `agentops/tasks/ready/<source>.md`
- when a path is provided, require it to be a file under one of:
  - `agentops/tasks/review/`
  - `agentops/tasks/done/`
  - `agentops/tasks/ready/`
- create a new ready task in:

      agentops/tasks/ready/

- do not overwrite existing files
- do not delete or move the original task
- reject unsafe task ids or output slugs containing `/` or `..`
- create `agentops/tasks/ready/` if missing
- include enough context in the generated revision task for an executor to act on it
- include at minimum in the generated ready task:
  - title identifying it as a revision task
  - status `ready`
  - source task path
  - revision note supplied by the caller
  - executor/model sections matching existing ready task conventions
  - read/write scope placeholders or conservative guidance
  - verification guidance
  - accept criteria
  - return format
- print the created ready task path
- do not invoke OpenCode
- do not invoke a reviewer
- do not submit the generated task to review
- do not commit
- do not push
- do not read or print secrets

Preferred usage:

    scripts/revise-agentops-task.sh <source-task-id-or-path> <new-task-id-slug> <revision-note>

Example:

    scripts/revise-agentops-task.sh TASK-0066-add-revision-task-helper TASK-0066-revision-1 "Address reviewer requested changes"

## Non-goals

- No automatic parsing of reviewer output
- No lifecycle movement of the source task
- No deletion of the source task
- No OpenCode execution
- No reviewer invocation
- No commit or push
- No broad workflow engine behavior beyond creating the new ready task

## Verification

Run:

    bash -n scripts/revise-agentops-task.sh
    scripts/revise-agentops-task.sh --help
    scripts/revise-agentops-task.sh -h

Verify missing arguments fail non-zero:

    set +e
    scripts/revise-agentops-task.sh >/tmp/TASK-0066-missing.out 2>/tmp/TASK-0066-missing.err
    missing_exit=$?
    set -e
    echo "missing_exit=$missing_exit"

Verify normal behavior with a dummy review task:

    mkdir -p agentops/tasks/review agentops/tasks/ready
    cp agentops/templates/READY-TASK-TEMPLATE.md agentops/tasks/review/TASK-9999-revise-source.md
    scripts/revise-agentops-task.sh TASK-9999-revise-source TASK-9999-revise-followup "Fix reviewer comments" > /tmp/TASK-0066-revise.out
    test -f agentops/tasks/review/TASK-9999-revise-source.md
    test -f agentops/tasks/ready/TASK-9999-revise-followup.md
    grep -q "TASK-9999-revise-source" agentops/tasks/ready/TASK-9999-revise-followup.md
    grep -q "Fix reviewer comments" agentops/tasks/ready/TASK-9999-revise-followup.md
    grep -q "agentops/tasks/ready/TASK-9999-revise-followup.md" /tmp/TASK-0066-revise.out
    set +e
    scripts/revise-agentops-task.sh TASK-9999-revise-source TASK-9999-revise-followup "Should not overwrite" >/tmp/TASK-0066-overwrite.out 2>/tmp/TASK-0066-overwrite.err
    overwrite_exit=$?
    set -e
    echo "overwrite_exit=$overwrite_exit"
    rm agentops/tasks/review/TASK-9999-revise-source.md
    rm agentops/tasks/ready/TASK-9999-revise-followup.md

Verify path input works with a dummy done task:

    mkdir -p agentops/tasks/done agentops/tasks/ready
    cp agentops/templates/READY-TASK-TEMPLATE.md agentops/tasks/done/TASK-9999-revise-done-source.md
    scripts/revise-agentops-task.sh agentops/tasks/done/TASK-9999-revise-done-source.md TASK-9999-revise-from-path "Path input revision" > /tmp/TASK-0066-path.out
    test -f agentops/tasks/done/TASK-9999-revise-done-source.md
    test -f agentops/tasks/ready/TASK-9999-revise-from-path.md
    grep -q "agentops/tasks/done/TASK-9999-revise-done-source.md" agentops/tasks/ready/TASK-9999-revise-from-path.md
    rm agentops/tasks/done/TASK-9999-revise-done-source.md
    rm agentops/tasks/ready/TASK-9999-revise-from-path.md

Then run:

    git status --short --branch
    git diff --stat

Expected:

    missing_exit=1
    overwrite_exit=1

## Accept criteria

- `scripts/revise-agentops-task.sh` exists and is executable.
- `-h` and `--help` print useful help and exit `0`.
- Missing or invalid arguments exit non-zero.
- The helper accepts source task id slugs and source task paths.
- Slug source lookup prefers `review/`, then `done/`, then `ready/`.
- Generated revision task is created under `agentops/tasks/ready/`.
- Existing ready files are not overwritten.
- Original source task is not moved or deleted.
- Dummy review-task verification passes.
- Path-input verification passes.
- Diff stays within write scope.
- No commits or pushes are made.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
