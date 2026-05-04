---
name: hermetic-coding-orchestrator
description: Use this custom Hermetic Agentarium skill for controlled coding orchestration with bounded delegation, dirty-worktree protection, parent verification, and no-op/revise/revert review decisions.
---

# Coding Orchestrator Workflow

Use this workflow for coding tasks that are more than a trivial one-line edit.

## Roles

Parent agent:
- Owns planning.
- Owns final review.
- Owns independent verification.
- Must not blindly trust child summaries.

Delegated child agent:
- Owns bounded investigation or implementation.
- Must receive clear scope, constraints, and verification commands.
- Must not commit unless explicitly instructed.

## Default workflow

1. Inspect repository state:
   - `git status --short --branch`

   If `git status --short --branch` shows unrelated existing changes, do not overwrite them.
   Work around them if safe, or ask before touching affected files.

2. Read project instructions if present:
   - `AGENTS.md`
   - `HERMES.md`
   - `CLAUDE.md`
   - `README.md`

3. Create a concise task plan:
   - goal
   - intended files
   - risks
   - verification command

4. Use `delegate_task` for implementation or investigation.

   Delegation guardrail:

   - Use at most one delegated implementation attempt for the same small corrective task.
   - If a delegated task appears stuck, retries the same goal repeatedly, or modifies the wrong file, stop delegating and report `blocked`.
   - Do not launch multiple child agents for the same corrective task unless the previous failure mode is understood.
   - For corrective tasks, if the delegated attempt fails or produces an unexpected diff, stop and report:
     - what went wrong
     - current `git status --short --branch`
     - current `git diff --stat`
     - recommended next action

5. Child task must include:

```text
Goal:
<one clear goal>

Scope:
<allowed files/directories>

Constraints:
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Keep the change minimal.

Verification:
<commands to run>

Return:
- changed files
- git diff summary
- verification output
- uncertainty
```

6. After child returns, parent must independently run verification:

```bash
git status --short --branch
git diff --stat
```

Run relevant tests/checks when applicable.

Examples:

```bash
pytest
npm test
npm run lint
make test
```

7. Parent decision:

Choose one:

- accept
- revise
- revert
- no-op / nothing to accept
- ask user

8. Acceptance rules:

- If `git diff` is empty, report `no-op / nothing to accept`.
- If the task says "add", prefer preserving existing relevant content unless replacement is explicitly requested.
- If the child summary contradicts command output, trust command output.
- If the diff is broader than requested, recommend `revise` or `revert`.
- If verification fails, do not claim success.
- If tests are not run, explain why.
- If the task is ambiguous, prefer a smaller change or ask for clarification.
- If a delegated corrective task required repeated delegation attempts, do not silently call it successful. Report the repeated attempts as a workflow issue even if the final diff is correct.

9. Default output format:

Return the final result in this format:

```text
Plan:
...

Implementation:
...

Verification:
...

Review:
accept / revise / revert / no-op / nothing to accept / ask user

Changed files:
...
```

## OpenCode executor orchestration

For AgentOps tasks that specify OpenCode as executor:

1. Check repository state:
   - `git status --short --branch`

2. Ensure work happens on a task branch, not directly on `main`, unless explicitly instructed.
   - Preferred: `scripts/start-agentops-task.sh <task-id-slug>` to prepare a clean branch from `main`. If it fails, stop and report `blocked` instead of editing on `main`.

3. Read the ready task file from `agentops/tasks/ready/`.

4. Generate a bounded executor prompt in `/tmp` that preserves:
   - goal
   - read scope
   - write scope
   - constraints
   - implementation requirements
   - verification commands
   - return format

5. Invoke OpenCode only through:
   - `scripts/run-opencode-executor.sh <prompt-file> <model>`

6. Use the model specified by the task. If unavailable, stop and report `blocked`. Do not fallback to another model unless explicitly allowed by the task.

7. If runtime environment overrides are provided, preserve them when invoking the wrapper:
   - `OPENCODE_XDG_CONFIG_HOME`
   - `OPENCODE_XDG_DATA_HOME`

8. Independently verify after executor returns:
   - `scripts/review-executor-result.sh`
   - `git diff`

Run task-specific tests/checks when applicable.

9. Review the diff against the task scope and decide:
   - `accept`
   - `revise`
   - `revert`
   - `no-op / nothing to accept`
   - `blocked`

10. Do not commit unless explicitly instructed.

### Canonical ready task invocation prompt

Add the following minimal prompt for executing AgentOps ready tasks:

```text
Execute AgentOps ready task:

agentops/tasks/ready/TASK-xxxx-name.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- create/switch to an appropriate task branch
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME and OPENCODE_XDG_DATA_HOME
- use the task-specified model
- do not fallback to another model
- do not commit
- independently verify the result

Return:
Plan:
Implementation:
Verification:
Review:
Changed files:
Uncertainty:

Also note: task-specific paths, verification commands, or constraints can be added below this prompt when needed
```
