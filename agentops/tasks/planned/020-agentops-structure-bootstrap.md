# agentops-structure-bootstrap - Bootstrap/check repo-local AgentOps lifecycle structure

## Status

planned

## Goal

Define a narrow bootstrap/check slice for repo-local AgentOps lifecycle
structure after the canonical repo-local path model is decided.

## Background / why now

`agentops-structure-00-plan-dot-agentops-repo-migration` should decide the
canonical repo-local structure first. Bootstrap should come after that decision
so we do not build a scaffolder for paths that are immediately migrated.

## Problem statement

Fresh repositories may miss lifecycle directories/placeholders, and manual setup
is error-prone. But bootstrap must align with the final repo-local path model.

## Smallest useful slice

Create/check lifecycle folders and placeholders for the chosen repo-local
layout, with idempotent behavior and clear diagnostics.

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- output of `agentops-structure-00-plan-dot-agentops-repo-migration`
- current lifecycle directories/templates
- `scripts/check-agentops-lifecycle.sh`
- `agentops/IDEAS.md` bootstrap note

## Write scope

TBD

Likely candidates:

- new helper under `scripts/` for bootstrap/check
- `.gitkeep` files in lifecycle directories
- docs updates for bootstrap usage

## Requirements

TBD

Candidate requirements:

- idempotent create/check behavior
- clear error messages when required paths are missing
- no dependency on user-level `$HOME/.agentops` design

## Non-goals

- No user-level AgentOps home design in this task.
- No skill rename.
- No observability packaging changes.
- No broad workflow redesign.

## Open questions

- Should bootstrap be strict (fail on drift) or permissive (repair by default)?
- Should templates directory be seeded or only validated?

## Promotion decision

Decision: keep_planned

Reason:
Should follow structure planning (`agentops-structure-00`) so it targets the
canonical repo-local path layout.

Next action:
Promote after structure planning outcome is concrete.

## Promotion criteria

- canonical repo-local path layout is decided
- bootstrap behavior (strict vs repair) is chosen
- write scope is concrete
- verification commands are concrete

## Verification

```bash
git status --short --branch
git diff --stat
```

## Accept criteria

- bootstrap/check behavior is clear and idempotent
- scope stays repo-local
- no coupling to user-level AgentOps home design
