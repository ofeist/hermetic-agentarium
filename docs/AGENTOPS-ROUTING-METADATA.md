# AgentOps Routing Metadata

## Decision

Before cost tests or cost-aware routing, AgentOps should record a small,
queryable routing contract for each run.

Near term:

- keep raw routing metadata local under `.agentops-runs/<run-id>/`
- commit only safe summaries under `.agentops/results/`
- do not introduce `$HOME/.agentops/` as canonical state
- do not change routing policy while adding metadata
- use boring key/value metadata first, consistent with existing
  `.agentops-runs/<run-id>/metadata.txt` and `outcome.txt`

The first implementation should prove the contract with one deterministic
bad-model or invalid-routing fixture before any cost optimization work.

## Why This Comes Before Cost Tests

Cost tests are not useful unless the workflow can answer what actually ran:

- which model the workflow requested
- which provider/model actually resolved, if known
- whether the run retried or fell back
- why the retry or fallback happened
- how long the run took
- which role requested the run
- whether the final outcome was useful

Without those facts, cost optimization would be guessing from incomplete run
stories.

## Storage Model

Use the packaging-boundary decision:

- `.agentops-runs/` stores raw local run artifacts and metadata. It remains
  gitignored.
- `.agentops/results/` stores reviewed, safe committed result summaries.
- `$HOME/.agentops/` is reserved only for optional future cross-repo
  index/cache/dashboard state. It is not canonical task or result storage.

Recommended near-term files:

```text
.agentops-runs/<run-id>/metadata.txt
.agentops-runs/<run-id>/routing.txt
.agentops-runs/<run-id>/outcome.txt
.agentops/results/TASK-xxxx-result.md
```

`routing.txt` should be prompt-safe when it excludes prompt text, raw logs,
auth paths, provider tokens, request payloads, and response payloads.

## Minimal Routing Contract

The near-term format should be key/value lines because existing run metadata is
already key/value and shell helpers can write/read it without new dependencies.

Required or best-effort fields:

```text
timestamp=<UTC ISO-8601 timestamp>
run_id=<run id>
task_id=<TASK-xxxx or empty>
phase=executor|reviewer|coordinator|helper
role=coordinator|executor|reviewer|helper
harness=Hermes|OpenCode|script
requested_model=<model requested by workflow>
resolved_provider=<provider that actually handled the request, if known>
resolved_model=<model that actually handled the request, if known>
token_counts_prompt=<integer or unknown>
token_counts_completion=<integer or unknown>
token_counts_total=<integer or unknown>
duration_ms=<integer or unknown>
retry_reason=<reason or empty>
fallback_reason=<reason or empty>
exit_code=<integer or unknown>
final_outcome=accept|revise|revert|no-op|blocked|unknown
error_class=<short class or empty>
error_reason=<short reason or empty>
debug_hint=<safe next step or empty>
```

Naming rules:

- `requested_model` means what AgentOps asked the harness/provider to use.
- `resolved_provider` means the provider that actually handled the request.
- `resolved_model` means the provider/model that actually ran, if known.
- Do not use ambiguous names like `model` for routing facts in the new routing
  contract. Existing `metadata.txt` may keep `model` for compatibility.
- Use `unknown` when a value is not available but the field is expected.
- Use an empty value only when the field is not applicable.

## Failure Representation

Failed routing/model-selection attempts should still write partial metadata.

Minimum failed-run example:

```text
timestamp=2026-05-20T12:00:00Z
run_id=TASK-0101-bad-model-fixture
task_id=TASK-0101
phase=executor
role=executor
harness=OpenCode
requested_model=invalid-provider/invalid-model
resolved_provider=
resolved_model=
token_counts_prompt=unknown
token_counts_completion=unknown
token_counts_total=unknown
duration_ms=742
retry_reason=
fallback_reason=
exit_code=1
final_outcome=blocked
error_class=model_resolution_failed
error_reason=model or provider was not found
debug_hint=rerun with a known configured model from AGENTOPS_EXECUTOR_MODEL
```

The important behavior is that `requested_model`, `exit_code`,
`final_outcome=blocked`, and a safe `debug_hint` survive even when provider
resolution fails before tokens or resolved provider/model are available.

