# OpenCode Executor Workflow

## Purpose

Delegate bounded, implementation-only tasks to OpenCode running in non-interactive mode. The executor model generates a diff; the parent (Hermes or a human) reviews and decides what to do with it.

## Constraints

- The executor must **never commit**.
- The executor must **never read or touch secrets** (`.env`, `auth.json`, API keys, SSH keys, tokens, credentials, private config).
- The executor may only modify files explicitly listed in the task prompt.
- The parent performs independent review before accepting any change.

## Minimal Flow

1. **Parent/Hermes prepares a bounded prompt file** — a plain text file (`/tmp/task-prompt.txt`) containing:
   - A single, bounded task description.
   - The list of file paths the executor is allowed to create or modify.
   - The list of forbidden operations (no commit, no secrets, no unrelated files).

2. **`scripts/run-opencode-executor.sh` runs OpenCode non-interactively**

   ```bash
   scripts/run-opencode-executor.sh /tmp/task-prompt.txt deepseek/deepseek-chat
   ```

3. **OpenCode/model produces a diff** — changes are written to disk but not staged or committed.

4. **`scripts/review-executor-result.sh` prints status and diff summary**

   ```bash
   scripts/review-executor-result.sh
   ```

5. **Parent reviews full diff/tests and decides.**

## Example Commands

```bash
# Run the executor
scripts/run-opencode-executor.sh /tmp/task-prompt.txt deepseek/deepseek-chat

# Review what changed
scripts/review-executor-result.sh
git diff

# Run tests
pytest tests/            # or equivalent
```

## Decision States

| State | Meaning |
|---|---|
| **accept** | The diff is correct; parent stages, tests, and commits. |
| **revise** | The diff needs changes; parent writes a revised prompt and re-runs. |
| **revert** | The diff is wrong; parent discards only the executor-touched files, for example with `git restore <allowed-files>`. |
| **no-op / nothing to accept** | Executor produced no useful changes; no action needed. |
