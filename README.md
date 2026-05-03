# Hermetic Agentarium

Controlled agentic coding workflows, profiles, and skills.

## Purpose

This repository stores sanitized Hermes profile and skill templates for safe, reviewable coding orchestration.

## Quickstart

Shortest path to a local smoke run:

1. Clone the repository and enter it:

       git clone https://github.com/ofeist/hermetic-agentarium.git
       cd hermetic-agentarium

2. Install the Hermes `coder` profile and custom skill:

       ./scripts/install-coder-profile.sh

3. Make sure OpenCode is installed and visible:

       which opencode
       opencode --version

4. In the shell where you start Hermes/coder, expose the user's OpenCode runtime homes if needed:

       export OPENCODE_XDG_CONFIG_HOME="$HOME/.config"
       export OPENCODE_XDG_DATA_HOME="$HOME/.local/share"

   Do not print or inspect OpenCode auth files.

5. Read the first-run guide:

       docs/FIRST-RUN.md

6. Run or review the minimal executor workflow:

       ./scripts/run-opencode-executor.sh examples/opencode-docs-task.prompt.md deepseek/deepseek-chat
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
- [OpenCode Executor Workflow](docs/OPENCODE-EXECUTOR-WORKFLOW.md) — Hermes/OpenCode execution model.
- [POC Status](docs/POC-STATUS.md) — current validated POC status.
- [AgentOps Task Lifecycle](agentops/TASK-LIFECYCLE.md) — task lifecycle states and decisions.
- [Security](docs/SECURITY.md) — repository and secret-handling rules.
- [DeepSeek Provider Setup](docs/DEEPSEEK_PROVIDER_SETUP.md) — configure Hermes so the parent can stay on OpenAI while delegated child agents use DeepSeek.

## Security warning

Agent instructions are not a security boundary.

Hermes agents may technically read any file accessible to the current operating-system user. For real repository testing, use clean clones without `.env` or secret files.
