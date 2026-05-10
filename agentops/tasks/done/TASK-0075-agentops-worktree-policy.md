# TASK-0075 — Add AgentOps worktree policy and helper

## Status

done

## Goal

Make the AgentOps worktree model explicit: keep the `main` worktree as the
planning cockpit, and run executor work in task-specific git worktrees.

## Background / why now

The current helper, `scripts/start-agentops-task.sh`, creates a task branch in
the current worktree. That was useful early on, but it makes it too easy for the
planning worktree to become the executor worktree.

Recent TASK-0072/TASK-0073 work showed that task branches and task worktrees are
safer when they are clearly separated from the planning cockpit.

## Problem statement

The repo does not yet have a durable worktree policy or a helper that makes the
desired workflow easy.

Without this, agents may:

- run OpenCode executor work directly on `main`
- switch the planning worktree away from `main`
- edit the same task file from the planning worktree and task worktree at the
  same time
- forget to update the main worktree after a task branch is merged

## Smallest useful slice

Document the worktree policy and add a minimal helper:

```bash
scripts/start-agentops-worktree.sh TASK-0073
```

The policy should say:

- `main` worktree is the planning cockpit.
- Executor work must happen in a task-specific git worktree.
- One task worktree should map to one task branch.
- Do not run OpenCode executor work directly on `main`.
- Do not edit the same task file from the planning worktree and task worktree
  at the same time.
- After a task branch is merged, update the main worktree with `git pull`.

The helper should create or prepare a task-specific worktree and branch without
switching the main planning worktree away from `main`.

Keep this first slice focused:

- add `scripts/start-agentops-worktree.sh`
- document the policy in the orchestrator skill
- keep `scripts/start-agentops-task.sh` unchanged except for references if
  necessary
- leave helper deprecation, cleanup helpers, and broader docs polish for later
  worktree tasks

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `scripts/start-agentops-task.sh`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/USAGE.md`, if present
- `docs/FIRST-RUN.md`, if present
- `agentops/tasks/ready/TASK-0075-agentops-worktree-policy.md`

## Write scope

- `scripts/start-agentops-worktree.sh`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/USAGE.md`, if present and clearly relevant

## Requirements

- Add `scripts/start-agentops-worktree.sh`.
- Document that the main worktree is the planning cockpit.
- Document that executor work must happen in a task-specific git worktree.
- Ensure one task worktree maps to one task branch.
- Ensure the helper does not switch the main planning worktree away from
  `main`.
- The helper should report whether the main planning worktree is dirty.
- The helper should report dirty state but should not block merely because the
  planning worktree has unrelated planning-only edits.
- The helper should refuse only if it cannot safely create the worktree.
- The helper should run `git fetch origin`.
- The helper should base new task branches on `origin/main` by default.
- The helper should not force `git pull` in the planning worktree if local
  planning changes exist.
- Ensure the helper creates a task branch named from the task slug, for example
  `task-0073-agentops-executor-run-metadata-baseline`.
- Ensure the helper creates a predictable sibling worktree path, for example
  `../hermetic-agentarium-task-0073`.
- Ensure the helper is idempotent enough to report an existing branch/worktree
  clearly instead of overwriting it.
- If the branch exists and is already attached to a worktree, print that path
  and exit with a clear no-op message.
- If the branch exists but is not attached to a worktree, create the worktree
  from that branch.
- If the target worktree path exists, refuse unless it is already the expected
  worktree for the expected branch.
- Update the orchestrator skill so future Hermes/coder runs prefer the worktree
  helper over running executor work in the main worktree.
- Keep `scripts/start-agentops-task.sh` unchanged in this slice unless a
  reference update is clearly necessary.

## Non-goals

- No broad lifecycle redesign.
- No automatic merge/accept/push behavior.
- No executor behavior changes.
- No deletion of existing task worktrees.
- No destructive cleanup.
- No replacement for the review prompt flow.
- No changes to model selection.
- No deprecation or redesign of `scripts/start-agentops-task.sh`.
- No worktree list/cleanup helpers.
- No configurable worktree root in this first slice.

## Open questions

None.

Resolved:

- Task worktrees should live next to the main repo by default:
  `../<repo-name>-task-XXXX`.
- This keeps the planning cockpit and executor worktree visibly separate
  without adding configuration.
- The helper should accept `TASK-XXXX` or `TASK-XXXX-slug`.
- Full ready-task path support can be added later.
- If the branch exists and is already attached to a worktree, print the path and
  exit with a clear no-op message.
- If the branch exists but is not attached to a worktree, create the worktree
  from that branch.
- If the target worktree path exists, refuse unless it is already the expected
  worktree for the expected branch.
- Keep `scripts/start-agentops-task.sh` unchanged in this slice. Update
  docs/skill to prefer `scripts/start-agentops-worktree.sh` for executor work.
- Deprecation or replacement of the older branch-only helper can be a later
  task.

## Verification

Run:

```bash
bash -n scripts/start-agentops-worktree.sh
scripts/start-agentops-worktree.sh --help
git status --short --branch
git diff --stat
```

Run a non-destructive smoke test using a temporary task ID, then clean it up:

```bash
scripts/start-agentops-worktree.sh TASK-9999-worktree-smoke-test
git worktree list
git worktree remove ../hermetic-agentarium-task-9999
git branch -D task-9999-worktree-smoke-test
```

Cleanup must only remove the temporary smoke-test worktree/branch created
during verification. If cleanup is unsafe or the branch/worktree already
exists, stop and report instead of deleting anything unrelated.

## Accept criteria

- The worktree policy is documented in the agreed durable location.
- `scripts/start-agentops-worktree.sh` exists and is executable.
- The helper creates a task-specific branch and worktree without switching the
  main worktree away from `main`.
- The helper reports dirty planning worktree state without blocking
  planning-only files by default.
- The helper handles existing branch/worktree cases according to the resolved
  policy.
- The helper prints the created/existing worktree path and suggested next
  command.
- The orchestrator skill tells future agents not to run executor work directly
  on `main`.
- `scripts/start-agentops-task.sh` is not redesigned or deprecated in this
  slice.
- Verification commands pass.
- Diff stays within write scope.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0075-agentops-worktree-policy.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- use or create a task-specific worktree
- do not switch the main planning worktree away from main
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME, OPENCODE_XDG_DATA_HOME, and AGENTOPS_EXECUTOR_MODEL
- use the runner-configured executor model
- do not silently fallback to another model
- do not commit
- independently verify the result

Return:
Plan:
Implementation:
Verification:
Review:
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

This should become a workflow guardrail before many more executor tasks are run.
The policy belongs in the repo because chat reminders are not durable.
