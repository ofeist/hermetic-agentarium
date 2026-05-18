# TASK-0085-reconcile-branch-worktree-docs-drift Result

## Decision

accept

## Decision note

Accepted after independent review: docs reconciled to worktree-first executor policy.

## Task file

agentops/tasks/done/TASK-0085-reconcile-branch-worktree-docs-drift.md

## Implementation summary

Updated docs to consistently describe execution policy:
- main is planning/control checkout
- executor work runs in task-specific worktree on task branch
- do not run executor work on main
- branch remains unit of change/review; worktree provides isolation
- prefer scripts/start-agentops-worktree.sh, keep start-agentops-task.sh as fallback wording

## Changed files

- README.md
- profiles/coder/SOUL.md
- docs/FIRST-RUN.md
- docs/DEBUGGING.md
- docs/POC-STATUS.md
- Ready-state task file moved to done-state path by lifecycle transition
- agentops/results/TASK-0085-reconcile-branch-worktree-docs-drift-result.md

## Verification

```bash
$ git status --short --branch
## task-0085-reconcile-branch-worktree-docs-drift
 M README.md
 D [ready-state task file removed by lifecycle move]
 M docs/DEBUGGING.md
 M docs/FIRST-RUN.md
 M docs/POC-STATUS.md
 M profiles/coder/SOUL.md
?? agentops/results/TASK-0085-reconcile-branch-worktree-docs-drift-result.md
?? agentops/tasks/done/TASK-0085-reconcile-branch-worktree-docs-drift.md

$ git diff --stat
 README.md                                          |   2 +-
 ...TASK-0085-reconcile-branch-worktree-docs-drift.md | 315 ---------------------
 docs/DEBUGGING.md                                  |   6 +-
 docs/FIRST-RUN.md                                  |   8 +-
 docs/POC-STATUS.md                                 |   2 +-
 profiles/coder/SOUL.md                             |   5 +-
 6 files changed, 13 insertions(+), 325 deletions(-)

$ scripts/check-agentops-lifecycle.sh
Errors: 0
Warnings: 0
```

## Independent reviewer output

Decision: accept
