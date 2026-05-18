# agentops-structure-01-evaluate-user-level-agentops-home - Evaluate user-level AgentOps home model

## Status

planned

## Goal

Evaluate whether AgentOps task/runtime state should remain fully repo-local under
`.agentops/` (or `.agentops/` during migration), or whether some state should
live in a user-level home such as `$HOME/.agentops/`.

## Background / why now

The repo-local structure migration and bootstrap tasks focus on project-local
metadata. This task is a separate architecture decision about cross-repository
user-level runtime/state.

## Problem statement

Two concerns must be distinguished clearly:

- `repo/.agentops/` (or `repo/.agentops/`): project-local lifecycle metadata
- `$HOME/.agentops/`: user-level runtime/state across repositories

Without this distinction, future tooling can mix scope boundaries and create
confusing behavior.

## Smallest useful slice

Produce an architecture/design decision document that evaluates:

- what must remain repo-local
- what, if anything, should become user-level shared state
- migration/compatibility implications

No path migrations in this task.

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `agentops-structure-00` planned output
- `agentops-structure-bootstrap` planned scope
- current lifecycle/helper docs and scripts

## Write scope

TBD

Likely candidates:

- architecture/design note under docs or planned task artifacts
- cross-references in structure planning tasks

## Requirements

TBD

Candidate requirements:

- clearly separate project-local metadata from user-level runtime state
- compare operational tradeoffs: portability, reproducibility, isolation, UX
- define recommended default model and rationale

## Non-goals

- No filesystem path migration in this task.
- No bootstrap implementation in this task.
- No skill rename or observability packaging work.

## Open questions

- Should user-level state exist at all for AgentOps?
- If yes, what specific categories belong there?
- What compatibility model is needed if both repo-local and user-level state exist?

## Promotion decision

Decision: keep_planned

Reason:
Architecture-only decision; should follow initial repo-local structure planning.

Next action:
Promote when structure planning outputs are available and decision boundaries are
clear.

## Promotion criteria

- evaluation criteria are explicit
- artifact format for decision output is chosen
- write scope is concrete
- no migration actions are included

## Verification

```bash
git status --short --branch
git diff --stat
```

## Accept criteria

- architecture decision clearly separates repo-local and user-level concerns
- recommended model is explicit with tradeoffs
- no path migration or implementation work is performed in this slice
