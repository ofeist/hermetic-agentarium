# observability-01-routing-metadata-and-bad-model-fixture - Plan queryable routing metadata before cost tests

## Status

planned

## Goal

Plan the first concrete AgentOps observability slice for boring-but-queryable
routing metadata before cost tests or cost-aware model routing.

The slice should define:

- what routing metadata to capture
- where raw and safe metadata should live
- how failed routing/model-selection cases should be represented
- what the future implementation task should verify

No routing policy changes, dashboards, cost optimization, executor-wrapper
changes, or metadata writer implementation in this task.

## Background / why now

External feedback on the AgentOps / Hermes + OpenCode workflow highlighted that
cost tests are not useful until the workflow can first answer what actually ran.

The useful first slice is intentionally boring:

- requested model
- resolved provider/model
- tokens, if available
- latency/duration
- retry/fallback reason
- timestamp
- role
- final outcome

This fits the AgentOps observability workstream, but should happen before
cost-aware routing experiments. Otherwise, cost analysis risks optimizing
against incomplete or incorrect assumptions about which model/provider actually
ran.

The packaging-boundary decision should already define the storage model:

- raw/local run metadata belongs under `.agentops-runs/`
- committed safe summaries belong under `.agentops/results/`
- `$HOME/.agentops/` is optional future cross-repo index/cache/dashboard state,
  not canonical task/result storage

## Problem statement

AgentOps currently has local run artifacts and result notes, but the routing
facts are not yet defined as a small, queryable metadata contract.

Without that contract, it is hard to answer:

- which model was requested
- which provider/model actually ran
- whether a retry or fallback happened
- why a retry happened
- how long the run took
- how many tokens were used, if available
- which role produced the run
- whether the run ended in accept, revise, revert, no-op, or blocked

A second gap is debugging. Before real traffic or cost tests, the workflow should
have a designed failure case that proves bad model/provider selection produces
useful metadata instead of an opaque failure.

## Smallest useful slice

Produce a planning/design document for a future observability implementation.

The design must:

1. Define a minimal routing metadata contract.
2. Define raw vs safe storage locations.
3. Define how failed routing/model-selection attempts are represented.
4. Recommend one deterministic bad-model / invalid-routing test strategy for a
   future implementation task.
5. Define verification and acceptance criteria for that future implementation.

