# Local Executor Run Audit

This document defines the local audit/debug contract for Hermes/OpenCode executor runs.

The goal is to make executor runs easier to inspect without committing raw prompts, logs, or model output to the repository.

## Status

Design only.

This document defines the target contract. It does not imply that wrapper capture is implemented yet.

## Local run directory

Local executor run artifacts should be stored under:

    .agentops-runs/<run-id>/

Examples:

    .agentops-runs/TASK-0038/
    .agentops-runs/TASK-0039-20260503-143000/
    .agentops-runs/manual-20260503-143000/

The `.agentops-runs/` directory is local-only and must remain gitignored.

## Expected files

A local run directory may contain:

    executor-prompt.md
    executor-stdout.log
    executor-stderr.log
    metadata.txt
    review-notes.md

## File meanings

- `executor-prompt.md` — copy of the prompt sent to the executor.
- `executor-stdout.log` — stdout captured from the executor process.
- `executor-stderr.log` — stderr captured from the executor process.
- `metadata.txt` — minimal run metadata.
- `review-notes.md` — optional parent review notes.

## Metadata

`metadata.txt` should stay simple and human-readable.

Suggested fields:

    run_id=TASK-xxxx
    harness=OpenCode
    model=deepseek/deepseek-chat
    prompt_file=/tmp/TASK-xxxx.prompt.md
    started_at=<timestamp>
    finished_at=<timestamp>
    exit_code=<number>

Do not store secrets, tokens, auth file contents, or private configuration values in metadata.

## Safety boundary

Raw prompts, stdout/stderr, and model responses may contain sensitive context.

Do not commit files from `.agentops-runs/`.

Do not store or copy:

- `.env` contents
- API keys
- provider tokens
- SSH keys
- OpenCode auth files
- private config dumps
- full request/response dumps that may contain secrets

If sensitive data appears in a local run log, delete the local log or redact it before sharing outside the machine.

## Committed summaries

Safe summaries belong under:

    agentops/results/TASK-xxxx-result.md

A committed result summary should include only reviewed, safe information such as:

- decision
- changed files
- verification commands
- high-level notes
- known risks or follow-ups

It should not include raw executor logs.

## Non-goals

This design does not introduce:

- wrapper implementation
- stdout/stderr capture
- smoke tests
- JSON schema
- database
- web UI
- lifecycle automation
- executor abstraction
- committed raw logs

## Future implementation

A future implementation may add optional run capture to:

    scripts/run-opencode-executor.sh

That implementation should preserve existing behavior by default and only add local audit files under `.agentops-runs/`.
