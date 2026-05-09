# AgentOps Usage Guide

This guide explains how to use the lightweight `agentops/` lifecycle directory.

The goal is not to replace Git, tests, or code review. The goal is to keep agentic tasks explicit, reviewable, and easy to resume.

## Lifecycle states

Tasks move through these states:

    planned -> ready -> running -> review -> done

The current directories are:

    agentops/tasks/planned/
    agentops/tasks/ready/
    agentops/tasks/running/
    agentops/tasks/review/
    agentops/tasks/done/
    agentops/results/

## State meanings

- `planned/` — rough task ideas that are not ready for execution.
- `ready/` — bounded tasks with clear goal, read scope, write scope, constraints, executor, and verification.
- `running/` — task currently being executed by a parent/executor workflow.
- `review/` — executor has produced a diff and parent review is pending.
- `done/` — terminal task state after accept, revise, revert, no-op, or blocked.
- `results/` — safe summary records for completed tasks.

### Planned-to-ready promotion

Promotion from `planned/` to `ready/` is a **mechanical transformation**, not a
rewrite. Ready-shaped planned tasks should keep their existing structure and
wording. See the full promotion policy in
`skills/hermetic-coding-orchestrator/SKILL.md`.

In short:
- move the file, assign the next `TASK-XXXX` ID, update `Status` to `ready`
- replace `TBD` fields and resolve open questions
- preserve existing structure and wording
- large unexpected diffs must be called out in review

## Minimal task file

A ready task should include:

    # TASK-xxxx — Short title

    Status: ready

    ## Goal

    One clear goal.

    ## Read scope

    Files the executor may inspect.

    ## Write scope

    Files the executor may create or modify.

    ## Constraints

    - Do not commit.
    - Do not modify unrelated files.
    - Do not read or print secrets.
    - Executor model selection is controlled by runner configuration.

    ## Executor

    Harness: OpenCode
    Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
    Fallback: disabled

    ## Implementation requirements

    Specific expected change.

    ## Verification

    Commands the parent must run.

    ## Decision states

    - accept
    - revise
    - revert
    - no-op / nothing to accept
    - blocked

## Minimal result file

A result file should be written under:

    agentops/results/TASK-xxxx-result.md

It should include:

    # TASK-xxxx Result

    Decision: accept / revise / revert / no-op / blocked

    ## Summary

    What happened.

    ## Executor

    Harness and model used.

    ## Changed files

    Files changed by the executor.

    ## Verification

    Commands run and result.

    ## Notes

    Important risks, follow-ups, or runtime details.

## Manual lifecycle movement

Move a completed task from `ready/` to `done/`:

    git mv agentops/tasks/ready/TASK-xxxx-name.md agentops/tasks/done/TASK-xxxx-name.md

Create the result summary:

    $EDITOR agentops/results/TASK-xxxx-result.md

Review:

    git status --short --branch
    git diff --stat
    git diff -- agentops/tasks/done/TASK-xxxx-name.md agentops/results/TASK-xxxx-result.md

Commit:

    git add agentops/tasks/done/TASK-xxxx-name.md agentops/results/TASK-xxxx-result.md
    git commit -m "TASK-xxxx: close out task name"

## Parent review rules

The parent must independently verify executor work:

    scripts/review-executor-result.sh
    git diff
    git diff --cached --stat

Run task-specific tests or checks when applicable.

Trust command output over agent summaries.

## What not to automate yet

Do not add a large task registry, PR automation, or Taskplane-like orchestration too early.

First keep the lifecycle simple and explicit:

- one task file
- one task branch
- one executor run
- one parent review
- one result record
