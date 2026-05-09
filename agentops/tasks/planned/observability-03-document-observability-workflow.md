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

- a compact recommended operator debugging flow as the main payload
- metadata files and local artifacts
- what should and should not go into prompts
- Hermes session/log inspection, only where locally accurate
- OpenCode stats, only where locally accurate
- when to inspect full logs manually

`docs/RUN-OBSERVABILITY.md` should complement, not replace,
`docs/DEBUGGING.md`.

Policy:

- `docs/DEBUGGING.md` remains the general troubleshooting/debugging entry
  point.
- `docs/RUN-OBSERVABILITY.md` becomes the focused operator guide for AgentOps
  run metadata, artifacts, logs, and token/time pressure.
- If `docs/DEBUGGING.md` exists, add only a short cross-reference there.
- Do not duplicate the same observability content across both files.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `docs/RUN-AUDIT.md`
- `docs/DEBUGGING.md`, if present
- `docs/DOCUMENTATION-MAP.md`, if present
- `scripts/run-opencode-executor.sh`
- `scripts/render-agentops-run-summary.sh`, if present
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/tasks/planned/observability-03-document-observability-workflow.md`

## Write scope

- `docs/RUN-OBSERVABILITY.md`
- `docs/DOCUMENTATION-MAP.md`, if it exists and needs an entry
- `docs/DEBUGGING.md`, only for a short cross-reference if it exists

## Requirements

- Add `docs/RUN-OBSERVABILITY.md`.
- Make the recommended debugging flow the centerpiece.
- Cover these operator flows:
  - slow run: check `duration_seconds`, executor metadata, then logs only if
    needed
  - high token/context pressure: check `prompt_bytes`, `prompt_lines`,
    `stdout_bytes`, `stderr_bytes`, and whether diffs/logs were pasted into
    prompts
  - executor failure: check `exit_code`, `stderr_bytes`, then local stderr log
    only if needed
  - suspicious review loop: check task/result notes, diff size, and repeated
    revise/review rounds
- Explain local run metadata and artifact locations.
- Explain what should not be pasted into model prompts by default.
- Explain how to inspect Hermes session/log information available in the local
  tooling.
- Explain how to inspect OpenCode stats if available.
- Keep examples compact and avoid raw log dumps.
- Link or reference `scripts/render-agentops-run-summary.sh` only if it exists.
- If `docs/DEBUGGING.md` exists, add only a short cross-reference there.
- Do not duplicate the same observability content across `docs/DEBUGGING.md`
  and `docs/RUN-OBSERVABILITY.md`.

## Non-goals

- No new scripts.
- No Prometheus export.
- No Grafana dashboard.
- No raw log examples that could encourage prompt bloat.
- No claims about Hermes commands that are not locally verified.

## Open questions

None.

Resolved:

- `docs/RUN-OBSERVABILITY.md` complements `docs/DEBUGGING.md`; it does not
  replace it.
- `docs/DEBUGGING.md` remains the general troubleshooting/debugging entry
  point.
- `docs/RUN-OBSERVABILITY.md` is the focused operator guide for AgentOps run
  metadata, artifacts, logs, and token/time pressure.
- If `docs/DEBUGGING.md` exists, add only a short cross-reference there.
- Do not duplicate the same observability content across both files.
- This can land before the run summary helper if references to that helper are
  conditional.
- Do not document Hermes commands as canonical unless they are locally verified.

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
- The recommended debugging flow is the centerpiece of the doc.
- The doc clearly states that raw logs are local by default.
- The doc explains compact summaries, artifact paths, and metrics as the
  default prompt-safe observability payload.
- The doc covers slow run, high token/context pressure, executor failure, and
  suspicious review loop flows.
- `docs/DEBUGGING.md` is only cross-referenced, not duplicated, if it exists.
- The doc avoids unverified or version-specific command claims unless marked as
  such.
- Diff stays within write scope.

## Promotion decision

Decision: promote_to_ready

Reason:

The scope is clear and can land before the run summary helper as long as helper
references are conditional. The doc should center the operator debugging flow
and avoid duplicating `docs/DEBUGGING.md`.

Next action:

Promote after these planning edits.

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
- use or create a task-specific worktree and branch
- do not switch the main planning worktree away from main
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
