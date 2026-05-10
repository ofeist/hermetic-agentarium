#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <TASK-XXXX[-slug]>" >&2
    echo "" >&2
    echo "Create or prepare a task-specific git worktree and branch" >&2
    echo "without switching the main planning worktree away from main." >&2
    echo "" >&2
    echo "The main worktree (planning cockpit) stays on main." >&2
    echo "Executor work happens in the task-specific sibling worktree." >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 TASK-0073" >&2
    echo "  $0 TASK-0073-agentops-executor-run-metadata-baseline" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

TASK_ID="$1"

if [[ ! "$TASK_ID" =~ ^TASK-[0-9]+(-.+)?$ ]]; then
    echo "Error: expected TASK-XXXX or TASK-XXXX-slug, got '$TASK_ID'" >&2
    exit 1
fi

if [[ "$TASK_ID" == *"/"* || "$TASK_ID" == *".."* ]]; then
    echo "Error: invalid task id: '$TASK_ID'" >&2
    exit 1
fi

BRANCH_NAME=$(echo "$TASK_ID" | tr '[:upper:]' '[:lower:]')

if ! git check-ref-format --branch "$BRANCH_NAME" >/dev/null 2>&1; then
    echo "Error: invalid branch name derived from task id: '$BRANCH_NAME'" >&2
    exit 1
fi

if ! REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
    echo "Error: not in a git repository" >&2
    exit 1
fi

REPO_PARENT=$(dirname "$REPO_ROOT")
REPO_DIR=$(basename "$REPO_ROOT")
REPO_BASE=$(echo "$REPO_DIR" | sed -E 's/-task-[0-9]+$//')

MAIN_WORKTREE=$(git -C "$REPO_ROOT" worktree list --porcelain | awk '
    /^worktree / { path = substr($0, 10) }
    /^branch refs\/heads\/main$/ { print path; exit }
')

if [ -z "$MAIN_WORKTREE" ]; then
    echo "Error: could not locate a worktree for branch main" >&2
    exit 1
fi

echo "Fetching origin..."
git -C "$REPO_ROOT" fetch origin

TASK_NUM=$(echo "$TASK_ID" | grep -oE '^TASK-[0-9]+' | grep -oE '[0-9]+')

WORKTREE_PATH="${REPO_PARENT}/${REPO_BASE}-task-${TASK_NUM}"
WORKTREE_PATH_ABS="$WORKTREE_PATH"

# Report main planning worktree dirty state (informational, not blocking)
if [ -n "$(git -C "$MAIN_WORKTREE" status --short)" ]; then
    echo "" >&2
    echo "Note: main planning worktree has uncommitted changes:" >&2
    echo "---" >&2
    git -C "$MAIN_WORKTREE" status --short --branch >&2
    echo "---" >&2
    echo "" >&2
fi

# ---- Branch already exists ----
if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    # Is it already attached to a worktree?
    EXISTING_PATH=$(git -C "$REPO_ROOT" worktree list --porcelain | awk -v br="refs/heads/$BRANCH_NAME" '
    /^worktree / { path = substr($0, 10) }
    /^branch / && $2 == br { print path; exit }
')

    if [ -n "$EXISTING_PATH" ]; then
        echo "Worktree already exists for branch '$BRANCH_NAME':"
        echo "  $EXISTING_PATH"
        echo ""
        echo "No-op: branch '$BRANCH_NAME' is already attached to this worktree."
        echo ""
        echo "To use it:"
        echo "  cd $EXISTING_PATH"
        exit 0
    fi

    # Branch exists but not attached: create worktree from it
    echo "Branch '$BRANCH_NAME' exists but is not attached to a worktree."

    if [ -d "$WORKTREE_PATH" ]; then
        EXISTING_BRANCH=$(git -C "$WORKTREE_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
        if [ "$EXISTING_BRANCH" = "$BRANCH_NAME" ]; then
            echo "Worktree already exists at '$WORKTREE_PATH_ABS' for branch '$BRANCH_NAME'."
            echo ""
            echo "To use it:"
            echo "  cd $WORKTREE_PATH_ABS"
            exit 0
        else
            echo "Error: path '$WORKTREE_PATH_ABS' already exists but is not a worktree for '$BRANCH_NAME'." >&2
            exit 1
        fi
    fi

    git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" "$BRANCH_NAME"

    echo ""
    echo "Worktree created at: $WORKTREE_PATH_ABS"
    echo "Branch: $BRANCH_NAME"
    echo ""
    echo "To start executor work:"
    echo "  cd $WORKTREE_PATH_ABS"
    exit 0
fi

# ---- Branch does not exist: create from origin/main ----
if [ -e "$WORKTREE_PATH" ]; then
    echo "Error: path '$WORKTREE_PATH_ABS' already exists." >&2
    if git -C "$REPO_ROOT" worktree list --porcelain | grep -qF "worktree $WORKTREE_PATH_ABS"; then
        EXISTING_BRANCH=$(git -C "$WORKTREE_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
        echo "  It is a worktree on branch: $EXISTING_BRANCH" >&2
    fi
    exit 1
fi

if ! git -C "$REPO_ROOT" show-ref --verify --quiet "refs/remotes/origin/main"; then
    echo "Error: origin/main not found. Ensure the remote is configured and fetched." >&2
    exit 1
fi

echo "Creating new worktree from origin/main..."
git -C "$REPO_ROOT" worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" origin/main

echo ""
echo "Worktree created at: $WORKTREE_PATH_ABS"
echo "Branch: $BRANCH_NAME"
echo ""
echo "To start executor work:"
echo "  cd $WORKTREE_PATH_ABS"

