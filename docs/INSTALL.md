# Install

This repository contains sanitized Hermes profile and skill templates.

It does not contain local runtime configuration, API keys, auth files, sessions, or logs.

## 1. Install Hermes

Install Hermes on the target machine first.

This repo assumes Hermes already exists and can run locally.

## 2. Clone this repository

```bash
git clone git@github.com:ofeist/hermetic-agentarium.git
cd hermetic-agentarium
```

## 3. Install the coder profile and custom skill

```bash
./scripts/install-coder-profile.sh
```

This copies:

```text
profiles/coder/SOUL.md
→ ~/.hermes/profiles/coder/SOUL.md

skills/hermetic-coding-orchestrator/SKILL.md
→ ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
```

## 4. Configure local runtime files manually

Local Hermes runtime files are intentionally not stored in this repository.

Create or configure these manually:

```text
~/.hermes/profiles/coder/config.yaml
~/.hermes/profiles/coder/auth.json
```

Never commit real API keys, auth files, `.env` files, sessions, logs, or request dumps.

See:

```text
examples/config.example.yaml
docs/SECURITY.md
```

## 5. Test skill detection

In a small test repository, run:

```bash
coder
```

Then prompt:

```text
Use the hermetic-coding-orchestrator skill.

Task:
Report the workflow rules you will follow for this repository.

Constraints:
- Read-only.
- Do not modify files.
- Do not use delegate_task.
- Do not commit.

Return:
- skill detected:
- first verification command:
- delegation guardrail:
- dirty-worktree rule:
- no-op rule:
```

Expected result:

```text
skill detected: hermetic-coding-orchestrator
```

## 6. Working with real repositories

Do not run Hermes against a repository that contains real secrets unless you have proper isolation.

Recommended pattern:

```bash
git clone <repo> ~/tmp/<repo>-agent-test
cd ~/tmp/<repo>-agent-test
rm -f .env .env.* auth.json config.yaml
coder
```

Agent instructions are not a security boundary.

Use clean clones, separate users, containers, or sandboxing for stronger isolation.
