#!/usr/bin/env bash
set -euo pipefail

USAGE="Usage: $0 <task-id-slug>"

# Ensure exactly one argument
if [ "$#" -ne 1 ]; then
  echo "$USAGE" >&2
  exit 1
fi

TASK_SLUG="$1"

# Validate slug: no slashes or parent traversal
if [[ "$TASK_SLUG" == *"/"* || "$TASK_SLUG" == *".."* ]]; then
  echo "Error: invalid task-id-slug: '$TASK_SLUG'" >&2
  exit 1
fi

READY_FILE="agentops/tasks/ready/${TASK_SLUG}.md"
REVIEW_DIR="agentops/tasks/review"
REVIEW_FILE="${REVIEW_DIR}/${TASK_SLUG}.md"

# Fail if ready file does not exist
if [ ! -f "$READY_FILE" ]; then
  echo "Error: ready task file not found: $READY_FILE" >&2
  exit 1
fi

# Fail if review file already exists
if [ -e "$REVIEW_FILE" ]; then
  echo "Error: review task file already exists: $REVIEW_FILE" >&2
  exit 1
fi

# Create review directory if missing
mkdir -p "$REVIEW_DIR"

# Move file
mv "$READY_FILE" "$REVIEW_FILE"

# Print the moved file path
echo "$REVIEW_FILE"