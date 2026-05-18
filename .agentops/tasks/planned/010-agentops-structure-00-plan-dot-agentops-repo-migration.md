# 010-agentops-structure-00 — Plan dot-agentops repo migration

## Status

planned

## Goal

Produce a concrete, verifiable migration plan that moves the `agentops/` lifecycle
directory to `.agentops/` in a single atomic cutover, without breaking helper scripts,
docs, or workflow references.

## Background / why now

The `agentops/` directory stores AgentOps lifecycle data (task files, templates,
results, lifecycle baseline). A dot-prefixed `.agentops/` directory name better
communicates that this is operational metadata — not primary product code/content —
and aligns with the existing `.agentops-runs/` runtime artifact convention.

## Problem statement

A direct rename breaks:
- 15 helper shell scripts in scope, with 13 containing `agentops/` references
  (10 runtime-hardcoded path logic + 3 usage-example references; 2 have none)
- 9 documentation files
- 2 task templates
- 1 SKILL.md orchestrator specification
- 1 coder profile (SOUL.md)
- The lifecycle checker's historical baseline

A compatibility-based (dual-path) approach would add implementation complexity
with no benefit — all paths are internal to this single repository and there is
no external consumer of `agentops/` that needs a transitional period.

## Smallest useful slice

This document is the migration plan itself. The future migration task will:
1. Rename `agentops/` → `.agentops/` (or `git mv`)
2. Update all runtime-critical paths in one commit
3. Leave historical records unchanged
4. Verify with concrete commands

---

## Phase 1: Complete path inventory

### Runtime-critical references (must be updated before migration is complete)

#### Shell scripts (15 files)

| # | File | Path variable | Lines |
|---|------|---------------|-------|
| 1 | `scripts/submit-agentops-task.sh` | `READY_FILE`, `REVIEW_DIR` | 25-26, 67 |
| 2 | `scripts/accept-agentops-task.sh` | `REVIEW_DIR`, `DONE_DIR`, `RESULT_DIR` | 38-42 |
| 3 | `scripts/check-agentops-lifecycle.sh` | `TASK_DIRS[]`, loop paths, `BASELINE_FILE` | 37-41, 67, 91, 108, 118, 123 |
| 4 | `scripts/next-agentops-task-id.sh` | `LIFECYCLE_DIRS[]` | 5-9 |
| 5 | `scripts/render-collection-prompt.sh` | `READY_DIR` + `realpath` guards | 21, 29-34 |
| 6 | `scripts/render-verification-notes.sh` | `READY_TASK_FILE` | 39 |
| 7 | `scripts/run-ready-task.sh` | `READY_TASK_FILE` | 28 |
| 8 | `scripts/new-ready-task.sh` | `TEMPLATE`, `OUTPUT_DIR` | 26, 32 |
| 9 | `scripts/revise-agentops-task.sh` | path validation, `OUTPUT_DIR` | 51, 62, 74 |
| 10 | `scripts/test-submit-agentops-task.sh` | mkdir, file create paths | 11, 24, 38-122 |
| 11 | `scripts/render-review-prompt.sh` | usage examples only | 17-18 |
| 12 | `scripts/render-revision-prompt.sh` | usage examples only | 17 |
| 13 | `scripts/render-opencode-prompt.sh` | usage examples only | 10 |
| 14 | `scripts/start-agentops-task.sh` | none (only references `scripts/start-agentops-worktree.sh`) | — |
| 15 | `scripts/start-agentops-worktree.sh` | none | — |

Scripts that reference `.agentops-runs/` (already dot-prefixed, NOT part of this migration):
- `scripts/run-opencode-executor.sh`
- `scripts/record-agentops-outcome.sh`
- `scripts/render-agentops-run-summary.sh`
- `scripts/export-agentops-prometheus-metrics.sh`
- `scripts/agentops-tmp-dir.sh`

#### Documentation (9 files)

