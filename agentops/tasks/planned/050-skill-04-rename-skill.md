# skill-04-rename-skill - Rename skill to a shorter name after core packaging stabilizes

## Status

planned

## Goal

Define a safe migration plan for renaming the skill to a shorter name once the
core packaging flow is stable, while preserving backward compatibility during
transition.

## Background / why now

Current skill name is considered too long. A shorter name is desired, but the
new canonical name is not yet defined.

The current compatibility contract is widely referenced:

- skill name: `hermetic-coding-orchestrator`
- slash invocation: `/hermetic-coding-orchestrator`
- audit marker: `USING_SKILL: hermetic-coding-orchestrator`

## Problem statement

A rename touches prompts, docs, templates, and invocation habits. Doing it
without a compatibility window risks workflow breakage and traceability drift.

## Smallest useful slice

Decide target short name and execute a staged migration:

- phase 1: introduce new canonical name with compatibility alias
- phase 2: migrate templates/docs/generators
- phase 3: remove alias in a later cleanup

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/tasks/ready/TASK-0092-package-hermetic-orchestrator-skill.md`
- `agentops/templates/PLANNED-TASK-TEMPLATE.md`
- `agentops/templates/READY-TASK-TEMPLATE.md`
- `scripts/render-collection-prompt.sh`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `agentops/USAGE.md`

## Write scope

TBD

Likely candidates:

- skill directory and skill metadata
- prompt/template docs and generators
- install docs

## Requirements

TBD

Candidate requirements:

- define target short name before implementation
- preserve compatibility during transition window
- preserve auditability across old/new name references

## Non-goals

- No core packaging redesign.
- No observability packaging in this slice.
- No lifecycle workflow redesign.

## Open questions

- What is the final short skill name?
- How long should alias compatibility stay in place?
- Should both old and new audit markers be accepted temporarily?

## Promotion decision

Decision: keep_planned

Reason:
Target name is not yet defined.

Next action:
Decide canonical short name and migration policy, then promote to ready.

## Promotion criteria

- canonical short name is decided
- compatibility/alias strategy is explicit
- read/write scope is concrete
- verification commands are concrete

## Verification

```bash
git status --short --branch
git diff --stat
```

## Accept criteria

- Rename plan preserves compatibility and traceability.
- Scope is limited and migration is staged.
