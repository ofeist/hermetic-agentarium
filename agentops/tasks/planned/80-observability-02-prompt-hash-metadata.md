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

Update the executor run capture path to write:

```text
prompt_sha256=<sha256>
```

into:

```text
.agentops-runs/<run-id>/metadata.txt
```

Keep existing `prompt_bytes` and `prompt_lines` fields unchanged.

## Non-goals

- no semantic prompt diffing
- no prompt content export
- no model-token calculation
- no automatic rerun prevention

## Open questions

- Should hash calculation use `sha256sum` only, or provide a portable fallback?
- Should summaries display the full hash or a short prefix?

## Promotion criteria

Promote to ready when the exact metadata writer is identified.

## Suggested verification

```bash
grep -R "prompt_sha256" .agentops-runs scripts docs 2>/dev/null || true
```
