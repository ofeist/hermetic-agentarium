# observability-01 — Add AgentOps run outcome metadata

## Status

planned

## Goal

Record a small post-review outcome summary for each AgentOps executor run,
so run cost/activity can be connected to actual value.

## Background / why now

The existing run artifacts capture activity signals such as prompt size,
duration, stdout/stderr, and exit code. `IDEAS.md` notes that these show
activity but not whether the run produced useful value.

`.agentops-runs/<run-id>/metadata.txt` is the run-capture metadata written
by the executor wrapper. It records `run_id`, `harness`, `model`,
`prompt_file`, `started_at`, `finished_at`, `exit_code`. The executor
wrapper does *not* know the final review decision (accept / revise /
revert / no-op / blocked).

Current decision-knowing helpers (inspection of `scripts/`):

- `scripts/accept-agentops-task.sh` — takes `<task-slug> <decision-note>`
  and moves review→done. Knows `decision=accept`.
- `scripts/revise-agentops-task.sh` — takes `<source> <new-slug> <revision-note>`
  and creates a revision task. Knows `decision=revise`.
- `scripts/review-executor-result.sh` (13 lines) — only prints git
  status/diff. Does not know decision.
- `scripts/submit-agentops-task.sh` — moves ready→review. Does not know
  the final decision.

`decision=revert`, `decision=no-op`, and `decision=blocked` currently have
no existing helper home. Outcome metadata for those cases must either be
written via a new tiny helper or via a manual entry path.

## Problem statement

A long or expensive executor run may be accepted, rejected, revised,
blocked, or produce no useful diff. Without outcome metadata, observability
cannot separate useful work from waste. The executor wrapper cannot record
this — it does not know the final decision.

## Smallest useful slice

Extend the review/decision flow to write a small local
`.agentops-runs/<run-id>/outcome.txt` for one executor run after the
decision is known, without parsing raw logs or judging quality
automatically.

## Executor

Harness: TBD (default in this repo: OpenCode).
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- `.agentops-runs/` (layout and existing `metadata.txt` format)
- `scripts/run-opencode-executor.sh` (run-capture wrapper that writes metadata.txt)
- `scripts/run-ready-task.sh`
- `scripts/review-executor-result.sh`
- `scripts/submit-agentops-task.sh`
- `scripts/accept-agentops-task.sh`
- `scripts/revise-agentops-task.sh`
- `scripts/render-agentops-run-summary.sh`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `agentops/IDEAS.md`

## Write scope

- the selected decision-owner script(s), once chosen
- optional: a small new helper (e.g. `scripts/record-agentops-outcome.sh`)
  if the chosen design routes through a single writer
- optional docs update for the outcome metadata contract in
  `docs/RUN-AUDIT.md` or `docs/RUN-OBSERVABILITY.md`
- runtime side effect only: writes `.agentops-runs/<run-id>/outcome.txt`
  (gitignored; not committed)

## Requirements

Locked decisions:

- Outcome metadata lives in a **separate file**:
  `.agentops-runs/<run-id>/outcome.txt`.
  Reason: `metadata.txt` is run-capture metadata written by the executor
  wrapper. Outcome is post-review metadata written by the decision flow.
  Mixing them blurs ownership and lifecycle.
- The executor wrapper **must not** write `outcome.txt`. It does not know
  the final decision.
- `verification_exit_code` uses the explicit string `unknown` when
  verification was not run or its exit code is unavailable. Do not use
  fake numeric sentinels like `-1`.

Locked file format (key=value, one per line, no header):

```text
decision=accept|revise|revert|no-op|blocked
changed_files_count=<n>
diff_bytes=<n>
diff_stat_lines=<n>
verification_exit_code=<n>|unknown
```

Locked representations for non-trivial cases:

- `blocked` run (no diff, verification not run or failed):

  ```text
  decision=blocked
  changed_files_count=0
  diff_bytes=0
  diff_stat_lines=0
  verification_exit_code=unknown
  ```

- `no-op` run with passing verification:

  ```text
  decision=no-op
  changed_files_count=0
  diff_bytes=0
  diff_stat_lines=0
  verification_exit_code=0
  ```

- `no-op` run where verification was not exercised:

  ```text
  decision=no-op
  changed_files_count=0
  diff_bytes=0
  diff_stat_lines=0
  verification_exit_code=unknown
  ```

The implementation should:

- keep outcome metadata local (`.agentops-runs/<run-id>/outcome.txt`)
  unless a later, explicitly safe summary helper includes it
