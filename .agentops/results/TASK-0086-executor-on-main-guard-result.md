# TASK-0086-executor-on-main-guard Result

## Decision

accept

## Decision note

Accepted after independent review: wrapper now guards main/master execution with explicit override.

## Task file

agentops/tasks/done/TASK-0086-executor-on-main-guard.md

## Implementation summary

Added a pre-execution guard in `scripts/run-opencode-executor.sh`:
- detects current branch with `git symbolic-ref --quiet --short HEAD`
- blocks on `main` and `master` with locked error wording and non-zero exit
- allows override via `AGENTOPS_ALLOW_MAIN_EXECUTOR=1` with loud stderr warning
- does not block detached HEAD
- does not block outside a git repository
- guard runs before executor launch and remains enforced even with `AGENTOPS_EXECUTOR_COMMAND` test mode

## Changed files

- scripts/run-opencode-executor.sh
- done-state task file (lifecycle move)
- agentops/results/TASK-0086-executor-on-main-guard-result.md

## Verification

```bash
$ git status --short --branch
## task-0086-executor-on-main-guard...origin/main
 D [ready-state task file removed by lifecycle move]
 M scripts/run-opencode-executor.sh
?? agentops/results/TASK-0086-executor-on-main-guard-result.md
?? agentops/tasks/done/TASK-0086-executor-on-main-guard.md

$ bash -n scripts/run-opencode-executor.sh
# exit 0

$ git diff --stat
 scripts/run-opencode-executor.sh | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

$ scripts/check-agentops-lifecycle.sh
Errors: 0
Warnings: 0

$ # branch guard behavior checks in temp git repo
EC_BLOCK=1
EC_OVERRIDE=0
EC_DETACHED=0
# blocked stderr contains: Error: refusing to run OpenCode executor from branch 'main'.
# override stderr contains: AGENTOPS_ALLOW_MAIN_EXECUTOR=1
# detached path output contains: detached-runs
```

## Independent reviewer output

Decision: accept
