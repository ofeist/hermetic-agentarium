# observability-03 — Document AgentOps observability workflow

## Status

planned

## Goal

Document how to inspect AgentOps run metadata and avoid token-heavy debugging.

## Background / why now

The workflow already has Hermes sessions/logs, OpenCode stats, local
`.agentops-runs/` artifacts, and AgentOps result notes.

The missing piece is a single operator-facing guide that explains when to use
each signal and what not to paste into prompts.

## Problem statement

When runs are slow or token-heavy, it is not obvious whether to inspect Hermes
sessions, Hermes logs, OpenCode stats, local run metadata, stdout/stderr logs,
or git diffs.

Without guidance, users may paste large logs/diffs into model prompts and make
the problem worse.

## Smallest useful slice

Add `docs/RUN-OBSERVABILITY.md` covering:

- metadata files and local artifacts
- what should and should not go into prompts
- Hermes session/log inspection
- OpenCode stats
- recommended debugging flow
- when to inspect full logs manually

## Executor

Harness: TBD
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

Notes:

- Fill this in only when the task becomes ready.
- Keep model selection out of the task body unless there is a specific reason.

## Read scope

TBD

Likely candidates:

- `agentops/IDEAS.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `profiles/coder/SOUL.md`
- `docs/`
- `scripts/run-opencode-executor.sh`
- `scripts/render-agentops-run-summary.sh`, if observability-02 has landed

## Write scope

TBD

Likely candidates:

- `docs/RUN-OBSERVABILITY.md`
- `docs/DOCUMENTATION-MAP.md`, if it exists and needs an entry
- `docs/DEBUGGING.md`, only if the repo already uses it for this topic

## Requirements

TBD

When ready, this task should require:

- Add `docs/RUN-OBSERVABILITY.md`.
- Explain local run metadata and artifact locations.
- Explain what should not be pasted into model prompts by default.
- Explain how to inspect Hermes session/log information available in the local
  tooling.
- Explain how to inspect OpenCode stats if available.
- Explain a recommended debugging flow for slow or token-heavy runs.
- Keep examples compact and avoid raw log dumps.
- Link or reference the run summary helper if observability-02 has landed.

## Non-goals

- No new scripts.
- No Prometheus export.
- No Grafana dashboard.
- No raw log examples that could encourage prompt bloat.
- No claims about Hermes commands that are not locally verified.

## Open questions

- Which Hermes commands should be documented as canonical for this repo?
- Should the doc reference `/usage`, `/stats`, or both, given version-specific
  Hermes behavior?
- Should the doc wait until observability-01 and observability-02 exist?
- Should `coder --resume` vs `hermes --resume` session behavior be documented
  here or in a separate debugging note?

If these are resolved before promotion, write:

```text
None.
```

## Verification

TBD

Likely commands:

```bash
test -f docs/RUN-OBSERVABILITY.md
git status --short --branch
git diff --stat
```

Add command checks for any documented script names when ready.

## Accept criteria

TBD

When ready, accept criteria should include:

- `docs/RUN-OBSERVABILITY.md` exists.
- The doc clearly states that raw logs are local by default.
- The doc explains compact summaries, artifact paths, and metrics as the
  default prompt-safe observability payload.
- The doc describes a practical local debugging flow.
- The doc avoids unverified or version-specific command claims unless marked as
  such.
- Diff stays within write scope.

## Promotion decision

Decision: keep_planned

Reason:

This doc can be useful before or after implementation, but the exact commands
and metadata fields should be based on the accepted observability-01 and observability-02
behavior where possible.

Next action:

Promote after deciding whether this should follow observability-01/02 or proceed as
a lightweight principles-first doc.

## Promotion criteria

This task can be promoted to ready when:

- read scope is known
- write scope is known
- open questions are resolved or explicitly marked as blockers
- requirements are concrete
- verification commands are known
- accept criteria are concrete
- non-goals are clear

## Hermes/coder collection prompt

TBD until ready.

When ready, use this shape:

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-XXXX-document-agentops-observability.md

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

## Return format

TBD until ready.

When ready, expected executor return format:

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

Core rule:

> Full logs are for humans and local debugging. Model prompts receive only
> compact summaries unless explicitly requested.
