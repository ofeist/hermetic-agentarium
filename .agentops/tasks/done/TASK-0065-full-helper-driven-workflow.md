# TASK-0065 — Dogfood full helper-driven workflow

## Status

done

## Goal

Dogfood the full helper-driven AgentOps workflow with Hermes/coder as coordinator.

The concrete implementation change is:

Improve `scripts/accept-agentops-task.sh` help output so `-h` and `--help` print a short usage block with an example, not only a single usage line.

## Background

We now have helper scripts for the main local AgentOps flow:

- `scripts/run-ready-task.sh`
- `scripts/render-verification-notes.sh`
- `scripts/submit-agentops-task.sh`
- `scripts/render-review-prompt.sh`
- `scripts/accept-agentops-task.sh`
- `scripts/agentops-tmp-dir.sh`

This task tests whether Hermes/coder can coordinate the flow using helper scripts instead of manually improvising each step.

Expected chain:

    ready task
      -> DeepSeek/OpenCode implementation
      -> parent verification
      -> verification notes
      -> submit to review
      -> GPT-5.5/coder stateless review
      -> parent decision

Do not automatically close the task unless the parent/user explicitly approves.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/accept-agentops-task.sh
- scripts/run-ready-task.sh
- scripts/render-verification-notes.sh
- scripts/submit-agentops-task.sh
- scripts/render-review-prompt.sh
- agentops/tasks/ready/TASK-0065-full-helper-driven-workflow.md

## Write scope

- scripts/accept-agentops-task.sh

Do not modify unrelated files.

## Requirements

- Keep the change minimal.
- Improve help output for:
  - `scripts/accept-agentops-task.sh -h`
  - `scripts/accept-agentops-task.sh --help`
- Help mode should still exit 0.
- Help output should include:
  - usage
  - short description
  - example command
- Missing or invalid arguments should still exit non-zero.
- Preserve existing accept closeout behavior:
  - move review task to done
  - create result summary
  - refuse unsafe task ids
  - refuse overwrite of existing done/result files
- Do not commit.
- Do not push.
- Do not read or print secrets.

## Non-goals

- No new docs.
- No template changes.
- No lifecycle format changes.
- No changes to other scripts.
- No PR creation.
- No automatic commit/push.

## Verification

Run:

    bash -n scripts/accept-agentops-task.sh
    scripts/accept-agentops-task.sh --help
    scripts/accept-agentops-task.sh -h

Verify missing argument exits non-zero:

    tmp_dir="$(scripts/agentops-tmp-dir.sh TASK-0065-full-helper-driven-workflow)"
    set +e
    scripts/accept-agentops-task.sh > "$tmp_dir/missing.out" 2> "$tmp_dir/missing.err"
    missing_exit=$?
    set -e
    echo "missing_exit=$missing_exit"

Verify normal behavior with a temporary review task:

    mkdir -p agentops/tasks/review
    cp agentops/templates/READY-TASK-TEMPLATE.md agentops/tasks/review/TASK-9999-accept-flow-test.md
    scripts/accept-agentops-task.sh TASK-9999-accept-flow-test "Accepted in TASK-0065 helper test" > "$tmp_dir/accept.out"
    test -f agentops/tasks/done/TASK-9999-accept-flow-test.md
    test -f agentops/results/TASK-9999-accept-flow-test-result.md
    test ! -f agentops/tasks/review/TASK-9999-accept-flow-test.md
    grep -q "Accepted in TASK-0065 helper test" agentops/results/TASK-9999-accept-flow-test-result.md
    rm agentops/tasks/done/TASK-9999-accept-flow-test.md
    rm agentops/results/TASK-9999-accept-flow-test-result.md

Then run:

    git status --short --branch
    git diff --stat

## Accept criteria

- Help output is more informative than before.
- `-h` and `--help` still exit 0.
- Missing argument still exits non-zero.
- Existing accept closeout behavior still works.
- Only `scripts/accept-agentops-task.sh` is modified.
- Verification commands pass or failures are clearly explained.
- Reviewer returns `accept`, or any requested changes are handled before final acceptance.

## Return format

Return:

- changed files
- diff summary
- verification output
- reviewer decision
- uncertainty or risks
