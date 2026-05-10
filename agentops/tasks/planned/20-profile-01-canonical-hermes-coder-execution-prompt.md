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

The section should include:

- `/hermetic-coding-orchestrator`
- ready task path
- create/switch task branch
- do not run executor work on `main`
- preserve `OPENCODE_XDG_CONFIG_HOME`, `OPENCODE_XDG_DATA_HOME`, and `AGENTOPS_EXECUTOR_MODEL`
- no silent model fallback
- do not commit
- independently verify
- standard return sections

## Non-goals

- no new helper script yet
- no executor behavior change
- no model routing policy change
- no automatic task execution

## Open questions

- Should the canonical prompt live in `SOUL.md`, `SKILL.md`, or a template file referenced by both?
- Should the prompt mention the runner-configured model or require task metadata?

## Promotion criteria

Promote to ready when the target file is chosen and the exact section title is known.

## Suggested verification

```bash
grep -R "hermetic-coding-orchestrator" profiles skills
```
