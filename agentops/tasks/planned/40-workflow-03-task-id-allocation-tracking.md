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

Add one small helper, probably:

```bash
scripts/next-agentops-task-id.sh
```

It should scan all lifecycle folders:

```text
agentops/tasks/ready/
agentops/tasks/running/
agentops/tasks/review/
agentops/tasks/done/
```

and print the next available `TASK-XXXX` ID.

## Non-goals

- no full ledger yet unless scanning proves insufficient
- no automatic promotion yet
- no locking across machines
- no Jira-like task database

## Open questions

- Should `planned/` also be scanned for accidental `TASK-XXXX` files?
- Should a later `promote-agentops-task.sh` reserve the ID atomically?
- Is a simple text ledger worth it for single-user use?

## Promotion criteria

Promote to ready when the lifecycle directories and filename matching rule are confirmed.

## Suggested verification

```bash
bash -n scripts/next-agentops-task-id.sh
scripts/next-agentops-task-id.sh
```
