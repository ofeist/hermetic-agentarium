# TASK-0089 — Add AgentOps run outcome metadata

## Status

review

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

Add a single small writer helper, `scripts/record-agentops-outcome.sh`,
that writes `.agentops-runs/<run-id>/outcome.txt` in the locked format for
one executor run after the decision is known. No accept/revise integration
in v1. No log parsing. No automatic quality judgment. No new
revert/no-op/blocked lifecycle helpers.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

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

- `scripts/record-agentops-outcome.sh` (new)
- optional minimal docs update for the outcome metadata contract in
  `docs/RUN-AUDIT.md` or `docs/RUN-OBSERVABILITY.md` if needed to reference
  the new helper
- runtime side effect only: writes `.agentops-runs/<run-id>/outcome.txt`
  (gitignored; not committed)

Do not modify `scripts/accept-agentops-task.sh`,
`scripts/revise-agentops-task.sh`, `scripts/run-opencode-executor.sh`, or
any other existing decision/execution helper in this slice.

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
- Single writer: outcome is written by one helper
  (`scripts/record-agentops-outcome.sh`). Existing decision helpers
  (`accept-agentops-task.sh`, `revise-agentops-task.sh`) are **not**
  modified in this slice. They may be wired to call the writer in a
  follow-up task.
- Run-id resolution: the writer takes an explicit `<run-id>` argument.
  No "most-recent `<task-id>-*`" guessing.
- Decision notes are **not** stored in `outcome.txt` in v1. The format
  stays small and machine-readable; free-text notes are out of scope.
- `revert`, `no-op`, and `blocked` are representable in the writer, but
  dedicated lifecycle helpers for those decisions are deferred to a later
  task.

Helper signature:

```text
scripts/record-agentops-outcome.sh \
  <run-id> \
  <decision: accept|revise|revert|no-op|blocked> \
  <changed_files_count> \
  <diff_bytes> \
  <diff_stat_lines> \
  <verification_exit_code: <n>|unknown>
```

Behavior:

- validate `<run-id>` (no slashes, no `..`)
- validate `<decision>` against the locked set
- validate numeric fields as non-negative integers (except
  `verification_exit_code` which may be `unknown`)
- ensure `.agentops-runs/<run-id>/` exists; refuse with non-zero exit if
  not (do not create the run dir)
- write `.agentops-runs/<run-id>/outcome.txt` atomically (e.g. write to
  temp file then `mv`)
- exit non-zero on any validation failure with a clear stderr message
- do not commit, do not modify git state, do not touch `metadata.txt`

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

None.

Resolved:

- Ownership shape: single writer helper
  `scripts/record-agentops-outcome.sh`. Reason: do not duplicate
  outcome-writing / key=value formatting logic across accept / revise /
  future decision helpers.
- Coverage gap: do not add `revert` / `no-op` / `blocked` lifecycle
  helpers in this slice. The writer must be capable of all five decisions;
  manual or future callers can use the writer until proper helpers exist.
  Reason: adding lifecycle helpers would expand the task into lifecycle
  tooling.
- Run-id resolution: writer takes an explicit `<run-id>` argument. No
  "most-recent `<task-id>-*`" guessing. Reason: implicit run-id lookup is
  non-deterministic and can write to the wrong run dir; a separate lookup
  helper can be added later if needed.
- Decision note: not stored in `outcome.txt` in v1. Reason: the locked
  format is deliberately small and machine-readable; free-text escaping
  is out of scope. Notes can stay in existing decision-helper behavior
  or a later safe summary helper.
- v1 slice: standalone writer helper only. No modifications to
  `accept-agentops-task.sh` / `revise-agentops-task.sh` / executor
  wrapper. Reason: minimal-risk first slice; integration can land in a
  follow-up task once the writer contract is in use.

## Promotion decision

Decision: promote_to_ready.

Reason:
All blockers are resolved: ownership shape (single writer
`scripts/record-agentops-outcome.sh`), coverage gap (no new lifecycle
helpers in this slice; writer covers all five decisions), run-id
resolution (explicit `<run-id>` argument), decision-note handling (not in
v1), and v1 scope (standalone writer only — no accept/revise/wrapper
modifications). Helper signature is locked.

