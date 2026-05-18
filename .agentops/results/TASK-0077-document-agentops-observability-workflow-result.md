# TASK-0077-document-agentops-observability-workflow Result

## Decision

accept

## Decision note

Accepted after parent review; docs-only observability guide is in scope, verification passed, and no blockers were found.

## Task file

agentops/tasks/done/TASK-0077-document-agentops-observability-workflow.md

## Summary

TASK-0077 added a focused operator guide for AgentOps run observability.

Changed files:

- `docs/RUN-OBSERVABILITY.md`
  - Added the focused guide for local run metadata, artifacts, logs, and
    token/time pressure.
  - Makes the recommended debugging flow the centerpiece: metadata first,
    quick signals, classify, surface-only first, logs last.
  - Covers slow run, high token/context pressure, executor failure, and
    suspicious review loop workflows.
  - Documents `.agentops-runs/<run-id>/` artifacts and prompt-safe metadata
    fields.
  - States that full logs are for humans/local debugging and model prompts
    should receive compact summaries by default.
- `docs/DEBUGGING.md`
  - Added a short cross-reference to `docs/RUN-OBSERVABILITY.md`.
- `docs/DOCUMENTATION-MAP.md`
  - Added `docs/RUN-OBSERVABILITY.md` to the setup/operator documentation map.
- `agentops/tasks/done/TASK-0077-document-agentops-observability-workflow.md`
  - Moved from ready to done by the AgentOps lifecycle helpers.
- `agentops/results/TASK-0077-document-agentops-observability-workflow-result.md`
  - Records this acceptance decision and verification evidence.

## Verification

Parent review verified:

```text
test -f docs/RUN-OBSERVABILITY.md
grep -n ".agentops-runs" docs/RUN-OBSERVABILITY.md
grep -n "Full logs" docs/RUN-OBSERVABILITY.md
grep -n "slow run" docs/RUN-OBSERVABILITY.md
grep -n "high token" docs/RUN-OBSERVABILITY.md
grep -n "executor failure\\|Executor failure" docs/RUN-OBSERVABILITY.md
grep -n "review loop\\|Review loop" docs/RUN-OBSERVABILITY.md
grep -n "RUN-OBSERVABILITY" docs/DEBUGGING.md docs/DOCUMENTATION-MAP.md
test -f scripts/render-agentops-run-summary.sh
git diff --check
scripts/check-agentops-lifecycle.sh
```

Results:

```text
scripts/render-agentops-run-summary.sh exists in the task worktree.
TASK-0076 commit is an ancestor of the TASK-0077 branch.
git diff --check -> exit 0
scripts/check-agentops-lifecycle.sh -> Errors: 0, Warnings: 0
```

Parent verdict:

```text
accept
```

## Follow-ups

None required for TASK-0077.
