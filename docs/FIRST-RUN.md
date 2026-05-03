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

Do not print or inspect OpenCode auth files.

## Safe smoke test

Create a branch:

    git checkout main
    git pull --ff-only
    git checkout -b first-run-smoke

Run the example prompt through the executor wrapper:

    ./scripts/run-opencode-executor.sh examples/opencode-docs-task.prompt.md deepseek/deepseek-chat

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
    git branch -D first-run-smoke

## Notes

- The executor must not commit.
- Git diffs and tests are the source of truth.
- Do not run executor work directly on `main` unless explicitly instructed.
- Do not fallback to another model unless the task explicitly allows it.
