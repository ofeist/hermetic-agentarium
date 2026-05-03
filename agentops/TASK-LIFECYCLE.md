# AgentOps Task Lifecycle

## States

- **planned** — A task has been identified but the prompt has not yet been written or queued for execution.
- **ready** — The prompt file is prepared and the task is queued for the executor; no executor has picked it up yet.
- **running** — An executor is actively working on the task. Changes are being written to disk but not committed.
- **review** — The executor has finished and produced a diff. The parent (Hermes or a human) must review the changes, run tests, and decide next steps.
- **done** — Terminal state. The parent has made a decision and the task is complete.

## Decisions (from review)

- **accept** — The diff is correct. Parent stages, tests, and commits.
- **revise** — The diff needs changes. Parent writes a revised prompt and re-runs the executor.
- **revert** — The diff is wrong. Parent discards the executor-touched files (e.g. `git restore`).
- **no-op / nothing to accept** — Executor produced no useful changes; no action required.

## Constraints

- The executor must **never commit**. All commits are performed by the parent after independent review.
- The parent performs independent verification of the diff and tests before accepting any change.
