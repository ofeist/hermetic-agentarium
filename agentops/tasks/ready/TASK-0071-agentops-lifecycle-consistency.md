# TASK-0071 — Add AgentOps lifecycle consistency checks and closeout rules

## Status

ready

## Goal

Prevent future AgentOps lifecycle drift between task folders, task status
metadata, and result notes.

## Background

TASK-0070 reconciled the stale ready queue by moving completed helper and
dogfood tasks into `agentops/tasks/done/`, normalizing visible task status to
`done`, and recording the cleanup in
`agentops/results/TASK-0070-reconcile-agentops-ready-queue-result.md`.

This task should not perform another broad queue reconciliation. It should add
the preventive guardrail and closeout behavior needed to keep future lifecycle
state consistent.

Lifecycle ownership must stay clear:

- `scripts/submit-agentops-task.sh` owns `ready -> review`.
- `scripts/accept-agentops-task.sh` owns `review -> done`.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- scripts/accept-agentops-task.sh
- scripts/submit-agentops-task.sh
- agentops/USAGE.md
- agentops/TASK-LIFECYCLE.md
- skills/hermetic-coding-orchestrator/SKILL.md
- profiles/coder/SOUL.md
- agentops/tasks/
- agentops/results/

## Write scope

- scripts/check-agentops-lifecycle.sh
- scripts/accept-agentops-task.sh
- skills/hermetic-coding-orchestrator/SKILL.md
- profiles/coder/SOUL.md
- agentops/USAGE.md

Only update `agentops/USAGE.md` if a short usage note is needed. Do not modify
other docs.

## Requirements

- The execution prompt MUST start with `/hermetic-coding-orchestrator` to explicitly invoke the custom skill.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near the beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration, not by task prompt text.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking OpenCode.

### 1. Add lifecycle checker

Add `scripts/check-agentops-lifecycle.sh`.

The checker must:

- use `set -euo pipefail`
- support `-h` and `--help`
- detect duplicate task IDs across:
  - `agentops/tasks/planned/`
  - `agentops/tasks/ready/`
  - `agentops/tasks/running/`
  - `agentops/tasks/review/`
  - `agentops/tasks/done/`
- fail if any task file under `agentops/tasks/done/` still says it is ready:
  - `Status: ready`
  - or a `## Status` section whose next non-empty line is `ready`
- fail if any result note references an `agentops/tasks/.../*.md` path that does not exist
- warn, but do not fail, for done tasks without result notes
- support existing result naming patterns, including:
  - `agentops/results/TASK-0023-result.md`
  - `agentops/results/TASK-0065-full-helper-driven-workflow-result.md`
  - `agentops/results/TASK-0070-reconcile-agentops-ready-queue-result.md`
- print clear `ERROR:` lines for failures
- print clear `WARN:` lines for warnings
- exit non-zero when at least one error is found
- exit zero when only warnings are found

### 2. Update accept closeout

Update `scripts/accept-agentops-task.sh` so accepted tasks are visibly closed
out.

The helper must continue to own only:

    agentops/tasks/review/<task-id>.md
    -> agentops/tasks/done/<task-id>.md

Do not add a `ready -> done` shortcut.

After moving the task file into `done/`, rewrite task status to `done` for both
known styles:

- `Status: ready`
- `## Status` followed by `ready`

The helper must continue to create the result note.

### 3. Update lifecycle rules

Update `skills/hermetic-coding-orchestrator/SKILL.md` with a detailed
`AgentOps lifecycle ownership` rule:

- `submit-agentops-task.sh` owns `ready -> review`
- `accept-agentops-task.sh` owns `review -> done`
- do not manually move lifecycle task files unless performing an explicit reconciliation task
- accepted tasks must be under `done/`, visibly marked `done`, and have a result note
- after lifecycle closeout, run `scripts/check-agentops-lifecycle.sh`
- treat duplicate task IDs, done tasks marked ready, and result notes pointing to missing tasks as workflow issues

Update `profiles/coder/SOUL.md` only with the short invariant:

- preserve AgentOps lifecycle ownership
- do not manually move lifecycle files except in explicit reconciliation tasks
- accepted tasks must be visibly marked done
- lifecycle consistency should be checked when the checker exists

## Non-goals

- No broad ready queue reconciliation.
- No task directory rename.
- No AgentOps naming decision.
- No changes to helper script runtime behavior beyond `accept-agentops-task.sh`.
- No changes to model configuration.
- No commits or pushes.

## Verification

Run:

    bash -n scripts/*.sh maintainer/*.sh
    scripts/check-agentops-lifecycle.sh
    scripts/check-agentops-lifecycle.sh --help
    scripts/accept-agentops-task.sh --help
    git status --short --branch
    git diff --stat

If useful, also run a temporary accept-helper smoke test using a synthetic
`TASK-9999-*` review task, then remove all temporary task/result files before
returning.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator:

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0071-agentops-lifecycle-consistency.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- create/switch to an appropriate task branch
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME, OPENCODE_XDG_DATA_HOME, and AGENTOPS_EXECUTOR_MODEL
- use the runner-configured executor model
- do not silently fallback to another model
- do not commit
- independently verify the result
- do not perform broad ready queue reconciliation

Return:
Plan:
Implementation:
Verification:
Review:
Changed files:
Uncertainty:
```

## Accept criteria

- `scripts/check-agentops-lifecycle.sh` exists and is executable.
- Lifecycle checker exits zero on the current reconciled repository state.
- Lifecycle checker reports warnings without failing for historical done tasks without result notes, if any.
- Lifecycle checker would fail on duplicate task IDs, done tasks marked ready, or result notes pointing to missing task paths.
- `scripts/accept-agentops-task.sh` still moves only `review -> done`.
- Accepted task status is rewritten to `done`.
- Result note creation remains intact.
- `SKILL.md` has the detailed lifecycle ownership rule.
- `SOUL.md` has only the short lifecycle invariant.
- No ready queue reconciliation is performed in this task.
- Diff stays within write scope.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
