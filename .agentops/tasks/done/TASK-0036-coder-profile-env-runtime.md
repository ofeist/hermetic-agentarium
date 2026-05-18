# TASK-0036 — Verify coder profile env runtime

Status: done

## Goal

Verify that Hermes/coder can execute an OpenCode task using runtime environment variables loaded from the local coder profile `.env`, without requiring manual shell exports.

## Read scope

The executor may read only:

- docs/OPENCODE-CONFIGURATION.md
- docs/FIRST-RUN.md
- scripts/run-opencode-executor.sh
- scripts/review-executor-result.sh

## Write scope

The executor may only create or modify:

- docs/HERMES-CODER-ENV-RUNTIME.md

## Constraints

- Do not commit.
- Do not modify unrelated files.
- Do not read other repository files unless explicitly listed in Read scope.
- Do not read, print, modify, or search for secrets.
- Do not inspect `.env`, auth files, API keys, SSH keys, tokens, credentials, or private config.
- Do not inspect `~/.hermes/profiles/coder/.env`; only rely on environment variables already available to the process.
- Keep the diff minimal.
- If the requested executor model/provider is unavailable, stop and report blocked. Do not fallback to another model unless explicitly allowed by the task.
- Parent will independently verify git diff and checks.

## Executor

Harness: OpenCode
Model: deepseek/deepseek-chat
Allow fallback: false

## Implementation requirements

Create docs/HERMES-CODER-ENV-RUNTIME.md with:

- title: Hermes Coder Profile Env Runtime
- short explanation that the local Hermes coder profile `.env` can provide runtime variables
- short explanation that this avoids manual shell exports for normal runs
- short explanation that `.env` contents must not be printed or committed
- short explanation that OpenCode still runs through `scripts/run-opencode-executor.sh`
- no external links
- no setup instructions

## Verification

Parent should run:

    ./scripts/review-executor-result.sh
    git diff -- docs/HERMES-CODER-ENV-RUNTIME.md

If the file is untracked, parent should stage only that file for review:

    git add docs/HERMES-CODER-ENV-RUNTIME.md
    git diff --cached --stat
    git diff --cached -- docs/HERMES-CODER-ENV-RUNTIME.md

## Decision states

- accept
- revise
- revert
- no-op / nothing to accept
- blocked
