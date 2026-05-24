# observability-00 — Document AgentOps observability workstream intent

## Status

planned

## Goal

Create a short documentation page explaining why the AgentOps observability
workstream exists and how the related slices fit together.

Target doc:

`docs/AGENTOPS-OBSERVABILITY.md`

## Background / why now

AgentOps observability is no longer only an idea.

Recent work established local run auditing and routing metadata:

- raw/local run artifacts under `.agentops-runs/<run-id>/`
- safe committed summaries under `.agentops/results/`
- existing `metadata.txt` for execution-level facts
- new `routing.txt` for routing/model metadata

That is useful, but the relationship between the observability slices is not
obvious from individual task files alone.

We need a concise overview so future work does not treat outcome metadata,
routing metadata, prompt hashes, bad-model fixtures, model usage audit, and
cost-aware routing as unrelated tweaks.

## Problem statement

Without a workstream overview, it is easy to forget:

- why observability exists
- which questions it should answer
- which artifacts are local-only
- which summaries are safe to commit
- why cost-aware routing must come after measurement
- why prompt text and raw logs must not be exported

This context should live in repo documentation, not only in chat history.

## Smallest useful slice

Create `docs/AGENTOPS-OBSERVABILITY.md`.

The doc should explain:

- origin of the observability workstream
- core questions observability should answer
- current and near-term slices by capability/theme
- safety rules for local run metadata, prompt handling, logs, and secrets
- why dashboards/cost-aware routing come later

No implementation work in this slice.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/AGENTOPS-ROUTING-METADATA.md`
- `docs/AGENTOPS-PACKAGING-BOUNDARIES.md`
- `docs/DOCUMENTATION-MAP.md`
- `.agentops/tasks/done/` examples for recently completed observability tasks
- `.agentops/results/` examples for recently completed observability tasks
- `.agentops/tasks/planned/` observability and policy follow-up tasks, if present

## Write scope

- `docs/AGENTOPS-OBSERVABILITY.md`
- `docs/DOCUMENTATION-MAP.md` only if needed to surface the new doc

Do not modify executor wrappers, helper scripts, lifecycle helpers, or task
files.

## Requirements

- Create `docs/AGENTOPS-OBSERVABILITY.md`.
- Keep the doc concise and practical.
- Use capability/theme-based slice descriptions instead of fragile lifecycle
  paths.
- Mention task IDs only for completed/landed work when useful.
- Do not link to lifecycle paths that will rot when files move between
  `planned/`, `ready/`, `review/`, and `done/`.
- Include a short section for each:
  - Origin
  - Core questions
  - Current artifacts
  - Current / near-term slices
  - Safety rules
  - What comes later
- Mention the current artifact split:
  - `.agentops-runs/<run-id>/metadata.txt`
  - `.agentops-runs/<run-id>/routing.txt`
  - `.agentops/results/`
- Explain that `.agentops-runs/` is local and gitignored.
- Explain that committed files should contain only safe summaries.
- Explain that prompt text, raw logs, request/response payloads, auth config,
  and secrets must not be exported.
- Explain that cost-aware routing should not be implemented until the metadata
  foundation is stable.
- Add a one-line pointer from `docs/DOCUMENTATION-MAP.md` if that is how the
  repository surfaces docs.

## Suggested doc outline

```md
# AgentOps Observability

## Origin

This workstream started from reviewing local AgentOps run summaries.

The early summaries showed activity: model, prompt size, duration,
stdout/stderr size, exit code, and local artifact paths. That was useful, but
not enough to answer whether a run produced value, repeated a prompt, used the
intended model role, or wasted time/cost.

## Core questions

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

- `.agentops-runs/<run-id>/metadata.txt` — local execution metadata.
- `.agentops-runs/<run-id>/routing.txt` — local routing/model metadata.
- `.agentops/results/` — committed safe summaries and review/result notes.

## Current and near-term slices

