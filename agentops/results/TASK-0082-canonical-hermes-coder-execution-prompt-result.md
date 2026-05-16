# TASK-0082-canonical-hermes-coder-execution-prompt Result

## Decision

accept

## Decision note

Accepted after policy-aligned prompt synchronization revisions:
- kept `SKILL.md` canonical
- kept templates as synchronized boilerplate copies for low-diff promotion ergonomics
- fixed placeholder and prompt-local label consistency

## Task file

agentops/tasks/done/TASK-0082-canonical-hermes-coder-execution-prompt.md

## Worktree

- Path: `/home/splinter/devops/hermetic-agentarium-task-0082`
- Branch: `task-0082-canonical-hermes-coder-execution-prompt`
- Main planning worktree remained on `main` at `/home/splinter/devops/hermetic-agentarium`.

## Changed files

- `skills/hermetic-coding-orchestrator/SKILL.md`
  - canonical prompt kept in one place
  - `TASK-xxxx-short-slug.md` placeholder
  - `Workflow requirements:` prompt-local label
- `agentops/templates/PLANNED-TASK-TEMPLATE.md`
  - synchronized full prompt copy retained
  - synchronization note added
  - placeholder aligned to `TASK-xxxx-short-slug.md`
- `agentops/templates/READY-TASK-TEMPLATE.md`
  - synchronized full prompt copy retained
  - synchronization note added
  - placeholder aligned to `TASK-xxxx-short-slug.md`
- `agentops/tasks/done/TASK-0082-canonical-hermes-coder-execution-prompt.md`
- `agentops/results/TASK-0082-canonical-hermes-coder-execution-prompt-result.md` (this note)
- Prior lifecycle task-file locations removed by lifecycle transitions.

## Verification

Commands run:

```text
grep -n 'TASK-xxxx-short-slug.md' skills/hermetic-coding-orchestrator/SKILL.md agentops/templates/PLANNED-TASK-TEMPLATE.md agentops/templates/READY-TASK-TEMPLATE.md
! grep -n 'TASK-xxxx-name.md' skills/hermetic-coding-orchestrator/SKILL.md agentops/templates/PLANNED-TASK-TEMPLATE.md agentops/templates/READY-TASK-TEMPLATE.md
grep -n '^Workflow requirements:$' skills/hermetic-coding-orchestrator/SKILL.md agentops/templates/PLANNED-TASK-TEMPLATE.md agentops/templates/READY-TASK-TEMPLATE.md
grep -n 'Synchronized copy policy:' agentops/templates/PLANNED-TASK-TEMPLATE.md agentops/templates/READY-TASK-TEMPLATE.md
test "$(grep -c '^### Canonical ready task invocation prompt' skills/hermetic-coding-orchestrator/SKILL.md)" = "1"
scripts/check-agentops-lifecycle.sh
git status --short --branch
git diff --stat
```

Outcomes:

```text
- placeholder alignment checks passed
- old placeholder absent
- workflow requirements label aligned
- synchronization notes present in both templates
- canonical heading count exactly 1 in SKILL.md
- lifecycle checker passed: Errors 0, Warnings 0
```

Independent review history:

```text
- initial review: revise (placeholder drift + prompt-local label consistency)
- revised implementation: policy-aligned and ready to accept
```

Lifecycle commands run:

```text
scripts/submit-agentops-task.sh TASK-0082-canonical-hermes-coder-execution-prompt
scripts/accept-agentops-task.sh TASK-0082-canonical-hermes-coder-execution-prompt "Accepted after policy-aligned prompt synchronization revisions."
```

## Follow-ups

No commit/push performed in this accept step.