# TASK-0090 — Add prompt hash to executor metadata

## Status

review

## Goal

Add a prompt hash to executor run metadata so duplicate executor
prompts can be detected without reading or exporting full prompt
content.

## Background / why now

`IDEAS.md` and the observability workstream propose adding
`prompt_sha256` next to the existing prompt size fields. This supports
cheap detection of repeated prompts across failed, no-op, or
repeated-review runs.

`scripts/run-opencode-executor.sh` already computes `prompt_bytes` and
`prompt_lines` from the on-disk prompt file and writes them into
`.agentops-runs/<run-id>/metadata.txt`. Hashing the same file is a
small, local addition with no new I/O paths and no new helpers.

The broader motivation is captured in the observability workstream
intent (planned `69-observability-00-...`): activity signals like
size/duration/exit are useful but incomplete; a stable prompt fingerprint
makes "we already ran this exact prompt" observable without exporting
the prompt body.

## Problem statement

Prompt duplication may waste model calls. But exporting full prompts
into summaries or future dashboards would increase token usage and risk
exposing sensitive context. A short, deterministic hash is enough to
detect repeats while keeping prompt content local.

## Smallest useful slice

Update `scripts/run-opencode-executor.sh` to write
`prompt_sha256=<64 lowercase hex>` into the existing
`.agentops-runs/<run-id>/metadata.txt`, immediately after the existing
`prompt_lines` field. Keep existing prompt size fields and all other
metadata behavior unchanged.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `scripts/run-opencode-executor.sh`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `.agentops-runs/` (existing layout — do not modify)
- `agentops/tasks/done/TASK-0073-agentops-executor-run-metadata-baseline.md`
  (baseline metadata contract)

## Write scope

- `scripts/run-opencode-executor.sh`
- optional minimal docs update for the metadata contract
  (`docs/RUN-AUDIT.md` and/or `docs/RUN-OBSERVABILITY.md`) — at most
  one short paragraph or bullet listing the new field

Do not modify `scripts/record-agentops-outcome.sh`,
`scripts/render-agentops-run-summary.sh`, or any other helper in this
slice. Do not change `.agentops-runs/` directory layout.

## Requirements

The executor wrapper MUST:

- compute `prompt_sha256` by hashing the exact on-disk prompt file
  passed in as `$PROMPT_FILE` (the same file already used to compute
  `prompt_bytes` and `prompt_lines`)
- write the field as the literal line:

  ```text
  prompt_sha256=<64 lowercase hex>
  ```

- insert the new line immediately after the existing `prompt_lines=...`
  line in the initial metadata block, so the resulting block reads in
  this order:

  ```text
  prompt_file=...
  prompt_bytes=...
  prompt_lines=...
  prompt_sha256=...
  started_at=...
  ```

- only write the field when `$RUN_ID` is set (i.e. inside the existing
  `if [[ -n "$RUN_ID" ]]` metadata block); the no-run-id mode is
  unchanged
- prefer `sha256sum` when available; otherwise use `shasum -a 256`
- if neither `sha256sum` nor `shasum -a 256` is available, fail with a
  clear error before writing any metadata
- if the prompt file becomes unreadable between the existing
  validation and the hash step, fail with a clear error (the existing
  `set -euo pipefail` plus an explicit check is acceptable)
- not write `prompt_sha256=unknown` or any sentinel — if hashing fails,
  fail the wrapper
- extract only the hash field (first whitespace-separated token) from
  the hash command output; do not write the filename or two-space
  separator
- not export, log, or echo the full prompt content
- not change `prompt_bytes`, `prompt_lines`, `prompt_file`, or any
  other existing metadata field

Hash representation:

- exactly 64 lowercase hexadecimal characters
- both `sha256sum` and `shasum -a 256` already produce lowercase hex by
  default; do not post-process beyond extracting the first field

Workflow requirements:

- The execution prompt MUST start with `/hermetic-coding-orchestrator`
  to explicitly invoke the custom skill.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator`
  near the beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration, not
  by task prompt text.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if
  invoking OpenCode.

## Non-goals

- Do not implement semantic prompt diffing.
- Do not export full prompt content.
- Do not calculate exact model tokens.
- Do not automatically prevent reruns.
- Do not add model-routing policy changes.
- Do not modify `scripts/record-agentops-outcome.sh` or `outcome.txt`.
- Do not change `.agentops-runs/` directory layout.
- Do not hash remote or streamed prompts.
- Do not create a new helper script for hashing — the wrapper owns it.
- Do not update `scripts/render-agentops-run-summary.sh` in this slice;
  surface in summary helper is deferred.
- Do not add `openssl dgst -sha256` as a third fallback in this slice
  unless inspection shows neither `sha256sum` nor `shasum -a 256` is
  available in the target environment.

## Open questions

None.

Resolved:

- Writer location: `scripts/run-opencode-executor.sh` writes the field
  directly. Reason: this is executor run-capture metadata; the wrapper
  already knows the prompt file and already writes metadata. No new
  helper.
- Prompt source: the exact on-disk prompt file passed in as
  `$PROMPT_FILE`. Reason: matches existing `prompt_bytes`/`prompt_lines`
  semantics; concrete and reproducible.
- Field shape: `prompt_sha256=<64 lowercase hex>`, placed immediately
  after `prompt_lines` in the initial metadata block.
- Missing-prompt behavior: do not write `prompt_sha256=unknown`. Fail
  with a clear error. The wrapper must not proceed without a readable
  prompt file.
- Portability: `sha256sum` preferred; fallback to `shasum -a 256`. No
  `openssl` fallback in this slice unless inspection shows neither is
  available.
- Summary display: deferred. `scripts/render-agentops-run-summary.sh`
  is out of scope for this slice.

## Promotion decision

Decision: promote_to_ready.

Reason:
All blockers are locked: writer location, prompt source, field shape,
missing-prompt behavior, portability, and summary-display scope. The
change is local to one wrapper, one line of insertion logic, and a
small hash helper block. No new helpers, no new files in
`.agentops-runs/`, no outcome-metadata coupling.

Next action:
Execute through the Hermes/coder collection prompt.

## Promotion criteria

Already promoted to ready.

## Verification

```bash
git status --short --branch
bash -n scripts/run-opencode-executor.sh
git diff --stat
```

Confirm the new field is written by running the wrapper with a
disposable run-id and a mock executor command, then inspecting
`metadata.txt`:

```bash
TMP_PROMPT="$(mktemp --suffix=.prompt.md)"
printf 'hello prompt\n' > "$TMP_PROMPT"
AGENTOPS_EXECUTOR_COMMAND='printf "executor ok\n"' \
  AGENTOPS_RUN_ID=TASK-0090-verify \
  scripts/run-opencode-executor.sh "$TMP_PROMPT"
