# TASK-0067 — Add revision prompt renderer

## Status

ready

## Goal

Add a helper that renders a focused revision prompt for DeepSeek/OpenCode when a reviewer returns `revise`.

The helper should support the loop:

    implementation
      -> reviewer says revise
      -> render revision prompt
      -> DeepSeek/OpenCode fixes only requested changes
      -> parent verifies
      -> reviewer reviews again

## Background

TASK-0057 proved that GPT-5.5/coder can review DeepSeek/OpenCode output.
TASK-0058 and TASK-0060 improved review context.
TASK-0065 proved the full helper-driven implementation/review flow.

We still need a clean mechanism for the `revise` path. Currently reviewer feedback would need to be manually pasted into a new executor prompt.

This task adds a helper for generating that revision prompt.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/render-review-prompt.sh
- scripts/render-opencode-prompt.sh
- scripts/run-ready-task.sh
- agentops/tasks/ready/TASK-0067-revision-prompt-renderer.md

## Write scope

- scripts/render-revision-prompt.sh

Do not modify unrelated files.

## Requirements

Create:

    scripts/render-revision-prompt.sh

The script should:

- be shell-only
- use `set -euo pipefail`
- support usage:

      scripts/render-revision-prompt.sh <task-file> <reviewer-feedback-file>

- support `-h` and `--help`
- fail if:
  - arguments are missing
  - task file does not exist
  - reviewer feedback file does not exist
- print the rendered revision prompt to stdout
- not modify files
- not create tmp files itself
- not invoke Hermes/coder
- not invoke OpenCode
- not read or print secrets
- include in the prompt:
  - role: implementation revision agent
  - instruction to fix only reviewer-requested changes
  - instruction not to broaden scope
  - instruction to preserve unrelated files
  - original task content
  - reviewer feedback content
  - current `git status --short --branch`
  - current `git diff --stat`
  - current `git diff`
  - required return format:
    - changed files
    - diff summary
    - verification output
    - remaining uncertainty

Keep the helper simple. Do not parse reviewer feedback.

## Non-goals

- No automatic rerun of OpenCode
- No reviewer invocation
- No lifecycle state changes
- No accept/closeout
- No result summaries
- No parsing reviewer decision
- No multi-reviewer orchestration

## Verification

Run:

    bash -n scripts/render-revision-prompt.sh
    scripts/render-revision-prompt.sh --help
    scripts/render-revision-prompt.sh -h

Create fake reviewer feedback using repo-local tmp:

    tmp_dir="$(scripts/agentops-tmp-dir.sh TASK-0067-revision-prompt-renderer)"
    cat > "$tmp_dir/reviewer-feedback.md" <<'EOF'
Decision:
revise

Requested changes:
- Add a clearer help example.
- Do not modify unrelated files.
EOF

Render revision prompt:

    scripts/render-revision-prompt.sh agentops/tasks/ready/TASK-0067-revision-prompt-renderer.md "$tmp_dir/reviewer-feedback.md" > "$tmp_dir/revision.prompt.md"

Check prompt content:

    grep -q "implementation revision agent" "$tmp_dir/revision.prompt.md"
    grep -q "fix only reviewer-requested changes" "$tmp_dir/revision.prompt.md"
    grep -q "Decision:" "$tmp_dir/revision.prompt.md"
    grep -q "Requested changes:" "$tmp_dir/revision.prompt.md"
    grep -q "TASK-0067" "$tmp_dir/revision.prompt.md"
    grep -q "git diff --stat" "$tmp_dir/revision.prompt.md"

Missing feedback file should fail:

    set +e
    scripts/render-revision-prompt.sh agentops/tasks/ready/TASK-0067-revision-prompt-renderer.md "$tmp_dir/missing.md" > "$tmp_dir/missing.out" 2> "$tmp_dir/missing.err"
    missing_feedback_exit=$?
    set -e
    echo "missing_feedback_exit=$missing_feedback_exit"

Then run:

    git status --short --branch
    git diff --stat

Expected:

    missing_feedback_exit=1

## Accept criteria

- `scripts/render-revision-prompt.sh` exists and is executable.
- Helper renders a self-contained revision prompt to stdout.
- Helper includes original task, reviewer feedback, git status, diff stat, and diff.
- Helper instructs revision agent to fix only requested changes.
- Helper does not modify files.
- Helper supports help mode.
- Helper fails on missing task or feedback files.
- Implementation only changes `scripts/render-revision-prompt.sh`.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