| # | File | Nature of references |
|---|------|---------------------|
| 1 | `docs/PLANNING-WORKFLOW.md` | 6 references: IDEAS.md, tasks/planned/, tasks/ready/, tasks/done/, results/ |
| 2 | `docs/POC-STATUS.md` | 2 references: agentops/ lifecycle, agentops/results/ |
| 3 | `docs/RUN-AUDIT.md` | 1 reference: agentops/results/ |
| 4 | `docs/RUN-OBSERVABILITY.md` | 1 reference: agentops/results/ |
| 5 | `docs/DEBUGGING.md` | 3 references: results/, tasks/ready/ |
| 6 | `docs/AGENTOPS-HELPERS.md` | ~13 references: tasks/running/, review/, ready/, .task-id-reservation |
| 7 | `docs/INSTALL.md` | 1 reference: tasks/ready/ |
| 8 | `docs/DOCUMENTATION-MAP.md` | 3 references: TASK-LIFECYCLE.md, USAGE.md, results/ |
| 9 | `README.md` (root) | 2 references: `agentops/TASK-LIFECYCLE.md` (line 159), `agentops/USAGE.md` (line 160) — documentation links in the "Documentation" section |

#### Templates (2 files)

| # | File | Nature of references |
|---|------|---------------------|
| 1 | `agentops/templates/READY-TASK-TEMPLATE.md` | 1 reference: agentops/tasks/ready/ in invocation prompt |
| 2 | `agentops/templates/PLANNED-TASK-TEMPLATE.md` | 2 references: tasks/planned/, tasks/ready/ |

#### Skills and profiles (2 files)

| # | File | Nature of references |
|---|------|---------------------|
| 1 | `skills/hermetic-coding-orchestrator/SKILL.md` | ~10 references: tasks/ready/, tasks/done/, results/, tasks/planned/ |
| 2 | `profiles/coder/SOUL.md` | 1 reference: agentops/tasks/ready/ |

#### AgentOps internal files (5 files, move with directory)

| # | File | Notes |
|---|------|-------|
| 1 | `agentops/README.md` | Moves with directory; self-referential paths updated |
| 2 | `agentops/TASK-LIFECYCLE.md` | Moves with directory |
| 3 | `agentops/USAGE.md` | Contains ~20 agentops/ path references; must be updated |
| 4 | `agentops/IDEAS.md` | Contains ~15 agentops/ path references; must be updated |
| 5 | `agentops/lifecycle/historical-baseline.txt` | Contains 13 agentops/ path references; must be updated |

#### .gitignore

| # | File | Change needed |
|---|------|--------------|
| 1 | `.gitignore` | Currently ignores `.agentops-runs/` (line 27). No change needed; `.agentops/` will be tracked in git (it contains committed lifecycle data). |

### Active workflow inputs (must be updated during migration)

These directories contain files that are actively read, moved, and processed
by the orchestrator, helper scripts, and lifecycle checker. Their `agentops/`
path references **must be updated** during migration so that ongoing workflow
operations target `.agentops/` correctly.

#### Task files (planned, ready, running, review) — contained within ~287 references across ~47 task files

All task files under `agentops/tasks/{planned,ready,running,review}/` contain
`agentops/` path references within their content (read scopes, write scopes,
related task references, promotion instructions). These are **active workflow
inputs** — the orchestrator reads them during task dispatch and their paths
must reflect the current directory layout.

#### Templates — 2 files (see Phase 1 inventory above)

Templates under `agentops/templates/` are **active workflow inputs** that
define the scaffolding for new tasks. Their path references must be updated
so new tasks are created under `.agentops/`.

### Historical records (leave unchanged)

These directories contain completed work products that document what was
true at the time of task execution. Rewriting them would corrupt historical
accuracy and offers no runtime benefit.

#### Task files (done)

All task files under `agentops/tasks/done/` contain `agentops/` path
references that were valid at the time the task was completed. These are
**immutable historical records**.

#### Result files — ~114 references across ~30+ files

All result files under `agentops/results/` contain `agentops/` path references
(documenting task file paths, changed file paths, verification commands).
These are **immutable historical records**.

### References that are already dot-prefixed (no change)

The `.agentops-runs/` directory and its references are already dot-prefixed.
These are completely separate from `agentops/`:

| # | Scope | Details |
|---|-------|---------|
| 1 | `.gitignore` line 27 | `.agentops-runs/` is gitignored |
| 2 | 5 shell scripts | `run-opencode-executor.sh`, `record-agentops-outcome.sh`, `render-agentops-run-summary.sh`, `export-agentops-prometheus-metrics.sh`, `agentops-tmp-dir.sh` — all use `.agentops-runs/` |

