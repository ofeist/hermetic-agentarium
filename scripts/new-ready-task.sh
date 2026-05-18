#!/usr/bin/env bash
set -euo pipefail

USAGE="Usage: $0 <task-id-slug> <task-title>"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "$USAGE"
  exit 0
fi

# Ensure exactly two arguments
if [ "$#" -ne 2 ]; then
  echo "$USAGE" >&2
  exit 1
fi

TASK_SLUG="$1"
TASK_TITLE="$2"

# Validate slug: no slashes or parent traversal
if [[ "$TASK_SLUG" == *"/"* || "$TASK_SLUG" == *".."* ]]; then
  echo "Error: invalid task-id-slug: '$TASK_SLUG'" >&2
  exit 1
fi

TEMPLATE=".agentops/templates/READY-TASK-TEMPLATE.md"
if [ ! -f "$TEMPLATE" ]; then
  echo "Error: template file not found: $TEMPLATE" >&2
  exit 1
fi

OUTPUT_DIR=".agentops/tasks/ready"
OUTPUT_FILE="$OUTPUT_DIR/${TASK_SLUG}.md"

# Ensure output does not already exist
if [ -e "$OUTPUT_FILE" ]; then
  echo "Error: task file already exists: $OUTPUT_FILE" >&2
  exit 1
fi

# Create directory if missing
mkdir -p "$OUTPUT_DIR"

# Generate new task file by replacing the title line
sed "1s/^# .*/# ${TASK_SLUG} — ${TASK_TITLE}/" "$TEMPLATE" > "$OUTPUT_FILE"

# Print the created file path
echo "$OUTPUT_FILE"
