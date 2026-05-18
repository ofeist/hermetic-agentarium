# TASK-0040 — Add render-opencode-prompt helper

## Status

done

## Goal

Add a small helper script that renders an AgentOps ready task file into a standardized OpenCode executor prompt.

The helper should reduce manual copy/paste when Hermes/coder prepares executor prompts.

## Background

The Hermes/OpenCode executor workflow currently often requires manually preparing a prompt file under `/tmp`.

TASK-0038 documented the local run audit contract.
TASK-0039 added optional local run capture to `scripts/run-opencode-executor.sh`.

This task adds the next small building block: deterministic prompt rendering from a ready task file.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

## Read scope

- scripts/
- docs/
- agentops/tasks/ready/TASK-0040-render-opencode-prompt-helper.md

## Write scope

- scripts/render-opencode-prompt.sh
- docs/DEBUGGING.md
- docs/RUN-AUDIT.md, only if a small note is useful

Do not modify unrelated files.

## Requirements

Create:

    scripts/render-opencode-prompt.sh

The script should:

- be shell-only
- use `set -euo pipefail`
- accept exactly one argument: path to a ready task file
- fail with a helpful usage message if no argument is provided
- fail if the task file does not exist
- print the rendered executor prompt to stdout
- not modify files
- not create `/tmp` files itself
- not run OpenCode itself
- not read `.env`, tokens, auth files, SSH keys, or private config

The rendered prompt should include:

- a short executor role instruction
- explicit constraints:
  - do not commit
  - do not modify unrelated files
  - do not read or print secrets
  - keep changes minimal
- the full original task file content
- a required return format:
  - changed files
  - diff summary
  - verification output
  - uncertainty or risks

The helper should be intentionally simple. Do not implement a parser yet.

## Example usage

    scripts/render-opencode-prompt.sh agentops/tasks/ready/TASK-0040-render-opencode-prompt-helper.md > /tmp/TASK-0040.prompt.md

Then executor can be run with audit capture:

    scripts/run-opencode-executor.sh /tmp/TASK-0040.prompt.md deepseek/deepseek-chat TASK-0040

## Documentation

Update `docs/DEBUGGING.md` with a short note showing how rendered prompts fit with local run capture.

Only update `docs/RUN-AUDIT.md` if needed. Keep documentation changes minimal.

## Non-goals

- No parser
- No JSON/YAML task schema
- No automatic lifecycle moves
- No wrapper changes
- No database
- No executor abstraction
- No OpenCode invocation from this helper
- No committing raw prompts or logs

## Verification

Run:

    bash -n scripts/render-opencode-prompt.sh
    scripts/render-opencode-prompt.sh agentops/tasks/ready/TASK-0040-render-opencode-prompt-helper.md > /tmp/TASK-0040.prompt.md
    grep -q "Do not commit" /tmp/TASK-0040.prompt.md
    grep -q "TASK-0040" /tmp/TASK-0040.prompt.md
    git status --short --branch
    git diff --stat

Optional, if safe:

    scripts/run-opencode-executor.sh /tmp/TASK-0040.prompt.md deepseek/deepseek-chat TASK-0040

## Accept criteria

- `scripts/render-opencode-prompt.sh` exists and is executable
- helper accepts exactly one ready task file argument
- helper writes rendered prompt to stdout
- helper does not modify files
- rendered prompt includes the original task content
- rendered prompt includes safety constraints
- rendered prompt includes required return format
- docs mention how to use render helper with run capture
- no wrapper behavior changed
- verification commands pass

## Return format

Return:

- changed files
- diff summary
- verification output
- any uncertainty or risks
