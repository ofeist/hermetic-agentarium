#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <prompt-file> [model] [run-id]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 /tmp/TASK-0039.prompt.md deepseek/deepseek-v4-pro" >&2
    echo "  $0 /tmp/TASK-0039.prompt.md deepseek/deepseek-v4-pro TASK-0039" >&2
    echo "" >&2
    echo "Optional:" >&2
    echo "  AGENTOPS_EXECUTOR_MODEL=deepseek/deepseek-v4-pro AGENTOPS_RUN_ID=TASK-0039 $0 /tmp/TASK-0039.prompt.md" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -lt 1 || $# -gt 3 ]]; then
    usage
    exit 1
fi

PROMPT_FILE="$1"
DEFAULT_MODEL="${AGENTOPS_EXECUTOR_MODEL:-deepseek/deepseek-v4-pro}"
MODEL="${2:-$DEFAULT_MODEL}"
RUN_ID="${3:-${AGENTOPS_RUN_ID:-}}"

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

RUN_DIR=""
STDOUT_FILE=""
STDERR_FILE=""
METADATA_FILE=""

timestamp_utc() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

if [[ -n "$RUN_ID" ]]; then
    if [[ "$RUN_ID" == *"/"* || "$RUN_ID" == *".."* ]]; then
        echo "Error: run-id must not contain '/' or '..': $RUN_ID" >&2
        exit 1
    fi

    RUN_DIR=".agentops-runs/$RUN_ID"
    STDOUT_FILE="$RUN_DIR/executor-stdout.log"
    STDERR_FILE="$RUN_DIR/executor-stderr.log"
    METADATA_FILE="$RUN_DIR/metadata.txt"

    mkdir -p "$RUN_DIR"
    cp "$PROMPT_FILE" "$RUN_DIR/executor-prompt.md"

    STARTED_AT="$(timestamp_utc)"

    {
        echo "run_id=$RUN_ID"
        echo "harness=OpenCode"
        echo "model=$MODEL"
        echo "prompt_file=$PROMPT_FILE"
        echo "started_at=$STARTED_AT"
    } > "$METADATA_FILE"
fi

run_opencode() {
    if [[ ${#EXTRA_ENV[@]} -gt 0 ]]; then
        echo "Using explicit OpenCode config/data home overrides"
        env "${EXTRA_ENV[@]}" opencode run --model "$MODEL" "$(cat "$PROMPT_FILE")"
    else
        opencode run --model "$MODEL" "$(cat "$PROMPT_FILE")"
    fi
}

if [[ -n "$RUN_ID" ]]; then
    EXIT_CODE=0

    set +e
    run_opencode > >(tee "$STDOUT_FILE") 2> >(tee "$STDERR_FILE" >&2)
    EXIT_CODE=$?
    set -e

    FINISHED_AT="$(timestamp_utc)"

    {
        echo "finished_at=$FINISHED_AT"
        echo "exit_code=$EXIT_CODE"
    } >> "$METADATA_FILE"

    echo "Local run audit: $RUN_DIR" >&2

    exit "$EXIT_CODE"
else
    run_opencode
fi
