# workflow-03 — Add task ID allocation tracking

## Status

planned

## Goal

Make assignment of the next `TASK-XXXX` ID explicit during planned-to-ready promotion.

## Background / why now

Planned tasks intentionally use soft local names such as `workflow-03-something.md`. The authoritative `TASK-XXXX` name appears only when the task becomes ready.

`IDEAS.md` notes that inferring the next task ID by scanning lifecycle folders can race with concurrent work or miss files in another lifecycle directory.

## Problem statement

Task ID allocation is currently implicit. That makes promotion fragile once more than one agent or operator can create tasks.

## Smallest useful slice

Add one small helper that scans AgentOps lifecycle folders and prints the next available `TASK-XXXX` ID.

## Executor

Harness: TBD (default in this repo: OpenCode).
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- `agentops/tasks/ready/`
- `agentops/tasks/running/`
- `agentops/tasks/review/`
- `agentops/tasks/done/`
- `agentops/tasks/planned/` (scanned defensively for accidental `TASK-XXXX-*.md` files; soft-named planned files do not allocate IDs)
- existing task lifecycle helper scripts
- relevant AgentOps workflow documentation

## Write scope

- one helper script, likely `scripts/next-agentops-task-id.sh`
- minimal docs update only if needed to document task ID allocation
- minimal tests or shell syntax checks if present

## Requirements

The helper should:

- scan all authoritative lifecycle folders that can contain `TASK-XXXX` files
- also scan `agentops/tasks/planned/` defensively for accidental `TASK-XXXX-*.md` files, while treating soft-named planned files (`<area>-<sequence>-<slug>.md`) as non-authoritative for ID allocation
- identify existing task IDs by filename
- print the next available `TASK-XXXX` ID
- avoid modifying files
- avoid reserving or allocating the ID persistently in this slice unless explicitly promoted that way

Initial lifecycle folders to scan:

```text
agentops/tasks/ready/
agentops/tasks/running/
agentops/tasks/review/
agentops/tasks/done/
agentops/tasks/planned/   # defensive only
```

## Non-goals

- Do not add a full ledger unless scanning is explicitly judged insufficient.
- Do not implement automatic planned-to-ready promotion.
- Do not implement locking across machines.
- Do not introduce a Jira-like task database.
- Do not rename existing tasks.

## Open questions

Resolved:
- `planned/` will be scanned defensively for accidental `TASK-XXXX-*.md` files. Soft-named planned files such as `<area>-<sequence>-<slug>.md` do not allocate task IDs. This reduces collision risk without changing the meaning of planned/.

Deferred:
- Atomic reservation belongs in a later promotion helper task.
- Ledger is out of scope unless scanning proves insufficient.

## Promotion decision

Decision: keep_planned.

Reason:
Lifecycle directories to scan are now decided (including defensive planned/ scan). Remaining blockers: confirm the filename matching rule, lock the helper name, and define behavior for an empty lifecycle.

Next action:
Lock the filename matching rule, confirm the helper name, define empty-lifecycle behavior, then promote.

## Promotion criteria

Promote to `ready` when:

- the lifecycle directories to scan are confirmed
- the filename matching rule is confirmed
- the helper name is confirmed
- behavior for an empty lifecycle is defined
- read/write scope is confirmed

## Verification

```bash
git status --short --branch
bash -n scripts/next-agentops-task-id.sh
scripts/next-agentops-task-id.sh
[[ "$(scripts/next-agentops-task-id.sh)" =~ ^TASK-[0-9]{4}$ ]]
git diff --stat
```

When promoted, add a small fixture test if the repo already has a suitable temporary directory helper.

## Accept criteria

TBD during promotion.

## Hermes/coder collection prompt

TBD during promotion.

When ready, use the canonical Hermes/coder collection prompt shape from the planned/ready task template, with the concrete ready task path.

## Return format

TBD during promotion.

When ready, use the standard AgentOps return format:

```text
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
```

## Notes

Keep this read-only first. ID reservation and promotion automation can be follow-up tasks if scanning proves insufficient.
