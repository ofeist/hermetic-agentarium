# observability-01-routing-metadata-and-bad-model-fixture - Plan queryable routing metadata before cost tests

## Status

planned

## Goal

Plan the first concrete AgentOps observability slice for boring-but-queryable
routing metadata before cost tests or cost-aware model routing.

The slice should define what routing metadata to capture, where it should live,
and how to test the support/debugging path with one forced bad-model or
invalid-routing fixture.

No routing policy changes, dashboards, or cost optimization implementation in
this task.

## Background / why now

External feedback on the AgentOps / Hermes + OpenCode workflow highlighted that
cost tests are not useful until the workflow can first answer what actually ran.

The useful first slice is intentionally boring:

- requested model
- resolved/provider model
- tokens
- latency
- retry reason
- timestamp

This fits the AgentOps observability workstream, but should happen before
cost-aware routing experiments. Otherwise, cost analysis risks optimizing
against incomplete or incorrect assumptions about which model/provider actually
ran.

## Problem statement

AgentOps currently has run artifacts and result notes, but the routing facts are
not yet defined as a small, queryable metadata contract.

Without that contract, it is hard to answer:

- which model was requested
- which provider/model actually ran
- whether a retry or fallback happened
- why a retry happened
- how long the run took
- how many tokens were used, if available
- which role produced the run
- whether the run ended in accept, revise, revert, no-op, or blocked

A second gap is the support/debugging path. The workflow should intentionally
exercise at least one bad-model or invalid-routing case before real traffic so
the failure path records useful information instead of only supporting happy
paths.

## Smallest useful slice

Produce a planning/design task for a future observability implementation that:

1. Defines a minimal routing metadata contract.
2. Defines where raw and safe metadata should be stored.
3. Defines one deterministic bad-model or invalid-routing fixture.
4. Defines verification and acceptance criteria for the future implementation.

No metadata writer implementation in this planning slice.

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/AGENTOPS-PACKAGING-BOUNDARIES.md` if present
- `docs/DOCUMENTATION-MAP.md`
- `scripts/run-opencode-executor.sh`
- `scripts/record-agentops-outcome.sh`
- `scripts/render-agentops-run-summary.sh`
- `.agentops/tasks/planned/050-skill-03-package-optional-agentops-observability.md`
- `.agentops/tasks/planned/690-observability-00-agentops-observability-workstream-intent.md` if present
- related observability planned/done task files if present

## Write scope

Planning/design output only:

- this planned task file, or
- optional new design note:
  - `docs/AGENTOPS-ROUTING-METADATA.md`

Optional cross-reference only if needed:

- `docs/DOCUMENTATION-MAP.md`
- `docs/AGENTOPS-OBSERVABILITY.md` if it already exists

Do not modify executor wrappers, helper scripts, routing behavior, or task
lifecycle helpers in this planning slice.

## Requirements

- Define a minimal routing metadata contract.
- Include the following fields where available:
  - `timestamp`
  - `role`
  - `requested_model`
  - `resolved_provider`
  - `resolved_model`
  - `token_counts`
  - `latency_ms` or `duration_ms`
  - `retry_reason`
  - `fallback_reason`
  - `exit_code`
  - `final_outcome`
- Clarify naming:
  - prefer `requested_model` for what the workflow asked for
  - prefer `resolved_provider` and `resolved_model` for what actually ran
  - avoid ambiguous names unless they are already used by existing tools
- Define storage locations according to the packaging-boundary model:
  - raw/local run metadata: `.agentops-runs/`
  - committed safe summaries/result notes: `.agentops/results/`
  - optional future cross-repo index/cache: `$HOME/.agentops/` only if a later
    architecture decision allows it
- Define one deterministic bad-model or invalid-routing fixture.
- The bad-model fixture must verify the debugging path records:
  - requested model
  - resolved provider/model if any
  - error class or reason
  - retry reason if available
  - timestamp and duration
  - rerun/debug hint if available
- Define how this slice relates to future cost-aware model routing.
- Keep prompt contents and secrets out of committed metadata.

## Non-goals

- Do not export prompt text.
- Do not parse secrets.
- Do not build a dashboard.
- Do not implement automatic cost optimization.
- Do not change routing policy.
- Do not change model selection behavior.
- Do not modify executor wrappers in this planning slice.
- Do not modify `.agentops-runs/` retention behavior.
- Do not introduce user-level `$HOME/.agentops/` storage as canonical state.
- Do not redesign AgentOps lifecycle states.

## Open questions

- Which existing helper should eventually write routing metadata?
- Should routing metadata be stored as JSON, line-delimited JSON, markdown, or a
  small key/value text file?
- Which token fields are reliably available from Hermes/OpenCode/provider logs?
- Should the bad-model fixture use an invalid model name, invalid provider
  mapping, or a deliberately unsupported executor model?
- Should the future implementation fail closed or record partial metadata when
  provider details are missing?
- Should `retry_reason` and `fallback_reason` be separate fields or one
  normalized event list?

## Promotion decision

Decision: keep_planned

Reason:
This is a planning slice for the first concrete routing observability contract.
It should be promoted after the packaging-boundary decision clarifies artifact
locations and after the current observability task inventory is checked.

Next action:
Confirm artifact locations, choose design-note location, and promote when ready
to produce the routing metadata design.

## Promotion criteria

- artifact locations are confirmed
- design output path is chosen
- read/write scope is concrete
- bad-model fixture strategy is chosen or explicitly left as a design output
- no implementation or routing-policy changes are included

## Verification

Planning-only verification:

```bash
git status --short --branch
git diff --stat
```

If a design note is added:

```bash
test -f docs/AGENTOPS-ROUTING-METADATA.md
grep -q 'requested_model' docs/AGENTOPS-ROUTING-METADATA.md
grep -q 'resolved_model' docs/AGENTOPS-ROUTING-METADATA.md
grep -q 'retry_reason' docs/AGENTOPS-ROUTING-METADATA.md
grep -q 'bad-model' docs/AGENTOPS-ROUTING-METADATA.md
```

Do not use `|| true` to mask required verification failures.

## Accept criteria

- The routing metadata contract is explicit and queryable.
- The design distinguishes requested model from resolved provider/model.
- Token, latency, retry/fallback, timestamp, role, and outcome fields are
  addressed.
- Artifact locations are explicit and aligned with the packaging-boundary
  decision.
- One deterministic bad-model or invalid-routing fixture is specified.
- Safety rules prevent prompt text, secrets, or raw sensitive logs from being
  committed.
- The design explains why this should precede cost tests or cost-aware routing.
- No implementation, dashboard, routing-policy, or lifecycle behavior changes
  are performed in this slice.

## Notes

Suggested future implementation direction:

```text
Raw/local routing metadata should be written into `.agentops-runs/` as part of
the run artifact set.

Safe, committed summaries may be referenced from `.agentops/results/` result
notes.

A future `$HOME/.agentops/` index may aggregate cross-repo metadata only after
the product-boundary decision allows it.
```

Possible follow-up tasks:

- `observability-02-implement-routing-metadata-writer`
- `observability-03-add-bad-model-debug-fixture`
- `observability-04-query-routing-metadata-summary`
- `policy-01-cost-aware-model-routing-policy`
