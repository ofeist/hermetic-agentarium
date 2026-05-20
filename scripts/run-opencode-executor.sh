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
    echo "" >&2
    echo "Test/verification (no-network metadata capture):" >&2
    echo "  AGENTOPS_EXECUTOR_COMMAND='printf \"executor ok\\\\n\"' AGENTOPS_RUN_ID=TASK-0073-test $0 /tmp/TASK-0073-test.prompt.md" >&2
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

if GUARD_BRANCH=$(git symbolic-ref --quiet --short HEAD 2>/dev/null); then
    if [[ "$GUARD_BRANCH" == "main" || "$GUARD_BRANCH" == "master" ]]; then
        if [[ "${AGENTOPS_ALLOW_MAIN_EXECUTOR:-}" == "1" ]]; then
            echo "WARNING: AGENTOPS_ALLOW_MAIN_EXECUTOR=1 is set, bypassing main-branch guard." >&2
            echo "WARNING: Executor work on '$GUARD_BRANCH' should only happen in exceptional circumstances." >&2
            echo "" >&2
        else
            cat >&2 <<EOF
Error: refusing to run OpenCode executor from branch '$GUARD_BRANCH'.

AgentOps executor work should run in a task-specific worktree on a task branch,
not directly from the planning checkout.

Suggested next step:
  scripts/start-agentops-worktree.sh <TASK-ID>

Override for exceptional cases:
  AGENTOPS_ALLOW_MAIN_EXECUTOR=1 scripts/run-opencode-executor.sh ...
EOF
            exit 1
        fi
    fi
fi

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
ROUTING_FILE=""

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
    ROUTING_FILE="$RUN_DIR/routing.txt"

    mkdir -p "$RUN_DIR"
    cp "$PROMPT_FILE" "$RUN_DIR/executor-prompt.md"

    PROMPT_BYTES=$(wc -c < "$PROMPT_FILE")
    PROMPT_LINES=$(wc -l < "$PROMPT_FILE")

    if command -v sha256sum &>/dev/null; then
        PROMPT_SHA256=$(sha256sum "$PROMPT_FILE" | awk '{print $1}')
    elif command -v shasum &>/dev/null; then
        PROMPT_SHA256=$(shasum -a 256 "$PROMPT_FILE" | awk '{print $1}')
    else
        echo "Error: neither sha256sum nor shasum is available; prompt hash cannot be computed" >&2
        exit 1
    fi

    TASK_ID=""
    if [[ "$RUN_ID" =~ ^TASK-[0-9]+ ]]; then
        TASK_ID="${BASH_REMATCH[0]}"
    fi

    STARTED_AT="$(timestamp_utc)"

    {
        echo "run_id=$RUN_ID"
        echo "task_id=$TASK_ID"
        echo "phase=executor"
        echo "harness=OpenCode"
        echo "model=$MODEL"
        echo "prompt_file=$PROMPT_FILE"
        echo "prompt_bytes=$PROMPT_BYTES"
        echo "prompt_lines=$PROMPT_LINES"
        echo "prompt_sha256=$PROMPT_SHA256"
        echo "started_at=$STARTED_AT"
    } > "$METADATA_FILE"
fi

run_opencode() {
    if [[ -n "${AGENTOPS_EXECUTOR_COMMAND:-}" ]]; then
        eval "$AGENTOPS_EXECUTOR_COMMAND"
    elif [[ ${#EXTRA_ENV[@]} -gt 0 ]]; then
        echo "Using explicit OpenCode config/data home overrides"
        env "${EXTRA_ENV[@]}" opencode run --model "$MODEL" "$(cat "$PROMPT_FILE")"
    else
        opencode run --model "$MODEL" "$(cat "$PROMPT_FILE")"
    fi
}

if [[ -n "$RUN_ID" ]]; then
    EXIT_CODE=0

    START_MS=$(date +%s%3N)

    set +e
    run_opencode > >(tee "$STDOUT_FILE") 2> >(tee "$STDERR_FILE" >&2)
    EXIT_CODE=$?
    set -e

    END_MS=$(date +%s%3N)

    FINISHED_AT="$(timestamp_utc)"

    STARTED_EPOCH=$(date -d "$STARTED_AT" +%s)
    FINISHED_EPOCH=$(date -d "$FINISHED_AT" +%s)
    DURATION_SECONDS=$((FINISHED_EPOCH - STARTED_EPOCH))

    STDOUT_BYTES=$(wc -c < "$STDOUT_FILE")
    STDERR_BYTES=$(wc -c < "$STDERR_FILE")

    {
        echo "finished_at=$FINISHED_AT"
        echo "duration_seconds=$DURATION_SECONDS"
        echo "exit_code=$EXIT_CODE"
        echo "stdout_bytes=$STDOUT_BYTES"
        echo "stderr_bytes=$STDERR_BYTES"
    } >> "$METADATA_FILE"

    DURATION_MS=$((END_MS - START_MS))

    ERROR_CLASS=""
    ERROR_REASON=""
    DEBUG_HINT=""
    if [[ "$EXIT_CODE" -ne 0 ]]; then
        ERROR_CLASS="executor_failed"
        ERROR_REASON="exit code $EXIT_CODE"
        DEBUG_HINT="check $RUN_DIR/executor-stderr.log"
    fi

    {
        echo "timestamp=$STARTED_AT"
        echo "run_id=$RUN_ID"
        echo "task_id=$TASK_ID"
        echo "phase=executor"
        echo "role=executor"
        echo "harness=OpenCode"
        echo "requested_model=$MODEL"
        echo "resolved_provider=unknown"
        echo "resolved_model=unknown"
        echo "token_counts_prompt=unknown"
        echo "token_counts_completion=unknown"
        echo "token_counts_total=unknown"
        echo "duration_ms=$DURATION_MS"
        echo "retry_reason="
        echo "fallback_reason="
        echo "exit_code=$EXIT_CODE"
        echo "final_outcome=unknown"
        echo "error_class=$ERROR_CLASS"
        echo "error_reason=$ERROR_REASON"
        echo "debug_hint=$DEBUG_HINT"
    } > "$ROUTING_FILE"

    echo "Local run audit: $RUN_DIR" >&2

    exit "$EXIT_CODE"
else
    run_opencode
fi
