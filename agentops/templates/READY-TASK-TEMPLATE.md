# TASK-xxxx — Short task title

## Status

ready

## Goal

One short paragraph describing what this task should achieve.

## Background / why now

Why this task exists.

Mention the current pain, drift, missing behavior, or opportunity.

## Problem statement

What is wrong or incomplete today?

Be specific enough that we can later judge whether the task solved the problem.

## Smallest useful slice

Describe the smallest valuable version of the task.

This should be narrow enough to execute without redesigning the whole system.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `path/to/file`
- `path/to/directory/`

## Write scope

- `path/to/file`
- `path/to/directory/`

## Requirements

- The execution prompt MUST start with `/hermetic-coding-orchestrator` to
  explicitly invoke the custom skill.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near the
  beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration, not by task
  prompt text.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking
  OpenCode.

Add task-specific requirements below.

## Non-goals

- No unrelated refactors.
- No broad lifecycle changes.
- No dashboard/observability/infra work unless this task is specifically about that.
- No changes outside write scope unless verification proves it is necessary.

## Open questions

None.

## Verification

Run:

```bash
git status --short --branch
git diff --stat
```

Add task-specific checks here.

## Accept criteria

- The requested change is implemented.
- The diff stays within write scope.
- Verification commands pass or failures are explained.
- No unrelated files are modified.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-xxxx-short-title.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- use or create a task-specific worktree and branch
- do not switch the main planning worktree away from main
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME, OPENCODE_XDG_DATA_HOME, and AGENTOPS_EXECUTOR_MODEL
- use the runner-configured executor model
- do not silently fallback to another model
- do not commit
- independently verify the result

Return:
Plan:
Implementation:
Verification:
Review:
Changed files:
Uncertainty:
```

## Return format

Expected executor return format:

```text
Plan:
...

Implementation:
...

Verification:
...

Review:
accept / revise / revert / no-op / blocked

Changed files:
...

Uncertainty:
...
```

## Notes

Free-form notes, links, related task IDs, or reasoning that should not be lost.
