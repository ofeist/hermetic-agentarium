# observability-01 — Add agent/model usage audit idea

## Status

planned

## Goal

Design a lightweight way to understand how much prompt/model traffic an AgentOps run creates, especially repeated prompts and calls to coordinator vs executor models.

## Background / why now

AgentOps run summaries already help explain what happened in a run, but they do not yet answer optimization questions clearly:

- whether the same prompt is sent repeatedly
- how large the rendered prompt is
- how often the coordinator/main model is used
- how often the coder/executor model is used
- where token/cost waste may be hiding

This matters before scaling the workflow or adding more helper automation.

## Problem statement

The workflow needs enough local observability to spot waste without committing raw logs or secrets.

The first slice should produce a safe, local-only or safe-summary view of prompt sizes and model call counts. It should not become a full tracing platform.

## Smallest useful slice

Create a docs-only audit design or one small helper update that identifies currently available run metadata and proposes the minimal extra safe fields needed for model/provider/prompt-size/call-count tracking.

## Executor

Harness: TBD.
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- `.agentops-runs/` contract docs
- run summary helper script
- OpenCode executor wrapper
- debugging/audit documentation
- relevant AgentOps workflow documentation

## Write scope

- one docs file and/or one summary helper script
- no raw run logs
- no secrets or private runtime config

## Requirements

The first slice should:

- review current `.agentops-runs/<run-id>/` artifacts and run summary helper output
- identify what metadata is already captured
- propose minimal extra fields for model/provider/prompt-size/call-count tracking
- add a safe summary format only if the data is already available or cheap to capture safely
- keep raw logs local and gitignored
- document what can and cannot be measured reliably

## Non-goals

- Do not parse or commit secrets.
- Do not commit raw executor stdout/stderr.
- Do not build a web dashboard.
- Do not optimize prompts in this slice; only make waste visible.
- Do not change model routing rules.
- Do not claim reliable per-call counts unless the tooling actually exposes them.

## Open questions

- Can OpenCode/Hermes expose reliable per-call counts, or only wrapper-level estimates?
- Should repeated-prompt detection hash the rendered prompt locally?
- Should prompt-size tracking use bytes, lines, approximate tokens, or all three?
- Should this be a docs-only design first, followed by implementation?

## Verification

```bash
git status --short --branch
bash -n scripts/*.sh
scripts/render-agentops-run-summary.sh --help || true
git diff --stat
```

Adjust the helper command to the actual CLI shape if different. If the first slice is docs-only, script syntax checks are only needed for touched scripts.

## Accept criteria

TBD during promotion.

## Promotion decision

Decision: keep_planned.

Reason:
The first slice is not yet narrowed to docs-only design vs one small helper update.

Next action:
Choose whether the first ready task is a docs-only audit design or a small safe-metadata implementation.

## Promotion criteria

Promote to `ready` when the first slice is narrowed to either:

1. docs-only audit design, or
2. one small helper update that adds safe metadata to existing run summaries.

Also confirm:

- target file or helper
- measurable fields for the first slice
- read/write scope

## Hermes/coder collection prompt

TBD during promotion.

## Return format

TBD during promotion.

## Notes

This is important for cost/control, but it should follow lifecycle and execution-strategy cleanup.
