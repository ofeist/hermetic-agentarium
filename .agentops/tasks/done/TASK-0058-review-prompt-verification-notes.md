# TASK-0058 — Improve review prompt with verification notes

## Status

done

## Goal

Improve `scripts/render-review-prompt.sh` so the parent/coordinator can include verification notes or extra review context in the generated reviewer prompt.

## Background

TASK-0056 added `scripts/render-review-prompt.sh`.

TASK-0057 dogfooded the chain:

    DeepSeek/OpenCode implementation
      -> parent verification
      -> GPT-5.5/coder stateless review

The first reviewer correctly returned `revise` because the review prompt did not include:
- parent verification output
- context that the untracked ready task file was expected

A second manual review prompt with that context returned `accept`.

This task improves the helper so future reviewer prompts can include such parent-provided verification/context notes.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/render-review-prompt.sh
- agentops/tasks/ready/TASK-0058-review-prompt-verification-notes.md

## Write scope

- scripts/render-review-prompt.sh

Do not modify unrelated files.

## Requirements

Update:

    scripts/render-review-prompt.sh

The script should:

- stay shell-only
- keep `set -euo pipefail`
- preserve existing one-argument usage:

      scripts/render-review-prompt.sh <task-file>

- add optional two-argument usage:

      scripts/render-review-prompt.sh <task-file> <verification-notes-file>

- support `-h` and `--help`
- fail if the task file does not exist
- if a verification notes file is provided:
  - fail if it does not exist
  - include its content in the rendered prompt
- if no verification notes file is provided:
  - include a clear placeholder section saying no parent verification notes were provided
- keep writing the rendered prompt to stdout
- not modify files
- not create `/tmp` files itself
- not invoke Hermes/coder
- not invoke OpenCode
- not read or print secrets
- preserve existing prompt content:
  - reviewer role
  - review only / do not modify files
  - original task content
  - current `git status --short --branch`
  - current `git diff --stat`
  - current `git diff`
  - decision options: accept / revise / blocked
  - return format

Add a section to the rendered prompt named:

    Parent verification / context notes

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

One-argument mode:

    scripts/render-review-prompt.sh agentops/tasks/ready/TASK-0058-review-prompt-verification-notes.md > /tmp/TASK-0058-review-no-notes.prompt.md
    grep -q "Parent verification / context notes" /tmp/TASK-0058-review-no-notes.prompt.md
    grep -q "No parent verification notes were provided" /tmp/TASK-0058-review-no-notes.prompt.md

Two-argument mode:

    cat > /tmp/TASK-0058-verification-notes.md <<'EOF'
Parent verification:
- bash -n scripts/render-review-prompt.sh passed
- expected ready task file is intentionally untracked before commit
EOF

    scripts/render-review-prompt.sh agentops/tasks/ready/TASK-0058-review-prompt-verification-notes.md /tmp/TASK-0058-verification-notes.md > /tmp/TASK-0058-review-with-notes.prompt.md
    grep -q "Parent verification:" /tmp/TASK-0058-review-with-notes.prompt.md
    grep -q "expected ready task file is intentionally untracked" /tmp/TASK-0058-review-with-notes.prompt.md

Missing notes file should fail:

    set +e
    scripts/render-review-prompt.sh agentops/tasks/ready/TASK-0058-review-prompt-verification-notes.md /tmp/does-not-exist.md >/tmp/TASK-0058-missing-notes.out 2>/tmp/TASK-0058-missing-notes.err
    missing_notes_exit=$?
    set -e
    echo "missing_notes_exit=$missing_notes_exit"

Then run:

    git status --short --branch
    git diff --stat

## Accept criteria

- Existing one-argument usage still works.
- Optional verification notes file is supported.
- Missing notes file fails non-zero.
- Prompt includes `Parent verification / context notes`.
- Prompt preserves task content, git status, diff stat, diff, decision options, and return format.
- Helper does not modify files.
- The implementation only changes `scripts/render-review-prompt.sh`.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
