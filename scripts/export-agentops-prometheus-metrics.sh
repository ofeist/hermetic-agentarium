#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <output.prom>" >&2
    echo "" >&2
    echo "Export AgentOps executor run metrics from .agentops-runs/*/metadata.txt" >&2
    echo "in Prometheus textfile collector format." >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 /tmp/agentops.prom" >&2
    echo "  $0 .agentops-runs/agentops.prom" >&2
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

OUTPUT="$1"
OUTPUT_DIR="$(dirname "$OUTPUT")"
TEMP_FILE="${OUTPUT}.tmp.$$"

cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT

METADATA_DIR=".agentops-runs"
if [[ ! -d "$METADATA_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR" 2>/dev/null || true
    cat > "$TEMP_FILE" <<'EOF'
# HELP agentops_executor_runs Number of executor runs in the current artifact set.
# TYPE agentops_executor_runs gauge
agentops_executor_runs 0
# HELP agentops_executor_prompt_bytes Total prompt bytes across runs in the current artifact set.
# TYPE agentops_executor_prompt_bytes gauge
agentops_executor_prompt_bytes 0
# HELP agentops_executor_stdout_bytes Total stdout bytes across runs in the current artifact set.
# TYPE agentops_executor_stdout_bytes gauge
agentops_executor_stdout_bytes 0
# HELP agentops_executor_stderr_bytes Total stderr bytes across runs in the current artifact set.
# TYPE agentops_executor_stderr_bytes gauge
agentops_executor_stderr_bytes 0
# HELP agentops_executor_duration_seconds Total duration in seconds across runs in the current artifact set.
# TYPE agentops_executor_duration_seconds gauge
agentops_executor_duration_seconds 0
# HELP agentops_executor_metadata_files_skipped Number of metadata files skipped due to incomplete data.
# TYPE agentops_executor_metadata_files_skipped gauge
agentops_executor_metadata_files_skipped 0
EOF
    mv "$TEMP_FILE" "$OUTPUT"
    exit 0
fi

declare -A RUNS_COUNT
declare -A PROMPT_BYTES_SUM
declare -A STDOUT_BYTES_SUM
declare -A STDERR_BYTES_SUM
declare -A DURATION_SECONDS_SUM
SKIPPED=0
HAVE_RUNS=0

REQUIRED_FIELDS=("harness" "phase" "model" "exit_code" "prompt_bytes" "stdout_bytes" "stderr_bytes" "duration_seconds")

while IFS= read -r -d '' metadata_file; do
    unset harness phase model exit_code prompt_bytes stdout_bytes stderr_bytes duration_seconds
    declare -A meta=()

    while IFS='=' read -r key value; do
        [[ -z "$key" ]] && continue
        meta["$key"]="$value"
    done < "$metadata_file"

    complete=true
    for field in "${REQUIRED_FIELDS[@]}"; do
        if [[ -z "${meta[$field]:-}" ]]; then
            echo "Warning: skipping incomplete metadata file (missing '$field'): $metadata_file" >&2
            complete=false
            break
        fi
    done

    if ! $complete; then
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    harness="${meta[harness]}"
    phase="${meta[phase]}"
    model="${meta[model]}"
    exit_code="${meta[exit_code]}"
    prompt_bytes="${meta[prompt_bytes]}"
    stdout_bytes="${meta[stdout_bytes]}"
    stderr_bytes="${meta[stderr_bytes]}"
    duration_seconds="${meta[duration_seconds]}"

    if [[ ! "$prompt_bytes" =~ ^[0-9]+$ || ! "$stdout_bytes" =~ ^[0-9]+$ || ! "$stderr_bytes" =~ ^[0-9]+$ || ! "$duration_seconds" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "Warning: skipping incomplete metadata file (invalid numeric field): $metadata_file" >&2
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    label_key="${harness}|${phase}|${model}|${exit_code}"
    HAVE_RUNS=1

    RUNS_COUNT["$label_key"]=$((${RUNS_COUNT["$label_key"]:-0} + 1))
    PROMPT_BYTES_SUM["$label_key"]=$((${PROMPT_BYTES_SUM["$label_key"]:-0} + prompt_bytes))
    STDOUT_BYTES_SUM["$label_key"]=$((${STDOUT_BYTES_SUM["$label_key"]:-0} + stdout_bytes))
    STDERR_BYTES_SUM["$label_key"]=$((${STDERR_BYTES_SUM["$label_key"]:-0} + stderr_bytes))
    DURATION_SECONDS_SUM["$label_key"]="$(LC_ALL=C awk -v a="${DURATION_SECONDS_SUM["$label_key"]:-0}" -v b="$duration_seconds" 'BEGIN { printf "%.6g", a + b }')"
done < <(find "$METADATA_DIR" -mindepth 2 -maxdepth 2 -name metadata.txt -type f -print0 | LC_ALL=C sort -z)

escape_label_value() {
    local val="$1"
    val="${val//\\/\\\\}"
    val="${val//\"/\\\"}"
    val="${val//$'\n'/\\n}"
    echo -n "$val"
}

format_labels() {
    local h p m e
    IFS='|' read -r h p m e <<< "$1"
    printf 'harness="%s",phase="%s",model="%s",exit_code="%s"' \
        "$(escape_label_value "$h")" \
        "$(escape_label_value "$p")" \
        "$(escape_label_value "$m")" \
        "$(escape_label_value "$e")"
}

mkdir -p "$OUTPUT_DIR"
exec 3> "$TEMP_FILE"

cat >&3 <<'EOF'
# HELP agentops_executor_runs Number of executor runs in the current artifact set.
# TYPE agentops_executor_runs gauge
EOF

sorted_keys=()
if ((HAVE_RUNS)); then
    mapfile -t sorted_keys < <(printf '%s\n' "${!RUNS_COUNT[@]}" | LC_ALL=C sort)
fi

for label_key in "${sorted_keys[@]}"; do
    labels="$(format_labels "$label_key")"
    printf 'agentops_executor_runs{%s} %d\n' "$labels" "${RUNS_COUNT[$label_key]}" >&3
done

cat >&3 <<'EOF'
# HELP agentops_executor_prompt_bytes Total prompt bytes across runs in the current artifact set.
# TYPE agentops_executor_prompt_bytes gauge
EOF

for label_key in "${sorted_keys[@]}"; do
    labels="$(format_labels "$label_key")"
    printf 'agentops_executor_prompt_bytes{%s} %d\n' "$labels" "${PROMPT_BYTES_SUM[$label_key]}" >&3
done

cat >&3 <<'EOF'
# HELP agentops_executor_stdout_bytes Total stdout bytes across runs in the current artifact set.
# TYPE agentops_executor_stdout_bytes gauge
EOF

for label_key in "${sorted_keys[@]}"; do
    labels="$(format_labels "$label_key")"
    printf 'agentops_executor_stdout_bytes{%s} %d\n' "$labels" "${STDOUT_BYTES_SUM[$label_key]}" >&3
done

cat >&3 <<'EOF'
# HELP agentops_executor_stderr_bytes Total stderr bytes across runs in the current artifact set.
# TYPE agentops_executor_stderr_bytes gauge
EOF

for label_key in "${sorted_keys[@]}"; do
    labels="$(format_labels "$label_key")"
    printf 'agentops_executor_stderr_bytes{%s} %d\n' "$labels" "${STDERR_BYTES_SUM[$label_key]}" >&3
done

cat >&3 <<'EOF'
# HELP agentops_executor_duration_seconds Total duration in seconds across runs in the current artifact set.
# TYPE agentops_executor_duration_seconds gauge
EOF

for label_key in "${sorted_keys[@]}"; do
    labels="$(format_labels "$label_key")"
    printf 'agentops_executor_duration_seconds{%s} %s\n' "$labels" "${DURATION_SECONDS_SUM[$label_key]}" >&3
done

cat >&3 <<'EOF'
# HELP agentops_executor_metadata_files_skipped Number of metadata files skipped due to incomplete data.
# TYPE agentops_executor_metadata_files_skipped gauge
EOF

printf 'agentops_executor_metadata_files_skipped %d\n' "$SKIPPED" >&3

exec 3>&-

mv "$TEMP_FILE" "$OUTPUT"
