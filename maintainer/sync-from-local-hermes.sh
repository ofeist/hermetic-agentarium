#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SRC_SOUL="$HOME/.hermes/profiles/coder/SOUL.md"
SRC_SKILL="$HOME/.hermes/skills/coding-orchestrator/SKILL.md"

DST_SOUL="$REPO_ROOT/profiles/coder/SOUL.md"
DST_SKILL="$REPO_ROOT/skills/coding-orchestrator/SKILL.md"

if [[ ! -f "$SRC_SOUL" ]]; then
  echo "ERROR: Missing source file: $SRC_SOUL"
  exit 1
fi

if [[ ! -f "$SRC_SKILL" ]]; then
  echo "ERROR: Missing source file: $SRC_SKILL"
  exit 1
fi

mkdir -p "$(dirname "$DST_SOUL")"
mkdir -p "$(dirname "$DST_SKILL")"

cp "$SRC_SOUL" "$DST_SOUL"
cp "$SRC_SKILL" "$DST_SKILL"

echo "Synced local Hermes files into repo:"
echo "- $SRC_SOUL -> $DST_SOUL"
echo "- $SRC_SKILL -> $DST_SKILL"
echo
echo "Review changes with:"
echo "  git diff -- profiles/coder/SOUL.md skills/coding-orchestrator/SKILL.md"

