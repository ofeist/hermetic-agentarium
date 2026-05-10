# TASK-0082 — Reconcile canonical Hermes/coder execution prompt

## Status

ready

## Goal

Reconcile the existing canonical Hermes/coder execution prompt variants and establish one repo-owned source of truth.

## Background / why now

`IDEAS.md` explicitly calls out documenting the canonical Hermes/coder minimal execution prompt.

A canonical prompt section already exists in `skills/hermetic-coding-orchestrator/SKILL.md` under `### Canonical ready task invocation prompt`.

A different variant also exists in `agentops/templates/PLANNED-TASK-TEMPLATE.md` and `agentops/templates/READY-TASK-TEMPLATE.md` under `## Hermes/coder collection prompt`.

Those variants disagree on small but important details, including the imperative verb, branch/worktree wording, and whether the prompt includes a trailer for task-specific paths, verification commands, or constraints.

The gap is drift between existing sources, not absence of a prompt.

## Problem statement

The canonical Hermes/coder execution prompt currently exists in more than one repo-owned location. Because the variants are not identical, humans and helper scripts can copy different versions of the execution contract.

AgentOps needs one canonical source of truth, with other locations referencing it or intentionally mirroring it without introducing drift.

## Smallest useful slice

Choose one canonical direction and remove the duplicate prompt drift.

Preferred direction: keep `skills/hermetic-coding-orchestrator/SKILL.md` as the canonical source for the execution prompt, and update task templates so their `## Hermes/coder collection prompt` sections reference that canonical prompt instead of carrying a separate full variant.

Do not add a third prompt template file in this slice.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/templates/PLANNED-TASK-TEMPLATE.md`
- `agentops/templates/READY-TASK-TEMPLATE.md`
- `profiles/coder/SOUL.md` only to confirm it is not the right source of truth for the full prompt
- relevant AgentOps workflow documentation if needed

## Write scope

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/templates/PLANNED-TASK-TEMPLATE.md`
- `agentops/templates/READY-TASK-TEMPLATE.md`
- minimal documentation update if the canonical source-of-truth decision needs to be explained

Do not add a new standalone prompt template file in this slice unless inspection proves both existing locations are unsuitable.

## Requirements

- Acknowledge that the canonical prompt already exists in multiple places.
- Choose one source of truth for the canonical Hermes/coder execution prompt.
- Prefer `skills/hermetic-coding-orchestrator/SKILL.md` as the canonical source unless inspection shows a better reason to make templates canonical.
- Update the non-canonical location so it references the canonical source instead of embedding a drifting full prompt variant.
- Preserve the execution invariants:
  - `/hermetic-coding-orchestrator`
  - ready task path
  - create or switch to task-specific branch/worktree as defined by the workflow
  - do not run executor work on `main`
  - preserve `OPENCODE_XDG_CONFIG_HOME`, `OPENCODE_XDG_DATA_HOME`, and `AGENTOPS_EXECUTOR_MODEL`
  - use the runner-configured executor model
  - no silent fallback
  - do not commit
  - independently verify
  - standard return sections
- Avoid creating a third source of truth.

## Non-goals

- no new helper script yet
- no executor behavior change
- no model routing policy change
- no automatic task execution
- no new standalone prompt-template file unless explicitly justified
- no broad rewrite of `SOUL.md`

## Open questions

None.

Resolved:
- `skills/hermetic-coding-orchestrator/SKILL.md` remains the canonical prompt
  source; templates should reference it instead of embedding drifting variants.
- Canonical wording should keep model guidance at runner-configured model via
  `AGENTOPS_EXECUTOR_MODEL` and should not add task-local model overrides.

## Verification

```bash
git status --short --branch
test "$(grep -c '^### Canonical ready task invocation prompt' skills/hermetic-coding-orchestrator/SKILL.md)" = "1"
grep -n 'Canonical ready task invocation prompt\|Hermes/coder collection prompt' agentops/templates/*.md
git diff --stat
```

When promoted, verification should confirm that the canonical prompt heading appears exactly once in the chosen source-of-truth file and that the other location references it rather than carrying a second full variant.

## Accept criteria

- Exactly one canonical prompt source remains.
- Template prompt sections do not silently diverge from the canonical source.
- All execution invariants remain represented in the canonical source.
- No third source of truth is introduced.

## Promotion decision

Decision: promote_to_ready.

Reason:
The source-of-truth direction is now explicit and scoped: `SKILL.md` canonical,
templates refer to it.

Next action:
Implement reconciliation and verify that only one canonical full prompt remains.

## Promotion criteria

Promote to ready when:

- the canonical source-of-truth direction is chosen
- the exact files to edit are confirmed
- the expected reference wording for the non-canonical location is known
- the executor/model wording is decided

## Hermes/coder collection prompt

/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0082-canonical-hermes-coder-execution-prompt.md

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

## Return format

Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:

## Notes

This task is about reconciliation, not initial documentation.

The prompt convention is already explicit in more than one place; the problem is drift between existing variants.

The executor-model wording question is related to prompt content, not source-of-truth location. If that decision becomes non-trivial during promotion, split it into a separate task rather than expanding this reconciliation slice.