No metadata writer implementation in this planning slice.

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `docs/AGENTOPS-PACKAGING-BOUNDARIES.md`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/DOCUMENTATION-MAP.md`
- `scripts/run-opencode-executor.sh`
- `scripts/record-agentops-outcome.sh`
- `scripts/render-agentops-run-summary.sh`
- `.agentops/tasks/planned/090-skill-03-package-optional-agentops-observability.md`
- `.agentops/tasks/planned/080-observability-00-agentops-observability-workstream-intent.md` if present
- related observability planned/done task files if present

## Write scope

Planning/design output only:

- `docs/AGENTOPS-ROUTING-METADATA.md`

Optional cross-reference only if needed:

- `docs/DOCUMENTATION-MAP.md`
- `docs/AGENTOPS-OBSERVABILITY.md` if it already exists

Do not modify executor wrappers, helper scripts, routing behavior, task lifecycle
helpers, or `.agentops-runs/` retention behavior in this planning slice.

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
  - use `requested_model` for what the workflow asked for
  - use `resolved_provider` and `resolved_model` for what actually ran
  - avoid ambiguous names unless they are already used by existing tools
- Define storage locations according to the packaging-boundary model:
  - raw/local run metadata: `.agentops-runs/`
  - committed safe summaries/result notes: `.agentops/results/`
  - optional future cross-repo index/cache: `$HOME/.agentops/` only if a later
    architecture decision allows it
- Define how failed routing/model-selection attempts are represented.
- Recommend one deterministic bad-model / invalid-routing test strategy for a
  future implementation task.
- The bad-model / invalid-routing strategy must specify what should be captured:
  - requested model
  - resolved provider/model if any
  - error class or reason
  - retry/fallback reason if available
  - timestamp and duration
  - rerun/debug hint if available
- Define how this slice relates to future cost-aware model routing.
- Keep prompt contents and secrets out of committed metadata.

## Bad-model / invalid-routing test strategy

This task does not implement the test.

It only designs the strategy for a future implementation task.

The design should recommend one deterministic way to trigger the failure path,
for example:

- request an invalid executor model name, or
- request a provider/model mapping that is known to be unsupported, or
- configure a deliberately invalid routing value in a disposable test context.

The purpose is not to test model quality.

The purpose is to prove that AgentOps records useful debugging metadata when
routing/model selection fails.

The future implementation should be able to show:

```text
requested_model: <what was asked for>
resolved_provider: <provider if known, otherwise empty/null>
resolved_model: <model if known, otherwise empty/null>
retry_reason: <reason if retry happened>
fallback_reason: <reason if fallback happened>
exit_code: <exit code>
final_outcome: blocked
debug_hint: <rerun or next step>
```

## Non-goals

- Do not export prompt text.
- Do not parse secrets.
- Do not build a dashboard.
- Do not implement automatic cost optimization.
- Do not change routing policy.
- Do not change model selection behavior.
- Do not implement the metadata writer in this planning slice.
- Do not implement the bad-model fixture in this planning slice.
- Do not modify executor wrappers in this planning slice.
- Do not modify `.agentops-runs/` retention behavior.
- Do not introduce user-level `$HOME/.agentops/` storage as canonical state.
- Do not redesign AgentOps lifecycle states.

## Open questions

The design document should answer or explicitly defer:

- Which existing helper should eventually write routing metadata?
- Should routing metadata be stored as JSON, line-delimited JSON, markdown, or a
  small key/value text file?
- Which token fields are reliably available from Hermes/OpenCode/provider logs?
- Which bad-model / invalid-routing strategy is safest and most deterministic?
- Should the future implementation fail closed or record partial metadata when
  provider details are missing?
- Should `retry_reason` and `fallback_reason` be separate fields or one
  normalized event list?
- How should metadata from task worktrees be surfaced back to the main checkout
  without committing raw `.agentops-runs/` artifacts?

## Promotion decision

Decision: promote_to_ready

Reason:
The packaging-boundary decision is available, so artifact locations are clear
enough to produce the routing metadata design. This task remains planning-only
and does not change routing behavior or implement metadata capture.

Next action:
Promote to ready and produce `docs/AGENTOPS-ROUTING-METADATA.md`.

## Promotion criteria

- artifact locations are confirmed from `docs/AGENTOPS-PACKAGING-BOUNDARIES.md`
- design output path is `docs/AGENTOPS-ROUTING-METADATA.md`
- read/write scope is concrete
- bad-model / invalid-routing fixture strategy is a design output
- no implementation, executor-wrapper, routing-policy, or lifecycle changes are included

## Verification

Planning-only verification:

```bash
git status --short --branch
git diff --stat
test -f docs/AGENTOPS-ROUTING-METADATA.md
grep -q 'requested_model' docs/AGENTOPS-ROUTING-METADATA.md
grep -q 'resolved_provider' docs/AGENTOPS-ROUTING-METADATA.md
grep -q 'resolved_model' docs/AGENTOPS-ROUTING-METADATA.md
grep -q 'retry_reason' docs/AGENTOPS-ROUTING-METADATA.md
grep -q 'bad-model' docs/AGENTOPS-ROUTING-METADATA.md
scripts/check-agentops-lifecycle.sh
```

Do not use `|| true` to mask required verification failures.

## Accept criteria

- `docs/AGENTOPS-ROUTING-METADATA.md` exists.
- The routing metadata contract is explicit and queryable.
- The design distinguishes requested model from resolved provider/model.
- Token, latency, retry/fallback, timestamp, role, exit code, and outcome fields
  are addressed.
- Artifact locations are explicit and aligned with the packaging-boundary
  decision.
- One deterministic bad-model or invalid-routing strategy is specified for a
  future implementation task.
- The design explains how metadata produced in task worktrees should be surfaced
  or summarized without committing raw `.agentops-runs/` artifacts.
- Safety rules prevent prompt text, secrets, or raw sensitive logs from being
  committed.
- The design explains why this should precede cost tests or cost-aware routing.
- No implementation, dashboard, routing-policy, executor-wrapper, or lifecycle
  behavior changes are performed in this slice.

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

Important worktree note:

```text
Agent runs usually happen inside task-specific worktrees. Raw `.agentops-runs/`
artifacts in those worktrees should remain local and gitignored. The future
implementation must decide how safe summaries are copied, rendered, or referenced
during submit/accept closeout without committing raw run logs.
```

Possible follow-up tasks:

- `observability-02-implement-routing-metadata-writer`
- `observability-03-add-bad-model-debug-fixture`
- `observability-04-query-routing-metadata-summary`
- `policy-01-cost-aware-model-routing-policy`
