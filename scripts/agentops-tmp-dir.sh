#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Usage: $(basename "$0") <task-id-slug>"
  echo
  echo "Create and print a repo-local executor-safe temporary directory for AgentOps task verification."
  echo
  echo "Arguments:"
  echo "  task-id-slug   Safe task identifier (no slashes, no '..')"
  echo
  echo "Example:"
  echo "  $(basename "$0") TASK-0068-some-task"
  exit 0
fi

if [ "$#" -ne 1 ]; then
  echo "Error: expected exactly one task-id-slug argument" >&2
  echo "Usage: $(basename "$0") <task-id-slug>" >&2
  exit 1
fi

task_id="$1"

case "$task_id" in
  */*|*..*)
    echo "Error: task-id-slug must not contain '/' or '..'" >&2
    exit 1
    ;;
esac

tmp_dir=".agentops-runs/${task_id}/tmp"
mkdir -p "$tmp_dir"
echo "$tmp_dir"
