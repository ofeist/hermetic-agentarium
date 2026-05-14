# TASK-0084 — Add task ID allocation tracking

## Status

ready

## Goal

Make assignment of the next `TASK-XXXX` ID explicit during planned-to-ready promotion.

## Background / why now

Planned tasks intentionally use soft local names such as `workflow-03-something.md`. The authoritative `TASK-XXXX` name appears only when the task becomes ready.

`IDEAS.md` notes that inferring the next task ID by scanning lifecycle folders can race with concurrent work or miss files in another lifecycle directory.

## Problem statement

Task ID allocation is currently implicit. That makes promotion fragile once more than one agent or operator can create tasks.

## Smallest useful slice

Add one small helper that scans AgentOps lifecycle folders and prints the next available `TASK-XXXX` ID.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `agentops/tasks/planned/`
- `agentops/tasks/ready/`
- `agentops/tasks/running/`
- `agentops/tasks/review/`
- `agentops/tasks/done/`
- existing task lifecycle helper scripts under `scripts/`
- relevant AgentOps workflow documentation

## Write scope

- `scripts/next-agentops-task-id.sh`
- minimal docs update only if needed to document task ID allocation
- minimal tests or shell syntax checks if present

## Requirements

The helper:

- is invoked as:

  ```bash
  scripts/next-agentops-task-id.sh
  ```

- scans the following lifecycle directories for existing task IDs:

  ```text
  agentops/tasks/planned/   # defensive only
  agentops/tasks/ready/
  agentops/tasks/running/
  agentops/tasks/review/
  agentops/tasks/done/
  ```

- identifies existing task IDs using the filename rule:

  ```text
  ^TASK-[0-9]{4}-.*\.md$
  ```

  Soft-named planned files such as `<area>-<sequence>-<slug>.md` do not allocate task IDs and are ignored by this rule.

- prints the next available `TASK-XXXX` ID to stdout, zero-padded to 4 digits
- prints `TASK-0001` if no matching files exist in any scanned directory (empty lifecycle)
- does not modify any files
- does not reserve or persist the allocated ID
- exits non-zero if a scanned directory is missing or unreadable

Workflow requirements:

- The execution prompt MUST start with `/hermetic-coding-orchestrator` to
  explicitly invoke the custom skill.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near the
  beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration, not by task
  prompt text.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking
  OpenCode.

## Non-goals

- Do not add a full ledger.
- Do not implement automatic planned-to-ready promotion.
- Do not implement locking across machines.
- Do not introduce a Jira-like task database.
- Do not rename existing tasks.
- Do not reserve or persist allocated IDs in this slice.
- Do not invoke Hermes or OpenCode from the helper.

## Open questions

None.

Resolved:
- Helper name: `scripts/next-agentops-task-id.sh`.
- Scan set: `planned/`, `ready/`, `running/`, `review/`, `done/`.
- Matching rule: `^TASK-[0-9]{4}-.*\.md$`.
- Empty lifecycle: print `TASK-0001`.
- `planned/` is scanned defensively; soft-named planned files do not allocate IDs.

Deferred:
- Atomic reservation belongs in a later promotion helper task.
- Ledger is out of scope unless scanning proves insufficient.

## Promotion decision

Decision: promote_to_ready.

Reason:
All five blocker decisions (helper name, scan set, matching rule,
empty-lifecycle behavior, reservation/ledger scope) are locked. Read/write
scope is concrete. Verification has a concrete output-shape assertion.

Next action:
Execute through the Hermes/coder collection prompt.

## Promotion criteria

Already promoted to ready.

## Verification

```bash
git status --short --branch
bash -n scripts/next-agentops-task-id.sh
scripts/next-agentops-task-id.sh
[[ "$(scripts/next-agentops-task-id.sh)" =~ ^TASK-[0-9]{4}$ ]]
git diff --stat
```

Do not use `|| true` to mask failures.

## Accept criteria

- Change is limited to write scope.
- Helper prints exactly one line matching `^TASK-[0-9]{4}$` for a non-empty lifecycle.
- Helper prints `TASK-0001` when no matching files exist in any scanned directory.
- Helper scans all five lifecycle directories listed above.
- Helper uses the matching rule `^TASK-[0-9]{4}-.*\.md$` to identify task IDs.
- Helper does not modify any files.
- Helper does not reserve or persist the allocated ID.
- Verification commands pass.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0084-task-id-allocation-tracking.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Workflow requirements:
- use or create a task-specific worktree and branch
- do not switch the main planning worktree away from main
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME, OPENCODE_XDG_DATA_HOME, and AGENTOPS_EXECUTOR_MODEL
- use the runner-configured executor model
- do not silently fallback to another model
- do not commit
- independently verify the result

Return:
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
```

## Return format

Expected executor return format:

```text
Plan:
...

Implementation:
...

Verification:
...

Review:
accept / revise / revert / no-op / blocked

Changed files:
...

Uncertainty:
...
```

## Notes

Keep this read-only first. ID reservation and promotion automation can be
follow-up tasks if scanning proves insufficient.

Related: TASK-0083 (collection prompt helper) — both are small `scripts/`
helpers that read AgentOps task state without modifying it.
