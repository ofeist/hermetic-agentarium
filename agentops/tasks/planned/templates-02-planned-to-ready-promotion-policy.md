# templates-02 — Add planned-to-ready promotion policy

## Status

planned

## Goal

Document and/or encode that planned-to-ready promotion should preserve existing
task content and only fill missing execution-critical fields.

## Background / why now

During promotion of `observability-01` to `TASK-0073`, the planned task was
already ready-shaped, but the promotion still rewrote a large part of the file:

- 83 insertions
- 139 deletions
- rename similarity 51%

That is too much churn for a planned-to-ready promotion.

Planned tasks are now intended to be ready-shaped. Promotion should be a
mechanical transformation, not a content rewrite, unless the user explicitly
asks for a rewrite.

## Problem statement

The repo has started to use ready-shaped planned tasks, but the promotion rule
is not durable enough. Without a written policy or helper, future promotions may
rewrite task bodies unnecessarily, wasting tokens, creating noisy diffs, and
risking loss of planning context.

## Smallest useful slice

Add a minimal promotion policy to the right durable location so future agents
preserve existing planned-task content during promotion.

The policy should say that planned-to-ready promotion normally does only these
mechanical edits:

- move file from `agentops/tasks/planned/` to `agentops/tasks/ready/`
- assign the next `TASK-XXXX` ID
- update the top-level title and file path
- change `Status` from `planned` to `ready`
- replace remaining `TBD` fields
- resolve or remove open questions
- update task path references
- add or finalize the Hermes/coder prompt only if needed

It should also say that promotion must preserve existing document structure and
wording unless a section is incomplete, incorrect, still marked `TBD`, or
explicitly planning-only.

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
- `agentops/tasks/planned/templates-01-planned-task-template.md`
- `agentops/tasks/planned/templates-02-planned-to-ready-promotion-policy.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/USAGE.md`

## Write scope

TBD

Likely candidates:

- `agentops/templates/PLANNED-TASK-TEMPLATE.md`, if it exists after
  `templates-01`
- `agentops/templates/READY-TASK-TEMPLATE.md`, only if a short note belongs
  there
- `skills/hermetic-coding-orchestrator/SKILL.md`, if the policy should become
  agent behavior
- `agentops/USAGE.md`, if the workflow doc should own the rule

## Requirements

TBD

When ready, this task should require:

- Document planned-to-ready promotion as a minimal mechanical transformation.
- State that ready-shaped planned tasks should not be rewritten wholesale during
  promotion.
- Preserve wording and section structure unless a section is incomplete,
  incorrect, still marked `TBD`, or explicitly planning-only.
- Explain that large rewrites require an explicit reason.
- Keep the policy short enough that agents can follow it.
- Do not implement a promotion helper in this task unless explicitly added to
  scope.

## Non-goals

- No broad lifecycle redesign.
- No implementation task execution.
- No promotion of existing planned tasks.
- No automatic helper unless the ready task explicitly includes one.
- No changes to executor behavior.

## Open questions

- Should this policy live first in `agentops/USAGE.md`, the planned-task
  template, the orchestrator skill, or all of them?
- Should this task wait for `templates-01` to create
  `agentops/templates/PLANNED-TASK-TEMPLATE.md`?
- Should a later task add `scripts/promote-agentops-task.sh` to enforce the
  policy mechanically?

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
```

Add doc/template checks when ready.

## Accept criteria

TBD

When ready, accept criteria should include:

- The promotion policy is documented in the agreed durable location.
- The policy explicitly prefers minimal mechanical promotion.
- The policy says to preserve existing planned-task wording and structure unless
  a section is incomplete, incorrect, still marked `TBD`, or explicitly
  planning-only.
- The policy explains when a larger rewrite is acceptable.
- Diff stays within write scope.

## Promotion decision

Decision: keep_planned

Reason:

The need is clear, but the durable location should be decided before promotion.
The strongest eventual location is likely the orchestrator skill plus the
planned-task template, with docs only if needed.

Next action:

Decide whether this should wait for `templates-01` or be promoted ahead of it
as a small policy-only task.

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

agentops/tasks/ready/TASK-XXXX-planned-to-ready-promotion-policy.md

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

This task exists because chat instructions are transient. The promotion
invariant needs to live in the repo so future agents preserve it.