There is no conflict or naming collision between `.agentops/` (committed
lifecycle data) and `.agentops-runs/` (gitignored runtime artifacts).

---

## Phase 2: Atomic cutover vs dual-path compatibility

### Recommendation: Atomic cutover (one commit with coordinated changes)

**Rationale:**
1. All `agentops/` path references are internal to this repository. There are
   no external consumers, no plugin ecosystem, and no published API surface
   that references `agentops/`.
2. All references are textual (shell script variables, markdown paths, grep
   patterns). A coordinated `sed` pass across the repo can update them in a
   single atomic change.
3. A dual-path approach (symlink, compatibility paths, or fallback logic) would:
   - Add 30+ lines of path-resolution logic to multiple scripts
   - Create confusion about which path is canonical
   - Need eventual cleanup (another migration)
   - Risk silent fallback to wrong directory
4. An atomic cutover is simple, auditable (`git diff`), and fully revertible
   (`git revert`).

**Decision: Atomic cutover.**

---

## Phase 3: Active workflow vs historical file handling

### Recommendation: Update active workflow files; leave historical files unchanged

**Rationale:**
1. Task files in `planned/`, `ready/`, `running/`, and `review/` are **active
   workflow inputs**. The orchestrator reads them during task dispatch and
   their internal `agentops/` path references (read scopes, write scopes,
   related task references) must resolve correctly against the post-migration
   `.agentops/` layout. These files **must be updated** during migration.
2. Template files under `templates/` are **active workflow inputs** used to
   scaffold new tasks. Their path references must be updated so new tasks are
   created under `.agentops/`.
3. Task files in `done/` and result files in `results/` are **immutable
   historical records**. The paths they contain were valid at the time of
   creation and accurately reflect the state of the repository when the task
   was executed.
4. Rewriting ~400+ path references across ~50+ historical files would be:
   - Error-prone (risk of corrupting historical records)
   - Not verifiable (no way to independently check correctness)
   - A large diff that obscures the actual migration
   - Without runtime benefit (these files are never executed as code)
5. The lifecycle checker (`check-agentops-lifecycle.sh`) uses `grep` patterns
   to find task paths in result files. After migration, the checker should:
   - Accept both `agentops/tasks/` and `.agentops/tasks/` patterns when
     cross-referencing historical files
   - OR be updated to grep for both patterns (preferred: simpler, backward
     compatible)
6. Future tasks will naturally use `.agentops/` paths.

**Decision: Update all active workflow files (planned/, ready/, running/,
review/, templates/). Leave all `done/` and `results/` files unchanged.**
Update the lifecycle checker to be path-agnostic (accept both old and new patterns).

---

## Phase 4: Future migration steps (for the implementation task)

### Step 1: Verify clean state

```bash
git status --short --branch
# Output must show clean working tree on main
```

### Step 2: Rename the directory

```bash
git mv agentops .agentops
```

### Step 3: Update scripts with `agentops/` references (13 files: 10 runtime logic + 3 usage examples)

Run a coordinated `sed` replacement across all scripts in `scripts/`:

```bash
# Replace agentops/ with .agentops/ in all shell scripts
# Pattern: only replace path literals, not variable names or comments
# Being more precise: replace occurrences that look like directory paths

# Files with hardcoded paths (high confidence — these define variables/functions):
for f in \
  scripts/submit-agentops-task.sh \
  scripts/accept-agentops-task.sh \
  scripts/check-agentops-lifecycle.sh \
  scripts/next-agentops-task-id.sh \
  scripts/render-collection-prompt.sh \
  scripts/render-verification-notes.sh \
  scripts/run-ready-task.sh \
  scripts/new-ready-task.sh \
  scripts/revise-agentops-task.sh \
  scripts/test-submit-agentops-task.sh \
  scripts/render-review-prompt.sh \
  scripts/render-revision-prompt.sh \
  scripts/render-opencode-prompt.sh \
; do
  sed -i 's|agentops/|.agentops/|g' "$f"
done

# start-agentops-task.sh and start-agentops-worktree.sh have no `agentops/` paths
# and do not require edits for this migration.
```