- Run audit metadata: capture basic executor facts.
- Routing metadata: record requested model, resolved provider/model, duration,
  exit code, outcome, retry/fallback/error fields.
- Bad-model fixture: intentionally exercise failure handling.
- Prompt hash metadata: detect repeated prompts without exporting prompt text.
- Agent/model usage audit: understand traffic by role/model safely.
- Cost-aware routing policy: later deterministic model selection based on
  lifecycle role and measured behavior.

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

After the metadata foundation is reliable, AgentOps can add query helpers,
failure fixtures, summaries, and eventually cost-aware model routing.
```

## Workflow requirements

- The execution prompt should use the canonical skill command:
  `/agentops-coder`
- The agent should include:
  `USING_SKILL: agentops-coder`
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking
  OpenCode.

## Non-goals

- Do not implement helper scripts.
- Do not modify executor wrappers.
- Do not modify `scripts/run-opencode-executor.sh`.
- Do not modify `scripts/record-agentops-outcome.sh`.
- Do not modify lifecycle helpers.
- Do not modify task files in lifecycle directories.
- Do not redefine AgentOps lifecycle states.
- Do not add automatic quality judgment.
- Do not build a dashboard.
- Do not implement cost-aware routing.
- Do not export prompt text or sensitive run contents.
- Do not parse raw logs.

## Open questions

These should be resolved during promotion:

- Should `docs/DOCUMENTATION-MAP.md` receive a pointer to the new doc?
- Should completed task IDs be mentioned in the doc, or should the doc stay
  purely theme-based?

Do not block the doc on historical perfection. Prefer a concise current overview.

## Promotion decision

Decision: keep_planned

Reason:
The task is now shaped, but should be promoted only after confirming whether
`docs/DOCUMENTATION-MAP.md` should be updated and whether completed task IDs
should be mentioned.

Next action:
Promote to ready after the link strategy is decided.

## Promotion criteria

This task can be promoted to ready when:

- doc location is confirmed as `docs/AGENTOPS-OBSERVABILITY.md`
- link strategy is decided
- read/write scope is still accurate
- the canonical skill marker remains `/agentops-coder` / `USING_SKILL:
  agentops-coder`

## Verification

```bash
git status --short --branch
git diff --stat
test -f docs/AGENTOPS-OBSERVABILITY.md
grep -q '^# AgentOps Observability' docs/AGENTOPS-OBSERVABILITY.md
grep -q '.agentops-runs' docs/AGENTOPS-OBSERVABILITY.md
grep -q 'routing.txt' docs/AGENTOPS-OBSERVABILITY.md
grep -q 'Do not export full prompt' docs/AGENTOPS-OBSERVABILITY.md
```

If `docs/DOCUMENTATION-MAP.md` is updated:

```bash
grep -q 'AGENTOPS-OBSERVABILITY.md' docs/DOCUMENTATION-MAP.md
```

Do not use `|| true` to mask required verification failures.

## Accept criteria

- `docs/AGENTOPS-OBSERVABILITY.md` exists.
- The doc covers origin, core questions, current artifacts, current/near-term
  slices, safety rules, and later work.
- The doc references `.agentops-runs/<run-id>/routing.txt`.
- The doc does not export prompt text or other sensitive run contents.
- No helper scripts, executor wrappers, lifecycle helpers, or task files are
  modified.
- Verification commands pass or failures are explained.

## Hermes/coder collection prompt

```text
/agentops-coder

Execute AgentOps ready task: .agentops/tasks/ready/<READY_TASK_FILENAME>.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- create/switch appropriate task branch or worktree
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME and OPENCODE_XDG_DATA_HOME
- use task-specified model
- do not fallback
- do not commit
- independently verify

Return:
Plan
Implementation
Verification
Review
Changed files
Uncertainty
```

## Return format

```text
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
```

## Notes

This task is documentation-only.

Keep it small. The purpose is to make the observability workstream legible
before adding more metadata, fixtures, helpers, dashboards, or cost-aware model
routing.
