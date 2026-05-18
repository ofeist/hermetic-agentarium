# TASK-0094-document-skill-activation-troubleshooting Result

## Decision

accept

## Decision note

accept: docs-only activation/troubleshooting coverage added in INSTALL, skill README, and docs map; no installer/runtime/lifecycle helper behavior changes.

## Task file

agentops/tasks/done/TASK-0094-document-skill-activation-troubleshooting.md

## Verification

- Verified changed files are within write scope:
  - docs/INSTALL.md
  - skills/hermetic-coding-orchestrator/README.md
  - docs/DOCUMENTATION-MAP.md
- Verified required content present:
  - global skill path
  - coder profile-local skill path
  - `/hermetic-coding-orchestrator` invocation
  - `USING_SKILL: hermetic-coding-orchestrator` marker
  - `Unknown command` troubleshooting
  - guidance that slash invocation is the practical acceptance test
  - note that `hermes skills list` may differ by mode and should not be sole verifier
- `scripts/check-agentops-lifecycle.sh` passed after result-note path cleanup.

## Follow-ups

None.
