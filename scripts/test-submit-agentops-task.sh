#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"
mkdir -p agentops/tasks/ready agentops/tasks/review

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "  PASS: $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  FAIL: $1" >&2; }

# --------------------------------------------------
# Test 1: successful move + status rewrite
# --------------------------------------------------
echo "=== Test 1: successful move + status rewrite ==="

cat > agentops/tasks/ready/TEST-001.md <<'HEREDOC'
# TEST-001

## Status

ready

## Goal

Something to review.
HEREDOC

"$REPO_ROOT/scripts/submit-agentops-task.sh" "TEST-001" >/dev/null

if [ -f agentops/tasks/review/TEST-001.md ] && [ ! -f agentops/tasks/ready/TEST-001.md ]; then
  pass "file moved from ready/ to review/"
else
  fail "file move failed"
fi

if grep -q '^review$' agentops/tasks/review/TEST-001.md; then
  pass "status rewritten from ready to review"
else
  fail "status was not rewritten to review"
fi

if ! grep -q '^ready$' agentops/tasks/review/TEST-001.md; then
  pass "no stale 'ready' status remains"
else
  fail "stale 'ready' status found in moved file"
fi

# --------------------------------------------------
# Test 2: collision protection (existing review file)
# --------------------------------------------------
echo "=== Test 2: collision protection ==="

cat > agentops/tasks/ready/TEST-002.md <<'HEREDOC'
# TEST-002

## Status

ready

## Goal

Something.
HEREDOC

mkdir -p agentops/tasks/review
echo "existing" > agentops/tasks/review/TEST-002.md

if "$REPO_ROOT/scripts/submit-agentops-task.sh" "TEST-002" >/dev/null 2>/dev/null; then
  fail "collision should be rejected (exit 0)"
else
  pass "collision correctly rejected (non-zero exit)"
fi

if grep -q 'existing' agentops/tasks/review/TEST-002.md; then
  pass "existing review file preserved (not overwritten)"
else
  fail "existing review file was overwritten"
fi

if [ -f agentops/tasks/ready/TEST-002.md ]; then
  pass "original ready file preserved on collision"
else
  fail "ready file incorrectly removed on collision"
fi

# --------------------------------------------------
# Test 3: task not marked done
# --------------------------------------------------
echo "=== Test 3: task not marked done ==="

if ! grep -qi 'done' agentops/tasks/review/TEST-001.md; then
  pass "task is not marked done (no 'done' in file)"
else
  fail "task incorrectly marked done"
fi

# --------------------------------------------------
# Test 4: single-line status format (Status: ready)
# --------------------------------------------------
echo "=== Test 4: single-line Status: ready format ==="

cat > agentops/tasks/ready/TEST-003.md <<'HEREDOC'
# TEST-003

Status: ready

## Goal

Something.
HEREDOC

"$REPO_ROOT/scripts/submit-agentops-task.sh" "TEST-003" >/dev/null

if grep -q 'Status: review' agentops/tasks/review/TEST-003.md; then
  pass "single-line Status: ready -> Status: review"
else
  fail "single-line status not rewritten"
fi

# --------------------------------------------------
# Summary
# --------------------------------------------------
echo ""
echo "=== Summary: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
