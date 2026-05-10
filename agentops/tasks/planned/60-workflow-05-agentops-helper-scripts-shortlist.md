# workflow-05 — Define AgentOps helper scripts shortlist

## Status

planned

## Goal

Turn the broad helper-script idea into a prioritized, small shortlist of scripts that make the AgentOps lifecycle more deterministic.

## Background / why now

`IDEAS.md` lists several useful helpers: moving tasks to review, rendering review packets, requesting senior review, checking lifecycle consistency, summarizing run artifacts, preparing accept checklists, and optionally creating local review commits.

That list is useful, but too broad for direct implementation.

## Problem statement

Without a shortlist, helper development can become a grab bag. The next scripts should reinforce lifecycle correctness, not add platform complexity.

## Smallest useful slice

Create a planning note or update workflow documentation with the first three helper priorities and a short contract for each helper.

## Executor

Harness: TBD.
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- `IDEAS.md`
- AgentOps workflow documentation
- `scripts/`
- existing lifecycle helper scripts
- existing run summary/review helper scripts, if present

## Write scope

- one planning note or workflow documentation file
- no implementation of the helper scripts in this slice unless explicitly promoted that way

## Requirements

Suggested initial order:

1. `move-task-to-review` or `submit-agentops-task.sh` refinement
2. `check-agentops-lifecycle.sh`
3. `render-review-packet.sh`

For each helper, document:

- purpose
- input
- output
- lifecycle state touched
- whether it is read-only or mutating
- verification command

The shortlist should prefer lifecycle correctness and observability over platform complexity.

## Non-goals

- Do not implement all helpers in one task.
- Do not add a background scheduler.
- Do not add hidden review decisions.
- Do not build a dashboard.
- Do not introduce a large wrapper framework unless explicitly chosen later.

## Open questions

- Should helpers live as separate scripts or subcommands under one `agentops` wrapper?
- Which helper should own moving to `review/`?
- Should review packet generation be required before acceptance?
- Should the first-three helper list be exactly the suggested order or adjusted after inspecting existing scripts?

## Verification

```bash
git status --short --branch
grep -R "check-agentops-lifecycle\|render-review-packet\|review" docs agentops scripts || true
git diff --stat
```

If scripts are touched during promotion, also run the relevant `bash -n` checks.

## Accept criteria

TBD during promotion.

## Promotion decision

Decision: keep_planned.

Reason:
The target documentation file and final first-three helper list are not yet selected.

Next action:
Choose the target doc file and confirm the first-three helper list, then promote.

## Promotion criteria

Promote to `ready` when:

- the target doc file is chosen
- the final first-three helper list is chosen
- the output format for each helper contract is confirmed
- read/write scope is confirmed

## Hermes/coder collection prompt

TBD during promotion.

## Return format

TBD during promotion.

## Notes

This is a planning task, not an implementation batch. The output should make future helper tasks smaller and more deterministic.
