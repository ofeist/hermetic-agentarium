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

Extend the review or submission flow to write a small local outcome file, for example:

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

## Non-goals

- no dashboard
- no token accounting
- no raw log parsing
- no automatic quality judgment
- no Prometheus export yet

## Open questions

- Which script knows the final decision and should write the outcome?
- Should outcome metadata update `metadata.txt` or live in a separate file?
- How should blocked runs with no diff be represented?

## Promotion criteria

Promote to ready when the owning script and file format are selected.

## Suggested verification

```bash
find .agentops-runs -maxdepth 2 -name outcome.txt -print 2>/dev/null || true
```
