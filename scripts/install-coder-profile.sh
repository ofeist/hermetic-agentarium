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
