# TASK-xxxx — Short task title

## Status

ready

## Goal

Describe the smallest useful outcome of this task.

## Background

Explain why this task exists and what context matters.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- List files or directories the executor may inspect.

## Write scope

- List files or directories the executor may modify or create.

## Requirements

- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking OpenCode.

## Non-goals

- List what is intentionally out of scope.

## Verification

Run:

    git status --short --branch
    git diff --stat

Add task-specific checks here.

## Accept criteria

- The requested change is implemented.
- The diff stays within write scope.
- Verification commands pass or failures are explained.
- No unrelated files are modified.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
