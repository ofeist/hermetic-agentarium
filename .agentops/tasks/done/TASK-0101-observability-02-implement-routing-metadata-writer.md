# TASK-0101 - Implement safe routing metadata writer

## Status

done

## Goal

Implement the first minimal AgentOps routing metadata writer based on the accepted
design in `docs/AGENTOPS-ROUTING-METADATA.md`.

This task should add a small, safe, queryable metadata artifact for each executor
run so later observability and cost-aware routing work can answer:

- what model was requested
- what provider/model actually ran, when available
- how long the run took
- whether retry/fallback happened, when available
- how the run ended

This task should not implement dashboards, automatic cost optimization, routing
policy changes, or the bad-model fixture.

## Background / why now

This task follows `070-observability-01-routing-metadata-and-bad-model-fixture`.

`070` accepted a near-term routing metadata design:

- write raw/local routing metadata under `.agentops-runs/<run-id>/`
- use a boring key/value file first
- write `routing.txt`
- keep prompt text, raw logs, request payloads, response payloads, and secrets
  out of committed files
- leave bad-model fixture implementation as a follow-up unless explicitly split
  differently later

## Problem statement

AgentOps currently records run artifacts and result notes, but routing metadata
is not yet captured as a small structured artifact.

Without a structured metadata file, later work such as model usage audit,
cost-aware model routing, retry analysis, and bad-model debugging has to infer
facts from logs or summaries.

That is fragile and makes cost analysis unreliable.

## Smallest useful slice

Implement the minimal routing metadata writer defined by
`docs/AGENTOPS-ROUTING-METADATA.md`.

Expected behavior:

- create `.agentops-runs/<run-id>/routing.txt` for executor runs
- use key/value lines
- record best-effort routing fields
- record partial metadata when some provider fields are unavailable
- do not fail successful executor runs only because optional metadata is missing
- preserve existing `.agentops-runs/<run-id>/metadata.txt` behavior
- do not commit `.agentops-runs/`

The bad-model fixture is a follow-up task.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `docs/AGENTOPS-ROUTING-METADATA.md`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/AGENTOPS-PACKAGING-BOUNDARIES.md`
- `scripts/run-opencode-executor.sh`
- `scripts/render-agentops-run-summary.sh`
- `scripts/record-agentops-outcome.sh`
- `.agentops/tasks/done/` and `.agentops/results/` examples from recent runs

## Write scope

- `scripts/run-opencode-executor.sh`
- `scripts/render-agentops-run-summary.sh`
- docs only if needed to reflect the implemented artifact:
  - `docs/RUN-AUDIT.md`
  - `docs/RUN-OBSERVABILITY.md`
  - `docs/AGENTOPS-ROUTING-METADATA.md`

Optional only if simpler and justified:

- a small dedicated helper script, for example:
  - `scripts/write-agentops-routing-metadata.sh`

Do not modify model routing policy, provider configuration, Hermes profile
configuration, OpenCode authentication, lifecycle helpers, or `.agentops/`
lifecycle semantics.

## Requirements

- Implement the metadata contract from `docs/AGENTOPS-ROUTING-METADATA.md`.
- Store raw/local metadata under `.agentops-runs/<run-id>/routing.txt`.
- Use key/value text format.
- Include at least these fields, with `unknown` or empty values where
  appropriate:
  - `timestamp`
  - `run_id`
  - `task_id`
  - `phase`
  - `role`
  - `harness`
  - `requested_model`
  - `resolved_provider`
  - `resolved_model`
  - `token_counts_prompt`
  - `token_counts_completion`
  - `token_counts_total`
  - `duration_ms`
  - `retry_reason`
  - `fallback_reason`
  - `exit_code`
  - `final_outcome`
  - `error_class`
  - `error_reason`
  - `debug_hint`
- Prefer `requested_model` for what AgentOps asked the harness/provider to use.
- Prefer `resolved_provider` and `resolved_model` for what actually ran, if
  known.
- Do not rename or remove existing `metadata.txt` fields in this slice.
- Record partial metadata when provider-specific values are unavailable.
- Do not parse secrets.
- Do not export prompt text.
- Do not commit `.agentops-runs/`.
- Preserve existing executor behavior.
- Preserve existing lifecycle behavior.
- Keep committed summaries optional and safe.

## Expected field behavior

Near-term expected values:

- `timestamp`: UTC ISO-8601 timestamp.
- `run_id`: current AgentOps run id.
- `task_id`: parsed from run id or empty/unknown if unavailable.
- `phase`: usually `executor` for this slice.
- `role`: usually `executor` for this slice.
- `harness`: likely `OpenCode` for `scripts/run-opencode-executor.sh`.
- `requested_model`: value requested by the workflow, usually
  `AGENTOPS_EXECUTOR_MODEL`.
- `resolved_provider`: best-effort provider name if reliably known, otherwise
  `unknown`.
- `resolved_model`: best-effort model name if reliably known, otherwise
  `unknown`.
- token counts: `unknown` unless reliably available without unsafe log parsing.
- `duration_ms`: derive from wrapper timing where possible.
- `retry_reason` / `fallback_reason`: empty unless reliably known.
- `exit_code`: executor command exit code.
- `final_outcome`: `unknown` for plain executor runs unless known at this stage;
  later outcome helpers may update or summarize outcome separately.
- `error_class`, `error_reason`, `debug_hint`: empty for successful runs unless
  available safely.

## Bad-model/debug fixture

Do not implement the bad-model fixture in this task.

Create or keep a separate follow-up task for:

```text
observability-03-add-bad-model-debug-fixture
```

That follow-up should intentionally request an invalid or unsupported model and
verify the failure path records useful routing metadata.

This task should only make the writer capable of recording failure fields when
they are available.

## Non-goals

- Do not implement the bad-model fixture.
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

These may remain partially open during implementation if values are not reliably
available yet:

- Which token fields are reliably available without parsing unsafe logs?
- Can `resolved_provider` and `resolved_model` be derived safely from existing
  configuration, or should they remain `unknown` for now?
- Should later outcome helpers update routing metadata, or should outcome remain
  separate in `outcome.txt`?
- Should the writer be inline in `run-opencode-executor.sh` or extracted into a
  small helper script?

Do not block the first implementation on unavailable provider-specific fields.
Use `unknown` when needed.

## Promotion decision

Decision: promote_to_ready

Reason:
`070` accepted the routing metadata design and chose the near-term key/value
`routing.txt` artifact under `.agentops-runs/<run-id>/`.

Next action:
Promote and implement the smallest safe writer. Keep the bad-model fixture as a
follow-up.

## Promotion criteria

- `docs/AGENTOPS-ROUTING-METADATA.md` exists.
- Metadata fields are decided.
- Storage format is decided: key/value `routing.txt`.
- Write scope is concrete.
- Verification commands are concrete.
- No routing-policy changes are included.

## Verification

Base verification:

```bash
git status --short --branch
git diff --stat
bash -n scripts/run-opencode-executor.sh
bash -n scripts/render-agentops-run-summary.sh
bash -n scripts/record-agentops-outcome.sh
# If a helper script is added in this slice, include it explicitly:
# bash -n scripts/write-agentops-routing-metadata.sh
scripts/check-agentops-lifecycle.sh
```

Routing metadata smoke verification:

```bash
printf 'test prompt\n' > /tmp/agentops-routing-smoke.prompt.md

