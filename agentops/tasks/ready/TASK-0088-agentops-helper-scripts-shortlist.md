# TASK-0088 — Define AgentOps helper scripts shortlist

## Status

ready

## Goal

Turn the broad helper-script idea into a prioritized, small shortlist of
scripts that make the AgentOps lifecycle more deterministic.

## Background / why now

Earlier helper planning and `IDEAS.md` history included ideas such as moving
tasks to review, rendering review packets, requesting senior review, checking
lifecycle consistency, summarizing run artifacts, preparing accept checklists,
and optionally creating local review commits. The current `agentops/IDEAS.md`
no longer carries that full list; some items shipped, others have moved into
adjacent tasks. Treat that historical list as backlog context, not as a live
backlog.

Several adjacent helper tasks have already moved forward and should not be
re-opened here:

- TASK-0081 — review handoff via `scripts/submit-agentops-task.sh` (shipped)
- TASK-0083 — Hermes/coder collection prompt helper (`scripts/render-collection-prompt.sh`, ready)
- TASK-0084 — task ID allocation (`scripts/next-agentops-task-id.sh`, ready)

A few baseline helpers already exist in `scripts/` and should not be
re-proposed as new work:

- `check-agentops-lifecycle.sh`
- `submit-agentops-task.sh`
- `accept-agentops-task.sh`
- `revise-agentops-task.sh`
- `review-executor-result.sh`
- `render-verification-notes.sh`
- `render-review-prompt.sh`
- `render-revision-prompt.sh`
- `render-agentops-run-summary.sh`
- `render-opencode-prompt.sh`
- `new-ready-task.sh`
- `start-agentops-task.sh`
- `start-agentops-worktree.sh`
- `run-opencode-executor.sh`
- `run-ready-task.sh`
- `export-agentops-prometheus-metrics.sh`
- `agentops-tmp-dir.sh`

`scripts/install-coder-profile.sh` also exists, but is intentionally excluded
from this lifecycle-helper shortlist because it is setup/install oriented
(copies profile/skill into `~/.hermes/`), not AgentOps lifecycle-helper
oriented.

This inventory is a planning snapshot; promotion must re-check `scripts/`.

## Problem statement

Without a shortlist, helper development can become a grab bag. The next
helpers should reinforce lifecycle correctness and observability, not
duplicate already-promoted work or add platform complexity.

## Smallest useful slice

Produce a single planning note that lists the next three helper priorities,
with a short contract for each (purpose, input, output, lifecycle state
touched, mutating vs read-only, verification command).

