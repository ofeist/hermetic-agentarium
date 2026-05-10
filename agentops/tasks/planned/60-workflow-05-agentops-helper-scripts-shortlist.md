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

Create a planning note or update workflow documentation with the first 3 helper priorities.

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

## Non-goals

- no implementation of all helpers in one task
- no background scheduler
- no hidden review decisions
- no dashboard

## Open questions

- Should helpers live as separate scripts or subcommands under one `agentops` wrapper?
- Which helper should own moving to `review/`?
- Should review packet generation be required before acceptance?

## Promotion criteria

Promote to ready when the target doc file and final first-three helper list are chosen.

## Suggested verification

```bash
grep -R "check-agentops-lifecycle\|render-review-packet\|review" docs agentops scripts || true
```
