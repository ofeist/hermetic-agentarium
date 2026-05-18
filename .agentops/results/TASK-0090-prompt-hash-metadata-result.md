# TASK-0090-prompt-hash-metadata Result

## Decision

accept

## Decision note

accept: added prompt_sha256 metadata field in executor wrapper and verified hash reproducibility.

## Task file

agentops/tasks/done/TASK-0090-prompt-hash-metadata.md

## Changed files

- scripts/run-opencode-executor.sh
- docs/RUN-AUDIT.md
- agentops/tasks/done/TASK-0090-prompt-hash-metadata.md (lifecycle)
- agentops/results/TASK-0090-prompt-hash-metadata-result.md

## Verification

```bash
bash -n scripts/run-opencode-executor.sh
TMP_PROMPT=$(mktemp --suffix=.prompt.md)
printf 'hello prompt\n' > "$TMP_PROMPT"
AGENTOPS_EXECUTOR_COMMAND='printf "executor ok\n"' AGENTOPS_RUN_ID=TASK-0090-ind-verify scripts/run-opencode-executor.sh "$TMP_PROMPT"
grep -E '^(prompt_lines|prompt_sha256)=' .agentops-runs/TASK-0090-ind-verify/metadata.txt
sha256sum "$TMP_PROMPT" | awk '{print $1}'
```

Observed: prompt_sha256 matched independent sha256sum output.

## Review

Focused independent re-review decision: accept.

## Follow-ups

None in this slice.
