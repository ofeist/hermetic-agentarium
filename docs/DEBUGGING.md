# Debugging

This guide covers common Hermes/OpenCode AgentOps failures and safe checks.

## Safety boundary

Do not inspect, print, copy, or commit secrets while debugging.

Do not print:

- `.env` files
- API keys
- provider tokens
- SSH keys
- OpenCode auth files
- request/response dumps that may contain secrets

In particular, do not inspect OpenCode auth files such as `auth.json`.

## First checks

Run these from the repository root:

    git status --short --branch
    which opencode
    opencode --version
    echo "$HOME"
    echo "${OPENCODE_XDG_CONFIG_HOME:-}"
    echo "${OPENCODE_XDG_DATA_HOME:-}"

These checks confirm branch state, OpenCode availability, and whether runtime environment overrides are visible.

## Model or provider not found

Symptom:

    ProviderModelNotFoundError
    Model not found

Likely cause:

- OpenCode is configured in your normal shell.
- Hermes/coder runs with an isolated `HOME`.
- OpenCode cannot see the expected config/data directories from the Hermes runtime.

Fix:

Set these in the shell where you start Hermes/coder:

    export OPENCODE_XDG_CONFIG_HOME="$HOME/.config"
    export OPENCODE_XDG_DATA_HOME="$HOME/.local/share"
    export AGENTOPS_EXECUTOR_MODEL=deepseek/deepseek-v4-pro

Then retry through the wrapper:

    scripts/run-opencode-executor.sh /tmp/task-prompt.txt

Do not silently fallback to another model.

## Wrong branch

Symptom:

- Executor work starts on `main`.
- `git status --short --branch` shows `## main`.

Fix:

Stop before running the executor and create a task branch:

    git checkout main
    git pull --ff-only
    git checkout -b task-xxxx-short-description

If changes already happened on `main`, inspect carefully before moving or committing them.

## Dirty working tree

Symptom:

    git status --short --branch

shows unrelated modified or untracked files before executor work.

Fix:

Do not overwrite unrelated changes. Either:

- finish or stash the unrelated work
- use a clean clone
- stop and ask for direction

## `git diff` is empty but a file exists

Symptom:

- Executor created a new file.
- `git diff` shows nothing.

Likely cause:

The file is untracked.

Check:

    git status --short --branch

For review only, stage the expected file and inspect the cached diff:

    git add <expected-file>
    git diff --cached --stat
    git diff --cached -- <expected-file>

Do not stage unrelated files.

## Executor changed the wrong files

Symptom:

    scripts/review-executor-result.sh

shows files outside the task write scope.

Fix:

Review the changed file list:

    git diff --name-only
    git diff --stat

Decision should usually be `revise` or `revert`.

To discard only executor-touched files:

    git restore <file>

Avoid broad commands such as `git restore .` unless you are certain there are no unrelated local changes.

## Verification failed

Symptom:

- tests fail
- syntax check fails
- command output contradicts executor summary

Fix:

Do not accept the task. Report `revise` or `blocked`, depending on the failure.

Trust command output over agent summaries.

## Wrapper is not executable

Symptom:

    Permission denied

Fix:

    chmod +x scripts/run-opencode-executor.sh
    chmod +x scripts/review-executor-result.sh

Then verify:

    bash -n scripts/run-opencode-executor.sh
    bash -n scripts/review-executor-result.sh

## OpenCode not on PATH

Symptom:

    opencode: command not found

Check:

    which opencode

Fix the local OpenCode installation or shell PATH before retrying.

## Audit signal

The executor wrapper prints:

    Executor harness: OpenCode
    Executor model: <provider/model>

Use this as a lightweight audit signal for which harness/model was requested.

This is not a substitute for reviewing the diff and verification output.

## Local run logs

Raw prompts, stdout/stderr, and model responses may contain sensitive information.

Do not commit local run logs by default.

Local executor run artifacts should stay under:

    .agentops-runs/

This directory is gitignored and is intended for local-only debugging/audit data.

The local run audit contract is documented in:

    docs/RUN-AUDIT.md

Optional run capture can be enabled by passing a run id:

    scripts/run-opencode-executor.sh /tmp/TASK-xxxx.prompt.md "$AGENTOPS_EXECUTOR_MODEL" TASK-xxxx

Or by setting:

    AGENTOPS_RUN_ID=TASK-xxxx

Safe committed summaries belong in:

    agentops/results/TASK-xxxx-result.md

## Rendered prompts

A ready task file under `agentops/tasks/ready/TASK-xxxx.md` can be turned into an executor
prompt with the render helper:

    scripts/render-opencode-prompt.sh agentops/tasks/ready/TASK-xxxx.md > /tmp/TASK-xxxx.prompt.md

The rendered prompt includes executor role instructions, safety constraints, and a required
return format alongside the full task content.

Pass the rendered prompt to the executor with local run capture:

    AGENTOPS_RUN_ID=TASK-xxxx scripts/run-opencode-executor.sh /tmp/TASK-xxxx.prompt.md

This creates a capture under `.agentops-runs/TASK-xxxx/` including the rendered prompt,
stdout, stderr, and metadata.