**Each file's exact changes:**

| Script | Replacements |
|--------|-------------|
| `submit-agentops-task.sh` | Lines 25, 26, 67: `READY_FILE`, `REVIEW_DIR`, echo path |
| `accept-agentops-task.sh` | Lines 10, 38-42: usage text + `REVIEW_DIR`, `DONE_DIR`, `RESULT_DIR` |
| `check-agentops-lifecycle.sh` | Lines 37-41 (TASK_DIRS array), 67, 91, 108, 118, 123: all path references |
| `next-agentops-task-id.sh` | Lines 5-9: `LIFECYCLE_DIRS` array |
| `render-collection-prompt.sh` | Lines 9, 12, 21, 34: usage text + `READY_DIR` + validation |
| `render-verification-notes.sh` | Lines 13, 39: usage text + `READY_TASK_FILE` |
| `run-ready-task.sh` | Line 28: `READY_TASK_FILE` |
| `new-ready-task.sh` | Lines 26, 32: `TEMPLATE`, `OUTPUT_DIR` |
| `revise-agentops-task.sh` | Lines 10, 14, 51, 52, 62, 69, 74: usage text + path construction |
| `test-submit-agentops-task.sh` | Lines 11, 24, 38-122: all mkdir/cat/grep paths |
| `render-review-prompt.sh` | Lines 17-18: usage example path (`agentops/tasks/ready/...`) |
| `render-revision-prompt.sh` | Line 17: usage example path (`agentops/tasks/ready/...`) |
| `render-opencode-prompt.sh` | Line 10: usage example path (`agentops/tasks/ready/...`) |

### Step 4: Update documentation (9 files)

```bash
for f in \
  README.md \
  docs/PLANNING-WORKFLOW.md \
  docs/POC-STATUS.md \
  docs/RUN-AUDIT.md \
  docs/RUN-OBSERVABILITY.md \
  docs/DEBUGGING.md \
  docs/AGENTOPS-HELPERS.md \
  docs/INSTALL.md \
  docs/DOCUMENTATION-MAP.md \
; do
  sed -i 's|agentops/|.agentops/|g' "$f"
done
```

### Step 5: Update templates (2 files)

```bash
for f in \
  .agentops/templates/READY-TASK-TEMPLATE.md \
  .agentops/templates/PLANNED-TASK-TEMPLATE.md \
; do
  sed -i 's|agentops/|.agentops/|g' "$f"
done
```

`sed` replaces `agentops/` with `.agentops/` — note that for files that have
been `git mv`'d into `.agentops/`, the paths are now `./.agentops/...`.

### Step 6: Update skill and profile (2 files)

```bash
sed -i 's|agentops/|.agentops/|g' skills/hermetic-coding-orchestrator/SKILL.md
sed -i 's|agentops/|.agentops/|g' profiles/coder/SOUL.md
```

### Step 7: Update agentops internal files (now under .agentops/)

```bash
# These files moved with the directory (Step 2) but still contain old paths:
for f in \
  .agentops/README.md \
  .agentops/USAGE.md \
  .agentops/IDEAS.md \
  .agentops/lifecycle/historical-baseline.txt \
; do
  sed -i 's|agentops/|.agentops/|g' "$f"
done
```

### Step 8: Update active workflow task files (planned/, ready/, running/, review/)

Task files in `planned/`, `ready/`, `running/`, and `review/` are active workflow
inputs. Their internal `agentops/` path references (read scopes, write scopes,
related task references) must be updated to `.agentops/` so the orchestrator
resolves them correctly post-migration.

```bash
# Update all active workflow task files (now under .agentops/ after Step 2)
for dir in .agentops/tasks/planned .agentops/tasks/ready .agentops/tasks/running .agentops/tasks/review; do
  for f in "$dir"/*.md; do
    [ -f "$f" ] && sed -i 's|agentops/|.agentops/|g' "$f"
  done
done
```

Note: `done/` and `results/` are explicitly excluded — they are immutable historical records.

### Step 9: Update lifecycle checker for backward compatibility

