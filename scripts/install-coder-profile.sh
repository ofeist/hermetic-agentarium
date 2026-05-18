#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

resolve_account_home() {
  local user_home
  user_home="$(getent passwd "$(id -un)" | cut -d: -f6 2>/dev/null || true)"
  if [ -n "$user_home" ] && [ -d "$user_home" ]; then
    printf '%s\n' "$user_home"
    return 0
  fi
  printf '%s\n' "$HOME"
}

install_into_home() {
  local target_home="$1"
  local hermes_root="$target_home/.hermes"
  local env_file="$hermes_root/profiles/coder/.env"

  mkdir -p "$hermes_root/profiles/coder"
  mkdir -p "$hermes_root/skills/hermetic-coding-orchestrator"
  mkdir -p "$hermes_root/profiles/coder/skills/hermetic-coding-orchestrator"
  mkdir -p "$hermes_root/skills/agentops-coder"
  mkdir -p "$hermes_root/profiles/coder/skills/agentops-coder"

  cp "$REPO_ROOT/profiles/coder/SOUL.md" \
     "$hermes_root/profiles/coder/SOUL.md"

  cp "$REPO_ROOT/skills/hermetic-coding-orchestrator/SKILL.md" \
     "$hermes_root/skills/hermetic-coding-orchestrator/SKILL.md"
  cp "$REPO_ROOT/skills/hermetic-coding-orchestrator/SKILL.md" \
     "$hermes_root/profiles/coder/skills/hermetic-coding-orchestrator/SKILL.md"

  cp "$REPO_ROOT/skills/agentops-coder/SKILL.md" \
     "$hermes_root/skills/agentops-coder/SKILL.md"
  cp "$REPO_ROOT/skills/agentops-coder/SKILL.md" \
     "$hermes_root/profiles/coder/skills/agentops-coder/SKILL.md"

  if [ ! -f "$env_file" ]; then
    cp "$REPO_ROOT/profiles/coder/.env.example" "$env_file"
  fi

  if grep -q '^OPENCODE_XDG_CONFIG_HOME=$' "$env_file" 2>/dev/null; then
    sed -i "s|^OPENCODE_XDG_CONFIG_HOME=$|OPENCODE_XDG_CONFIG_HOME=$target_home/.config|" "$env_file"
  elif ! grep -q '^OPENCODE_XDG_CONFIG_HOME=' "$env_file" 2>/dev/null; then
    echo "OPENCODE_XDG_CONFIG_HOME=$target_home/.config" >> "$env_file"
  fi

  if grep -q '^OPENCODE_XDG_DATA_HOME=$' "$env_file" 2>/dev/null; then
    sed -i "s|^OPENCODE_XDG_DATA_HOME=$|OPENCODE_XDG_DATA_HOME=$target_home/.local/share|" "$env_file"
  elif ! grep -q '^OPENCODE_XDG_DATA_HOME=' "$env_file" 2>/dev/null; then
    echo "OPENCODE_XDG_DATA_HOME=$target_home/.local/share" >> "$env_file"
  fi

  if grep -q '^AGENTOPS_EXECUTOR_MODEL=$' "$env_file" 2>/dev/null; then
    sed -i "s|^AGENTOPS_EXECUTOR_MODEL=$|AGENTOPS_EXECUTOR_MODEL=deepseek/deepseek-v4-pro|" "$env_file"
  elif ! grep -q '^AGENTOPS_EXECUTOR_MODEL=' "$env_file" 2>/dev/null; then
    echo "AGENTOPS_EXECUTOR_MODEL=deepseek/deepseek-v4-pro" >> "$env_file"
  fi

  echo "$hermes_root"
}

ACCOUNT_HOME="$(resolve_account_home)"
ACTIVE_HOME="$HOME"

TARGET_HOMES=()
if [ -n "${HERMES_INSTALL_HOME:-}" ]; then
  TARGET_HOMES+=("$HERMES_INSTALL_HOME")
else
  TARGET_HOMES+=("$ACCOUNT_HOME")
  if [ "$ACTIVE_HOME" != "$ACCOUNT_HOME" ]; then
    TARGET_HOMES+=("$ACTIVE_HOME")
  fi
fi

INSTALLED_ROOTS=()
for target_home in "${TARGET_HOMES[@]}"; do
  INSTALLED_ROOTS+=("$(install_into_home "$target_home")")
done

echo "Installed from repo:"
for root in "${INSTALLED_ROOTS[@]}"; do
  echo "- $root/profiles/coder/SOUL.md"
  echo "- $root/skills/hermetic-coding-orchestrator/SKILL.md (compatibility bridge)"
  echo "- $root/profiles/coder/skills/hermetic-coding-orchestrator/SKILL.md (compatibility bridge)"
  echo "- $root/skills/agentops-coder/SKILL.md (canonical)"
  echo "- $root/profiles/coder/skills/agentops-coder/SKILL.md (canonical)"
done

echo
echo "Install targets:"
for target_home in "${TARGET_HOMES[@]}"; do
  echo "- $target_home"
done
echo "(override all targets with HERMES_INSTALL_HOME=/absolute/path)"
echo
echo "Ensured local runtime defaults:"
echo "- Created .env from .env.example if it was missing"
echo "- Ensured OPENCODE_XDG_CONFIG_HOME default is set"
echo "- Ensured OPENCODE_XDG_DATA_HOME default is set"
echo "- Ensured AGENTOPS_EXECUTOR_MODEL default is set"
echo
echo "Preserved local-only runtime files:"
echo "- ~/.hermes/config.yaml"
echo "- ~/.hermes/auth.json"
echo
echo "Re-run this script after changing repo SOUL.md or SKILL.md to update local copies."
