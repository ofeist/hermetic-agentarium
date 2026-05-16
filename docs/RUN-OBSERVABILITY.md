# Run Observability

Focused operator guide for inspecting AgentOps run metadata, local artifacts,
and observability signals — without pasting raw logs into model prompts.

This doc complements `docs/DEBUGGING.md` (general troubleshooting). When
something fails, start there. When you need to understand *how* a run behaved
without reading full logs, use this guide.

## Core rule

> Full logs are for humans and local debugging. Model prompts receive only
> compact summaries unless explicitly requested.

## Recommended debugging flow

This is the operator-first observability flow. Follow it before opening raw logs.

```
1. METADATA FIRST
   scripts/render-agentops-run-summary.sh <run-id>

2. QUICK SIGNALS
   git diff --stat
   git status --short --branch

3. CLASSIFY
   Is this a slow run, high token run, executor failure, or review loop?
   Jump to the matching section below.

4. SURFACE-ONLY FIRST
   Read metadata.txt if the summary helper is not available.
   Inspect review-notes.md if it exists.

5. LOGS LAST (only if needed)
   Less than 1 KB stderr → skim directly.
   Larger → inspect with tools, do not paste into prompts.
```

The summary helper (`scripts/render-agentops-run-summary.sh <run-id>`) reads
only `metadata.txt` — it never touches raw logs. Output includes model,
prompt size, duration, stdout/stderr sizes, exit code, and artifact path.

## Local run metadata and artifacts

All local run artifacts live under `.agentops-runs/<run-id>/` (gitignored).

### Artifact directory

| File | Purpose | Prompt-safe? |
|------|---------|--------------|
| `metadata.txt` | Compact key=value run metadata | Yes — always safe |
| `executor-prompt.md` | Copy of the prompt sent to the executor | No — may be large |
| `executor-stdout.log` | Stdout from the executor process | No — may be large |
| `executor-stderr.log` | Stderr from the executor process | No — may be large |
| `outcome.txt` | Post-review outcome metadata (decision, diff stats, verification exit code) | Yes — always safe |
| `review-notes.md` | Optional parent review notes | Conditional — inspect first |

### Metadata fields (from `metadata.txt`)

```
run_id, task_id, phase, harness, model, prompt_file
prompt_bytes, prompt_lines
started_at, finished_at, duration_seconds
exit_code, stdout_bytes, stderr_bytes
```

These are always safe to paste into prompts. They contain no secrets,
no raw log content, and no model output.

### Quick inspection without raw logs

```bash
# Preferred — reads only metadata.txt
scripts/render-agentops-run-summary.sh <run-id>

# Fallback — manual metadata inspection
cat .agentops-runs/<run-id>/metadata.txt
```

## Operator flows

### Slow run

Checklist (in order):

1. `duration_seconds` in metadata — threshold depends on task, but >120s
   for a docs-only task or >600s for a code task suggests inspection.
2. `prompt_bytes` / `prompt_lines` — was the prompt unusually large?
3. If prompt was reasonable and duration was high, skim `executor-stdout.log`
   for signs of repeated retries, loops, or model indecision.
4. Do **not** paste the full stdout log into a follow-up prompt. Instead
   paste: `duration_seconds`, `prompt_bytes`, `stdout_bytes`, and a
   one-sentence summary of what the executor appeared to spend time on.

### High token / context pressure

Checklist (in order):

1. `prompt_bytes` / `prompt_lines` — is the prompt itself large?
   Compare against typical prompts for the same task type.
2. `stdout_bytes` — did the executor produce a large response?
   Large stdout may mean the model echoed too much context back.
3. `stderr_bytes` — non-trivial stderr may signal tool errors or warnings
   that consumed context.
4. Check whether large diffs or raw logs were pasted into the original
   prompt (inspect `executor-prompt.md` cautiously — only if prompt size
   already looks suspicious).
5. If context pressure is confirmed, the fix is usually **reducing the
   prompt**, not adding debugging output. Remove verbose file contents,
   raw diffs, or log excerpts from the prompt. Use references (file paths,
   line ranges) instead.

**Default prompt-safe payload for context pressure diagnosis:**

```
prompt_bytes: ...
prompt_lines: ...
stdout_bytes: ...
stderr_bytes: ...
duration_seconds: ...
exit_code: ...
```

### Executor failure

Checklist (in order):

1. `exit_code` — non-zero means the executor process itself failed.
2. `stderr_bytes` — if non-zero, stderr likely contains the error.
3. If `stderr_bytes` ≤ 1024, it is safe to skim directly. Extract the
   error message (first/last few lines) rather than pasting the whole file.
4. If `stderr_bytes` > 1024, inspect with `head`/`tail`/`grep` locally.
   Paste **only** the error line(s), not the full log.
