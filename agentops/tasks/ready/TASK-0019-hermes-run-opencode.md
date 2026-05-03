# TASK-0019 — Hermes runs OpenCode executor

Status: ready

## Goal

Verify that the Hermes/coder parent can use the repository's OpenCode executor wrapper to run a bounded docs-only task, then independently review the result.

## Read scope

The executor may read only:

- README.md
- docs/OPENCODE-EXECUTOR-WORKFLOW.md
- templates/opencode-executor-task.prompt.md
- examples/opencode-docs-task.prompt.md
- scripts/run-opencode-executor.sh
- scripts/review-executor-result.sh

## Write scope

The executor may only create or modify:

- docs/HERMES-OPENCODE-RUN.md

## Constraints

- Do not commit.
- Do not modify unrelated files.
- Do not read other repository files unless they are explicitly listed in Read scope.
- Do not read, print, modify, or search for secrets.
- Do not touch .env files, API keys, auth files, SSH keys, tokens, credentials, or private config.
- Do not inspect ~/.config, ~/.local/share, or any auth/config locations outside this repository.
- Keep the diff minimal.
- Do not introduce Taskplane.
- Do not introduce a larger framework.
- Parent will independently verify git diff and checks.

## Executor

Harness: OpenCode  
Model: deepseek/deepseek-chat  

Wrapper command:

    ./scripts/run-opencode-executor.sh /tmp/task-0019-hermes-run-opencode.prompt.txt deepseek/deepseek-chat

## Implementation requirements

Create docs/HERMES-OPENCODE-RUN.md with:

- title: Hermes to OpenCode Run
- short explanation that Hermes/coder prepares the bounded task and parent review
- short explanation that OpenCode runs as the executor through scripts/run-opencode-executor.sh
- short explanation that the executor must not commit
- short explanation that Git diff and verification commands are the source of truth
- no external links
- no setup instructions

## Verification

Parent should run:

    ./scripts/review-executor-result.sh
    git diff -- docs/HERMES-OPENCODE-RUN.md

If the file is untracked, parent should stage only that file for review:

    git add docs/HERMES-OPENCODE-RUN.md
    git diff --cached --stat
    git diff --cached -- docs/HERMES-OPENCODE-RUN.md

## Decision states

- accept
- revise
- revert
- no-op / nothing to accept
