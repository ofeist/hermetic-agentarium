# TASK-0097-agentops-structure-bootstrap Result

## Decision

accept

## Decision note

accept: `scripts/bootstrap-agentops-structure.sh` creates and validates the canonical `.agentops/` lifecycle layout; idempotent (repeated runs succeed); docs updated; lifecycle checker passes; no user-level `$HOME/.agentops` behavior introduced.

## Task file

.agentops/tasks/done/TASK-0097-agentops-structure-bootstrap.md

## Changed files

- `scripts/bootstrap-agentops-structure.sh` (new) — idempotent bootstrap/check script
- `docs/AGENTOPS-HELPERS.md` — added bootstrap helper to inventory table
- `.agentops/README.md` — added "Bootstrapping" section
- `.agentops/USAGE.md` — added "First-time setup" section
- `.agentops/tasks/done/TASK-0097-agentops-structure-bootstrap.md` — moved from ready/ with status updated to done

## Verification

- `bash -n scripts/bootstrap-agentops-structure.sh` — pass
- `scripts/bootstrap-agentops-structure.sh .agentops` (first run) — pass
- `scripts/bootstrap-agentops-structure.sh .agentops` (second run) — pass (idempotent)
- `scripts/check-agentops-lifecycle.sh` — Errors: 0, Warnings: 0
- All 8 required directories exist
- Both required templates (`PLANNED-TASK-TEMPLATE.md`, `READY-TASK-TEMPLATE.md`) present
- No user-level `$HOME/.agentops` code

## Notes

Bootstrap targets `.agentops/` by default and accepts an optional argument for the target directory. It creates missing directories, ensures `.gitkeep` placeholders in empty-tracked directories, and fails if required template files are absent.
