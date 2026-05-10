# observability-03 — Add prompt hash to executor metadata

## Status

planned

## Goal

Add a prompt hash to executor run metadata so duplicate executor prompts can be detected without reading or exporting full prompt content.

## Background / why now

`IDEAS.md` proposes adding `prompt_sha256` next to existing prompt size fields. This supports cheap detection of repeated prompts across failed, no-op, or repeated-review runs.

## Problem statement

Prompt duplication may waste model calls. But exporting full prompts into summaries or future dashboards would increase token usage and risk exposing sensitive context.

## Smallest useful slice

Update the executor run capture path to write `prompt_sha256=<sha256>` into the existing run metadata file while keeping existing prompt size fields unchanged.

## Executor

Harness: TBD.
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- executor run capture wrapper
- `.agentops-runs/` contract documentation
- run summary helper script, if present
- debugging/audit documentation

## Write scope

- executor run capture wrapper that writes `.agentops-runs/<run-id>/metadata.txt`
- optional docs update for the metadata contract
- optional summary helper update only if promoted as in scope

## Requirements

Update the executor run capture path to write:

```text
prompt_sha256=<sha256>
```

into:

```text
.agentops-runs/<run-id>/metadata.txt
```

Keep existing fields unchanged, especially:

- `prompt_bytes`
- `prompt_lines`

The implementation should:

- hash the rendered prompt locally
- avoid exporting full prompt content into summaries
- preserve existing metadata behavior
- avoid preventing reruns automatically

## Non-goals

- Do not implement semantic prompt diffing.
- Do not export prompt content.
- Do not calculate exact model tokens.
- Do not automatically prevent reruns.
- Do not add model-routing policy changes.

## Open questions

- Should hash calculation use `sha256sum` only, or provide a portable fallback?
- Should summaries display the full hash or a short prefix?
- Should the summary helper be updated in the same slice or deferred?

## Verification

```bash
git status --short --branch
grep -R "prompt_sha256" .agentops-runs scripts docs 2>/dev/null || true
git diff --stat
```

When promoted, add a small run-capture fixture or dry-run check that proves `prompt_sha256` is written without changing prompt content handling.

## Accept criteria

TBD during promotion.

## Promotion decision

Decision: keep_planned.

Reason:
The exact metadata writer and summary display behavior are not yet selected.

Next action:
Identify the metadata writer and decide full-hash vs prefix display, then promote.

## Promotion criteria

Promote to `ready` when:

- the exact metadata writer is identified
- hash calculation portability is decided
- summary display behavior is decided or explicitly deferred
- read/write scope is confirmed

## Hermes/coder collection prompt

TBD during promotion.

## Return format

TBD during promotion.

## Notes

This is a low-risk observability slice if it stays metadata-only and avoids prompt content export.
