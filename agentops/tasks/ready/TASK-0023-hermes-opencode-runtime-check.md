# TASK-0023 — Hermes OpenCode runtime check

Status: ready

## Goal

Verify that Hermes/coder can execute an OpenCode task from an isolated profile while preserving the required OpenCode runtime configuration.

## Read scope

The executor may read only:

- docs/OPENCODE-EXECUTOR-WORKFLOW.md
- scripts/run-opencode-executor.sh
- scripts/review-executor-result.sh

## Write scope

The executor may only create or modify:

- docs/HERMES-OPENCODE-RUNTIME.md

## Constraints

- Do not commit.
- Do not modify unrelated files.
- Do not read other repository files unless they are explicitly listed in Read scope.
- Do not read, print, modify, or search for secrets.
- Do not touch .env files, API keys, auth files, SSH keys, tokens, credentials, or private config.
- Do not inspect ~/.config, ~/.local/share, or any auth/config locations outside this repository.
- Keep the diff minimal.
- If the requested executor model/provider is unavailable, stop and report blocked. Do not fallback to another model unless explicitly allowed by the task.
- When running OpenCode from an isolated Hermes profile, pass explicit `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if needed.
- Parent will independently verify git diff and checks.

## Executor

Harness: OpenCode  
Model: deepseek/deepseek-chat  
Allow fallback: false

## Implementation requirements

Create docs/HERMES-OPENCODE-RUNTIME.md with:

- title: Hermes OpenCode Runtime
- short explanation that Hermes may run with an isolated HOME
- short explanation that OpenCode config/data homes can be passed explicitly through environment variables
- short explanation that no auth/config file contents should be printed or inspected
- short explanation that missing model/provider configuration should be reported as blocked, not silently replaced
- no external links
- no setup instructions

## Verification

Parent should run:

    ./scripts/review-executor-result.sh
    git diff -- docs/HERMES-OPENCODE-RUNTIME.md

If the file is untracked, parent should stage only that file for review:

    git add docs/HERMES-OPENCODE-RUNTIME.md
    git diff --cached --stat
    git diff --cached -- docs/HERMES-OPENCODE-RUNTIME.md

## Decision states

- accept
- revise
- revert
- no-op / nothing to accept
- blocked