After migration, `check-agentops-lifecycle.sh` should match both old and new
path patterns when scanning result files and done tasks. Add a dual-pattern
grep to the result-note reference check (lines 91-102):

```bash
# Replace:
#   grep -Eo 'agentops/tasks/(planned|ready|running|review|done)/TASK-[0-9][^ )`[:space:]]*\.md'
# With:
#   grep -Eo '(\.agentops|agentops)/tasks/(planned|ready|running|review|done)/TASK-[0-9][^ )`[:space:]]*\.md'
```

### Step 10: Update .gitignore if needed

No change required. `.agentops/` is committed lifecycle data; `.agentops-runs/`
remains gitignored. No overlap or conflict.

---

## Phase 5: Verification commands

### Pre-migration verification

```bash
# 1. Ensure clean working tree
git status --short --branch

# 2. Verify all scripts still parse
for f in scripts/*.sh; do bash -n "$f" || echo "FAIL: $f"; done

# 3. Verify the lifecycle checker passes on current state
scripts/check-agentops-lifecycle.sh; echo "exit=$?"

# 4. Verify all hardcoded agentops/ paths are accounted for
grep -rn 'agentops/' scripts/ docs/ skills/ profiles/ templates/ agentops/README.md agentops/USAGE.md agentops/IDEAS.md agentops/TASK-LIFECYCLE.md agentops/templates/ | grep -v '\.agentops-runs' | grep -v 'agentops/tasks/done/' | grep -v 'agentops/results/' | wc -l
# This prints the count of non-historical references (active workflow + runtime-critical).
# Excludes only immutable historical records (done/, results/).
# Active workflow directories (planned/, ready/, running/, review/) are included.

# 5. Verify no stale agentops/ paths in scripts (pre-check)
grep -n 'agentops/' scripts/*.sh
```

### Post-migration verification

```bash
# 1. Directory renamed
test -d .agentops && test ! -d agentops && echo "PASS: directory renamed" || echo "FAIL: directory"

# 2. All subdirectories intact
for d in tasks/planned tasks/ready tasks/running tasks/review tasks/done results templates lifecycle; do
  test -d ".agentops/$d" && echo "PASS: .agentops/$d" || echo "FAIL: .agentops/$d"
done

# 3. Sanctioned agentops/ reference audit in scripts
#    ALLOWED categories after migration:
#    a) Lifecycle checker dual-pattern grep (compatibility with historical files)
#    b) Script names containing "agentops" (e.g., submit-agentops-task.sh — not paths)
#    c) Comments/documenting the migration itself
#    UNSANCTIONED: any hardcoded path literal agentops/ that resolves to a directory
echo "=== Script agentops/ references (sanctioned audit) ==="
grep -n 'agentops/' scripts/*.sh
echo "=== Review each match above: allowed only if compatibility grep, script name, or migration comment ==="

# 4. Sanctioned agentops/ reference audit in docs
#    ALLOWED: migration documentation, historical context, compatibility instructions
#    UNSANCTIONED: path literals that should have been replaced
echo "=== Doc agentops/ references (sanctioned audit) ==="
grep -n 'agentops/' docs/*.md README.md
echo "=== Review each match above: allowed only if migration/historical/compatibility context ==="

# 5. Skill and profile: same sanctioned-reference rule
echo "=== Skill/profile agentops/ references (sanctioned audit) ==="
grep -n 'agentops/' skills/hermetic-coding-orchestrator/SKILL.md profiles/coder/SOUL.md
echo "=== Review each match above: allowed only if compatibility/historical/migration context ==="

# 6. All scripts parse and pass bash syntax check
for f in scripts/*.sh; do bash -n "$f" || echo "FAIL: $f"; done

# 7. Lifecycle checker runs on new directory structure
scripts/check-agentops-lifecycle.sh; echo "exit=$?"
# Expected: exit=0 (or same as pre-migration)

# 8. Next task ID helper works
scripts/next-agentops-task-id.sh
# Expected: prints the next TASK-XXXX ID

# 9. New ready task helper works (creates file under .agentops/)
scripts/new-ready-task.sh TEST-9999 "test migration" && \
  test -f .agentops/tasks/ready/TEST-9999.md && \
  rm .agentops/tasks/ready/TEST-9999.md && \
  echo "PASS: new-ready-task.sh" || echo "FAIL: new-ready-task.sh"

# 10. Render helpers work with new paths
scripts/render-opencode-prompt.sh .agentops/tasks/ready/TASK-0095-plan-dot-agentops-repo-migration.md > /dev/null && \
  echo "PASS: render-opencode-prompt.sh" || echo "FAIL: render-opencode-prompt.sh"

# 11. Test submit helper (accept path rejects, then cleanup)
scripts/accept-agentops-task.sh --help > /dev/null && echo "PASS: accept help" || echo "FAIL: accept help"

# 12. Full git diff review
git diff --stat
git diff
```

### Post-migration test script

```bash
# scripts/test-submit-agentops-task.sh should still pass
# (it creates its own temp dirs, not dependent on working tree paths)
scripts/test-submit-agentops-task.sh
# Expected: all tests pass (the script constructs paths internally)
```

---

## Phase 6: Rollback plan

### Rollback is a single `git revert`

Since the migration is one atomic commit with coordinated changes, rollback is:

```bash
git revert <migration-commit-hash>
```

This restores:
- Directory name `agentops/` (from `.agentops/`)
- All script paths
- All documentation paths
- All template, skill, and profile paths
- The lifecycle checker pattern
- All agentops internal files

### Pre-revert verification

```bash
# Check that revert would produce the expected changes
git revert --no-commit <commit-hash>
git diff --stat  # review before finalizing
git revert --abort  # if anything looks wrong
```

### Rollback decision tree

| Scenario | Action |
|----------|--------|
| Migration commit is clean, all tests pass | No rollback needed |
| Scripts fail post-migration (bash -n, runtime error) | Stop and `git revert` immediately |
| Lifecycle checker shows spurious errors | Fix checker pattern (Step 9), do NOT rollback |
| Docs reference wrong paths | Fix docs inline, do NOT rollback |
| Historical results show path warnings | Expected — historical files unchanged; suppress warnings |
| Anything unexpected | `git revert` and re-plan |

---

## Summary

| Decision | Answer |
|----------|--------|
| Migration strategy | **Atomic cutover** (one commit) |
| Dual-path compatibility? | **No** — adds complexity, no external consumers |
| Historical done/ files? | **Leave unchanged** — immutable records |
| Historical result files? | **Leave unchanged** — immutable records |
| Active workflow files? | **Update** — planned/, ready/, running/, review/, templates/ |
| Lifecycle checker change? | **Accept both old and new patterns** in grep |
| .gitignore change? | **None needed** |
| `.agentops-runs/` affected? | **No** — already using dot-prefix |
| Skill rename needed? | **No** — out of scope for this slice |
| Observability redesign? | **No** — out of scope |

## Risks

1. **Lifecycle checker historical warnings**: After migration, the checker's
   result-note path validation will find old `agentops/` paths in historical
   result files. Mitigation: update the grep pattern to accept both forms (Step 9).

2. **Scripts with `agentops` in variable names**: Some scripts use variable names
   like `REVIEW_DIR="agentops/tasks/review"`. The `sed` replacement `agentops/`
   → `.agentops/` handles this correctly because the `/` is part of the match
   pattern — it does NOT replace occurrences of the word "agentops" without a
   trailing `/`. Script names like `submit-agentops-task.sh` are not affected.

3. **`.agentops/` being hidden**: Some tools (file browsers, `ls` without `-a`)
   will not show `.agentops/` by default. Mitigation: document this in README
   and installation docs. The directory is still discoverable via `ls -a`,
   `git status`, and glob patterns.

4. **IDE / editor discoverability**: Code editors that hide dotfiles by default
   may hide `.agentops/`. Mitigation: not a blocking concern — the existing
   `.agentops-runs/` directory has the same behavior and no issues have been
   reported.

## Non-goals (confirmed)

- No skill rename work (separate TASK-0092 / TASK-0094)
- No observability feature redesign
- No unrelated refactors
- No `.agentops-runs/` changes
- No runtime helper behavior changes (path-only textual replacement)
- No rewriting historical task/result files (done/ and results/ stay unchanged)
- Active workflow files (planned/, ready/, running/, review/, templates/) ARE in scope for path updates
