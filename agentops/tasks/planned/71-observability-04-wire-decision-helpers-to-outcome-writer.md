# observability-04 — Wire decision helpers to outcome writer

## Status

planned

## Goal

Update existing decision helpers so they can optionally record outcome
metadata through `scripts/record-agentops-outcome.sh`.

## Background / why now

TASK-0089 (observability-01) adds the standalone outcome writer
`scripts/record-agentops-outcome.sh`, which writes
`.agentops-runs/<run-id>/outcome.txt` for any of the five decisions
(`accept`, `revise`, `revert`, `no-op`, `blocked`).

That task intentionally does **not** modify the existing decision-knowing
helpers:

- `scripts/accept-agentops-task.sh` (knows `decision=accept`)
- `scripts/revise-agentops-task.sh` (knows `decision=revise`)

As a result, today nothing automatically writes `outcome.txt` after an
accept or revise decision. Operators have to call the writer manually.
This task closes that gap by wiring the existing decision helpers to the
writer, behind an explicit opt-in flag.

## Problem statement

Until the existing decision helpers call the outcome writer, the writer
is useful only via manual invocation. The accept and revise flows produce
the post-review data points (decision, diff stats, verification exit
code) but do not persist them as outcome metadata.

## Smallest useful slice

Add an opt-in run-id argument to `scripts/accept-agentops-task.sh` and
`scripts/revise-agentops-task.sh`. When provided, the helper calls
`scripts/record-agentops-outcome.sh` to write `outcome.txt`. When not
provided, the helper behaves exactly as today.

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

TBD

Likely candidates:

- `scripts/accept-agentops-task.sh`
- `scripts/revise-agentops-task.sh`
- `scripts/record-agentops-outcome.sh` (added by TASK-0089)
- `agentops/tasks/done/TASK-0089-run-outcome-metadata.md` (when done)
  or `agentops/tasks/ready/TASK-0089-run-outcome-metadata.md` (until then)
- `.agentops-runs/` (layout)
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`

## Write scope

TBD

Likely candidates:

- `scripts/accept-agentops-task.sh`
- `scripts/revise-agentops-task.sh`
- minimal docs update if the new flag/argument needs to be documented

Do not modify `scripts/run-opencode-executor.sh` or other execution
wrappers.

## Requirements

TBD

When ready, this section should contain concrete implementation
requirements covering:

- exact CLI shape (e.g. `--run-id <run-id>` flag vs trailing positional
  argument) for both helpers
- how the helper computes or accepts each outcome field
  (`changed_files_count`, `diff_bytes`, `diff_stat_lines`,
  `verification_exit_code`) — derived from `git diff` against the source
  ref, or passed in explicitly
- exit-code semantics if the outcome writer fails (does the decision
  helper still succeed, or does the whole call fail?)
- behavior when the run dir does not exist
- preservation of all current behavior when no run-id is provided
- no duplication of outcome-writing or key=value formatting logic — call
  `scripts/record-agentops-outcome.sh` instead

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

- Do not modify `scripts/run-opencode-executor.sh`.
- Do not modify `scripts/record-agentops-outcome.sh` (that is TASK-0089's
  contract).
- Do not add helpers for `revert`, `no-op`, or `blocked` decisions in
  this task — those belong in observability-05.
- Do not guess run id from task slug or "most recent" heuristics.
- Do not parse raw logs.
- Do not add automatic quality judgment.
- Do not redesign the accept/revise flows beyond adding the opt-in
  outcome integration.
- Do not move outcome data into `metadata.txt`.

## Open questions

- Exact CLI shape: `--run-id <run-id>` flag vs trailing positional
  argument?
- How should `changed_files_count`, `diff_bytes`, `diff_stat_lines`, and
  `verification_exit_code` be derived or passed? Derived from `git diff`
  inside the helper, or passed in by the caller?
- Should integration be accept-only first as the smallest slice, or
  accept and revise together?
- Should `accept-agentops-task.sh`'s existing `<decision-note>` argument
  remain entirely separate from `outcome.txt`, matching TASK-0089's
  decision that notes are not stored in `outcome.txt` in v1?
- If the outcome writer fails (e.g. run dir missing), should the
  decision helper still succeed (warn-and-continue) or fail
  (strict-and-rollback)?

## Promotion decision

Decision: keep_planned.

Reason:
This task depends on `scripts/record-agentops-outcome.sh` from TASK-0089.
Until that writer exists and its contract is stable, the integration
points (argument shape, error semantics) cannot be locked. Several
implementation questions (CLI shape, field derivation, scope of accept
vs accept+revise, error semantics) remain open.

Next action:
Wait for TASK-0089 to be done or for its writer contract to be
ratified, then lock the open questions and promote.

## Promotion criteria

This task can be promoted to ready when:

- TASK-0089 is done, or its writer contract (helper signature, file
  format, validation rules) is explicitly ratified as stable
- the CLI shape for the new opt-in argument is decided
- the field-derivation strategy is decided (derived vs explicit)
- the accept-only-vs-accept+revise scope is decided
- the writer-failure handling rule is decided
- read/write scope is concrete

## Verification

```bash
git status --short --branch
bash -n scripts/accept-agentops-task.sh
bash -n scripts/revise-agentops-task.sh
git diff --stat
```

Add task-specific checks below this base set during promotion (smoke
tests for: no-flag = legacy behavior; `--run-id <id>` triggers
outcome.txt writing in a disposable run dir; missing-run-dir error
path).

Do not use `|| true` to mask failures.

## Accept criteria

TBD during promotion.

Expected direction:

- `scripts/accept-agentops-task.sh` and (depending on slice decision)
  `scripts/revise-agentops-task.sh` accept the new opt-in run-id
  argument and call `scripts/record-agentops-outcome.sh`.
- Behavior is unchanged when no run-id is provided.
- The decision helpers do not duplicate outcome-writing logic.
- `outcome.txt` is written only when an explicit run-id is provided.
- No modification to `scripts/run-opencode-executor.sh` or
  `scripts/record-agentops-outcome.sh`.
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

- TASK-0089 (observability-01, ready) — defines the standalone outcome
  writer this task wires into.
- observability-05 (planned 72, no-op/blocked/revert outcome paths) —
  parallel follow-up that decides how decisions without existing
  helpers record outcomes. Independent of this task.
- observability-02 (planned 80, prompt-hash metadata) — separate
  metadata stream; not coupled to this task.
- observability-03 (planned 90, agent/model usage audit) — separate
  observability concern; not coupled to this task.

Keep this slice narrow: opt-in integration only. Heavier work — making
outcome recording mandatory, adding lifecycle helpers for the missing
decisions, or auto-deriving run-id — belongs in later tasks.
