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

## Bootstrapping

Fresh checkouts or repositories new to AgentOps can bootstrap the required layout with:

```bash
scripts/bootstrap-agentops-structure.sh .agentops
```

The helper is idempotent — it creates missing directories, ensures `.gitkeep`
placeholders, and validates that required template files are present.

## Source of truth

Git, diffs, and tests remain the authoritative source of truth for changes. The .agentops/ directory is a lightweight tracking aid, not a replacement for version control or test results.
