# observability-02-implement-routing-metadata-writer - Implement safe routing metadata writer

## Status

planned

## Goal

Implement the first minimal AgentOps routing metadata writer based on the design
produced by `070-observability-01-routing-metadata-and-bad-model-fixture`.

This task should add a small, safe, queryable metadata artifact for each executor
run, so later observability and cost-aware routing work can answer:

- what model was requested
- what provider/model actually ran, when available
- how long the run took
- whether retry/fallback happened, when available
- how the run ended

This task should not implement dashboards, automatic cost optimization, or
routing policy changes.

## Background / why later

This task intentionally follows `070`.

`070` should first decide the routing metadata contract, storage format,
bad-model fixture strategy, and safety rules. This task implements the smallest
useful writer only after that design is accepted.

## Problem statement

AgentOps currently records run artifacts and result notes, but routing metadata
is not yet captured as a small structured artifact.

Without a structured metadata file, later work such as model usage audit,
cost-aware model routing, retry analysis, and bad-model debugging has to infer
facts from logs or summaries.

That is fragile and makes cost analysis unreliable.

## Smallest useful slice

Implement the minimal routing metadata writer defined by `070`.

Expected direction, to be confirmed by the `070` design:

- write raw/local routing metadata under `.agentops-runs/<run-id>/`
- keep raw prompt text and raw logs out of committed files
- optionally surface a safe summary into `.agentops/results/` only if the design
  explicitly allows it
- capture partial metadata when some provider fields are unavailable
- do not fail successful executor runs only because optional metadata is missing

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

To be finalized after `070`.

Likely candidates:

- `docs/AGENTOPS-ROUTING-METADATA.md`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/AGENTOPS-PACKAGING-BOUNDARIES.md`
- `scripts/run-opencode-executor.sh`
- `scripts/record-agentops-outcome.sh`
- `scripts/render-agentops-run-summary.sh`
- `.agentops/tasks/done/` and `.agentops/results/` examples from recent runs

## Write scope

To be finalized after `070`.

Likely candidates:

- `scripts/run-opencode-executor.sh`
- `scripts/render-agentops-run-summary.sh`
- optional helper script if the design chooses one, for example:
  - `scripts/write-agentops-routing-metadata.sh`
- docs/tests only as required by the design:
  - `docs/RUN-AUDIT.md`
  - `docs/RUN-OBSERVABILITY.md`
  - `docs/AGENTOPS-ROUTING-METADATA.md`

Do not modify model routing policy, provider configuration, Hermes profile
configuration, or OpenCode authentication.

## Requirements

To be finalized after `070`.

Expected implementation requirements:

- Implement the metadata contract accepted in
  `docs/AGENTOPS-ROUTING-METADATA.md`.
- Store raw/local metadata under `.agentops-runs/<run-id>/`.
- Include at least the fields selected by `070`, likely:
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
- Record partial metadata when provider-specific values are unavailable.
- Do not export prompt text.
- Do not parse secrets.
- Do not commit `.agentops-runs/`.
- Preserve existing executor behavior.
- Preserve existing lifecycle behavior.
- Keep output safe for local debugging first; committed summaries are optional
  and must be explicitly safe.

## Bad-model/debug fixture

This implementation task may include the bad-model fixture only if `070` says
the fixture should be implemented together with the metadata writer.

Otherwise, create a separate follow-up task for the fixture.

Expected future fixture behavior:

- intentionally request an invalid or unsupported model/provider configuration
- verify the metadata writer records the failure path safely
- record requested model
- record resolved provider/model if available
- record error/retry/fallback reason if available
- record timestamp and duration
- provide a rerun/debug hint if available

## Non-goals

- Do not implement automatic cost optimization.
- Do not change routing policy.
- Do not change model selection behavior.
- Do not build a dashboard.
- Do not export full prompt text.
- Do not parse secrets.
- Do not introduce `$HOME/.agentops/` as canonical storage.
- Do not redesign AgentOps lifecycle states.
- Do not make observability mandatory for core AgentOps usage.
- Do not move helper scripts into the skill package.
- Do not create a standalone CLI.

## Open questions

These should be resolved by `070` before promotion:

- Which helper owns metadata writing?
- Should the metadata format be JSON, JSONL, Markdown, or key/value text?
- Which token fields are reliably available?
- Should retries/fallbacks be represented as separate fields or a normalized
  event list?
- Should the bad-model fixture be implemented in this task or in a follow-up?
- Should safe summaries be surfaced into `.agentops/results/`, or should this
  task only write `.agentops-runs/` artifacts?

## Promotion decision

Decision: keep_planned

Reason:
This implementation task depends on the design output from
`070-observability-01-routing-metadata-and-bad-model-fixture`.

Next action:
Promote only after `070` is accepted and the routing metadata contract, storage
format, and fixture strategy are known.

## Promotion criteria

- `docs/AGENTOPS-ROUTING-METADATA.md` or equivalent design exists
- metadata fields are decided
- storage format is decided
- writer ownership is decided
- bad-model fixture strategy is decided
- write scope is concrete
- verification commands are concrete
- no routing-policy changes are included

## Verification

Base verification:

```bash
git status --short --branch
git diff --stat
bash -n scripts/*.sh
scripts/check-agentops-lifecycle.sh
```

Expected future task-specific verification, to be finalized after `070`:

```bash
# Example only; exact paths depend on the accepted design.
test -f .agentops-runs/<run-id>/routing-metadata.json
grep -q 'requested_model' .agentops-runs/<run-id>/routing-metadata.json
grep -q 'resolved_model' .agentops-runs/<run-id>/routing-metadata.json
grep -q 'duration' .agentops-runs/<run-id>/routing-metadata.json
```

Do not use `|| true` to mask required verification failures.

## Accept criteria

- A structured routing metadata artifact is written for executor runs.
- The artifact is local/raw under `.agentops-runs/` unless the accepted design
  says otherwise.
- The metadata captures requested model, resolved provider/model if available,
  timing, retry/fallback reason if available, exit code, and outcome fields
  chosen by `070`.
- Missing provider-specific fields are handled gracefully.
- Prompt text and secrets are not exported.
- Existing executor and lifecycle behavior remains compatible.
- `.agentops-runs/` artifacts remain gitignored and uncommitted.
- Documentation is updated only as needed to explain the new metadata artifact.
- No dashboard, automatic cost optimization, routing-policy change, or lifecycle
  redesign is included.

## Notes

This task should remain intentionally small.

The purpose is to create the first reliable metadata foundation for later work:

- routing/model usage audit
- bad-model debug fixture
- queryable local run summaries
- cost-aware model routing policy

Do not combine those follow-ups into this implementation slice.
