# Planned Task Template

Use this template for **planned but not-yet-ready** AgentOps tasks.

Core idea:

```text
planned = same structure as ready, but some fields may be TBD
ready = same structure, all execution-critical fields filled
```

This keeps promotion cheap and mechanical:

- change `Status` from `planned` to `ready`
- replace `TBD` sections with concrete values
- resolve or remove open questions
- fill the Hermes/coder collection prompt only when ready
- move the file from `agentops/tasks/planned/` to `agentops/tasks/ready/`
- assign a `TASK-XXXX` ID only when promoting to `ready/`

---

# <area>-<local-sequence>-<short-slug> — Short task title

## Status

planned

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

This should be narrow enough to become executor-ready without redesigning the
whole system.

## Executor

Harness: TBD
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

Notes:

- Fill this in only when the task becomes ready.
- Keep model selection out of the task body unless there is a specific reason.

## Read scope

TBD

Likely candidates:

- `path/to/file`
- `path/to/directory/`

## Write scope

TBD

Likely candidates:

- `path/to/file`
- `path/to/directory/`

## Requirements

TBD

When ready, this section should contain concrete implementation requirements.

Possible planning notes:

- requirement idea 1
- requirement idea 2
- requirement idea 3

## Non-goals

- No unrelated refactors.
- No broad lifecycle changes.
- No dashboard/observability/infra work unless this task is specifically about that.
- No changes outside write scope unless verification proves it is necessary.

## Open questions

- Question 1?
- Question 2?
- Question 3?

If there are no open questions, write:

```text
None.
```

## Verification

TBD

Likely commands:

```bash
git status --short --branch
git diff --stat
```

Add task-specific checks later.

## Accept criteria

TBD

When ready, this section should state exactly what must be true to accept the
result.

Example:

- Change is limited to write scope.
- Verification commands pass.
- Existing behavior is preserved unless explicitly changed.
- The new behavior is documented or covered by a check.

## Promotion decision

Decision: promote_to_ready / keep_planned / blocked / discard

Reason:

Next action:

## Promotion criteria

This task can be promoted to ready when:

- read scope is known
- write scope is known
- open questions are resolved or explicitly marked as blockers
- requirements are concrete
- verification commands are known
- accept criteria are concrete
- non-goals are clear

## Hermes/coder collection prompt

TBD until ready.

When ready, use this shape:

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-XXXX-short-title.md

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

TBD until ready.

When ready, expected executor return format:

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

Assign a TASK-XXXX ID only when promoting to `ready/`.
