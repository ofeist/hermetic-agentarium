# AgentOps Ideas

Raw inbox for unrefined AgentOps ideas, bug suspicions, follow-ups, and one-liners.

This file is intentionally lightweight and informal.

Items here are not ready tasks.
Do not execute directly from this file.

## Inbox

- document the canonical Hermes/coder minimal execution prompt in SOUL or SKILL
- investigate coordinator model / Codex subscription options
- maybe add a helper for result summary creation
- maybe add a lifecycle closeout helper for ready/review/done/result movement
- reduce historical lifecycle warnings by adding result notes or an explicit historical-warning allowlist
- bug? remember that untracked files do not appear in plain `git diff --stat`
- later: define planned task promotion format
- later: add ready task template
- later: add planned task template
- later: decide whether planned tasks need a template or only a loose format
- later: consider whether task closeout should move ready/review files automatically or stay manual

## Observability plan

Goal: make the Hermes / coder / OpenCode AgentOps workflow observable without
increasing model context or token usage.

Core principle:

> Observe to local files first. Export later. Never paste full observability
> logs into model prompts by default.

Why this matters:

- one task may involve Hermes parent context, OpenCode executor prompt,
  executor stdout/stderr, review prompt, git diff/test output, repeated
  revise/review rounds, and long-running session history
- we need to know where time, prompt size, output size, and token pressure are
  coming from

Existing foundation:

- ready task files under `agentops/tasks/ready/`
- bounded executor prompt generation
- OpenCode invocation via `scripts/run-opencode-executor.sh`
- local run artifacts under `.agentops-runs/<run-id>/`
- independent review via `scripts/review-executor-result.sh`
- explicit review outcomes: accept, revise, revert, no-op / nothing to accept, blocked

Suggested task sequence:

### TASK-0072 — Add AgentOps executor run metadata baseline

Goal: extend local executor run metadata without changing prompt content.

Scope:

- `scripts/run-opencode-executor.sh`
- `docs/RUN-AUDIT.md`

Capture in `.agentops-runs/<run-id>/metadata.txt`:

- `run_id`
- `task_id`, if derivable
- `phase=executor`
- `harness=OpenCode`
- `model` from runner configuration, for example `AGENTOPS_EXECUTOR_MODEL`
- `prompt_file`
- `prompt_bytes`
- `prompt_lines`
- `started_at`
- `finished_at`
- `duration_seconds`
- `exit_code`
- `stdout_bytes`
- `stderr_bytes`

Non-goals:

- no `events.tsv`
- no review decision
- no Prometheus
- no token/cost estimates
- no dashboard
- no prompt expansion

### TASK-0073 — Add AgentOps run summary helper

Goal: add a local summary command for one run.

Scope:

- add `scripts/render-agentops-run-summary.sh`
- read `.agentops-runs/<run-id>/metadata.txt`
- print a compact human-readable summary

Example output:

```text
TASK-0072

model: deepseek/deepseek-v4-pro
prompt: 18.4 KB / 412 lines
duration: 94s
stdout: 8.1 KB
stderr: 0 KB
exit code: 0
artifacts: .agentops-runs/TASK-0072/
```

Non-goals:

- no metrics exporter
- no dashboard

### TASK-0074 — Document AgentOps observability workflow

Goal: document how to inspect run metadata and avoid token-heavy debugging.

Scope:

- add `docs/RUN-OBSERVABILITY.md`
- explain metadata files and local artifacts
- explain what should and should not go into prompts
- explain Hermes session/log inspection
- explain recommended debugging flow

Core rule:

> Full logs are for humans and local debugging. Model prompts receive only
> compact summaries unless explicitly requested.

### TASK-0075 — Add Prometheus textfile export

Goal: export selected AgentOps metrics in Prometheus textfile format.

Scope:

- add `scripts/export-agentops-prometheus-metrics.sh`
- read local metadata
- write a `.prom` metrics file
- document Node Exporter textfile collector usage

Candidate metrics:

- `agentops_executor_prompt_bytes`
- `agentops_executor_stdout_bytes`
- `agentops_executor_stderr_bytes`
- `agentops_executor_duration_seconds`
- `agentops_executor_runs_total`

Notes:

- keep label cardinality controlled
- avoid high-cardinality labels unless this remains local-only
- token and cost metrics should stay estimates unless Hermes/OpenCode exposes
  reliable machine-readable usage data

### TASK-0076 — Add Grafana dashboard draft

Goal: create a first Grafana dashboard for AgentOps task observability.

