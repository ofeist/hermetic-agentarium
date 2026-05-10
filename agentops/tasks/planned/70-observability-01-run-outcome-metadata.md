# observability-02 — Add AgentOps run outcome metadata

## Status

planned

## Goal

Record a small post-review outcome summary for each AgentOps executor run, so run cost/activity can be connected to actual value.

## Background / why now

The existing run artifacts capture activity signals such as prompt size, duration, stdout/stderr, and exit code. `IDEAS.md` notes that these show activity but not whether the run produced useful value.

## Problem statement

A long or expensive executor run may be accepted, rejected, revised, blocked, or produce no useful diff. Without outcome metadata, observability cannot separate useful work from waste.

## Smallest useful slice

Extend the review or submission flow to write a small local outcome file for one executor run after review, without parsing raw logs or judging quality automatically.

## Executor

Harness: TBD.
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- `.agentops-runs/` contract documentation
- executor run capture wrapper
- review/submission helper scripts
- run summary helper script, if present
- debugging/audit documentation

## Write scope

- one review or submission helper script, once selected
- optional docs update for the outcome metadata contract
- local-only `.agentops-runs/<run-id>/outcome.txt` fixture or example only if safe and gitignored

## Requirements

Candidate output file:

```text
.agentops-runs/<run-id>/outcome.txt
```

Candidate fields:

```text
decision=accept|revise|revert|no-op|blocked
changed_files_count=<n>
diff_bytes=<n>
diff_stat_lines=<n>
verification_exit_code=<n>
```

The implementation should:

- keep outcome metadata local unless a later safe summary explicitly includes it
- avoid raw log parsing
- avoid automatic quality judgment
- make blocked and no-op runs representable
- preserve the existing `.agentops-runs/` local-only boundary

## Non-goals

- Do not build a dashboard.
- Do not add token accounting.
- Do not parse raw logs.
- Do not implement automatic quality judgment.
- Do not add Prometheus export.
- Do not commit raw `.agentops-runs/` logs.

## Open questions

- Which script knows the final decision and should write the outcome?
- Should outcome metadata update `metadata.txt` or live in a separate file?
- How should blocked runs with no diff be represented?

## Verification

```bash
git status --short --branch
find .agentops-runs -maxdepth 2 -name outcome.txt -print 2>/dev/null || true
git diff --stat
```

When promoted, add the smallest fixture or dry-run check that proves the selected script writes the selected outcome format.

## Accept criteria

TBD during promotion.

## Promotion decision

Decision: keep_planned.

Reason:
The owning script and exact file format are not yet selected. Promoting now would lock in where outcome state belongs.

Next action:
Decide the owning script and whether outcome metadata lives in `metadata.txt` or a separate `outcome.txt` file, then promote.

## Promotion criteria

Promote to `ready` when:

- the owning script is selected
- the outcome file format is selected
- blocked/no-op representation is defined
- read/write scope is confirmed

## Hermes/coder collection prompt

TBD during promotion.

## Return format

TBD during promotion.

## Notes

This task is about connecting executor activity to review value. Keep it local, small, and safe.
