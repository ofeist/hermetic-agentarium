#!/usr/bin/env bash
set -euo pipefail

echo "=== git status ==="
git status --short --branch

echo ""
echo "=== git diff --stat ==="
git diff --stat

echo ""
echo "=== git diff --name-only ==="
git diff --name-only
