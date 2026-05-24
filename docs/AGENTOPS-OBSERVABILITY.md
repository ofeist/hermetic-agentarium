# AgentOps Observability

## Origin

This workstream started from reviewing local AgentOps run summaries.

The early summaries showed activity: model, prompt size, duration,
stdout/stderr size, exit code, and local artifact paths. That was useful, but
not enough to answer whether a run produced value, repeated a prompt, used the
intended model role, or wasted time/cost.

## Core questions

Observability should answer:

- What happened in this run?
- Which model was requested?
- Which provider/model actually resolved, if known?
- How long did the run take?
- Did the run produce accepted value, revision work, no-op, blocked output, or
  reverted output?
- Was the prompt repeated?
- Which lifecycle role was involved: coordinator, executor, reviewer, helper?
- Where might cost/time/token waste be hiding?

## Current artifacts

Local run artifacts under `.agentops-runs/<run-id>/` (gitignored):

- `metadata.txt` — local executor metadata, including prompt size/hash fields
  such as `prompt_sha256`.
- `routing.txt` — local routing/model metadata (requested model, resolved
  provider/model, token counts, duration, retry/fallback fields, exit code,
  final outcome).
- `outcome.txt` — local post-review outcome metadata (review decision, diff
  stats, verification status/exit code).

Committed safe summaries under `.agentops/results/`:

- `TASK-xxxx-result.md` — reviewed result notes containing only safe
  summaries (decision, changed files, verification commands, high-level
  notes). Never contains raw logs or prompt content.

## Current and near-term slices

- **Run audit metadata**: capture basic executor facts (model, prompt size,
  duration, stdout/stderr size, exit code, `prompt_sha256`). Implemented in
  `scripts/run-opencode-executor.sh`.

- **Routing metadata**: record requested model, resolved provider/model,
  duration, exit code, outcome, retry/fallback/error fields. Planning in
  `docs/AGENTOPS-ROUTING-METADATA.md`, writer implemented.

- **Run outcome metadata**: record post-review decision and diff/verification
  facts via `scripts/record-agentops-outcome.sh`.

- **Bad-model fixture**: intentionally exercise failure handling with an
  invalid model to verify that routing metadata survives provider resolution
  failure.

- **Prompt hash metadata**: detect repeated prompts without exporting prompt
  text (using `prompt_sha256` in `metadata.txt`).

- **Agent/model usage audit**: understand traffic by role/model safely,
  identifying where repeated prompts or waste might be hiding.

- **Cost-aware routing policy**: later deterministic model selection based on
  lifecycle role and measured behavior. Deliberately deferred until the
  metadata foundation is stable.

## Safety rules

- Keep raw `.agentops-runs/` logs local and gitignored.
- Do not export full prompt content.
- Do not copy stdout/stderr contents into committed docs.
- Do not export provider request/response payloads.
- Do not parse or print secrets.
- Prefer hashes, counts, sizes, durations, exit codes, and safe summaries.
- Do not build dashboards or routing policy before the local metadata contract
  is stable.

## What comes later

After the metadata foundation is reliable, AgentOps can add:

- decision-helper wiring to the outcome metadata writer
- bad-model debug fixture for routing failure paths
- agent/model usage audit helpers
- Prometheus/Grafana dashboards from exported metrics
- cost-aware model routing based on role and measured performance

These are explicitly deferred until the local metadata contract and recording
paths are stable. Cost-aware routing especially must not be implemented before
we can reliably answer what actually ran, what it cost, and whether it produced
value.