5. Common causes (refer to `docs/DEBUGGING.md` for full guidance):
   - Model/provider not found → `exit_code=1`, stderr mentions model
   - Wrapper not executable → `exit_code=126`
   - OpenCode not on PATH → `exit_code=127`
   - Runtime environment mismatch → stderr mentions HOME/config

### Suspicious review loop

Checklist (in order):

1. Check `agentops/results/TASK-xxxx-result.md` for repeated
   revise/review rounds in the decision history.
2. Check `review-notes.md` in the run artifact directory for parent
   review comments that triggered rework.
3. Check `git diff --stat` — large or growing diffs across repeated
   executor invocations for the same task signal a loop.
4. If a loop is confirmed, stop delegating. The parent should:
   - Summarize the current state (diff stat, result notes).
   - Decide whether to accept the best attempt, narrow the scope, or
     close as blocked.
   - Do **not** paste full diffs or logs into a new executor prompt.

## What should not go into model prompts by default

| Do not paste | Use instead |
|--------------|-------------|
| Raw `executor-stdout.log` | `stdout_bytes` from metadata |
| Raw `executor-stderr.log` | `stderr_bytes` + extracted error line |
| Full `executor-prompt.md` | `prompt_bytes` + `prompt_lines` |
| `git diff` output > 100 lines | `git diff --stat` |
| Full file contents | File path + line range reference |
| Hermes session transcripts | Session ID reference (if needed) |
| Any file from `.agentops-runs/` (except `metadata.txt`) | Metadata fields |

If a model explicitly requests a specific log excerpt, provide only the
minimum relevant lines — never the full artifact.

## Hermes session / log inspection

Hermes maintains session data and logs locally. The exact paths and
commands depend on the Hermes installation and version and should be
verified against your local setup.

What is locally verifiable in this repository:

- The Hermes/OpenCode executor wrapper (`scripts/run-opencode-executor.sh`)
  captures executor run artifacts under `.agentops-runs/`.
- Hermes profile configuration lives at `~/.hermes/profiles/coder/`.
- Hermes runtime environment variables (`OPENCODE_XDG_CONFIG_HOME`,
  `OPENCODE_XDG_DATA_HOME`) are documented in `docs/HERMES-CODER-ENV-RUNTIME.md`
  and `docs/HERMES-OPENCODE-RUNTIME.md`.

For session-level inspection (e.g. viewing a past Hermes conversation
transcript), consult your local Hermes installation documentation.
Session transcripts are **not** prompt-safe by default — they may be
large and contain full model exchanges.

## OpenCode stats

OpenCode may provide per-session or per-invocation statistics such as
token counts, model latency, tool call counts, and context window usage.

These stats are available through `opencode`'s own output or session
metadata. The exact commands and format depend on your OpenCode version.

When available, OpenCode stats are prompt-safe in compact form:

- Token count summaries (not full token lists)
- Tool call counts
- Context window utilization percentage

Do **not** paste raw OpenCode session dumps or token-by-token traces
into model prompts.

## Prometheus textfile export

For trend-oriented local dashboards, export aggregate metrics from run metadata:

```bash
scripts/export-agentops-prometheus-metrics.sh <output.prom>
```

The exporter reads `.agentops-runs/*/metadata.txt` and writes Prometheus
textfile collector output to the explicit path you provide. It exports only
aggregate metadata-derived gauges for the current local artifact set; it does
not export raw prompts, stdout, stderr, logs, `run_id`, or `task_id` labels.

Example local paths:

```bash
scripts/export-agentops-prometheus-metrics.sh .agentops-runs/agentops.prom
scripts/export-agentops-prometheus-metrics.sh /tmp/agentops.prom
```

Use system Node Exporter collector paths only when your local Prometheus setup
expects them; the script does not assume or hardcode those paths.

## When to inspect full logs manually

Inspect full logs manually when:

- Metadata signals (`exit_code`, `stderr_bytes`) indicate a failure but
  the extracted error line is not enough to diagnose it.
- A review loop persists and surface-level signals (diff stat, result
  notes) do not explain why.
- You need to understand *how* an executor reached a particular file edit.

When inspecting full logs:

1. Keep the inspection local — use `grep`, `head`, `tail`, or an editor.
2. Summarize your findings in one or two sentences before sharing with
   a model or another operator.
3. Never pipe raw logs directly into a model prompt.

## Cross-references

- `docs/DEBUGGING.md` — general troubleshooting for common failures
  (model not found, wrong branch, dirty tree, verification failures).
- `docs/RUN-AUDIT.md` — local run audit contract, metadata field
  definitions, safety boundary.
- `docs/HERMES-OPENCODE-RUNTIME.md` — Hermes/OpenCode runtime env setup.
- `docs/GRAFANA-AGENTOPS.md` — Grafana dashboard specification for
  executor run observability using Prometheus textfile metrics.
