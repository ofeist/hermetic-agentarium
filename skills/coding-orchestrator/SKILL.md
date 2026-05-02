---
name: coding-orchestrator
description: Use this skill for non-trivial software development tasks that require planning, implementation, verification, and review.
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
