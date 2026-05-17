# observability-05 — Define no-op blocked revert outcome paths

## Status

planned

## Goal

Define safe, explicit paths for recording `no-op`, `blocked`, and `revert`
outcomes using `scripts/record-agentops-outcome.sh`.

## Background / why now

TASK-0089 (observability-01) adds the standalone outcome writer
`scripts/record-agentops-outcome.sh`, which already accepts all five
decisions (`accept`, `revise`, `revert`, `no-op`, `blocked`) as valid
input.

The accept and revise decisions have existing helper homes:

- `scripts/accept-agentops-task.sh` (knows `decision=accept`)
- `scripts/revise-agentops-task.sh` (knows `decision=revise`)

The other three decisions do not:

- `revert` — no helper currently owns this lifecycle action
- `no-op` — no helper currently owns this lifecycle action
- `blocked` — no helper currently owns this lifecycle action

Today, recording an outcome for these three decisions means manually
invoking `scripts/record-agentops-outcome.sh` with the right arguments
and remembering to do it. That is fragile and easy to forget.

This task is a planning slice: decide what the right answer is before
adding more scripts.

## Problem statement

Without an explicit path for `no-op`, `blocked`, and `revert` outcomes,
the writer is reachable only through manual invocation in exactly the
cases where operators are least likely to remember to invoke it
(blocked/no-op flows often skip cleanup steps; revert flows are
exceptional).

The result is observability gaps for the very decisions that most
benefit from being recorded.

## Smallest useful slice

A planning note that picks one of:

1. add three small dedicated helpers
   (`scripts/record-agentops-noop.sh`,
   `scripts/record-agentops-blocked.sh`,
   `scripts/record-agentops-revert.sh`) that each call
   `scripts/record-agentops-outcome.sh` under the hood, or
2. document the manual `scripts/record-agentops-outcome.sh`
   invocation pattern for these three decisions in
   `docs/RUN-OBSERVABILITY.md` (or equivalent) and treat manual usage
   as sufficient, or
3. fold these decisions into a future generic review helper rather
   than three per-decision helpers.

No implementation in this slice. The output is the decision plus a
short rationale.

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

TBD

Likely candidates:

- `scripts/record-agentops-outcome.sh` (added by TASK-0089)
- `scripts/accept-agentops-task.sh`
- `scripts/revise-agentops-task.sh`
- `agentops/tasks/done/TASK-0089-run-outcome-metadata.md` (when done)
  or `agentops/tasks/ready/TASK-0089-run-outcome-metadata.md` (until then)
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/WORKFLOW.md`
- `.agentops-runs/` (layout)

## Write scope

TBD

Likely candidates:

- a short planning/decision note inside this task file, or
- a small docs update under `docs/` describing the chosen path, or
- (only if the decision is option 1) future task files for each of the
  three dedicated helpers — but those follow-up tasks belong in their
  own promotion slices, not in this one

Do not modify `scripts/run-opencode-executor.sh` or
`scripts/record-agentops-outcome.sh` (TASK-0089's contract).

## Requirements

TBD

When ready, this section should contain a concrete decision covering:

- chosen path (dedicated helpers vs documented manual usage vs future
  generic review helper)
- where blocked/no-op/revert decisions should be documented in the
  AgentOps workflow (which doc, which section)
- how `verification_exit_code` should be represented when verification
  was not run (e.g. `unknown` literal, vs `0`, vs omission) — note that
  TASK-0089 already locks `unknown` as a valid value; this task should
  state when each value applies for these three decisions
- minimum field set required for `no-op` (e.g. `changed_files_count=0`,
  `diff_bytes=0`, `diff_stat_lines=0`, `verification_exit_code=unknown`)
- minimum field set required for `blocked` (same fields; semantics
  documented)
- minimum field set required for `revert` (whether diff stats refer to
  the revert diff or the original change)

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

- Do not implement any scripts in this slice.
- Do not modify `scripts/run-opencode-executor.sh`.
- Do not modify `scripts/record-agentops-outcome.sh` (that is TASK-0089's
  contract).
- Do not modify `scripts/accept-agentops-task.sh` or
  `scripts/revise-agentops-task.sh` (their outcome integration is
  observability-04's scope).
- Do not redesign the accept/revise/review flow.
- Do not parse raw logs.
- Do not add automatic quality judgment.
- Do not move outcome data into `metadata.txt`.
- Do not define new AgentOps lifecycle states.
- Do not change the existing outcome writer format.

## Open questions

- Should there be separate helpers, e.g.
  `scripts/record-agentops-noop.sh`,
  `scripts/record-agentops-blocked.sh`,
  `scripts/record-agentops-revert.sh`?
- Or should docs instruct manual `scripts/record-agentops-outcome.sh`
  usage for these cases?
- Or should these decisions be folded into a future generic review
  helper rather than three per-decision helpers?
- Where in the AgentOps workflow docs should blocked/no-op/revert
  decisions be documented (`docs/RUN-OBSERVABILITY.md`,
  `docs/RUN-AUDIT.md`, `docs/WORKFLOW.md`, or a new section)?
- How should `verification_exit_code` be represented when verification
  was not run (e.g. blocked-before-verify, no-op with no diff)?
  TASK-0089 allows `unknown` — this task should say when to use it.
- For `revert`, do `changed_files_count`, `diff_bytes`, and
  `diff_stat_lines` refer to the revert diff itself or to the diff
  being reverted?

## Promotion decision

Decision: keep_planned.

Reason:
This task depends on `scripts/record-agentops-outcome.sh` from TASK-0089.
Until that writer exists and operators have used it manually for at
least one `no-op`, `blocked`, or `revert` decision, the right path
(dedicated helpers vs documented manual usage vs future generic review
helper) cannot be picked with confidence. The open questions above
remain unresolved.

Next action:
Wait for TASK-0089 to be done. Then evaluate whether manual writer
usage is sufficient or whether dedicated helpers (or a future generic
review helper) are warranted, lock the open questions, and promote.

## Promotion criteria

This task can be promoted to ready when:

- TASK-0089 is done, or its writer contract is explicitly ratified as
  stable
- the chosen path (dedicated helpers vs documented manual usage vs
  future generic review helper) is decided
- the doc location for blocked/no-op/revert documentation is decided
- the `verification_exit_code` representation rule for these decisions
  is decided
- the minimum field sets for `no-op`, `blocked`, and `revert` are
  decided
- the `revert` diff-stats interpretation is decided
- read/write scope is concrete

## Verification

```bash
git status --short --branch
git diff --stat
```

Add task-specific checks below this base set during promotion. If the
chosen path adds new scripts, include `bash -n` checks for each.

Do not use `|| true` to mask failures.

## Accept criteria

TBD during promotion.

Expected direction:

- A clear decision is recorded for the no-op/blocked/revert outcome
  recording path.
- The chosen path does not modify the outcome writer or executor
  wrapper.
- The chosen path does not redesign the review/accept/revise flow.
- The chosen path does not parse raw logs or add automatic quality
  judgment.
- The chosen path uses the existing outcome writer format only.
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
  writer this task plans paths into.
- observability-04 (planned 71, wire decision helpers to outcome
  writer) — parallel follow-up that handles the accept and revise
  decisions, which already have helper homes. Independent of this task.
- observability-02 (planned 80, prompt-hash metadata) — separate
  metadata stream; not coupled to this task.
- observability-03 (planned 90, agent/model usage audit) — separate
  observability concern; not coupled to this task.

Keep this slice narrow: planning only. Implementation of any chosen
path (dedicated helpers, doc updates, or a future generic review
helper) belongs in later tasks once the path is locked.
