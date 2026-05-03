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

echo "Using model: $MODEL"
opencode run --model "$MODEL" "$(cat "$PROMPT_FILE")"
