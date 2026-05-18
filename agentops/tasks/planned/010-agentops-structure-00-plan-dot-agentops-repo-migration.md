# agentops-structure-00-plan-dot-agentops-repo-migration - Plan repo-local migration from `agentops/` to `.agentops/`

## Status

planned

## Goal

Produce a planning/inventory slice for a safe repository-wide migration from
`agentops/` to `.agentops/`, including cutover strategy and rollback, without
moving directories yet.

## Background / why now

A dot-prefixed directory may better communicate that AgentOps lifecycle data is
operational metadata rather than primary product code/content.

Current workflow, helpers, and docs are tightly coupled to `agentops/` paths.

## Problem statement

A direct rename can break helper scripts, docs, task references, and existing
task artifacts unless migration is staged and consistently applied.

## Smallest useful slice

Design a staged migration plan:

- phase 1: inventory every hardcoded `agentops/` path
- phase 2: decide compatibility-based vs atomic cutover
- phase 3: decide handling for historical `done/` and `results/` files
- phase 4: define verification and rollback

Do not move directories in this task.

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

Planning output only:

- `agentops/tasks/planned/010-agentops-structure-00-plan-dot-agentops-repo-migration.md`
- optional: `docs/AGENTOPS-PATH-MIGRATION.md`

Do not modify runtime helper scripts, lifecycle helpers, templates, or move
directories in this slice.

## Requirements

- Do not execute path migration actions in this task.
- Inventory scripts, docs, templates, skills, task files, result files, and
  path-sensitive checks that reference `agentops/`.
- Explicitly choose or recommend atomic cutover vs temporary dual-path
  compatibility.
- Explicitly decide how historical `done/` and `results/` files should be
  handled.
- Define concrete verification commands for the future migration task.
- Define rollback strategy for the future migration task.

## Expected planning output

The executor must produce a migration plan that answers:

- where all `agentops/` path references exist
- which references are runtime-critical vs historical/docs-only
- whether the future migration should be atomic or compatibility-based
- whether historical done/result files should remain unchanged or be rewritten
- exact future migration steps
- exact verification commands
- rollback plan

## Non-goals

- No skill rename work in this slice.
- No observability feature redesign.
- No unrelated refactors.
- Do not move `agentops/` to `.agentops/` in this task.
- Do not modify runtime helper behavior in this task.
- Do not rewrite lifecycle paths yet.

## Open questions

- Should migration use temporary dual-path compatibility or one-shot atomic move?
- What is the exact cutover/rollback plan?
- Should historical references remain unchanged in completed task/result files?

## Promotion decision

Decision: keep_planned

Reason:
This is a cross-cutting migration and should start as planning/inventory only
before any path movement is attempted.

Next action:
Prepare a concrete migration plan with exact path impacts, cutover strategy,
historical-file handling, verification, and rollback.

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
