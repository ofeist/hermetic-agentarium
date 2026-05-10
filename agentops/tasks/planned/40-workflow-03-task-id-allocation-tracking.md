# workflow-04 — Add task ID allocation tracking

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

Harness: TBD.
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- `agentops/tasks/ready/`
- `agentops/tasks/running/`
- `agentops/tasks/review/`
- `agentops/tasks/done/`
- optionally `agentops/tasks/planned/` if the promotion behavior decides planned should be scanned defensively
- existing task lifecycle helper scripts
- relevant AgentOps workflow documentation

## Write scope

- one helper script, likely `scripts/next-agentops-task-id.sh`
- minimal docs update only if needed to document task ID allocation
- minimal tests or shell syntax checks if present

## Requirements

The helper should:

- scan all authoritative lifecycle folders that can contain `TASK-XXXX` files
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
```

## Non-goals

- Do not add a full ledger unless scanning is explicitly judged insufficient.
- Do not implement automatic planned-to-ready promotion.
- Do not implement locking across machines.
- Do not introduce a Jira-like task database.
- Do not rename existing tasks.

## Open questions

- Should `planned/` also be scanned for accidental `TASK-XXXX` files?
- Should a later `promote-agentops-task.sh` reserve the ID atomically?
- Is a simple text ledger worth it for single-user use?

## Verification

```bash
git status --short --branch
bash -n scripts/next-agentops-task-id.sh
scripts/next-agentops-task-id.sh
git diff --stat
```

When promoted, add a small fixture test if the repo already has a suitable temporary directory helper.

## Accept criteria

TBD during promotion.

## Promotion decision

Decision: keep_planned.

Reason:
The lifecycle directories and filename matching rule are not yet fully confirmed, especially whether `planned/` should be scanned defensively.

Next action:
Decide the scan set and matching rule, then promote.

## Promotion criteria

Promote to `ready` when:

- the lifecycle directories to scan are confirmed
- the filename matching rule is confirmed
- the helper name is confirmed
- behavior for an empty lifecycle is defined
- read/write scope is confirmed

## Hermes/coder collection prompt

TBD during promotion.

## Return format

TBD during promotion.

## Notes

Keep this read-only first. ID reservation and promotion automation can be follow-up tasks if scanning proves insufficient.
