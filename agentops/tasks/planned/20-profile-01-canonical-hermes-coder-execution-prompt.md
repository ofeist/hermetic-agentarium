# profile-01 — Canonical Hermes/coder execution prompt

## Status

planned

## Goal

Document the canonical minimal prompt used to start Hermes/coder on an AgentOps ready task, so humans and helper scripts stop reconstructing it manually.

## Background / why now

`IDEAS.md` explicitly calls out documenting the canonical Hermes/coder minimal execution prompt in `SOUL` or `SKILL`.

The workflow already depends on several non-obvious invariants: invoke the Hermetic skill, do not run executor work on `main`, preserve OpenCode runtime env vars, do not fallback models, do not commit, and independently verify.

## Problem statement

Right now the prompt contract exists partly in memory, partly in ready task files, and partly in profile/skill text. That creates drift and makes every manual copy/paste a chance to miss one workflow invariant.

## Smallest useful slice

Add a short canonical section to the appropriate repo-owned source of truth, probably `profiles/coder/SOUL.md` or `skills/hermetic-coding-orchestrator/SKILL.md`, containing the minimal execution prompt shape.

## Executor

Harness: TBD.
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- `profiles/coder/SOUL.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- existing AgentOps ready task files that contain Hermes/coder execution prompts
- relevant workflow documentation, if present

## Write scope

- one chosen repo-owned source of truth, likely one of:
  - `profiles/coder/SOUL.md`
  - `skills/hermetic-coding-orchestrator/SKILL.md`
  - a small template file referenced by one or both
- minimal documentation update only if needed to point humans to the canonical prompt

## Requirements

The canonical prompt section should include:

- `/hermetic-coding-orchestrator`
- ready task path placeholder
- create or switch to a task-specific branch or worktree
- do not run executor work on `main`
- preserve `OPENCODE_XDG_CONFIG_HOME`, `OPENCODE_XDG_DATA_HOME`, and `AGENTOPS_EXECUTOR_MODEL`
- use the runner-configured executor model
- do not silently fallback to another model
- do not commit
- independently verify the result
- standard return sections

## Non-goals

- Do not add a new helper script in this slice.
- Do not change executor behavior.
- Do not change model routing policy.
- Do not add automatic task execution.
- Do not solve the whole AgentOps prompt-generation workflow.

## Open questions

- Should the canonical prompt live in `SOUL.md`, `SKILL.md`, or a template file referenced by both?
- Should the prompt mention only the runner-configured model, or should it also require task metadata to specify the model?

## Verification

```bash
git status --short --branch
grep -R "hermetic-coding-orchestrator" profiles skills
git diff --stat
```

When promoted, add the smallest useful verification that proves the canonical prompt text is discoverable from the chosen source of truth.

## Accept criteria

TBD during promotion.

## Promotion decision

Decision: keep_planned.

Reason:
The target source of truth is not yet decided. Promoting now would lock in whether the canonical prompt belongs in `SOUL.md`, `SKILL.md`, or a shared template file.

Next action:
Decide the target file and exact section title, then promote.

## Promotion criteria

Promote to `ready` when:

- the target file is chosen
- the exact section title is known
- the expected prompt content is bounded enough for a small documentation-only change
- read/write scope is confirmed

## Hermes/coder collection prompt

TBD during promotion.

## Return format

TBD during promotion.

## Notes

This task is about making an existing manual prompt convention explicit. Keep it small and documentation-focused.
