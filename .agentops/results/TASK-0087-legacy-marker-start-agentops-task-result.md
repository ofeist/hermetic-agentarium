# TASK-0087-legacy-marker-start-agentops-task Result

## Decision

accept

## Decision note

Accepted after independent review: legacy/fallback marker and startup stderr hint added.

## Task file

agentops/tasks/done/TASK-0087-legacy-marker-start-agentops-task.md

## Implementation summary

Messaging-only update in `scripts/start-agentops-task.sh`:
- Added locked usage/help marker:
  - Legacy/fallback helper: starts executor work in the current checkout.
  - Preferred helper: scripts/start-agentops-worktree.sh
- Added locked runtime hint to stderr at startup, before branch-mutating action:
  - Hint: start-agentops-task.sh is the legacy/fallback path. Prefer scripts/start-agentops-worktree.sh for executor work.

No branch logic, refusal behavior, or auto-forwarding behavior was changed.

## Changed files

- scripts/start-agentops-task.sh
- done-state task file (lifecycle move)
- agentops/results/TASK-0087-legacy-marker-start-agentops-task-result.md

## Verification

```bash
$ git status --short --branch
## task-0087-legacy-marker-start-agentops-task...origin/main [behind 1]
 D [ready-state task file removed by lifecycle move]
 M scripts/start-agentops-task.sh
?? agentops/results/TASK-0087-legacy-marker-start-agentops-task-result.md
?? agentops/tasks/done/TASK-0087-legacy-marker-start-agentops-task.md

$ bash -n scripts/start-agentops-task.sh
# exit 0

$ scripts/start-agentops-task.sh --help 2>&1 | grep -F "Legacy/fallback helper: starts executor work in the current checkout."
Legacy/fallback helper: starts executor work in the current checkout.

$ scripts/start-agentops-task.sh --help 2>&1 | grep -F "Preferred helper: scripts/start-agentops-worktree.sh"
Preferred helper: scripts/start-agentops-worktree.sh

$ # runtime hint exercised in disposable repo
EC=1
Hint: start-agentops-task.sh is the legacy/fallback path. Prefer scripts/start-agentops-worktree.sh for executor work.
error: pathspec 'main' did not match any file(s) known to git

$ scripts/check-agentops-lifecycle.sh
Errors: 0
Warnings: 0
```

## Independent reviewer output

Decision: accept
