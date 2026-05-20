# observability-00 — Document AgentOps observability workstream intent

## Status

planned

## Goal

Create a short documentation page explaining why the AgentOps
observability tasks exist and how the related slices fit together.

Suggested target doc:

`docs/AGENTOPS-OBSERVABILITY.md`

## Background / why now

We keep revisiting why the observability tasks exist.

The original trigger was reviewing local AgentOps run summaries. Those
summaries showed activity signals such as:

- model
- prompt size
- duration
- stdout/stderr size
- exit code
- local artifact path

That was useful, but incomplete. It did not answer whether a run
produced useful value, repeated an old prompt, used the intended model
role, or wasted time/cost.

This context should be captured in repo documentation so the intent
does not live only in chat memory.

## Problem statement

The observability tasks are related, but their relationship is not
obvious from the individual task files alone.

Without a short workstream overview, it is easy to forget why these
tasks exist or accidentally treat them as unrelated metadata tweaks.

## Smallest useful slice

Create `docs/AGENTOPS-OBSERVABILITY.md` with a concise workstream
overview.

The doc should explain:

- origin of the observability workstream
- core questions it should answer
- how current planned/ready slices fit together
- safety rules for local run metadata and prompt handling

No implementation work in this slice.

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

TBD

Likely candidates:

- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/DOCUMENTATION-MAP.md`
- `.agentops/tasks/ready/TASK-0089-run-outcome-metadata.md` (or its
  `done/` counterpart, once landed)
- `.agentops/tasks/planned/71-observability-04-wire-decision-helpers-to-outcome-writer.md`
- `.agentops/tasks/planned/72-observability-05-noop-blocked-revert-outcome-paths.md`
- `.agentops/tasks/planned/80-observability-02-prompt-hash-metadata.md`
- `.agentops/tasks/planned/90-observability-03-agent-model-usage-audit.md`
- `.agentops/tasks/planned/100-policy-01-cost-aware-agentops-model-routing.md`

## Write scope

TBD

Likely candidates:

- `docs/AGENTOPS-OBSERVABILITY.md` (new)
- minimal cross-link update to `docs/DOCUMENTATION-MAP.md` if needed to
  surface the new doc

Do not modify executor wrappers, helper scripts, or task files.

## Requirements

TBD

When ready, this section should contain concrete requirements covering:

- exact doc location (`docs/AGENTOPS-OBSERVABILITY.md` unless a better
  home is identified)
- whether the workstream overview also needs a one-line pointer from
  `docs/DOCUMENTATION-MAP.md`
- which related slices the "Current slices" section names (must reflect
  the actual planned/ready state at promotion time)

Suggested content (to confirm at promotion):

````md
# AgentOps Observability Workstream

## Origin

This workstream started from reviewing local AgentOps run summaries.

The existing summaries showed activity:

- model
- prompt size
- duration
- stdout/stderr size
- exit code
- local artifact path

That was useful, but incomplete. It did not answer whether the run
produced value, repeated an old prompt, used the intended model role,
or wasted time/cost.

## Core questions

- What happened in this run?
- Which prompt and model were used?
- Was the prompt repeated?
- Which model role was used: coordinator, executor, helper, or
  reviewer?
- What was the final review outcome?
- Did the run produce accepted value, revision work, no-op, blocked
  output, or reverted output?
- Where might cost/time/token waste be hiding?

## Current slices

- Run outcome metadata: connect executor activity to review value.
- Prompt hash metadata: detect repeated prompts without exporting
  prompt text.
- Agent/model usage audit: understand model-role traffic safely.
- Cost-aware model routing policy: choose models deterministically by
  lifecycle role.

## Safety rules

- Keep raw `.agentops-runs/` logs local and gitignored.
- Do not export full prompt content.
- Prefer hashes, counts, sizes, and safe summaries.
- Do not parse secrets.
- Do not build a dashboard before the local metadata contract is
  stable.
````

Workflow requirements (to apply at promotion):

- The execution prompt MUST start with `/hermetic-coding-orchestrator`.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near
  the beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if
  invoking OpenCode.

## Non-goals

- Do not implement any helper scripts.
- Do not modify executor wrappers (`scripts/run-opencode-executor.sh`).
- Do not modify `scripts/record-agentops-outcome.sh` or other helper
  scripts.
- Do not modify task files in `planned/`, `ready/`, `running/`,
  `review/`, or `done/`.
- Do not redefine AgentOps lifecycle states.
- Do not add automatic quality judgment.
- Do not build a dashboard.
- Do not export prompt text or other sensitive run contents.
- Do not parse raw logs.

## Open questions

- Is `docs/AGENTOPS-OBSERVABILITY.md` the right home, or should this
  content live as a section inside an existing doc (e.g.
  `docs/RUN-OBSERVABILITY.md` or `docs/RUN-AUDIT.md`)?
- Should the doc link out to each related task file by path, or only
  by name (path links rot when tasks move between lifecycle dirs)?
- Should the "Current slices" section enumerate task IDs, or only
  describe slices by theme (task IDs are more precise but rot faster
  than themes)?

## Promotion decision

Decision: keep_planned.

Reason:
The doc location and link strategy are open questions, and the
"Current slices" listing should reflect the workstream state at
promotion time (which slices are ready, which are planned, which are
done). Lock those before promoting.

Next action:
Decide doc location, link strategy, and the slice-listing approach.
Then promote.

## Promotion criteria

This task can be promoted to ready when:

- the doc location is decided (`docs/AGENTOPS-OBSERVABILITY.md` or an
  alternative)
- the link strategy is decided (by path, by name, or by task ID)
- the "Current slices" listing approach is decided
- read/write scope is concrete

## Verification

```bash
git status --short --branch
git diff --stat
```

Add task-specific checks below this base set during promotion (e.g.
confirming the new doc is referenced from `docs/DOCUMENTATION-MAP.md`
if that is part of the chosen scope).

Do not use `|| true` to mask failures.

## Accept criteria

TBD during promotion.

Expected direction:

- `docs/AGENTOPS-OBSERVABILITY.md` (or the chosen alternative) exists
  and is concise.
- The doc covers origin, core questions, current slices, and safety
  rules.
- The doc does not export prompt text or other sensitive run contents.
- No helper scripts, executor wrappers, or task files are modified.
- Verification commands pass or failures are explained.

## Hermes/coder collection prompt

TBD during promotion.

When ready, use the canonical Hermes/coder collection prompt shape from
the planned/ready task template, with the concrete ready task path.

## Return format

TBD during promotion.

When ready, use the standard AgentOps return format:

```text
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
```

## Notes

Relationship to other observability planning:

- TASK-0089 (observability-01, ready) — run outcome metadata writer.
- observability-04 (planned 71) — wire decision helpers to outcome
  writer.
- observability-05 (planned 72) — paths for `no-op`, `blocked`, and
  `revert` outcomes.
- observability-02 (planned 80) — prompt-hash metadata.
- observability-03 (planned 90) — agent/model usage audit.
- policy-01 (planned 100) — cost-aware model routing policy.

This task is documentation-only. Keep it that way. Heavier work —
implementation, dashboards, automated quality judgment — belongs in
the other observability slices, not here.
