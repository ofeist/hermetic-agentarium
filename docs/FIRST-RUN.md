# First Run

This guide shows the smallest safe workflow for running the Hermes/OpenCode executor loop.

## Before you start

You should already have:

- this repository cloned locally
- Hermes Agent installed
- the `coder` profile installed from this repository
- OpenCode installed and available as `opencode`
- at least one OpenCode provider/model configured
- a clean Git working tree

Check:

    git status --short --branch
    which opencode
    opencode --version

## Runtime environment

Hermes may run with an isolated `HOME`, so OpenCode might not see your normal user configuration unless you pass explicit runtime homes.

In the shell where you start Hermes/coder, set:

    export OPENCODE_XDG_CONFIG_HOME="$HOME/.config"
    export OPENCODE_XDG_DATA_HOME="$HOME/.local/share"
    export AGENTOPS_EXECUTOR_MODEL=deepseek/deepseek-v4-pro

If `./scripts/install-coder-profile.sh` has been run, the OpenCode runtime env
vars may already be configured in the local coder profile `.env` at
`~/.hermes/profiles/coder/.env`. Manual export remains useful for debugging.

Do not print or inspect OpenCode auth files.

## Safe smoke test

Create a task-specific worktree on a task branch:

    git checkout main
    git pull --ff-only
    ./scripts/start-agentops-worktree.sh TASK-0000-first-run-smoke

`main` stays as the planning/control checkout. The worktree isolates executor work from `main`. `scripts/start-agentops-task.sh` remains a fallback.

Run the example prompt through the executor wrapper:

    ./scripts/run-opencode-executor.sh examples/opencode-docs-task.prompt.md

Review the result:

    ./scripts/review-executor-result.sh
    git diff

Stage only the expected file for review before inspecting the cached diff:

    git add docs/EXAMPLE.md
    git diff --cached --stat
    git diff --cached -- docs/EXAMPLE.md

## Decision

Choose one:

- `accept` — the diff is correct; commit it.
- `revise` — write a narrower prompt and re-run.
- `revert` — discard only executor-touched files.
- `no-op / nothing to accept` — no useful diff was produced.
- `blocked` — required model, provider, or runtime setup is unavailable.

## Cleanup

If this was only a smoke test and you do not want to keep the result:

    git restore --staged docs/EXAMPLE.md 2>/dev/null || true
    git restore docs/EXAMPLE.md

Then return to main and delete the smoke branch if desired:

    git checkout main
    git branch -D task-0000-first-run-smoke

## Notes

- The executor must not commit.
- Git diffs and tests are the source of truth.
- Do not run executor work on `main`. Executor work belongs in a task-specific worktree on a task branch.
- Executor model selection is controlled by runner configuration, not task prompt text.
