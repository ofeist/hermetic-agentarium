# TASK-0062 — Add accept closeout helper

## Status

done

## Goal

Add a small helper that closes an accepted AgentOps task by moving it from `review/` to `done/` and creating a safe committed result summary.

The helper should be used after parent/reviewer decision is `accept`.

## Background

Current workflow:

    ready task
      -> DeepSeek/OpenCode implementation
      -> parent verification
      -> verification notes
      -> submit to review
      -> GPT-5.5/coder review
      -> accept/revise/blocked decision

TASK-0061 improved `scripts/submit-agentops-task.sh` so accepted implementations can be submitted to review and reviewers can be invoked.

This task adds the next transition:

    review/
      -> done/
      -> agentops/results/

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/submit-agentops-task.sh
- agentops/tasks/review/
- agentops/tasks/done/
- agentops/results/
- agentops/tasks/ready/TASK-0062-accept-closeout-helper.md

## Write scope

- scripts/accept-agentops-task.sh

Do not modify unrelated files.

## Requirements

Create:

    scripts/accept-agentops-task.sh

The script should:

- be shell-only
- use `set -euo pipefail`
- support usage:

      scripts/accept-agentops-task.sh <task-id-slug> <decision-note>

- example:

      scripts/accept-agentops-task.sh TASK-0062-accept-closeout-helper "Accepted after GPT-5.5 review"

- support `-h` and `--help`
- fail if:
  - arguments are missing
  - task id contains `/` or `..`
  - review task file does not exist
  - done task target already exists
  - result summary target already exists
- create directories if missing:
  - `agentops/tasks/done/`
  - `agentops/results/`
- move:

      agentops/tasks/review/<task-id-slug>.md

  to:

      agentops/tasks/done/<task-id-slug>.md

- create result summary:

      agentops/results/<task-id-slug>-result.md

- result summary should include:
  - title
  - Decision
  - Decision note
  - Task file
  - Git status
  - Diff stat
  - Verification
  - Follow-ups
- use placeholders where parent should edit later
- print paths of the done task and result summary
- do not inspect raw `.agentops-runs/`
- do not invoke reviewer
- do not invoke OpenCode
- do not commit
- do not push
- do not read or print secrets

Keep this as a closeout helper, not a workflow engine.

## Non-goals

- No automatic accept decision
- No reviewer invocation
- No PR creation
- No git commit/push
- No parsing reviewer output
- No scanning all review tasks
- No lifecycle automation beyond review -> done
- No raw log copying

## Verification

Run:

    bash -n scripts/accept-agentops-task.sh
    scripts/accept-agentops-task.sh --help
    scripts/accept-agentops-task.sh -h

Verify normal behavior with a temporary review task:

    mkdir -p agentops/tasks/review
    cp agentops/templates/READY-TASK-TEMPLATE.md agentops/tasks/review/TASK-9999-accept-test.md
    scripts/accept-agentops-task.sh TASK-9999-accept-test "Accepted in helper test" > /tmp/TASK-0062-accept.out
    test -f agentops/tasks/done/TASK-9999-accept-test.md
    test -f agentops/results/TASK-9999-accept-test-result.md
    test ! -f agentops/tasks/review/TASK-9999-accept-test.md
    grep -q "Decision" agentops/results/TASK-9999-accept-test-result.md
    grep -q "Accepted in helper test" agentops/results/TASK-9999-accept-test-result.md
    grep -q "agentops/tasks/done/TASK-9999-accept-test.md" /tmp/TASK-0062-accept.out
    grep -q "agentops/results/TASK-9999-accept-test-result.md" /tmp/TASK-0062-accept.out
    rm agentops/tasks/done/TASK-9999-accept-test.md
    rm agentops/results/TASK-9999-accept-test-result.md

Invalid task id should fail:

    set +e
    scripts/accept-agentops-task.sh bad/slug "bad" >/tmp/TASK-0062-badslug.out 2>/tmp/TASK-0062-badslug.err
    badslug_exit=$?
    set -e
    echo "badslug_exit=$badslug_exit"

Then run:

    git status --short --branch
    git diff --stat

Expected:

    badslug_exit=1

## Accept criteria

- `scripts/accept-agentops-task.sh` exists and is executable.
- Helper moves review task to done.
- Helper creates safe result summary.
- Helper refuses to overwrite existing done/result files.
- Helper supports help mode.
- Helper rejects unsafe task ids.
- Helper does not commit/push.
- Helper does not inspect raw run logs.
- Implementation only changes `scripts/accept-agentops-task.sh`.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
