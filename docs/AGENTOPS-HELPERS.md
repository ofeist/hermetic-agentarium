# AgentOps Helpers — Catalog & Roadmap

This document catalogs existing AgentOps lifecycle helper scripts and defines
the next three helper priorities. Future helper implementation tasks should
reference this shortlist rather than starting from zero.

**No helper scripts are implemented in this slice.** This is a planning
document.

## Inventory of existing helpers

The following helpers already exist in `scripts/` and are **not** candidates
for re-proposal:

| Script | Purpose | Lifecycle state |
|--------|---------|-----------------|
| `bootstrap-agentops-structure.sh` | Create/validate .agentops/ directories, placeholders, templates | none (bootstrap) |
| `check-agentops-lifecycle.sh` | Duplicate IDs, stale statuses, result-note gaps | done, review, results |
| `submit-agentops-task.sh` | Move ready → review; update status to review | ready → review |
| `accept-agentops-task.sh` | Move review → done | review → done |
| `revise-agentops-task.sh` | Move review → ready (revision loop) | review → ready |
| `review-executor-result.sh` | Print git status and diff stat | running, review |
| `render-verification-notes.sh` | Render verification notes template | review |
| `render-review-prompt.sh` | Render review prompt from task + notes | review |
| `render-revision-prompt.sh` | Render revision prompt from task + feedback | review |
| `render-agentops-run-summary.sh` | Print compact run summary from metadata | running, results |
| `render-opencode-prompt.sh` | Render OpenCode executor prompt | ready |
| `render-collection-prompt.sh` | Render Hermes/coder collection prompt | ready |
| `new-ready-task.sh` | Create a new ready task file | ready |
| `start-agentops-task.sh` | Legacy/fallback branch helper in current checkout | none |
| `start-agentops-worktree.sh` | Create task-specific worktree and branch | none |
| `run-opencode-executor.sh` | Run OpenCode non-interactively | running |
| `run-ready-task.sh` | Render prompt + invoke executor for one ready task | ready, running |
| `next-agentops-task-id.sh` | Print next available task ID | planned, ready |
| `export-agentops-prometheus-metrics.sh` | Export Prometheus textfile metrics | running, results |
| `agentops-tmp-dir.sh` | Create temp AgentOps directory for fixtures | none |

`scripts/install-coder-profile.sh` is excluded from this catalog — it is a
setup/install helper, not a lifecycle helper.

## Adjacent helper tasks (not re-opened here)

- **TASK-0081** — `submit-agentops-task.sh` status-update refinement (done)
- **TASK-0083** — `render-collection-prompt.sh` (done)
- **TASK-0084** — `next-agentops-task-id.sh` (done)

---

## Priority 1 — Lifecycle consistency follow-up

### check-agentops-lifecycle-deep.sh

Status: proposed
Type: read-only

Lifecycle state touched:
- running
- review
- done
- local run artifacts

Purpose:
Extend the existing `check-agentops-lifecycle.sh` baseline with checks for
orphaned git worktrees, stale `running/` entries, and cross-state-vs-directory
mismatches that the current checker does not cover.

The existing checker covers duplicate IDs, done tasks with stale ready status,
missing result-note paths, and done-tasks-without-results (warning). It does
not check:

- Orphaned worktrees (`git worktree list` entries with no matching task in
  any lifecycle directory, or entries pointing to removed branches).
- Tasks in `.agentops/tasks/running/` whose `## Status` is not `running`.
- Tasks in `.agentops/tasks/review/` whose `## Status` is not `review`.
- Tasks in `.agentops/tasks/ready/` whose `## Status` is not `ready` or does
  not match.
- Stale `running/` entries (task file exists but `.agentops-runs/<task-id>/`
  metadata shows the executor exited hours ago).

Input:
None (reads the repo working tree, AgentOps lifecycle directories, and
`git worktree list` output).

Output:
Writes errors and warnings to stdout/stderr. Exits 0 if clean, 1 if errors
found.

Verification:
```bash
git worktree list
bash -n scripts/check-agentops-lifecycle-deep.sh

# Simulate a stale running entry: move a task to running/ with a done status
# then run the checker and confirm it flags the mismatch.
scripts/check-agentops-lifecycle-deep.sh; echo "exit=$?"
```

Notes:
This helper should be additive, not a replacement. The existing
`check-agentops-lifecycle.sh` keeps its current scope; the deep variant
adds worktree and cross-state checks. Consider naming to avoid confusion.
May optionally accept a `--worktrees` flag to skip worktree checks when
running inside a task-specific worktree where `git worktree list` output
differs.

---

## Priority 2 — Review packet / verification-notes rendering

### Decision: existing render helpers cover the use case

Status: existing
Type: read-only

Lifecycle state touched:
- review

Purpose:
Record the explicit decision for the review-packet question: no new composing
helper is needed.

The existing two-helper pipeline already covers the reviewer handoff use case:

1. `scripts/render-verification-notes.sh <task-id-slug>` produces a markdown
   template with git status, diff stat, changed files, and untracked files
   baked in. The reviewer fills in verification commands and output.

2. `scripts/render-review-prompt.sh <task-file> <verification-notes-file>`
   consumes the filled verification notes and the task file, then renders a
   self-contained review prompt with the full task spec, verification notes,
   git status, diff stat, and full diff.

This is a two-step manual composition, not a single "review packet" helper,
but it is sufficient for the current workflow. A composing wrapper would save
one command invocation but does not unlock a new review capability. The
existing helpers remain the canonical review handoff pipeline.

Input:
`scripts/render-verification-notes.sh` takes a task-id-slug.
`scripts/render-review-prompt.sh` takes a task file path and optional
verification notes file path.