grep -E '^(prompt_bytes|prompt_lines|prompt_sha256)=' \
  .agentops-runs/TASK-0090-verify/metadata.txt
```

Expected output: three lines, with `prompt_sha256=` followed by exactly
64 lowercase hex characters and no trailing filename.

Confirm independent reproducibility:

```bash
sha256sum "$TMP_PROMPT" | awk '{print $1}'
```

This value MUST equal the `prompt_sha256` value in `metadata.txt`.

Confirm the no-run-id path is unchanged:

```bash
AGENTOPS_EXECUTOR_COMMAND='printf "executor ok\n"' \
  scripts/run-opencode-executor.sh "$TMP_PROMPT"
```

No `.agentops-runs/` directory should be created or modified for this
call.

Clean up the verification artifact:

```bash
rm -rf .agentops-runs/TASK-0090-verify "$TMP_PROMPT"
```

Do not use `|| true` to mask failures.

## Accept criteria

- Change is limited to write scope.
- `scripts/run-opencode-executor.sh` writes `prompt_sha256=<64 lowercase hex>`
  into `.agentops-runs/<run-id>/metadata.txt`, immediately after the
  existing `prompt_lines` line.
- The hash matches the output of `sha256sum <prompt-file>` (or
  `shasum -a 256 <prompt-file>`) for the same on-disk prompt file.
- `prompt_bytes`, `prompt_lines`, `prompt_file`, and all other existing
  metadata fields are unchanged in name, value semantics, and order.
- The wrapper fails with a clear error if neither `sha256sum` nor
  `shasum -a 256` is available.
- The wrapper does not write `prompt_sha256=unknown` or any sentinel
  value.
- The no-run-id path is unchanged (no metadata file created).
- No new helper scripts are added.
- `scripts/record-agentops-outcome.sh`, `outcome.txt`, and
  `.agentops-runs/` directory layout are unchanged.
- `scripts/render-agentops-run-summary.sh` is not modified.
- Verification commands pass or failures are explained.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0090-prompt-hash-metadata.md

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

Scope:
- modify only scripts/run-opencode-executor.sh (optional: at most one short paragraph or bullet in docs/RUN-AUDIT.md or docs/RUN-OBSERVABILITY.md describing the new field)
- compute prompt_sha256 from the exact on-disk $PROMPT_FILE, the same file used for prompt_bytes/prompt_lines
- write the field as `prompt_sha256=<64 lowercase hex>` immediately after the existing `prompt_lines=` line in the initial metadata block
- only write the field when $RUN_ID is set (inside the existing `if [[ -n "$RUN_ID" ]]` block)
- prefer `sha256sum`; fallback to `shasum -a 256`; fail with a clear error if neither is available
- do not write `prompt_sha256=unknown` or any sentinel; fail the wrapper if hashing fails
- extract only the first whitespace-separated token from the hash command output
- do not export, log, or echo full prompt content
- do not modify scripts/record-agentops-outcome.sh, outcome.txt, or .agentops-runs/ directory layout
- do not modify scripts/render-agentops-run-summary.sh in this slice
- do not add openssl as a third fallback unless inspection shows neither sha256sum nor `shasum -a 256` is available
- verify with the steps in the Verification section, including the independent `sha256sum` reproducibility check

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

This is a low-risk observability slice: metadata-only, single wrapper,
no new files, no prompt content export.

Surfacing `prompt_sha256` in `scripts/render-agentops-run-summary.sh`
(full hash vs short prefix) is intentionally deferred to a follow-up
task once the field has flowed through real runs.

Related:

- TASK-0073 (executor run metadata baseline, done) established the
  metadata.txt contract this task extends.
- TASK-0089 (run outcome metadata, ready) defines a separate
  post-review `outcome.txt`; the two streams remain independent and
  this task does not touch outcome metadata.
- planned `69-observability-00-...` (workstream intent) captures the
  broader motivation.
- planned `90-observability-03-...` (agent/model usage audit) is a
  separate observability slice and is not coupled to this task.