- avoid raw log parsing
- avoid automatic quality judgment
- make `accept`, `revise`, `revert`, `no-op`, and `blocked` runs all
  representable
- preserve the existing `.agentops-runs/` local-only boundary (no committed
  raw logs; `outcome.txt` is local)

Workflow requirements:

- The execution prompt MUST start with `/hermetic-coding-orchestrator` to
  explicitly invoke the custom skill.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near the
  beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration, not by task
  prompt text.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking
  OpenCode.

## Non-goals

- Do not build a dashboard.
- Do not add token accounting.
- Do not parse raw logs.
- Do not implement automatic quality judgment.
- Do not add Prometheus export in this task (separate observability work).
- Do not commit raw `.agentops-runs/` logs.
- Do not have the executor wrapper write `outcome.txt`.
- Do not extend `metadata.txt` to carry decision/outcome fields.

## Open questions

- Ownership shape: should a single new small helper
  (`scripts/record-agentops-outcome.sh`) be the sole writer, called by
  `accept-agentops-task.sh`, `revise-agentops-task.sh`, and (future)
  revert/no-op/blocked helpers — or should each decision-helper write
  `outcome.txt` inline?
- Coverage gap: `decision=revert`, `decision=no-op`, and `decision=blocked`
  have no current owner script. Should this task add minimal helpers for
  those decisions, or accept that those cases require manual `outcome.txt`
  entry in this slice?
- Run-id resolution: the decision-helpers take a `<task-slug>` but
  `.agentops-runs/<run-id>/` may use `<task-id>` only (e.g. `TASK-0040`)
  or `<task-id>-<extra-slug>` (e.g. `TASK-0055-dogfood-run-ready-task`).
  How should the writer locate the run dir — exact match on task-slug,
  most-recent `<task-id>-*` match, or an explicit `<run-id>` argument?
- Should `accept-agentops-task.sh`'s `<decision-note>` be appended to
  `outcome.txt` (e.g. `decision_note=...`) or kept separate?

## Promotion decision

Decision: keep_planned.

Reason:
Format, file location, blocked/no-op representation, and the rule that the
executor wrapper does not write outcome are locked. Real blockers remain:
ownership shape (single writer vs each-helper-inline), the coverage gap
for revert/no-op/blocked decisions, and run-id resolution between task-slug
and `.agentops-runs/<run-id>/`.

Next action:
Decide ownership shape, decide whether to add minimal revert/no-op/blocked
helpers in this slice or defer them, and lock the run-id resolution rule —
then promote.

## Promotion criteria

Promote to `ready` when:

- ownership shape is locked (single writer helper, or each-helper-inline)
- the revert/no-op/blocked coverage decision is made (add minimal helpers
  here, or defer)
- the run-id resolution rule is locked
- the decision-note handling is decided (in `outcome.txt` or not)
- write scope is concrete (which exact scripts get modified)

## Verification

```bash
git status --short --branch
git diff --stat
```

When promoted, also:

```bash
bash -n scripts/<changed-script>.sh
# happy path: after accept, .agentops-runs/<run-id>/outcome.txt exists and
# matches the locked key=value format
# blocked path: outcome.txt with decision=blocked, verification_exit_code=unknown
```

Do not use `|| true` to mask failures.

## Accept criteria

TBD during promotion.

Expected direction:

- Outcome metadata is written only after a review decision is available.
- Outcome metadata lives in `.agentops-runs/<run-id>/outcome.txt` (separate
  from `metadata.txt`).
- `accept`, `revise`, `revert`, `no-op`, and `blocked` runs are all
  representable using the locked format.
- The executor wrapper does not write `outcome.txt`.
- Raw `.agentops-runs/` logs are not committed.
- Existing run-capture metadata behavior is preserved.
- Verification commands pass or failures are explained.

## Hermes/coder collection prompt

TBD during promotion.

When ready, use the canonical Hermes/coder collection prompt shape from the
planned/ready task template, with the concrete ready task path.

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

This task is about connecting executor activity to review value. Keep it
local, small, and safe.

Inspection findings (planned-stage, may drift before promotion):

- `accept-agentops-task.sh` and `revise-agentops-task.sh` already know
  their decisions and take a `<task-slug>` argument.
- `review-executor-result.sh` (13 lines) only prints git diff and is not
  the right owner.
- `submit-agentops-task.sh` does not know the final decision.
- `.agentops-runs/<run-id>/metadata.txt` already records `run_id` and
  `prompt_file` — usable to resolve task-slug→run-id mapping.
- No existing helper owns `revert`, `no-op`, or `blocked` decisions.
