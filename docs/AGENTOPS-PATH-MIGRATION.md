# AgentOps Path Migration: `agentops/` → `.agentops/`

## Overview

The AgentOps lifecycle directory is being migrated from `agentops/` to
`.agentops/`. The dot prefix better communicates that lifecycle data is
operational metadata rather than primary product code.

This document is the reference for the migration. The detailed migration plan
lives at `agentops/tasks/planned/010-agentops-structure-00-plan-dot-agentops-repo-migration.md`
(which will itself move to `.agentops/` during the migration).

## What changes (active workflow inputs)

- `agentops/tasks/planned/` → `.agentops/tasks/planned/`
- `agentops/tasks/ready/` → `.agentops/tasks/ready/`
- `agentops/tasks/running/` → `.agentops/tasks/running/`
- `agentops/tasks/review/` → `.agentops/tasks/review/`
- `agentops/templates/` → `.agentops/templates/`
- `agentops/README.md` → `.agentops/README.md`
- `agentops/TASK-LIFECYCLE.md` → `.agentops/TASK-LIFECYCLE.md`
- `agentops/USAGE.md` → `.agentops/USAGE.md`
- `agentops/IDEAS.md` → `.agentops/IDEAS.md`
- `agentops/lifecycle/` → `.agentops/lifecycle/`

Task files in `planned/`, `ready/`, `running/`, and `review/` are **active
workflow inputs** — their internal `agentops/` path references are updated
during migration so the orchestrator resolves them correctly.

## What does NOT change

- `agentops/tasks/done/` → `.agentops/tasks/done/` (directory moves but file
  contents are **not rewritten** — immutable historical records)
- `agentops/results/` → `.agentops/results/` (directory moves but file
  contents are **not rewritten** — immutable historical records)
- `.agentops-runs/` — runtime artifact directory (already dot-prefixed)
- Helper script names — e.g., `submit-agentops-task.sh` retains its name
- Skill name — no skill rename in this slice

## Why atomic (not dual-path)

All `agentops/` references are internal to this repository. There are no
external consumers or published APIs. An atomic cutover (single commit with
coordinated `sed` replacements) is simpler, more auditable, and fully
revertible with `git revert`.

A compatibility-based approach would:
- Add fallback logic to scripts
- Create confusion about which path is canonical
- Need eventual cleanup (a second migration)

## Script / doc location after migration

| Current | After migration |
|---------|----------------|
| Scripts reference `agentops/tasks/ready/` | Scripts reference `.agentops/tasks/ready/` |
| Docs reference `agentops/USAGE.md` | Docs reference `.agentops/USAGE.md` |
| SKILL.md references `agentops/tasks/ready/` | SKILL.md references `.agentops/tasks/ready/` |
| New tasks create files under `agentops/tasks/ready/` | New tasks create files under `.agentops/tasks/ready/` |

## Rollback

Rollback is a single `git revert` of the migration commit.

## Historical references

Completed task files (`done/`) and result files (`results/`) contain `agentops/`
paths that were correct at the time of execution. These files are not rewritten
during migration. The lifecycle checker (`check-agentops-lifecycle.sh`) is
updated to accept both old (`agentops/...`) and new (`.agentops/...`) path
patterns when cross-referencing historical records.

## Verification

After migration, run these smoke tests:

```bash
scripts/check-agentops-lifecycle.sh
scripts/next-agentops-task-id.sh
scripts/render-opencode-prompt.sh .agentops/tasks/ready/TASK-0095-plan-dot-agentops-repo-migration.md
scripts/test-submit-agentops-task.sh
```

**Sanctioned `agentops/` references after migration**: Grep for `agentops/` will
still produce matches. These are expected and allowed in the following categories:
- **Compatibility**: The lifecycle checker's dual-pattern grep accepts both
  `agentops/` and `.agentops/` when cross-referencing historical files.
- **Historical records**: `done/` and `results/` files are not rewritten —
  they accurately reflect `agentops/` paths valid at execution time.
- **Migration documentation**: Docs describing the migration itself may
  reference the old `agentops/` path for clarity.
- **Script names**: Helper script filenames like `submit-agentops-task.sh` are
  not renamed — only their internal path literals are updated.

All other `agentops/` path literals (hardcoded directory references in scripts,
docs, skill, profile, templates, and active workflow task files) must resolve
to `.agentops/`.
