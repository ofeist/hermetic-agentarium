# TASK-0074 — Add planned-to-ready promotion policy

## Status

done

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

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `agentops/tasks/ready/TASK-0074-planned-to-ready-promotion-policy.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/templates/READY-TASK-TEMPLATE.md`, if present
- `agentops/USAGE.md`, if present

## Write scope

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/USAGE.md`, only if it already contains task lifecycle workflow
  notes

## Requirements

- Document planned-to-ready promotion as a minimal mechanical transformation.
- State that ready-shaped planned tasks should not be rewritten wholesale during
  promotion.
- Preserve wording and section structure unless a section is incomplete,
  incorrect, still marked `TBD`, or explicitly planning-only.
- Prefer preserving section names and order from the planned task when they
  already match the ready-shaped template.
- Explain that large rewrites require an explicit reason.
- If a promotion changes more than expected, the agent should call it out in the
  review instead of silently treating it as normal.
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

None.

Resolved:

- The policy should live first in
  `skills/hermetic-coding-orchestrator/SKILL.md`, because this is agent
  behavior.
- It should not wait for `templates-01`; the drift already affects current
  promotions.
- A later task may add `scripts/promote-agentops-task.sh` to enforce the policy
  mechanically.
- A later template task may mirror the same rule in
  `agentops/templates/PLANNED-TASK-TEMPLATE.md`.

## Verification

Run:

```bash
git status --short --branch
git diff --stat
git diff -- skills/hermetic-coding-orchestrator/SKILL.md
```

If Markdown checks exist, use them. Do not invent a new checker for this
policy-only task.

## Accept criteria

- The promotion policy is documented in the agreed durable location.
- The policy explicitly prefers minimal mechanical promotion.
- The policy says to preserve existing planned-task wording and structure unless
  a section is incomplete, incorrect, still marked `TBD`, or explicitly
  planning-only.
- The policy says large unexpected promotion diffs should be called out in
  review.
- The policy explains when a larger rewrite is acceptable.
- Diff stays within write scope.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0074-planned-to-ready-promotion-policy.md

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

This task exists because chat instructions are transient. The promotion
invariant needs to live in the repo so future agents preserve it.