AGENTOPS_RUN_ID=TASK-xxxx-routing-smoke \
AGENTOPS_EXECUTOR_COMMAND='printf "ok\n"' \
scripts/run-opencode-executor.sh /tmp/agentops-routing-smoke.prompt.md

test -f .agentops-runs/TASK-xxxx-routing-smoke/metadata.txt
test -f .agentops-runs/TASK-xxxx-routing-smoke/routing.txt

grep -q '^timestamp=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^run_id=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^task_id=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^phase=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^role=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^harness=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^requested_model=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^resolved_provider=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^resolved_model=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^token_counts_prompt=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^token_counts_completion=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^token_counts_total=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^duration_ms=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^retry_reason=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^fallback_reason=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^exit_code=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^final_outcome=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^error_class=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^error_reason=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
grep -q '^debug_hint=' .agentops-runs/TASK-xxxx-routing-smoke/routing.txt
```

Safety verification:

```bash
# Optional diagnostic: ignored local run artifacts may appear here.
git status --short --ignored | grep '.agentops-runs/' || true

# Required check: .agentops-runs must not be tracked.
if git status --short | grep '.agentops-runs/'; then
  echo 'FAIL: .agentops-runs contains tracked changes'
  exit 1
fi
```

Do not use `|| true` to mask required verification failures. The optional
ignored-file diagnostic above is allowed because it is not a required pass/fail
check.

## Accept criteria

- `.agentops-runs/<run-id>/routing.txt` is written for executor runs.
- The artifact uses key/value text format.
- The artifact includes the selected routing metadata fields.
- Missing provider-specific fields are handled gracefully with `unknown` or empty
  values according to the design.
- Prompt text and secrets are not exported.
- Existing `metadata.txt` behavior remains compatible.
- Existing executor and lifecycle behavior remains compatible.
- `.agentops-runs/` artifacts remain gitignored and uncommitted.
- Documentation is updated only as needed to explain the new metadata artifact.
- No bad-model fixture, dashboard, automatic cost optimization, routing-policy
  change, or lifecycle redesign is included.

## Notes

This task should remain intentionally small.

The purpose is to create the first reliable metadata foundation for later work:

- routing/model usage audit
- bad-model debug fixture
- queryable local run summaries
- cost-aware model routing policy

Do not combine those follow-ups into this implementation slice.