## Retry And Fallback

Keep `retry_reason` and `fallback_reason` separate for the first implementation.

Reason:

- a retry can happen against the same requested model
- a fallback means the effective provider/model changed or was attempted
- separating them keeps queries simple

If future providers expose richer event streams, add a separate local-only
`routing-events.jsonl` later. Do not introduce that until there is real event
data to store.

## Token And Duration Fields

Token fields are best-effort:

- use provider/OpenCode/Hermes stats when available
- otherwise write `unknown`
- do not parse raw logs looking for secrets or full request/response bodies
- do not fail the run only because token counts are unavailable

Duration should be available from the wrapper even when provider stats are not.
Prefer `duration_ms` in the routing contract, while keeping existing
`duration_seconds` in `metadata.txt` for compatibility.

## Bad-Model Fixture Strategy

The future implementation should add one deterministic invalid-routing fixture.

Recommended strategy:

1. Use `scripts/run-opencode-executor.sh` with a disposable prompt and an
   explicit invalid model value, for example
   `invalid-provider/invalid-model`.
2. Set a disposable `AGENTOPS_RUN_ID`, for example
   `TASK-xxxx-bad-model-fixture`.
3. Run in a safe test context where no real task files are modified.
4. Assert that the wrapper exits non-zero.
5. Assert that routing metadata still exists and contains:
   - `requested_model`
   - `resolved_provider` and `resolved_model` as empty or `unknown`
   - `error_class` or `error_reason`
   - `exit_code`
   - `duration_ms`
   - `final_outcome=blocked`
   - `debug_hint`

This fixture tests support/debugging behavior, not model quality.

Do not use a live expensive model call for the first fixture if the failure can
be triggered before provider execution.

## Safe Committed Summary

Committed `.agentops/results/` notes may include compact routing facts:

```text
requested_model: deepseek/deepseek-v4-pro
resolved_provider: deepseek
resolved_model: deepseek-v4-pro
duration_ms: 12345
token_counts_total: unknown
retry_reason:
fallback_reason:
final_outcome: accept
```

They must not include:

- prompt text
- raw stdout/stderr
- provider request payloads
- response payloads
- auth/config file contents
- provider tokens or credentials

## Future Implementation Acceptance Criteria

A future implementation task should be accepted only if:

- normal executor runs write routing metadata without changing routing policy
- bad-model fixture writes partial routing metadata on failure
- existing `.agentops-runs/<run-id>/metadata.txt` behavior remains compatible
- no raw prompt text is exported into committed result notes
- result notes can include a safe routing summary
- missing token/provider details are recorded as `unknown` instead of causing
  metadata writing to fail
- lifecycle checks still pass

Suggested future verification commands:

```bash
bash -n scripts/run-opencode-executor.sh
bash -n scripts/render-agentops-run-summary.sh
bash -n scripts/record-agentops-outcome.sh
AGENTOPS_RUN_ID=TASK-xxxx-routing-smoke AGENTOPS_EXECUTOR_COMMAND='printf "ok\n"' scripts/run-opencode-executor.sh /tmp/agentops-routing-smoke.prompt.md
test -f .agentops-runs/TASK-xxxx-routing-smoke/metadata.txt
test -f .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^requested_model=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^resolved_provider=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^resolved_model=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^final_outcome=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
scripts/check-agentops-lifecycle.sh
```

The invalid-model fixture should use a separate run id and should assert
non-zero exit plus `final_outcome=blocked`.

## Relationship To Cost-Aware Routing

Cost-aware routing should wait until this metadata exists.

The cost workstream can later consume:

- requested versus resolved model/provider
- token totals
- duration
- retry/fallback reasons
- final outcome

That gives cost policy a factual baseline: what ran, what it cost or likely
cost, and whether it produced accepted value.

## Deferred Questions

- Whether routing metadata should eventually become JSON or JSONL.
- Whether a future CLI should aggregate routing metadata across repositories.
- Whether `$HOME/.agentops/` should hold a derived cross-repo index.
- Which provider-specific token fields are stable enough to normalize.
- Whether retry/fallback should later become a normalized event list.
