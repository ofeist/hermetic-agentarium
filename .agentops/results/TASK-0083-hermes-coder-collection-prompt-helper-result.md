# TASK-0083-hermes-coder-collection-prompt-helper Result

## Decision

accept

## Decision note

Accepted after focused re-review clarified that ready→review movement is expected lifecycle state, and confirmed the helper implementation/verification evidence were sufficient with no script defects.

## Task file

agentops/tasks/done/TASK-0083-hermes-coder-collection-prompt-helper.md

## Lifecycle state

- Ready-state task file was moved through lifecycle and is now represented at the done path above.
- Review-stage lifecycle movement was treated as expected state transition, not implementation scope drift.

## Changed files

- scripts/render-collection-prompt.sh
- agentops/tasks/done/TASK-0083-hermes-coder-collection-prompt-helper.md
- agentops/results/TASK-0083-hermes-coder-collection-prompt-helper-result.md
- Ready-state task file removed by lifecycle move.

## Verification

```bash
# helper syntax
bash -n scripts/render-collection-prompt.sh
# result: pass (exit 0)

# positive render (captured before submit-to-review when task was in ready state)
scripts/render-collection-prompt.sh <ready-task-path>
# result: prints prompt to stdout beginning with /hermetic-coding-orchestrator,
# includes task path and required guardrails

# negative: existing file outside ready scope
scripts/render-collection-prompt.sh <non-ready-existing-task-path>
# result: Error: task path must be under agentops/tasks/ready/ (exit 1)

# negative: missing file
scripts/render-collection-prompt.sh agentops/tasks/review/DOES-NOT-EXIST.md
# result: Error: task file 'agentops/tasks/review/DOES-NOT-EXIST.md' not found or is not a regular file (exit 1)

# lifecycle consistency
scripts/check-agentops-lifecycle.sh
```

## Reviewer record

- Initial broad review: `revise` (context confusion around lifecycle move)
- Focused re-review packet (lifecycle vs implementation separated): `accept`

## Follow-ups

None.
