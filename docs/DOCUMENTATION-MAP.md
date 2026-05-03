# Documentation Map

This document explains where to start and which documents to read depending on what you want to do.

## New user path

Read these in order:

1. `README.md` — project overview and current status.
2. `docs/INSTALL.md` — install the Hermes coder profile and custom skill.
3. `docs/OPENCODE-CONFIGURATION.md` — configure OpenCode and runtime environment variables.
4. `docs/FIRST-RUN.md` — run the first safe smoke test.
5. `docs/DEBUGGING.md` — troubleshoot common setup and execution issues.

## Operator path

Use these documents when running or reviewing AgentOps tasks:

1. `agentops/TASK-LIFECYCLE.md` — task states and decision model.
2. `docs/OPENCODE-EXECUTOR-WORKFLOW.md` — Hermes/OpenCode execution flow.
3. `templates/opencode-executor-task.prompt.md` — reusable bounded executor prompt template.
4. `examples/opencode-docs-task.prompt.md` — filled example prompt.
5. `agentops/results/` — safe result summaries for completed tasks.

## Maintainer path

Use these documents when changing this repository or local Hermes installation:

1. `docs/SECURITY.md` — secret-handling and repository safety rules.
2. `docs/WORKFLOW.md` — repository maintenance workflow.
3. `docs/DEEPSEEK_PROVIDER_SETUP.md` — DeepSeek provider setup notes.
4. `profiles/coder/SOUL.md` — Hermes coder profile behavior.
5. `skills/hermetic-coding-orchestrator/SKILL.md` — custom orchestration skill.

## Current project phase

The POC is validated. The next focus is usability and documentation:

- make first-run onboarding clear
- document OpenCode configuration and runtime env vars
- document debugging/audit practices
- keep AgentOps lifecycle operations small and reviewable

## Not a framework yet

This repository intentionally avoids becoming a large SDLC platform too early. Git, diffs, tests, and explicit parent review remain the source of truth.
