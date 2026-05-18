# skill-03-package-optional-agentops-observability - Package optional AgentOps observability support

## Status

planned

## Goal

Define a follow-up slice that packages/document optional AgentOps observability
support without making it mandatory for the core skill.

## Background / why now

Observability artifacts and helpers exist, but they should remain optional and
separate from the core skill package to keep the first slice small and safe.

## Problem statement

Mixing observability packaging into core skill packaging increases scope and
risk. Optional observability needs a dedicated task with clear safety
boundaries.

## Smallest useful slice

Document/package optional observability usage for local run inspection while
preserving the current safety boundary:

- local-only `.agentops-runs/`
- no raw prompt export
- no committed raw logs

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `scripts/run-opencode-executor.sh`
- `scripts/render-agentops-run-summary.sh`
- `scripts/record-agentops-outcome.sh`
- `scripts/export-agentops-prometheus-metrics.sh`
- `.gitignore`

## Write scope

TBD

Likely candidates:

- `skills/hermetic-coding-orchestrator/README.md`
- optional docs under `skills/hermetic-coding-orchestrator/observability/`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`

## Requirements

TBD

Candidate requirements:

- Keep observability optional.
- Keep raw prompts/logs out of commits.
- Prefer metadata/hash/summary-based guidance.
- Keep Prometheus/Grafana explicitly optional.

## Non-goals

- No core skill rename or invocation changes.
- No mandatory observability enablement.
- No lifecycle workflow redesign.

## Open questions

- Which observability components are documentation-only vs packaging artifacts?
- Should optional observability use a profile/install flag or doc-only guidance?

## Promotion decision

Decision: keep_planned

Reason:
This follows core packaging and activation docs work.

Next action:
Promote after `skill-00` and `skill-02` so optional docs align with final core
install path and activation guidance.

## Promotion criteria

- core packaging is complete
- activation/troubleshooting docs are complete
- optional component boundaries are explicit
- safety guardrails are concrete

## Verification

```bash
git status --short --branch
git diff --stat
```

## Accept criteria

- Optional observability boundaries are explicit.
- Core skill remains usable without observability setup.
- Safety constraints are documented and preserved.
