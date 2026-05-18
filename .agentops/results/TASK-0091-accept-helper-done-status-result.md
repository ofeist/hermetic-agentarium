# TASK-0091-accept-helper-done-status Result

## Decision

accept

## Decision note

accept: accept helper now rewrites internal task status from review to done for both supported status styles.

## Task file

agentops/tasks/done/TASK-0091-accept-helper-done-status.md

## Changed files

- scripts/accept-agentops-task.sh
- agentops/tasks/done/TASK-0091-accept-helper-done-status.md (lifecycle)
- agentops/results/TASK-0091-accept-helper-done-status-result.md

## Verification

```bash
bash -n scripts/accept-agentops-task.sh
scripts/check-agentops-lifecycle.sh
```

Observed: syntax check passed and lifecycle checker reported Errors: 0, Warnings: 0 after fixture-based rewrite tests were run and cleaned up.

## Review

Focused independent re-review verdict: accept.

## Follow-ups

None.
