# Hermes to OpenCode Run

Hermes/coder prepares a bounded task prompt and delegates execution to OpenCode. After the executor finishes, the parent independently reviews the result before accepting any change.

OpenCode runs as the executor through `scripts/run-opencode-executor.sh`, which passes the task prompt and model identifier to `opencode run --model`.

The executor must never commit. All changes remain unstaged so the parent can inspect, accept, revise, or discard them.

Git diff and verification commands (`git diff`, `git diff --stat`, `git status`) are the source of truth for what changed. The parent reviews the full diff and tests before deciding next steps.
