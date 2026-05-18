# agentops

## Purpose

Store task lifecycle artifacts for Hermes/OpenCode executor workflows. This directory tracks task state transitions — it does not hold runtime secrets, credentials, or configuration.

## Directory overview

```
.agentops/
  README.md           # This file
  TASK-LIFECYCLE.md   # Lifecycle state definitions
  tasks/
    planned/          # Tasks identified but not yet prepared
    ready/            # Tasks ready for executor dispatch
    running/          # Tasks currently being executed
    review/           # Tasks awaiting parent review
    done/             # Completed (accepted, reverted, or no-op)
  results/            # Execution output artifacts (diffs, logs)
```

## Source of truth

Git, diffs, and tests remain the authoritative source of truth for changes. The .agentops/ directory is a lightweight tracking aid, not a replacement for version control or test results.
