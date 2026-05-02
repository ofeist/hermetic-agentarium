#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"

echo "Bootstrapping hermetic-agentarium in: $ROOT"

# Safety check: avoid running inside home or filesystem root by mistake.
if [[ "$ROOT" == "$HOME" || "$ROOT" == "/" ]]; then
  echo "ERROR: Refusing to run in $ROOT"
  echo "Create and enter a dedicated hermetic-agentarium directory first."
  exit 1
fi

mkdir -p profiles/coder
mkdir -p skills/coding-orchestrator
mkdir -p examples
mkdir -p docs
mkdir -p scripts

# Copy existing local Hermes files if present.
if [[ -f "$HOME/.hermes/profiles/coder/SOUL.md" ]]; then
  cp "$HOME/.hermes/profiles/coder/SOUL.md" profiles/coder/SOUL.md
  echo "Copied SOUL.md from ~/.hermes/profiles/coder/"
else
  echo "WARNING: ~/.hermes/profiles/coder/SOUL.md not found"
  touch profiles/coder/SOUL.md
fi

if [[ -f "$HOME/.hermes/skills/coding-orchestrator/SKILL.md" ]]; then
  cp "$HOME/.hermes/skills/coding-orchestrator/SKILL.md" skills/coding-orchestrator/SKILL.md
  echo "Copied SKILL.md from ~/.hermes/skills/coding-orchestrator/"
else
  echo "WARNING: ~/.hermes/skills/coding-orchestrator/SKILL.md not found"
  touch skills/coding-orchestrator/SKILL.md
fi

cat > .gitignore <<'GITIGNORE_EOF'
# Secrets
.env
.env.*
*.key
*.pem
id_rsa
id_ed25519
auth.json
config.yaml
request_dump_*.json

# Hermes runtime state
sessions/
logs/
*.log

# Python/editor noise
__pycache__/
.pytest_cache/
.venv/
venv/
.DS_Store
.idea/
.vscode/
GITIGNORE_EOF

cat > README.md <<'README_EOF'
# Hermetic Agentarium

Controlled agentic coding workflows, profiles, and skills.

## Purpose

This repository stores sanitized Hermes profile and skill templates for safe, reviewable coding orchestration.

## Includes

- coder `SOUL.md`
- `coding-orchestrator` `SKILL.md`
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

## Core workflow

User task  
→ parent agent plans  
→ bounded child delegation  
→ parent verifies with git diff/status/tests  
→ parent decides accept/revise/revert/no-op

## Security warning

Agent instructions are not a security boundary.

Hermes agents may technically read any file accessible to the current operating-system user. For real repository testing, use clean clones without `.env` or secret files.
README_EOF

cat > docs/SECURITY.md <<'SECURITY_EOF'
# Security

This repository must not contain secrets.

Do not commit:

- `.env`
- `.env.*`
- `auth.json`
- `config.yaml`
- API keys
- SSH keys
- tokens
- request dumps
- Hermes sessions
- Hermes logs

## Working with real repositories

Hermes agents may technically read any file accessible to the current operating-system user.

For agent testing, use a clean clone without secret files.

Recommended pattern:

```bash
git clone <repo> ~/tmp/<repo>-agent-test
cd ~/tmp/<repo>-agent-test
rm -f .env .env.* auth.json config.yaml
coder
```

## Rule

Agent instructions are not a security boundary.

Do not rely only on prompts to protect secrets. Use clean clones, file permissions, containers, or separate users for stronger isolation.
SECURITY_EOF

cat > docs/WORKFLOW.md <<'WORKFLOW_EOF'
# Workflow

## Default coding workflow

1. Inspect repository state.
2. Read project instructions.
3. Plan the smallest useful change.
4. Delegate bounded implementation or investigation when useful.
5. Parent independently verifies results.
6. Parent reviews diff and decides:
   - accept
   - revise
   - revert
   - no-op / nothing to accept
   - ask user

## Verification baseline

Use at least:

```bash
git status --short --branch
git diff --stat
```

Add targeted tests when applicable.
WORKFLOW_EOF

cat > examples/config.example.yaml <<'CONFIG_EOF'
# Example only. Do not store real API keys in Git.
#
# In some Hermes/custom-provider setups, environment variable interpolation
# such as ${OPENAI_API_KEY} may not work reliably in api_key fields.
# If you use literal keys locally, keep config.yaml ignored and private.

providers:
  openai-custom:
    base_url: "https://api.openai.com/v1"
    api_key: "REPLACE_ME_DO_NOT_COMMIT_REAL_KEY"

models:
  parent:
    provider: openai-custom
    model: o4-mini

  child:
    provider: openai-custom
    model: gpt-4.1-nano
CONFIG_EOF

cat > examples/real-repo-readonly-test.prompt.md <<'PROMPT_EOF'
Use the coding-orchestrator skill.

Task:
Inspect this repository and summarize:
- project type
- main languages/tools
- how to run tests if discoverable
- whether it is safe for a small docs-only delegated edit

Constraints:
- Read-only inspection only.
- Do not modify files.
- Do not read secret files.
- Do not commit.
- Use delegate_task for repository inspection.
- Parent must independently verify:
  - git status --short --branch
  - git diff --stat

Return:
Plan:
Implementation:
Verification:
Review:
Changed files:
PROMPT_EOF

cat > scripts/install-coder-profile.sh <<'INSTALL_EOF'
#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/.hermes/profiles/coder"
mkdir -p "$HOME/.hermes/skills/coding-orchestrator"

cp "$REPO_ROOT/profiles/coder/SOUL.md" \
   "$HOME/.hermes/profiles/coder/SOUL.md"

cp "$REPO_ROOT/skills/coding-orchestrator/SKILL.md" \
   "$HOME/.hermes/skills/coding-orchestrator/SKILL.md"

echo "Installed:"
echo "- $HOME/.hermes/profiles/coder/SOUL.md"
echo "- $HOME/.hermes/skills/coding-orchestrator/SKILL.md"
echo
echo "Note: config.yaml and auth.json are local runtime files and are not installed from this repo."
INSTALL_EOF

chmod +x scripts/install-coder-profile.sh

echo
echo "Done."
echo
echo "Created:"
find . -maxdepth 3 -type f | sort
