#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <run-id> <decision> <changed_files_count> <diff_bytes> <diff_stat_lines> <verification_exit_code>" >&2
    echo "" >&2
    echo "Record post-review outcome metadata for an AgentOps executor run." >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  run-id                    Run identifier (no slashes, no '..')" >&2
    echo "  decision                  One of: accept | revise | revert | no-op | blocked" >&2
    echo "  changed_files_count       Non-negative integer" >&2
    echo "  diff_bytes                Non-negative integer" >&2
    echo "  diff_stat_lines           Non-negative integer" >&2
    echo "  verification_exit_code    Non-negative integer or the literal string 'unknown'" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -h, --help                Show this help message and exit" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 TASK-0089-run-1 accept 3 1234 5 0" >&2
    echo "  $0 TASK-0089-run-2 blocked 0 0 0 unknown" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -ne 6 ]]; then
    usage
    exit 1
fi

RUN_ID="$1"
DECISION="$2"
CHANGED_FILES_COUNT="$3"
DIFF_BYTES="$4"
DIFF_STAT_LINES="$5"
VERIFICATION_EXIT_CODE="$6"

if [[ -z "$RUN_ID" ]]; then
    echo "Error: invalid run-id (must not be empty)" >&2
    exit 1
fi

if [[ ! "$RUN_ID" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Error: invalid run-id (allowed chars: A-Z a-z 0-9 . _ -): $RUN_ID" >&2
    exit 1
fi

if [[ "$RUN_ID" == *"/"* || "$RUN_ID" == *".."* ]]; then
    echo "Error: invalid run-id (must not contain '/' or '..'): $RUN_ID" >&2
    exit 1
fi

RUN_DIR=".agentops-runs/$RUN_ID"
if [[ ! -d "$RUN_DIR" ]]; then
    echo "Error: run directory does not exist: $RUN_DIR" >&2
    exit 1
fi

case "$DECISION" in
    accept|revise|revert|no-op|blocked) ;;
    *)
        echo "Error: invalid decision '$DECISION'. Must be one of: accept revise revert no-op blocked" >&2
        exit 1
        ;;
esac

validate_non_negative_integer() {
    local val="$1"
    local label="$2"
    if [[ ! "$val" =~ ^[0-9]+$ ]]; then
        echo "Error: $label must be a non-negative integer, got: '$val'" >&2
        exit 1
    fi
}

validate_non_negative_integer "$CHANGED_FILES_COUNT" "changed_files_count"
validate_non_negative_integer "$DIFF_BYTES" "diff_bytes"
validate_non_negative_integer "$DIFF_STAT_LINES" "diff_stat_lines"

case "$VERIFICATION_EXIT_CODE" in
    unknown) ;;
    *)
        if [[ ! "$VERIFICATION_EXIT_CODE" =~ ^[0-9]+$ ]]; then
            echo "Error: verification_exit_code must be a non-negative integer or the literal string 'unknown', got: '$VERIFICATION_EXIT_CODE'" >&2
            exit 1
        fi
        ;;
esac

OUTCOME_FILE="$RUN_DIR/outcome.txt"
TMP_FILE="$OUTCOME_FILE.tmp.$$"

cat > "$TMP_FILE" <<EOF
decision=$DECISION
changed_files_count=$CHANGED_FILES_COUNT
diff_bytes=$DIFF_BYTES
diff_stat_lines=$DIFF_STAT_LINES
verification_exit_code=$VERIFICATION_EXIT_CODE
EOF

mv "$TMP_FILE" "$OUTCOME_FILE"
