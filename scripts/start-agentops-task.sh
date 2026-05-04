#!/usr/bin/env bash
set -euo pipefail

USAGE="Usage: $0 <task-id-slug>"

# Ensure exactly one argument
if [ $# -ne 1 ]; then
  echo "$USAGE" >&2
  exit 1
fi

TASK_SLUG="$1"

# Validate slug: no slashes or parent traversal
if [[ "$TASK_SLUG" == *"/"* || "$TASK_SLUG" == *".."* ]]; then
  echo "Error: invalid task-id-slug: '$TASK_SLUG'" >&2
  exit 1
fi

# Check clean worktree
STATUS=$(git status --short)
if [ -n "$STATUS" ]; then
  echo "Error: worktree is dirty. Please commit or stash changes." >&2
  git status --short
  exit 1
fi

# Switch to main and update
git checkout main

git pull --ff-only

# Derive branch name (lowercase)
BRANCH_NAME=$(echo "$TASK_SLUG" | tr '[:upper:]' '[:lower:]')

# Ensure branch does not exist
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  echo "Error: branch '$BRANCH_NAME' already exists." >&2
  exit 1
fi

# Create and switch to new branch
git checkout -b "$BRANCH_NAME"

# Show final status
git status --short --branch
