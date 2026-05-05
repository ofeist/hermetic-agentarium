# TASK-0063 — Add AgentOps tmp helper

## Status

ready

## Goal

Add a small helper that creates and prints a repo-local temporary directory for AgentOps task verification.

The helper should reduce use of `/tmp` in executor-run verification examples, because OpenCode/DeepSeek may reject `/tmp/*` as an external directory.

## Background

Several recent DeepSeek/OpenCode runs failed during verification with:

    permission requested: external_directory (/tmp/*); auto-rejecting

The implementation itself was usually fine, and parent verification still worked. But future ready tasks should prefer repo-local ignored temp paths under:

    .agentops-runs/<task-id>/tmp/

This directory is inside the repo workspace and `.agentops-runs/` is already gitignored.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- .gitignore
- scripts/
- agentops/tasks/ready/TASK-0063-agentops-tmp-helper.md

## Write scope

- scripts/agentops-tmp-dir.sh

Do not modify unrelated files.

## Requirements

Create:

    scripts/agentops-tmp-dir.sh

The script should:

- be shell-only
- use `set -euo pipefail`
- support usage:

      scripts/agentops-tmp-dir.sh <task-id-slug>

- support `-h` and `--help`
- fail if:
  - argument is missing
  - task id contains `/` or `..`
- create:

      .agentops-runs/<task-id-slug>/tmp/

- print the created directory path to stdout
- not create files inside the tmp directory
- not invoke Hermes/coder
- not invoke OpenCode
- not inspect git diff contents
- not read or print secrets

Keep the helper minimal.

## Non-goals

- No changes to existing ready task files
- No rewrite of historical `/tmp` examples
- No lifecycle state changes
- No result summaries
- No reviewer invocation
- No OpenCode invocation
- No framework or scheduler

## Verification

Run:

    bash -n scripts/agentops-tmp-dir.sh
    scripts/agentops-tmp-dir.sh --help
    scripts/agentops-tmp-dir.sh -h

Create tmp dir:

    tmp_dir="$(scripts/agentops-tmp-dir.sh TASK-0063-agentops-tmp-helper)"
    test "$tmp_dir" = ".agentops-runs/TASK-0063-agentops-tmp-helper/tmp"
    test -d "$tmp_dir"

Verify ignored:

    git check-ignore "$tmp_dir/test-output.txt"

Invalid task id should fail:

    set +e
    scripts/agentops-tmp-dir.sh bad/slug > .agentops-runs/TASK-0063-agentops-tmp-helper/tmp/badslug.out 2> .agentops-runs/TASK-0063-agentops-tmp-helper/tmp/badslug.err
    badslug_exit=$?
    set -e
    echo "badslug_exit=$badslug_exit"

Then run:

    git status --short --branch
    git diff --stat

Expected:

    badslug_exit=1

## Accept criteria

- `scripts/agentops-tmp-dir.sh` exists and is executable.
- Helper creates `.agentops-runs/<task-id>/tmp/`.
- Helper prints only the tmp directory path to stdout during normal use.
- Helper supports `-h` and `--help`.
- Helper rejects unsafe task ids.
- Created tmp path is gitignored.
- Implementation only changes `scripts/agentops-tmp-dir.sh`.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
