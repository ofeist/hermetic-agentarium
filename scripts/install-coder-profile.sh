#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/.hermes/profiles/coder"
mkdir -p "$HOME/.hermes/skills/hermetic-coding-orchestrator"

cp "$REPO_ROOT/profiles/coder/SOUL.md" \
   "$HOME/.hermes/profiles/coder/SOUL.md"

cp "$REPO_ROOT/skills/hermetic-coding-orchestrator/SKILL.md" \
   "$HOME/.hermes/skills/hermetic-coding-orchestrator/SKILL.md"

ENV_FILE="$HOME/.hermes/profiles/coder/.env"
if [ ! -f "$ENV_FILE" ]; then
  cp "$REPO_ROOT/profiles/coder/.env.example" "$ENV_FILE"
fi

if grep -q '^OPENCODE_XDG_CONFIG_HOME=$' "$ENV_FILE" 2>/dev/null; then
  sed -i "s|^OPENCODE_XDG_CONFIG_HOME=$|OPENCODE_XDG_CONFIG_HOME=$HOME/.config|" "$ENV_FILE"
elif ! grep -q '^OPENCODE_XDG_CONFIG_HOME=' "$ENV_FILE" 2>/dev/null; then
  echo "OPENCODE_XDG_CONFIG_HOME=$HOME/.config" >> "$ENV_FILE"
fi

if grep -q '^OPENCODE_XDG_DATA_HOME=$' "$ENV_FILE" 2>/dev/null; then
  sed -i "s|^OPENCODE_XDG_DATA_HOME=$|OPENCODE_XDG_DATA_HOME=$HOME/.local/share|" "$ENV_FILE"
elif ! grep -q '^OPENCODE_XDG_DATA_HOME=' "$ENV_FILE" 2>/dev/null; then
  echo "OPENCODE_XDG_DATA_HOME=$HOME/.local/share" >> "$ENV_FILE"
fi

if grep -q '^AGENTOPS_EXECUTOR_MODEL=$' "$ENV_FILE" 2>/dev/null; then
  sed -i "s|^AGENTOPS_EXECUTOR_MODEL=$|AGENTOPS_EXECUTOR_MODEL=deepseek/deepseek-v4-pro|" "$ENV_FILE"
elif ! grep -q '^AGENTOPS_EXECUTOR_MODEL=' "$ENV_FILE" 2>/dev/null; then
  echo "AGENTOPS_EXECUTOR_MODEL=deepseek/deepseek-v4-pro" >> "$ENV_FILE"
fi

echo "Installed from repo:"
echo "- $HOME/.hermes/profiles/coder/SOUL.md"
echo "- $HOME/.hermes/skills/hermetic-coding-orchestrator/SKILL.md"
echo
echo "Ensured local runtime defaults:"
echo "- Created ~/.hermes/profiles/coder/.env from .env.example if it was missing"
echo "- Ensured OPENCODE_XDG_CONFIG_HOME default is set"
echo "- Ensured OPENCODE_XDG_DATA_HOME default is set"
echo "- Ensured AGENTOPS_EXECUTOR_MODEL default is set"
echo
echo "Preserved local-only runtime files:"
echo "- ~/.hermes/config.yaml"
echo "- ~/.hermes/auth.json"
echo
echo "Re-run this script after changing repo SOUL.md or SKILL.md to update your local copies."
