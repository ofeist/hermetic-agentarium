# TASK-0075-agentops-worktree-policy Result

## Decision

accept

## Decision note

Accepted by user after OpenCode executor implementation, parent verification, user-requested hardening revisions, and independent review. The task-specific worktree helper and durable worktree policy meet TASK-0075 intent.

## Task file

agentops/tasks/done/TASK-0075-agentops-worktree-policy.md

## Changed files

- `scripts/start-agentops-worktree.sh`
  - New executable helper for creating or preparing task-specific sibling worktrees without switching the main planning worktree away from `main`.
  - Uses `git rev-parse --show-toplevel` so paths are derived from the repository root, not the caller's current directory.
  - Locates the real `main` worktree via `git worktree list --porcelain` and reports that planning worktree's dirty state without blocking.
  - Validates derived branch names with `git check-ref-format --branch` before fetching or creating worktrees.
  - Handles existing attached branches as no-op, existing unattached branches by creating a worktree, and conflicting paths by refusing.
- `skills/hermetic-coding-orchestrator/SKILL.md`
  - Documents the AgentOps worktree policy and updates OpenCode executor orchestration to prefer `scripts/start-agentops-worktree.sh`.
- `agentops/USAGE.md`
  - Adds the “one task worktree” lifecycle principle.
- `agentops/tasks/done/TASK-0075-agentops-worktree-policy.md`
  - Moved from ready to done by AgentOps lifecycle helper.
- `agentops/results/TASK-0075-agentops-worktree-policy-result.md`
  - Records this acceptance decision and verification evidence.

## Verification evidence

Executor:

- Prompt included:
  - `/hermetic-coding-orchestrator`
  - `USING_SKILL: hermetic-coding-orchestrator`
- Wrapper: `scripts/run-opencode-executor.sh`
- Model source: `AGENTOPS_EXECUTOR_MODEL`
- Model used: `deepseek/deepseek-v4-pro`
- Fallback: not used
- Successful run audit: `.agentops-runs/TASK-0075-agentops-worktree-policy-concise`

Parent verification before lifecycle closeout:

```text
bash -n scripts/start-agentops-worktree.sh
# passed

scripts/start-agentops-worktree.sh --help
# printed expected usage

scripts/start-agentops-worktree.sh 'TASK-9999-bad slug'
# exited 1 as expected before fetching
# Error: invalid branch name derived from task id: 'task-9999-bad slug'

scripts/start-agentops-worktree.sh TASK-0075-agentops-worktree-policy
# detected existing worktree and exited as a no-op
```

Subdirectory smoke test:

```text
cd docs
../scripts/start-agentops-worktree.sh TASK-9997-subdir-worktree-smoke
```

Result:

```text
Worktree created at: /home/splinter/devops/hermetic-agentarium-task-9997
Branch: task-9997-subdir-worktree-smoke
```

The smoke worktree and branch were cleaned up:

```text
git worktree remove /home/splinter/devops/hermetic-agentarium-task-9997
git branch -d task-9997-subdir-worktree-smoke
cleanup-ok
```

Lifecycle checker before closeout:

```text
Historical baseline entries tolerated: 13
Errors: 0
Warnings: 0
```

Review:

- Parent review: accept after requested fixes.
- Independent revision review: accept; both user findings were verified fixed.

## Follow-ups

None required for TASK-0075.
