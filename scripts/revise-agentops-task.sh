#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <source-task-id-or-path> <new-task-id-slug> <revision-note>" >&2
    echo "" >&2
    echo "Create a new ready revision task from an existing reviewed/done/ready task." >&2
    echo "" >&2
    echo "The source task is not moved or deleted. The new task is created under" >&2
    echo "agentops/tasks/ready/ and includes context from the source plus the revision note." >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  source-task-id-or-path  Task id slug (e.g. TASK-xxxx) or path under" >&2
    echo "                          agentops/tasks/{review,done,ready}/" >&2
    echo "  new-task-id-slug        Slug for the new revision task (e.g. TASK-xxxx-revision-1)" >&2
    echo "  revision-note           Short note describing the revision reason" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -h, --help              Show this help message and exit" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 TASK-0066-add-revision-task-helper TASK-0066-revision-1 \"Address reviewer requested changes\"" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [ "$#" -ne 3 ]; then
  usage
  exit 1
fi

SOURCE_ARG="$1"
NEW_SLUG="$2"
REVISION_NOTE="$3"

if [[ "$NEW_SLUG" == *"/"* || "$NEW_SLUG" == *".."* ]]; then
  echo "Error: invalid new-task-id-slug: '$NEW_SLUG'" >&2
  exit 1
fi

# Determine source file: slug or path
if [[ "$SOURCE_ARG" == *".md" ]]; then
  SOURCE_FILE="$(realpath -e "$SOURCE_ARG" 2>/dev/null)" || {
    echo "Error: source task file not found or invalid: $SOURCE_ARG" >&2
    exit 1
  }
  case "$SOURCE_FILE" in
    "$(realpath "agentops/tasks/review")"/*|"$(realpath "agentops/tasks/done")"/*|"$(realpath "agentops/tasks/ready")"/*) ;;
    *) echo "Error: source path must be under agentops/tasks/{review,done,ready}/: $SOURCE_ARG" >&2; exit 1 ;;
  esac
else
  SOURCE_SLUG="$SOURCE_ARG"
  if [[ "$SOURCE_SLUG" == *"/"* || "$SOURCE_SLUG" == *".."* ]]; then
    echo "Error: invalid source task id: '$SOURCE_SLUG'" >&2
    exit 1
  fi
  SOURCE_FILE=""
  for dir in review done ready; do
    candidate="agentops/tasks/${dir}/${SOURCE_SLUG}.md"
    if [ -f "$candidate" ]; then
      SOURCE_FILE="$candidate"
      break
    fi
  done
  if [ -z "$SOURCE_FILE" ]; then
    echo "Error: source task not found in agentops/tasks/{review,done,ready}/: $SOURCE_SLUG" >&2
    exit 1
  fi
fi

OUTPUT_DIR="agentops/tasks/ready"
OUTPUT_FILE="${OUTPUT_DIR}/${NEW_SLUG}.md"

if [ -e "$OUTPUT_FILE" ]; then
  echo "Error: task file already exists: $OUTPUT_FILE" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

SOURCE_BASENAME="$(basename "$SOURCE_FILE")"

cat > "$OUTPUT_FILE" <<REVISION
# ${NEW_SLUG} — Revision of ${SOURCE_BASENAME%.md}

## Status

ready

## Goal

Revise and address feedback for the source task (${SOURCE_BASENAME%.md}).

## Background

This is a revision of ${SOURCE_FILE}, created in response to reviewer
feedback. The original task remains unchanged. The revision note follows.

Revision note: ${REVISION_NOTE}

## Executor

Harness: OpenCode
Model source: runner configuration (\`AGENTOPS_EXECUTOR_MODEL\`)
Fallback: disabled

## Read scope

<!-- Parent: list files to read. Start with the source task file: -->
- ${SOURCE_FILE}
<!-- Add more paths as needed -->

## Write scope

<!-- Parent: list files the executor may modify or create. -->
<!-- Keep the scope minimal. -->

## Requirements

- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration, not by task prompt text.
- Preserve \`OPENCODE_XDG_CONFIG_HOME\` and \`OPENCODE_XDG_DATA_HOME\` if invoking OpenCode.

## Non-goals

<!-- Parent: list what is out of scope for this revision. -->

## Verification

Run:

    git status --short --branch
    git diff --stat

Add revision-specific checks here.

## Accept criteria

- Reviewer feedback from ${SOURCE_BASENAME%.md} is addressed.
- The diff stays within write scope.
- Verification commands pass or failures are explained.
- No unrelated files are modified.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
REVISION

echo "$OUTPUT_FILE"