Output:
Both write rendered markdown to stdout (typically redirected to a file).

Verification:
```bash
# Verify the two helpers compose for a task in review
TASK_SLUG="TASK-0081-review-handoff-helper"
scripts/render-verification-notes.sh "$TASK_SLUG" > /tmp/verify-notes.md
scripts/render-review-prompt.sh ".agentops/tasks/review/$TASK_SLUG.md" /tmp/verify-notes.md > /tmp/review-packet.md
head -5 /tmp/review-packet.md
```

Notes:
A future composing wrapper (`render-review-packet.sh`) could be considered if
the two-step pipeline becomes a friction point at scale, but it is not a
priority now. The decision recorded here prevents duplicate proposals.

---

## Priority 3 — Deferred helper backlog

The following candidates are captured for future planning but are **not**
proposed for implementation in this slice. Each entry includes a one-line
rationale.

### accept-agentops-task-status-fix

Status: deferred
Type: mutating

Lifecycle state touched:
- review → done

Purpose:
Fix `scripts/accept-agentops-task.sh` to update the moved task file's
`## Status` from `review` to `done` on accept. Currently the helper moves
`.agentops/tasks/review/<slug>.md` to `.agentops/tasks/done/<slug>.md` but
leaves the internal status as `review` — lifecycle drift observed on
TASK-0084, TASK-0085, and TASK-0086 closeouts.

Input:
Task file path under `.agentops/tasks/review/`.

Output:
File moved to `.agentops/tasks/done/` with `## Status` updated to `done`.

Verification:
```bash
# Create a temp fixture, run accept, assert status updated
# (exact fixture shape to be designed at implementation time)
TEMP_DIR=$(scripts/agentops-tmp-dir.sh)
# ... prepare fixture ...
scripts/accept-agentops-task.sh "$TEMP_DIR/.agentops/tasks/review/TEST-X.md"
grep -q 'done' "$TEMP_DIR/.agentops/tasks/done/TEST-X.md" || echo "FAIL: status not updated"
scripts/check-agentops-lifecycle.sh
```

Notes:
Listed in `IDEAS.md` as a known bug. Does not depend on TASK-0083 or
TASK-0084 outcomes. Narrow scope — mutate only the status line in the
moved file, preserve all other behavior.

### agentops-subcommand-wrapper

Status: deferred
Type: read-only (wrapper orchestrates existing mutating scripts)

Lifecycle state touched:
- ready / running / review / done

Purpose:
Wrap existing lifecycle helpers under a unified `agentops` subcommand
interface (`agentops start`, `agentops submit`, `agentops accept`, etc.).

Input:
Subcommand and arguments (e.g. `agentops submit TASK-0090-slug`).

Output:
Delegates to existing helpers; no new behavior beyond the wrapper.

Verification:
```bash
bash -n scripts/agentops
scripts/agentops --help
```

Notes:
Explicitly deferred by TASK-0088 resolution. All current helpers are
separate scripts; no wrapper exists. A wrapper is a future UX improvement,
not a correctness or observability gap. Do not propose implementation
until an explicit wrapper task is promoted.

### task-id-atomic-reservation

Status: deferred
Type: mutating

Lifecycle state touched:
- planned → ready

Purpose:
Extend `scripts/next-agentops-task-id.sh` with atomic reservation so that two
concurrent operators cannot claim the same task ID. Current helper prints the
next ID without reserving it.

Input:
None (reads lifecycle directories).

Output:
Reserved ID written to a lightweight reservation file (e.g.
`.agentops/.task-id-reservation`).

Verification:
```bash
bash -n scripts/reserve-agentops-task-id.sh
# Concurrent-reservation stress test (two parallel invocations)
```

Notes:
Depends on TASK-0084 outcome (`next-agentops-task-id.sh` pattern and scan
rule). Keep this as deferred until the current ID-allocation behavior remains
stable in everyday usage.

### review-decision-capture-in-metadata

Status: deferred
Type: mutating

Lifecycle state touched:
- review → done / review → ready

Purpose:
Write a `review-notes.md` or update metadata in `.agentops-runs/<run-id>/`
when the parent accepts, revises, or reverts. Bridges the lifecycle handoff
with the observability trail documented in `docs/RUN-AUDIT.md`.

Input:
Run ID, decision (accept/revise/revert/no-op), optional review notes.

Output:
Appends or creates a review artifact in `.agentops-runs/<run-id>/`.

Verification:
```bash
bash -n scripts/capture-review-decision.sh
# Create a fixture run, accept, verify review-notes.md exists
```

Notes:
Listed as future work in `docs/RUN-AUDIT.md` ("review decision capture").
Does not depend on TASK-0083 or TASK-0084. Requires careful safety boundary
review — must never commit `.agentops-runs/` content.

### collection-prompt-worktree-auto

Status: deferred
Type: read-only

Lifecycle state touched:
- ready → running

Purpose:
Extend `scripts/render-collection-prompt.sh` to optionally emit worktree
setup commands (e.g. `scripts/start-agentops-worktree.sh <task-id>`) as part
of the rendered collection prompt, reducing the manual instruction gap.

Input:
Ready task path, optional `--with-worktree` flag.

Output:
Collection prompt with inline worktree setup instruction.

Verification:
```bash
bash -n scripts/render-collection-prompt.sh
scripts/render-collection-prompt.sh --with-worktree .agentops/tasks/ready/TASK-0088-slug.md
```

Notes:
Depends on TASK-0083 outcome (`render-collection-prompt.sh` contract and
output shape). Keep this as deferred until the current collection prompt flow
remains stable across multiple tasks.
