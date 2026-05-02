# Hermetic Agentarium

Controlled agentic coding workflows, profiles, and skills.

## Purpose

This repository stores sanitized Hermes profile and skill templates for safe, reviewable coding orchestration.

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

## Security warning

Agent instructions are not a security boundary.

Hermes agents may technically read any file accessible to the current operating-system user. For real repository testing, use clean clones without `.env` or secret files.
