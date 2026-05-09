# TASK-0078 — Add planned task template

## Status

planned

## Goal

Add a planned task template that stays structurally close to ready tasks, so
promotion from planned to ready is cheap and mechanical.

## Background / why now

The repo has a ready-task template, but no planned-task template. The first
planned-task batch showed that the planned format and ready format can drift
apart, forcing broad rewrites when promoting a task.

That wastes tokens, creates review noise, and makes promotion harder than it
needs to be.

## Problem statement

Planned tasks need room for uncertainty, but they should not use a completely
different shape from ready tasks.

A planned task should be the same basic contract as a ready task, with
execution-critical fields allowed to be `TBD` until promotion.

## Smallest useful slice

Add `agentops/templates/PLANNED-TASK-TEMPLATE.md` with a full planned-task
structure that mirrors ready-task execution fields while allowing unresolved
planning fields to remain `TBD`.

The template should document that promotion is mechanical:

- change `Status` from `planned` to `ready`
- replace `TBD` sections with concrete values
- resolve or remove open questions
- fill the Hermes/coder collection prompt only when ready
- move the file from `agentops/tasks/planned/` to `agentops/tasks/ready/`

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

- `agentops/templates/READY-TASK-TEMPLATE.md`
- `agentops/tasks/planned/TASK-0078-planned-task-template.md`
- `agentops/USAGE.md`

## Write scope

TBD

Likely candidates:

- `agentops/templates/PLANNED-TASK-TEMPLATE.md`
- `agentops/USAGE.md` only if a short note is needed

## Requirements

TBD

When ready, this task should require:

- Add `agentops/templates/PLANNED-TASK-TEMPLATE.md`.
- Use the planned/ready structure below.
- Keep the planned template structurally close to ready-task execution fields.
- Allow execution-critical fields to be `TBD` while task status is `planned`.
- Include promotion mechanics from planned to ready.
- Include a Hermes/coder collection prompt section that remains `TBD` until
  ready.
- Include a ready-state return format section that remains `TBD` until ready.
- Avoid changing lifecycle behavior.
- Avoid promoting existing planned tasks.

Suggested template content:

````markdown
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

---

# TASK-XXXX — Short task title

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
- create/switch to an appropriate task branch
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
````

## Non-goals

- No unrelated refactors.
- No broad lifecycle changes.
- No dashboard/observability/infra work.
- No changes to executor behavior.
- No lifecycle automation.
- No new task creation helper.
- No promotion of existing planned tasks.

## Open questions

- Should `agentops/USAGE.md` get a short note about the planned/ready promotion
  rule, or is the template enough for the first slice?
- Should a future helper create planned tasks from this template?

If these are resolved before promotion, write:

```text
None.
```

## Verification

TBD

Likely commands:

```bash
git status --short --branch
git diff --stat
test -f agentops/templates/PLANNED-TASK-TEMPLATE.md
```

Add markdown/rendering inspection if needed.

## Accept criteria

TBD

When ready, accept criteria should include:

- `agentops/templates/PLANNED-TASK-TEMPLATE.md` exists.
- The planned template uses the same core structure as ready tasks.
- Execution-critical fields may remain `TBD` only while status is `planned`.
- Promotion mechanics are documented.
- The Hermes/coder collection prompt is present but marked `TBD until ready`.
- Existing ready-task behavior is unchanged.
- Diff stays within write scope.

## Promotion decision

Decision: keep_planned

Reason:

The task now has a concrete proposed template, but read/write scope,
verification, and accept criteria should be finalized before it becomes
executor-ready.

Next action:

Promote this task to ready after deciding whether `agentops/USAGE.md` should be
included in write scope.

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

agentops/tasks/ready/TASK-0078-planned-task-template.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- create/switch to an appropriate task branch
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

The user suggested TASK-0073, but TASK-0073 through TASK-0077 are already used
for the observability task sequence. Keep this as TASK-0078 unless the task
sequence is explicitly renumbered.
