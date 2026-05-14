# workflow-05 — Define AgentOps helper scripts shortlist

## Status

planned

## Goal

Turn the broad helper-script idea into a prioritized, small shortlist of
scripts that make the AgentOps lifecycle more deterministic.

## Background / why now

`IDEAS.md` lists several useful helpers: moving tasks to review, rendering
review packets, requesting senior review, checking lifecycle consistency,
summarizing run artifacts, preparing accept checklists, and optionally
creating local review commits.

That list is useful, but too broad for direct implementation.

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

Harness: TBD (default in this repo: OpenCode).
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

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

- one helper shortlist / workflow planning doc, likely `docs/AGENTOPS-HELPERS.md`
  (new) or an existing AgentOps workflow doc such as `docs/WORKFLOW.md` or
  `docs/PLANNING-WORKFLOW.md`
- no implementation of the helper scripts in this slice unless explicitly
  promoted that way

The target file must be chosen before promotion; do not create the doc yet.

## Requirements

Suggested helper priorities (to be confirmed during promotion after a fresh
`scripts/` inspection):

1. Lifecycle consistency follow-up — gaps left by `check-agentops-lifecycle.sh`
   (e.g. orphaned worktrees, stale `running/` entries, missing result notes
   beyond the existing baseline)
2. Review packet / verification-notes rendering — either a composing helper
   on top of the existing `render-verification-notes.sh` and
   `render-review-prompt.sh`, or an explicit decision that the existing
   helpers cover the use case
3. Follow-up helper gap left by TASK-0081, TASK-0083, or TASK-0084, only if
   inspection shows a real gap (e.g. an atomic ID-reservation companion to
   `scripts/next-agentops-task-id.sh`, or a promotion helper that combines
   ID allocation + collection-prompt rendering)

For each helper, document:

- purpose
- input
- output
- lifecycle state touched
- whether it is read-only or mutating
- verification command

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

- Should helpers live as separate scripts or as subcommands under one
  `agentops` wrapper?
- Should review packet generation be required before acceptance, or remain
  optional and composed from existing render helpers?
- Should the first-three helper list be exactly the suggested order, or
  adjusted after inspecting `scripts/` against the IDEAS.md backlog?
- Is the shortlist's target file `docs/AGENTOPS-HELPERS.md` (new) or an
  extension to an existing workflow doc?

## Promotion decision

Decision: keep_planned.

Reason:
The target documentation file is not yet chosen, the final first-three
helper list is not yet locked against the current `scripts/` inventory, and
the helper-contract output format is not yet confirmed.

Next action:
Inspect `scripts/` against IDEAS.md, pick the target doc file, lock the
first-three list, and confirm the per-helper contract shape — then promote.

## Promotion criteria

Promote to `ready` when:

- the target doc file is chosen
- the final first-three helper list is chosen (after a fresh `scripts/` inspection)
- the helper-contract output format is confirmed
- the separate-scripts-vs-wrapper question is resolved or explicitly deferred
- read/write scope is confirmed

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

This is a planning task, not an implementation batch.

This task should make future helper implementation tasks smaller and more
deterministic. It should not create a helper mega-batch.

Related: TASK-0081 (review handoff, done), TASK-0083 (collection prompt
helper, ready), TASK-0084 (task ID allocation, ready).