Next action:
Promote to ready and execute through the Hermes/coder collection prompt.

## Promotion criteria

Already promoted to ready.

## Verification

```bash
git status --short --branch
bash -n scripts/record-agentops-outcome.sh
git diff --stat
```

Happy path — verify the writer in a disposable run dir:

```bash
RUN_ID=outcome-helper-smoke
mkdir -p ".agentops-runs/${RUN_ID}"
scripts/record-agentops-outcome.sh "${RUN_ID}" accept 3 1234 5 0
cat ".agentops-runs/${RUN_ID}/outcome.txt"
# expect: decision=accept, changed_files_count=3, diff_bytes=1234,
#         diff_stat_lines=5, verification_exit_code=0
```

Blocked-path representation:

```bash
RUN_ID=outcome-helper-blocked
mkdir -p ".agentops-runs/${RUN_ID}"
scripts/record-agentops-outcome.sh "${RUN_ID}" blocked 0 0 0 unknown
grep -q '^decision=blocked$' ".agentops-runs/${RUN_ID}/outcome.txt"
grep -q '^verification_exit_code=unknown$' ".agentops-runs/${RUN_ID}/outcome.txt"
```

Negative paths:

```bash
# refuses missing run dir
! scripts/record-agentops-outcome.sh nonexistent-run accept 0 0 0 0 2>/dev/null
# rejects unknown decision
! scripts/record-agentops-outcome.sh "${RUN_ID}" totally-not-a-decision 0 0 0 0 2>/dev/null
# rejects unsafe run-id
! scripts/record-agentops-outcome.sh "../escape" accept 0 0 0 0 2>/dev/null
```

Do not use `|| true` to mask failures.

## Accept criteria

- Change is limited to write scope.
- `scripts/record-agentops-outcome.sh` exists and is executable.
- The helper writes `.agentops-runs/<run-id>/outcome.txt` in the locked
  key=value format.
- `accept`, `revise`, `revert`, `no-op`, and `blocked` are all accepted as
  valid `<decision>` values.
- The helper rejects unknown decisions, unsafe run-ids (slashes / `..`),
  non-existent run dirs, and non-numeric / non-`unknown`
  `verification_exit_code` values with non-zero exit and a clear stderr
  message.
- The helper does not create the run dir; it requires
  `.agentops-runs/<run-id>/` to already exist.
- The helper does not modify `metadata.txt`.
- The helper does not commit, push, or modify git state.
- `scripts/accept-agentops-task.sh`, `scripts/revise-agentops-task.sh`,
  `scripts/run-opencode-executor.sh`, and other existing helpers are not
  modified.
- Verification commands pass or failures are explained.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0089-run-outcome-metadata.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Workflow requirements:
- use or create a task-specific worktree and branch
- do not switch the main planning worktree away from main
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME, OPENCODE_XDG_DATA_HOME, and AGENTOPS_EXECUTOR_MODEL
- use the runner-configured executor model
- do not silently fallback to another model
- do not commit
- independently verify the result

Scope:
- create only scripts/record-agentops-outcome.sh
- writer takes <run-id> <decision> <changed_files_count> <diff_bytes> <diff_stat_lines> <verification_exit_code>
- decision is one of: accept | revise | revert | no-op | blocked
- verification_exit_code is a non-negative integer or the literal string "unknown"
- writes .agentops-runs/<run-id>/outcome.txt in the locked key=value format (atomically via tmp + mv)
- requires .agentops-runs/<run-id>/ to already exist; refuses with non-zero exit otherwise
- validates run-id (no slashes, no "..")
- does not modify metadata.txt
- does not commit, push, or modify git state
- do not modify scripts/accept-agentops-task.sh, scripts/revise-agentops-task.sh, or scripts/run-opencode-executor.sh
- do not add lifecycle helpers for revert / no-op / blocked

Return:
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
```

## Return format

Expected executor return format:

```text
Plan:
...

Implementation:
...

Verification:
...

Review:
accept / revise / revert / no-op / blocked

Changed files:
...

Uncertainty:
...
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
