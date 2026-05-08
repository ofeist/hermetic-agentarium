# Hermetic Agentarium

Controlled agentic coding workflows, profiles, and skills.

## Purpose

This repository stores sanitized Hermes profile and skill templates for safe, reviewable coding orchestration.

## Prerequisites

Before installing the coder profile, make sure you already have:

- Git
- Bash
- Python 3
- Hermes installed and usable locally
- OpenCode installed and authenticated locally
- an OpenCode provider/model configured, for example `deepseek/deepseek-v4-pro`

Tested locally with:
- Hermes Agent v0.12.0 (2026.4.30)
- OpenCode 1.14.33
- Node for Codex/OpenCode path: v22.14.0
- Python used by Hermes: 3.11.15
- OpenAI SDK used by Hermes: 2.32.0

This repository does **not** install Hermes, OpenCode, provider credentials, or auth files.

The install script only copies the repo-managed Hermes `coder` profile and custom skill into your local Hermes runtime. Local runtime files such as `~/.hermes/config.yaml`, `~/.hermes/auth.json`, OpenCode auth/config, and provider keys stay local and are not managed by this repo.

## Coder coordinator profile

`hermes` and `coder` can use different Hermes runtime profiles. The `coder` wrapper uses the isolated profile under `~/.hermes/profiles/coder/`, so `hermes status` and `coder status` can show different model, provider, and auth state.

For this AgentOps workflow, configure the `coder` profile, not only global `hermes`. A typical coordinator target is `gpt-5.5` with `OpenAI Codex`; the OpenCode executor can still use a different worker model through `AGENTOPS_EXECUTOR_MODEL`, for example `deepseek/deepseek-v4-pro`.

Safe coordinator setup checks:

    coder auth add openai-codex --type oauth --no-browser
    coder model
    coder status
    coder -z "Reply with exactly: coder coordinator ok"

Do not print or inspect auth files, especially `~/.hermes/profiles/coder/auth.json` or `~/.hermes/auth.json`.

## Quickstart

Shortest path to a local smoke run:

1. Clone the repository and enter it:

       git clone https://github.com/ofeist/hermetic-agentarium.git
       cd hermetic-agentarium

2. Install the Hermes `coder` profile and custom skill:

       ./scripts/install-coder-profile.sh

   This installs:

       profiles/coder/SOUL.md
       skills/hermetic-coding-orchestrator/SKILL.md

   into your local `~/.hermes/` runtime.

3. Make sure OpenCode is installed and visible:

       which opencode
       opencode --version

4. In the shell where you start Hermes/coder, expose the user's OpenCode runtime homes if needed:

       export OPENCODE_XDG_CONFIG_HOME="$HOME/.config"
       export OPENCODE_XDG_DATA_HOME="$HOME/.local/share"
       export AGENTOPS_EXECUTOR_MODEL=deepseek/deepseek-v4-pro

   Do not print or inspect OpenCode auth files.

5. Read the first-run guide:

       docs/FIRST-RUN.md

6. Run or review the minimal executor workflow:

       ./scripts/run-opencode-executor.sh examples/opencode-docs-task.prompt.md
       ./scripts/review-executor-result.sh

Always run executor work on a branch, not directly on `main`, unless explicitly instructed.

## Includes

- coder `SOUL.md`
- `hermetic-coding-orchestrator` `SKILL.md`
- example configuration templates
- workflow and security documentation
- install helper scripts

## Does not include

- API keys
- `.env` files
- `auth.json`
- real `config.yaml`
- local sessions
- logs
- request dumps

## Custom skill name

The main custom skill is `hermetic-coding-orchestrator`.

It is intentionally named differently from Hermes bundled skills such as `subagent-driven-development`, so prompts can target this repository's workflow more explicitly.

## Core workflow

User task
→ parent agent plans
→ bounded child delegation
→ parent verifies with git diff/status/tests
→ parent decides accept/revise/revert/no-op

## Documentation

Start here:

- [Documentation Map](docs/DOCUMENTATION-MAP.md) — what to read and in which order.
- [Install](docs/INSTALL.md) — install the Hermes profile and skill.
- [First Run](docs/FIRST-RUN.md) — first safe smoke run.
- [OpenCode Configuration](docs/OPENCODE-CONFIGURATION.md) — provider/model setup and runtime environment variables.
- [OpenCode Executor Workflow](docs/OPENCODE-EXECUTOR-WORKFLOW.md) — Hermes/OpenCode execution model.
- [Debugging](docs/DEBUGGING.md) — common failures and safe checks.
- [POC Status](docs/POC-STATUS.md) — current validated POC status.
- [AgentOps Task Lifecycle](agentops/TASK-LIFECYCLE.md) — task lifecycle states and decisions.
- [AgentOps Usage Guide](agentops/USAGE.md) — practical lifecycle usage.
- [Security](docs/SECURITY.md) — repository and secret-handling rules.
- [DeepSeek Provider Setup](docs/DEEPSEEK_PROVIDER_SETUP.md) — configure Hermes so the parent can stay on OpenAI while delegated child agents use DeepSeek.

## Security warning

Agent instructions are not a security boundary.

Hermes agents may technically read any file accessible to the current operating-system user. For real repository testing, use clean clones without `.env` or secret files.
