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

The installer resolves two possible install targets:

- account home from `getent passwd $(id -un)`
- active `$HOME` (when different, e.g. profile-managed/sandbox sessions)

It installs into each target's `.hermes/...` tree so the skill remains discoverable
in normal and profile-managed workflows.

You can override the install root explicitly:

```bash
HERMES_INSTALL_HOME=/absolute/path ./scripts/install-coder-profile.sh
```

This copies:

```text
profiles/coder/SOUL.md
→ <install-root>/.hermes/profiles/coder/SOUL.md

skills/hermetic-coding-orchestrator/SKILL.md
→ <install-root>/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
→ <install-root>/.hermes/profiles/coder/skills/hermetic-coding-orchestrator/SKILL.md
```

The installer also creates or updates the local runtime file:

```text
~/.hermes/profiles/coder/.env
```

This `.env` is local runtime config and must not be committed.
OpenCode runtime home variables (`OPENCODE_XDG_CONFIG_HOME`, `OPENCODE_XDG_DATA_HOME`)
and the executor model variable (`AGENTOPS_EXECUTOR_MODEL`) are added automatically
if missing.

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

## 5. Verify skill package

After install, verify the skill package is intact (replace `~` if you used
`HERMES_INSTALL_HOME`):

```bash
test -f ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
grep -q '^name: hermetic-coding-orchestrator$' ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
grep -q 'USING_SKILL: hermetic-coding-orchestrator' ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
```

Verify the collection prompt generator still produces the correct invocation:

```bash
scripts/render-collection-prompt.sh agentops/tasks/ready/<any-ready-task>.md | head -1
```

Expected output starts with:

```text
/hermetic-coding-orchestrator
```

Run the lifecycle check:

```bash
scripts/check-agentops-lifecycle.sh
```

If Hermes CLI is available, verify slash invocation works:

```bash
hermes --profile coder chat -q "/hermetic-coding-orchestrator Summarize your workflow rules in 3 bullets"
```

Expected result: the skill is detected and the response includes
`USING_SKILL: hermetic-coding-orchestrator`.

## 6. Skill package authority

The package README at `skills/hermetic-coding-orchestrator/README.md` is the
authoritative document for compatibility guarantees, install path, and
verification. Consult it when the installed skill does not behave as expected.

## 7. Working with real repositories

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
