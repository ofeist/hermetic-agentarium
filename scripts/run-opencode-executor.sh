#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <prompt-file> [model]" >&2
    exit 1
fi

PROMPT_FILE="$1"
MODEL="${2:-deepseek/deepseek-chat}"

if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "Error: prompt file '$PROMPT_FILE' not found or is not a regular file" >&2
    exit 1
fi

echo "Executor harness: OpenCode"
echo "Executor model: $MODEL"

EXTRA_ENV=()
if [[ -n "${OPENCODE_XDG_CONFIG_HOME:-}" ]]; then
    EXTRA_ENV+=("XDG_CONFIG_HOME=$OPENCODE_XDG_CONFIG_HOME")
fi
if [[ -n "${OPENCODE_XDG_DATA_HOME:-}" ]]; then
    EXTRA_ENV+=("XDG_DATA_HOME=$OPENCODE_XDG_DATA_HOME")
fi

if [[ ${#EXTRA_ENV[@]} -gt 0 ]]; then
    echo "Using explicit OpenCode config/data home overrides"
    env "${EXTRA_ENV[@]}" opencode run --model "$MODEL" "$(cat "$PROMPT_FILE")"
else
    opencode run --model "$MODEL" "$(cat "$PROMPT_FILE")"
fi
