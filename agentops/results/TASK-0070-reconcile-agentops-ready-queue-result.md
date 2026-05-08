# TASK-0070 Result — Reconcile AgentOps Ready Queue

## Decision

accept

## Summary

The ready queue contained historical helper and dogfood tasks whose requested
artifacts already exist in the repository or were superseded by later completed
workflow tasks. Leaving them in `agentops/tasks/ready/` made the queue unsafe to
execute as fresh work.

This cleanup moved those historical tasks to `agentops/tasks/done/` and
normalized `## Status` to `done` for files already under `done/`.

## Moved from ready to done

- TASK-0019-hermes-run-opencode
- TASK-0035-coder-profile-env-defaults
- TASK-0055-dogfood-run-ready-task
- TASK-0056-review-prompt-renderer
- TASK-0057-dogfood-ds-to-gpt-review
- TASK-0058-review-prompt-verification-notes
- TASK-0059-dogfood-review-prompt-notes
- TASK-0060-verification-notes-helper
- TASK-0061-submit-task-to-review-helper
- TASK-0062-accept-closeout-helper
- TASK-0063-agentops-tmp-helper
- TASK-0064-untracked-files-in-verification-notes
- TASK-0067-revision-prompt-renderer

## Rationale

The corresponding scripts, docs, or later dogfood tasks are present:

- `scripts/run-ready-task.sh`
- `scripts/render-review-prompt.sh`
- `scripts/submit-agentops-task.sh`
- `scripts/render-verification-notes.sh`
- `scripts/start-agentops-task.sh`
- `scripts/accept-agentops-task.sh`
- `scripts/agentops-tmp-dir.sh`
- `scripts/render-revision-prompt.sh`
- `scripts/install-coder-profile.sh`
- `profiles/coder/.env.example`
- `docs/HERMES-OPENCODE-RUN.md`

Later completed tasks/results also cover the workflow consolidation:

- TASK-0023-hermes-opencode-runtime-check
- TASK-0036-coder-profile-env-runtime
- TASK-0040-render-opencode-prompt-helper
- TASK-0065-full-helper-driven-workflow
- TASK-0066-add-revision-task-helper
- TASK-0067-make-skill-usage-auditable
- TASK-0068-dogfood-revise-loop

## Scope

Only AgentOps lifecycle artifacts were changed. No helper scripts, profile files,
skills, runtime behavior, or documentation outside task/result lifecycle records
were modified.

## Verification

Run:

```bash
find agentops/tasks/ready -maxdepth 1 -type f -name 'TASK-*.md' -print | sort
find agentops/tasks/done -maxdepth 1 -type f -name 'TASK-*.md' -print | sort
rg -n '^ready$' agentops/tasks/done
git diff --stat
git status --short --branch
```

Expected:

- no executable `TASK-*.md` files remain in `agentops/tasks/ready/`
- moved/completed tasks are under `agentops/tasks/done/`
- no `## Status` body value under `agentops/tasks/done/` remains `ready`
- diff is limited to AgentOps lifecycle files
