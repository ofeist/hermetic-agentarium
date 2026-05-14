# workflow-06 — Add executor-on-main guard to OpenCode wrapper

## Status

planned

## Goal

Prevent `scripts/run-opencode-executor.sh` from running executor work when the
current git context indicates the caller is on `main`.

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

Add a guard to `scripts/run-opencode-executor.sh` that refuses (or warns) when
the current branch is `main`. First slice should be conservative: detect the
case clearly, exit non-zero with a clear message and a suggested next command.
No automatic worktree creation; no automatic switching.

## Executor

Harness: TBD (default in this repo: OpenCode).
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

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

- detect the current branch reliably (handle detached HEAD, non-git directories, alternative main branch names)
- refuse to invoke the executor when the current branch is the canonical main branch
- print a clear error message
- suggest using `scripts/start-agentops-worktree.sh` as the corrective next step
- preserve existing wrapper behavior when not on main
- decide explicitly how to interact with `AGENTOPS_EXECUTOR_COMMAND` test/no-network mode (skip the guard or keep it enforced)

Guard semantics that need explicit decisions before promotion:

- branch detection: `git rev-parse --abbrev-ref HEAD` returns `HEAD` in detached state — how should that be treated?
- alternative main branch names: should `master` also be guarded? Should it be configurable via env var or refs lookup?
- worktree awareness: should the guard also check whether the current checkout is the canonical "planning cockpit" worktree, or is current-branch-is-main enough for this slice?
- escape hatch: should `AGENTOPS_ALLOW_MAIN=1` (or similar) be supported?
- non-git directory: should the wrapper refuse outright, or proceed without the guard?
- error message wording.

## Non-goals

- Do not change the worktree policy.
- Do not auto-create worktrees.
- Do not auto-switch branches.
- Do not deprecate or remove `scripts/start-agentops-task.sh`.
- Do not modify `scripts/start-agentops-worktree.sh`.
- Do not add stale worktree cleanup.
- Do not redesign the wrapper's metadata/audit flow.

## Open questions

- Should the guard also cover `master` by default?
- Should `AGENTOPS_ALLOW_MAIN=1` (or similar escape hatch) be supported?
- Should the guard skip when `AGENTOPS_EXECUTOR_COMMAND` is set (test/no-network mode)?
- Should the guard also block when invoked from the canonical main planning worktree even if on a task branch (i.e. enforce "executor in main worktree" anti-pattern), or is current-branch-on-main enough for this slice?
- What is the right error message wording?

## Promotion decision

Decision: keep_planned.

Reason:
The guard semantics need explicit decisions before promotion. In particular: detached HEAD handling, alternative main names, optional escape hatch, test-mode interaction, and whether the guard should block by current branch only or also by current worktree.

Next action:
Lock the guard semantics above, then promote.

## Promotion criteria

Promote to `ready` when:

- the branch detection rule is locked (including detached HEAD)
- the alternative main names policy is decided
- the escape hatch (if any) is decided
- the test/no-network mode interaction is decided
- error message wording is agreed
- read/write scope is confirmed

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
```

Do not use `|| true` to mask failures.

## Accept criteria

TBD during promotion.

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

This is the real safety net for the worktree policy. Documentation drift
cleanup (TASK-0085) covers the wording side; this task covers the enforcement
side.

The guard is not "5-line": branch detection needs careful semantics
(detached HEAD, alternative main branch names, worktree-awareness, CI/test
mode). Decide those before promoting.
