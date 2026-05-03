# OpenCode Configuration

This document explains how OpenCode fits into the Hermetic Agentarium workflow.

## Purpose

OpenCode is used as the executor harness. Hermes/coder acts as the parent orchestrator, prepares a bounded prompt, invokes OpenCode through the repository wrapper, and independently reviews the result.

## Required command

OpenCode must be available on `PATH`:

    which opencode
    opencode --version

The wrapper calls OpenCode with:

    opencode run --model <provider/model> <prompt>

Do not call OpenCode directly for AgentOps executor tasks unless you are debugging. Use:

    scripts/run-opencode-executor.sh <prompt-file> <model>

## Model naming

Models are passed as:

    provider/model

Example:

    deepseek/deepseek-chat

The model should normally come from the AgentOps task file:

    Harness: OpenCode
    Model: deepseek/deepseek-chat
    Allow fallback: false

If the requested model/provider is unavailable, stop and report `blocked`. Do not silently fallback to another model unless the task explicitly allows fallback.

## Hermes isolated HOME

Hermes/coder may run with an isolated `HOME`, for example inside the local Hermes profile directory. In that case OpenCode may not see the user's normal configuration and data directories.

Symptoms include:

- OpenCode works in your normal shell.
- OpenCode fails from Hermes/coder with a model/provider not found error.
- `deepseek/deepseek-chat` or another configured model is not visible from the Hermes run.

## Runtime environment variables

The wrapper supports these optional environment variables:

- `OPENCODE_XDG_CONFIG_HOME`
- `OPENCODE_XDG_DATA_HOME`

When set, the wrapper forwards them to OpenCode as:

- `XDG_CONFIG_HOME`
- `XDG_DATA_HOME`

Typical local setup:

    export OPENCODE_XDG_CONFIG_HOME="$HOME/.config"
    export OPENCODE_XDG_DATA_HOME="$HOME/.local/share"

Set these in the shell where you start Hermes/coder.

## Security rules

Do not print or inspect OpenCode auth files.

Do not commit:

- API keys
- `.env` files
- `auth.json`
- provider tokens
- local OpenCode session data
- request or response dumps that may contain secrets

The repository may document paths and environment variable names, but it must not store runtime credentials.

## Wrapper audit output

The executor wrapper prints the effective harness and model:

    Executor harness: OpenCode
    Executor model: deepseek/deepseek-chat

This is intended as a small audit signal. It should not print auth contents, token values, or secret file contents.

## Debug checklist

If OpenCode works manually but fails from Hermes/coder:

1. Check the current branch and workspace:

       git status --short --branch

2. Check OpenCode availability:

       which opencode
       opencode --version

3. Check the runtime environment visible to Hermes/coder:

       echo "$HOME"
       echo "${OPENCODE_XDG_CONFIG_HOME:-}"
       echo "${OPENCODE_XDG_DATA_HOME:-}"

4. Re-run through the wrapper with explicit runtime homes:

       OPENCODE_XDG_CONFIG_HOME="$HOME/.config" \
       OPENCODE_XDG_DATA_HOME="$HOME/.local/share" \
       scripts/run-opencode-executor.sh /tmp/task-prompt.txt deepseek/deepseek-chat

Do not inspect auth files while debugging.
