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

TBD

Likely candidates (planning docs/notes only):

- `scripts/*.sh` that reference `agentops/`
- `docs/*.md` with lifecycle path references
- templates and planned/ready task references
- no directory move in this task

## Requirements

TBD

Candidate requirements:

- no path migration actions are executed in this task
- inventory includes scripts, docs, templates, and known path-sensitive checks
- migration strategy explicitly chooses atomic vs compatibility-based approach
- handling of historical `done/` and `results/` files is explicit
- verification and rollback are explicitly defined

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
