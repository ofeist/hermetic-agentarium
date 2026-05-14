# TASK-0086 — Add executor-on-main guard to OpenCode wrapper

## Status

ready

## Goal

Prevent `scripts/run-opencode-executor.sh` from running executor work when the
current git context indicates the caller is on `main` (or `master`).

## Background / why now

The AgentOps worktree policy (TASK-0075, documented in
`skills/hermetic-coding-orchestrator/SKILL.md` §"AgentOps worktree policy")
says executor work must not run directly on `main`. The orchestrator skill
also tells future agents to use `scripts/start-agentops-worktree.sh`.

Today, `scripts/run-opencode-executor.sh` is checkout-agnostic. If an operator
or agent skips the worktree helper and invokes the wrapper from the main
planning checkout while on `main`, nothing stops them.

This is the real safety net for the worktree policy. Documentation alone
cannot enforce it.

## Problem statement

The executor wrapper trusts the caller's git context. The actual policy
enforcement is missing at the wrapper level.

## Smallest useful slice

Add a guard to `scripts/run-opencode-executor.sh` that refuses (with a clear
message and non-zero exit) when the current branch is `main` or `master`,
unless an explicit escape hatch env var is set. No automatic worktree
creation; no automatic switching; no worktree-path inference.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `scripts/run-opencode-executor.sh`
- `scripts/start-agentops-worktree.sh`
- `scripts/start-agentops-task.sh`
- `skills/hermetic-coding-orchestrator/SKILL.md` (worktree policy section)
- `agentops/USAGE.md`
- existing test/smoke patterns under `scripts/` or `examples/` if present

## Write scope

- `scripts/run-opencode-executor.sh`
- minimal docs update only if needed to document the guard
- minimal tests or shell syntax checks if present

## Requirements

The guard should:

- detect the current branch using `git symbolic-ref --quiet --short HEAD`
- refuse to invoke the executor (exit non-zero, before launching OpenCode)
  when the current branch is `main` or `master`
- support an escape hatch via `AGENTOPS_ALLOW_MAIN_EXECUTOR=1`
  - when set, print a loud warning to stderr and continue
- do nothing special when HEAD is detached (do not block in this slice)
- preserve existing wrapper behavior when not on `main`/`master`
- preserve existing wrapper behavior when invoked outside a git repository
  (do not block; do not assume git if the wrapper does not already)
- enforce the guard even when `AGENTOPS_EXECUTOR_COMMAND` is set
  (test/no-network mode); tests that need to bypass must set
  `AGENTOPS_ALLOW_MAIN_EXECUTOR=1` explicitly
- not infer the canonical planning checkout path in this slice
  (current-branch-is-main is enough)

Locked guard semantics:

- branch detection: `git symbolic-ref --quiet --short HEAD`
- blocked branches: `main`, `master` (hardcoded for this slice; env-driven
  override list is a follow-up if ever needed)
- detached HEAD: do not block in this slice
- non-git directory: do not block; preserve existing wrapper behavior
- escape hatch: `AGENTOPS_ALLOW_MAIN_EXECUTOR=1` (prints warning, then continues)
- test/no-network mode: guard stays enforced even when
  `AGENTOPS_EXECUTOR_COMMAND` is set; bypass requires
  `AGENTOPS_ALLOW_MAIN_EXECUTOR=1`
- worktree awareness: out of scope for this slice; later task

Error message wording (exact text the guard prints to stderr before exiting
non-zero). `<branch>` is a placeholder for the actual detected branch value
(e.g. `main` or `master`) and MUST be substituted at runtime, not printed
literally:

```text
Error: refusing to run OpenCode executor from branch '<branch>'.

AgentOps executor work should run in a task-specific worktree on a task branch,
not directly from the planning checkout.

Suggested next step:
  scripts/start-agentops-worktree.sh <TASK-ID>

Override for exceptional cases:
  AGENTOPS_ALLOW_MAIN_EXECUTOR=1 scripts/run-opencode-executor.sh ...
```

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

- Do not change the worktree policy.
- Do not auto-create worktrees.
- Do not auto-switch branches.
- Do not deprecate or remove `scripts/start-agentops-task.sh`.
- Do not modify `scripts/start-agentops-worktree.sh`.
- Do not add stale worktree cleanup.
- Do not redesign the wrapper's metadata/audit flow.
- Do not add a configurable blocked-branches list in this slice.
- Do not solve "executor invoked from main planning worktree even on a task
  branch" in this slice.

## Open questions

None.

Resolved:

- Branch detection: `git symbolic-ref --quiet --short HEAD`.
- Blocked branches: `main`, `master` (hardcoded for this slice).
- Detached HEAD: do not block.
- Non-git directory: do not block.
- Escape hatch: `AGENTOPS_ALLOW_MAIN_EXECUTOR=1`, with loud warning.
- Test/no-network mode: guard stays enforced; bypass requires
  `AGENTOPS_ALLOW_MAIN_EXECUTOR=1`.
- Worktree awareness: deferred to a later task.
- Error message wording: locked above.

## Promotion decision

Decision: promote_to_ready.

Reason:
All previously open guard semantics (branch detection rule, blocked branch
set, detached HEAD handling, non-git handling, escape hatch, test-mode
interaction, error message wording) are now locked. Read/write scope is
concrete.

Next action:
Promote to ready and execute through the Hermes/coder collection prompt.

## Promotion criteria

Already promoted to ready.

## Verification

```bash
git status --short --branch
bash -n scripts/run-opencode-executor.sh
git diff --stat
```

When promoted, add concrete invocation checks:

```bash
# happy path: from a task branch, runs as before
# negative path: from main, refuses with clear message and non-zero exit
# escape hatch: AGENTOPS_ALLOW_MAIN_EXECUTOR=1 prints warning and continues
# detached HEAD: does not block
```

Do not use `|| true` to mask failures.

## Accept criteria

- Change is limited to write scope.
- Guard refuses with non-zero exit when current branch is `main` or `master`.
- Guard prints the locked error message wording to stderr.
- Guard honors `AGENTOPS_ALLOW_MAIN_EXECUTOR=1` and prints a loud warning before continuing.
- Guard does not block on detached HEAD.
- Guard does not block when invoked outside a git repository.
- Guard stays enforced when `AGENTOPS_EXECUTOR_COMMAND` is set.
- Existing wrapper behavior is preserved on non-main, non-master branches.
- Verification commands pass.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0086-executor-on-main-guard.md

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
- modify only scripts/run-opencode-executor.sh (+ minimal docs/tests if needed)
- detect current branch via `git symbolic-ref --quiet --short HEAD`
- refuse with non-zero exit when on `main` or `master`
- honor `AGENTOPS_ALLOW_MAIN_EXECUTOR=1` as escape hatch (with loud stderr warning)
- do not block on detached HEAD
- do not block when outside a git repository
- keep guard enforced even when `AGENTOPS_EXECUTOR_COMMAND` is set
- use the locked error message wording from the task file (substitute the actual branch name)
- do not infer canonical planning checkout path in this slice

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

This is the real safety net for the worktree policy. Documentation drift
cleanup (TASK-0085) covers the wording side; this task covers the enforcement
side.

The escape hatch is intentionally named `AGENTOPS_ALLOW_MAIN_EXECUTOR` (not
`AGENTOPS_ALLOW_MAIN`) so it is narrower and less likely to be confused with
other lifecycle operations on `main`.

Worktree-aware blocking ("executor invoked from the main planning worktree
even on a task branch") is deliberately deferred. Current-branch-on-main is
enough for this slice.
