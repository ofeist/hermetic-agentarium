#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <run-id>" >&2
    echo "" >&2
    echo "Summarize an AgentOps run from its metadata.txt without reading raw logs." >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 TASK-0076-agentops-run-summary-helper" >&2
    echo "  $0 --help" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

RUN_ID="$1"

if [[ "$RUN_ID" == *"/"* || "$RUN_ID" == *".."* ]]; then
    echo "Error: invalid run id: '$RUN_ID'" >&2
    exit 1
fi

METADATA_FILE=".agentops-runs/$RUN_ID/metadata.txt"

if [[ ! -f "$METADATA_FILE" ]]; then
    echo "Error: metadata file not found: $METADATA_FILE" >&2
    exit 1
fi

RUN_ID_VAL=""
TASK_ID="unknown"
MODEL="unknown"
PROMPT_BYTES=""
PROMPT_LINES=""
DURATION_SECONDS="unknown"
EXIT_CODE="unknown"
STDOUT_BYTES=""
STDERR_BYTES=""

while IFS='=' read -r key value; do
    case "$key" in
        run_id)           RUN_ID_VAL="$value" ;;
        task_id)          TASK_ID="$value" ;;
        model)            MODEL="$value" ;;
        prompt_bytes)     PROMPT_BYTES="$value" ;;
        prompt_lines)     PROMPT_LINES="$value" ;;
        duration_seconds) DURATION_SECONDS="$value" ;;
        exit_code)        EXIT_CODE="$value" ;;
        stdout_bytes)     STDOUT_BYTES="$value" ;;
        stderr_bytes)     STDERR_BYTES="$value" ;;
    esac
done < "$METADATA_FILE"

RUN_ID_VAL="${RUN_ID_VAL:-$RUN_ID}"
TASK_ID="${TASK_ID:-unknown}"
MODEL="${MODEL:-unknown}"
EXIT_CODE="${EXIT_CODE:-unknown}"

format_bytes() {
    local b="${1:-}"
    if [[ -z "$b" || "$b" == "unknown" ]]; then
        echo "unknown"
        return
    fi
    LC_NUMERIC=C awk -v b="$b" 'BEGIN { printf "%.1f KB", b / 1000 }'
}

format_prompt() {
    local b="${1:-}"
    local l="${2:-unknown}"
    if [[ -z "$l" ]]; then
        l="unknown"
    fi
    echo "$(format_bytes "$b") / ${l} lines"
}

format_duration() {
    if [[ "${1:-unknown}" == "unknown" ]]; then
        echo "unknown"
    else
        echo "${1}s"
    fi
}

echo "run: $RUN_ID_VAL"
echo "task: $TASK_ID"
echo ""
echo "model: $MODEL"
echo "prompt: $(format_prompt "$PROMPT_BYTES" "$PROMPT_LINES")"
echo "duration: $(format_duration "$DURATION_SECONDS")"
echo "stdout: $(format_bytes "$STDOUT_BYTES")"
echo "stderr: $(format_bytes "$STDERR_BYTES")"
echo "exit code: $EXIT_CODE"
echo "artifacts: .agentops-runs/$RUN_ID/"