No helper implementation in this slice unless explicitly promoted that way.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `IDEAS.md`
- `scripts/` (full directory — confirm what already exists)
- `docs/WORKFLOW.md`
- `docs/PLANNING-WORKFLOW.md`
- `docs/OPENCODE-EXECUTOR-WORKFLOW.md`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/DOCUMENTATION-MAP.md`
- ready/done task files for TASK-0081, TASK-0083, TASK-0084

## Write scope

- `docs/AGENTOPS-HELPERS.md` (new helper catalog/roadmap doc)
- no implementation of the helper scripts in this slice unless explicitly
  promoted that way

Do not create the doc until this task is promoted.

## Requirements

Suggested helper priorities (to be confirmed during execution after a fresh
`scripts/` inspection):

1. Lifecycle consistency follow-up — gaps left by `check-agentops-lifecycle.sh`
   (e.g. orphaned worktrees, stale `running/` entries, missing result notes
   beyond the existing baseline)
2. Review packet / verification-notes rendering — either a composing helper
   on top of the existing `render-verification-notes.sh` and
   `render-review-prompt.sh`, or an explicit decision that the existing
   helpers cover the use case
3. Deferred helper backlog — capture candidate follow-up helper gaps after
   existing and ready helper tasks (TASK-0081, TASK-0083, TASK-0084) are
   accounted for, but do not propose implementation work that depends on
   TASK-0083 or TASK-0084 outcomes until those tasks land. The catalog may
   list such candidates as "deferred" entries with a one-line rationale.

For each helper, use this per-helper section template inside
`docs/AGENTOPS-HELPERS.md`. `Lifecycle state touched` is an annotation
referencing existing AgentOps lifecycle areas only; do not define new
lifecycle states in this task.

````md
### <helper-name>

Status: existing / proposed / deferred
Type: read-only / mutating

Lifecycle state touched:
- planned / ready / running / review / done / results / local run artifacts / none

Purpose:
...

Input:
...

Output:
...

Verification:
```bash
...
```

Notes:
...
````

This template captures purpose, input, output, lifecycle state touched,
mutating vs read-only behavior, and a verification command — the contract
the shortlist needs.

The shortlist should prefer lifecycle correctness and observability over
platform complexity, and must not duplicate already-promoted work.

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

- Do not implement any helper scripts in this slice.
- Do not re-open `submit-agentops-task.sh` ownership (settled by TASK-0081).
- Do not duplicate TASK-0083 (collection prompt helper) or TASK-0084 (task
  ID allocation).
- Do not propose creating helpers that already exist in `scripts/`.
- Do not add a background scheduler.
- Do not add hidden review decisions.
- Do not build a dashboard.
- Do not introduce a large wrapper framework unless explicitly chosen later.

## Open questions

None.

Resolved:

- Helper-contract output format: locked above (per-helper section template
  with `Status`, `Type`, `Lifecycle state touched`, `Purpose`, `Input`,
  `Output`, `Verification`, `Notes` fields). `Lifecycle state touched` uses
  existing AgentOps lifecycle terms only.
- Priority item 3 dependency: rephrased as a "deferred helper backlog"
  bucket; the catalog may list candidates as `deferred` with a one-line
  rationale, and must not propose implementation work that depends on
  TASK-0083 or TASK-0084 outcomes until those land.
- Review-packet-vs-compose question: folded into priority 2; the catalog
  must record an explicit decision (new composing helper, or existing
  render helpers cover the use case) rather than leaving it open.
- Target doc: `docs/AGENTOPS-HELPERS.md` (new). Reason: existing workflow
  docs are small and focused; a helper catalog/roadmap deserves its own
  file. Do not create the doc until this task is promoted.
- Wrapper question: separate scripts remain the default. A future `agentops`
  wrapper/subcommand interface is deferred to a later explicit task. Reason:
  all current helpers are separate scripts and no wrapper exists.

## Promotion decision

Decision: promote_to_ready.

Reason:
All blocker decisions are resolved: target doc (`docs/AGENTOPS-HELPERS.md`),
wrapper question (separate scripts by default; wrapper deferred),
helper-contract output format (locked per-helper template), and priority
item 3 dependency (rephrased as a `deferred` backlog bucket that does not
depend on TASK-0083 / TASK-0084 landing). The first-three helper list is
locked as a suggested order to be confirmed during execution against the
current `scripts/` inventory.

Next action:
Promote to ready and execute through the Hermes/coder collection prompt.

## Promotion criteria

Already promoted to ready.

## Verification

```bash
git status --short --branch
git diff --stat
```

Inspect existing helpers and references before finalizing the shortlist:

```bash
ls scripts/
grep -RIn "check-agentops-lifecycle\|submit-agentops-task\|render-verification-notes\|render-review-prompt\|render-revision-prompt\|render-agentops-run-summary" \
  docs agentops IDEAS.md scripts
```

If scripts are touched during promotion, also run the relevant `bash -n`
checks.

Do not use `|| true` to mask failures.

## Accept criteria

TBD during promotion.

Expected direction:

- The output identifies the next three helper priorities.
- Each helper entry includes purpose, input, output, lifecycle state touched,
  mutating/read-only behavior, and verification command.
- The shortlist accounts for already-promoted helper tasks (TASK-0081,
  TASK-0083, TASK-0084) and does not duplicate them.
- The shortlist does not propose helpers that already exist in `scripts/`.
- The output stays documentation/planning-only unless this task is
  explicitly promoted otherwise.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0088-agentops-helper-scripts-shortlist.md

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
- create docs/AGENTOPS-HELPERS.md as the helper catalog/roadmap doc
- list the first three helper priorities using the locked per-helper template
- record an explicit decision for the review-packet question (new composing helper, or existing render helpers cover it)
- include "deferred" candidates with one-line rationale; do not propose implementation work that depends on TASK-0083 or TASK-0084 outcomes
- do not implement any helper scripts in this slice
- do not duplicate TASK-0081, TASK-0083, or TASK-0084
- do not propose creating helpers that already exist in scripts/
- use existing AgentOps lifecycle terms only in `Lifecycle state touched`; do not define new lifecycle states

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

This is a planning task, not an implementation batch.

This task should make future helper implementation tasks smaller and more
deterministic. It should not create a helper mega-batch.

Related: TASK-0081 (review handoff, done), TASK-0083 (collection prompt
helper, ready), TASK-0084 (task ID allocation, ready).
