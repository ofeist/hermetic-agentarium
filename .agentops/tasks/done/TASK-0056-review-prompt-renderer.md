# TASK-0056 — Add review prompt renderer

## Status

done

## Goal

Add a small helper script that renders a self-contained reviewer prompt from an AgentOps task file and the current git diff.

The helper should prepare input for a stateless reviewer agent such as:

    coder -z "$(cat /tmp/TASK-xxxx-review.prompt.md)"

## Background

TASK-0054 added `scripts/run-ready-task.sh`.
TASK-0055 dogfooded the ready task -> DeepSeek/OpenCode implementation link.

The next link is:

    implementation diff
      -> self-contained reviewer prompt
      -> GPT-5.5/coder reviewer

We want reviewer agents to rely on explicit task/diff/verification context, not hidden chat memory.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/
- agentops/tasks/ready/TASK-0056-review-prompt-renderer.md

## Write scope

- scripts/render-review-prompt.sh

Do not modify unrelated files.

## Requirements

Create:

    scripts/render-review-prompt.sh

The script should:

- be shell-only
- use `set -euo pipefail`
- accept exactly one argument: path to an AgentOps task file
- support `-h` and `--help`
- fail if the task file does not exist
- print the rendered review prompt to stdout
- not modify files
- not create `/tmp` files itself
- not invoke Hermes/coder
- not invoke OpenCode
- not read or print secrets
- include in the prompt:
  - reviewer role
  - instruction to review only
  - instruction not to modify files
  - original task content
  - current `git status --short --branch`
  - current `git diff --stat`
  - current `git diff`
  - reviewer decision options:
    - accept
    - revise
    - blocked
  - reviewer return format:
    - Decision
    - Scope review
    - Verification review
    - Requested changes
    - Risks / uncertainty

Keep the helper simple. Do not implement JSON, schemas, lifecycle movement, or reviewer routing.

## Non-goals

- No lifecycle state changes
- No submit-to-review
- No done/closeout helper
- No result summaries
- No multi-reviewer orchestration
- No automatic verification command execution
- No OpenCode invocation
- No Hermes invocation
- No parser for task metadata

## Verification

Run:

    bash -n scripts/render-review-prompt.sh
    scripts/render-review-prompt.sh --help
    scripts/render-review-prompt.sh -h
    scripts/render-review-prompt.sh agentops/tasks/ready/TASK-0056-review-prompt-renderer.md > /tmp/TASK-0056-review.prompt.md
    grep -q "You are the reviewer agent" /tmp/TASK-0056-review.prompt.md
    grep -q "Decision:" /tmp/TASK-0056-review.prompt.md
    grep -q "git diff --stat" /tmp/TASK-0056-review.prompt.md
    grep -q "TASK-0056" /tmp/TASK-0056-review.prompt.md
    git status --short --branch
    git diff --stat

## Accept criteria

- `scripts/render-review-prompt.sh` exists and is executable
- helper accepts one task file argument
- helper supports `-h` and `--help`
- helper writes prompt to stdout
- helper does not modify files
- prompt includes task content
- prompt includes current git status, diff stat, and diff
- prompt instructs reviewer to review only and not modify files
- prompt has accept/revise/blocked decision options
- no lifecycle folders are changed

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