Scope:

- dashboard JSON or documentation
- panels for executor duration, prompt size, output size, result ratio, and model usage

Non-goals:

- no complex alerting
- no long-running exporter service unless textfile export proves insufficient

Final target architecture:

```text
Hermes / coder
  -> AgentOps scripts
  -> .agentops-runs/<run-id>/metadata.txt
  -> local summary helper
  -> Prometheus textfile export or /metrics exporter
  -> Prometheus
  -> Grafana
```

Invariants:

- Observability must not significantly increase token usage.
- Raw logs stay local by default.
- Prompts should contain paths, counts, hashes, and short summaries, not full logs.
- Full stdout/stderr should only be read when debugging.
- Prometheus/Grafana are export layers, not the first source of truth.
- Local `.agentops-runs/` artifacts remain the canonical run record.
- The first implementation should be shell-script simple.

## Planned task template idea

Goal: add a lightweight `agentops/templates/PLANNED-TASK-TEMPLATE.md` so ideas
can be promoted into planned tasks without pretending they are executor-ready.

Proposed sections:

- `# TASK-xxxx — Short planned task title`
- `## Status`
- `## Goal`
- `## Background / why now`
- `## Problem statement`
- `## Smallest useful slice`
- `## Non-goals`
- `## Open questions`
- `## Expected output`
- `## Promotion criteria`
- `## Candidate ready task notes`
- `## Notes`

Planned tasks should avoid executor/model instructions and detailed verification
until they are promoted to `ready/`.

## Planned task naming

Planned tasks do not receive `TASK-XXXX` IDs.

Use soft workstream-local numbering for planned tasks instead of assigning
`TASK-XXXX` IDs too early. This enables changing priorities while in the
planning phase.

Use:

```text
<area>-<local-sequence>-<short-slug>.md
```

Examples:

- `observability-01-executor-run-metadata.md`
- `observability-02-run-summary-helper.md`
- `lifecycle-01-historical-warning-baseline.md`
- `templates-01-planned-task-template.md`

Rules:

- `<area>` identifies the workstream.
- `<local-sequence>` is a soft suggested order inside that workstream.
- `<short-slug>` describes the task.
- Planned sequence numbers do not reserve execution order.
- Assign `TASK-XXXX` only when promoting a planned task to `ready/`.

## Hermes/coder collection prompt helper idea

Goal: formalize the prompt used to hand a ready AgentOps task to the
Hermes/coder orchestrator.

Problem:

- ready tasks include a collection prompt, but humans still copy/paste and
  adapt it manually
- repeated prompt text increases the chance of drift
- missing details can break the workflow, especially:
  - not invoking `/hermetic-coding-orchestrator`
  - running executor work on `main`
  - losing `OPENCODE_XDG_CONFIG_HOME`, `OPENCODE_XDG_DATA_HOME`, or
    `AGENTOPS_EXECUTOR_MODEL`
  - accidentally allowing model fallback
  - committing from the executor instead of returning results for review

Possible task:

- add a helper such as `scripts/render-hermes-coder-collection-prompt.sh`
- input: `agentops/tasks/ready/TASK-xxxx-slug.md`
- output: the canonical Hermes/coder collection prompt
- optionally validate that the task is under `agentops/tasks/ready/`
- optionally include task-specific extra requirements from the task body if a
  stable marker is introduced later

Initial canonical prompt shape:

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-XXXX-short-title.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- create/switch to an appropriate task branch
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME, OPENCODE_XDG_DATA_HOME, and AGENTOPS_EXECUTOR_MODEL
- use the runner-configured executor model
- do not silently fallback to another model
- do not commit
- independently verify the result

Return:
Plan:
Implementation:
Verification:
Review:
Changed files:
Uncertainty:
```

Non-goals:

- no model hardcoding in prompts
- no executor behavior changes
- no automatic commit/push
- no replacement for the review prompt flow

Why:

The collection prompt is part of the workflow contract. It should be generated
from one canonical source instead of being manually reconstructed each time.

## Promotion path

When an idea becomes actionable, promote it gradually:

    IDEAS.md
      -> agentops/tasks/planned/
      -> agentops/tasks/ready/
      -> agentops/tasks/running/
      -> agentops/tasks/review/
      -> agentops/tasks/done/
      -> agentops/results/

Meaning:

- `IDEAS.md` = do not forget this
- `planned/` = think this through
- `ready/` = executor can do this
- `done/` + `results/` = reviewed outcome

Keep this simple. Do not turn this file into a Jira clone.
