# agentops-xx-migrate-agentops-to-dot-agentops - Migrate AgentOps paths from `agentops/` to `.agentops/`

## Status

planned

## Goal

Plan a safe repository-wide migration from `agentops/` to `.agentops/` with
clear compatibility handling and low workflow disruption.

## Background / why now

A dot-prefixed directory may better communicate that AgentOps lifecycle data is
operational metadata rather than primary product code/content.

Current workflow, helpers, and docs are tightly coupled to `agentops/` paths.

## Problem statement

A direct rename can break helper scripts, docs, task references, and existing
task artifacts unless migration is staged and consistently applied.

## Smallest useful slice

Design a staged migration:

- phase 1: inventory every hardcoded `agentops/` path
- phase 2: introduce compatibility handling (or bulk atomic cutover strategy)
- phase 3: migrate scripts/docs/templates and validate lifecycle checks
- phase 4: remove compatibility layer if one was used

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `agentops/` directory tree
- `scripts/` helpers
- `docs/` AgentOps docs
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `.gitignore`

## Write scope

TBD

Likely candidates:

- `scripts/*.sh` that reference `agentops/`
- `docs/*.md` with lifecycle path references
- templates and planned/ready task references
- directory move from `agentops/` to `.agentops/` when ready

## Requirements

TBD

Candidate requirements:

- no data loss in lifecycle folders/tasks/results
- lifecycle helpers continue to function
- migration path is reversible or checkpointed
- docs and templates are updated consistently

## Non-goals

- No skill rename work in this slice.
- No observability feature redesign.
- No unrelated refactors.

## Open questions

- Should migration use temporary dual-path compatibility or one-shot atomic move?
- What is the exact cutover/rollback plan?
- Should historical references remain unchanged in completed task/result files?

## Promotion decision

Decision: keep_planned

Reason:
This is a cross-cutting migration and needs explicit inventory and cutover
strategy before execution.

Next action:
Prepare a concrete migration plan with exact path impacts and verification.

## Promotion criteria

- path inventory is complete
- migration strategy and rollback are explicit
- write scope is concrete
- verification commands are concrete

## Verification

```bash
git status --short --branch
git diff --stat
```

## Accept criteria

- Migration plan is complete and staged.
- All high-impact path dependencies are identified.
- Risk controls (cutover + rollback) are explicit.
