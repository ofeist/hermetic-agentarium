# skill-01-improve-installer-support-if-needed - Improve installer support only if skill packaging confirms a real gap

## Status

planned

## Goal

Capture a narrow follow-up slice to adjust `scripts/install-coder-profile.sh`
only when `skill-00` proves the installer does not correctly install or preserve
the required skill/profile wiring.

## Background / why now

`skill-00` includes installer inspection and classification. This follow-up
exists only for the case where classification is:

- narrow installer fix needed

If `skill-00` concludes no installer change is needed, this task may be dropped.

## Problem statement

Installer behavior should stay stable, but it must reliably preserve:

- `skills/hermetic-coding-orchestrator/` installation path
- coder profile wiring
- `SOUL.md`/profile linkage required for `/hermetic-coding-orchestrator`

## Smallest useful slice

Implement only the smallest installer fix needed to close a verified gap found
by `skill-00`, with no workflow behavior changes.

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `scripts/install-coder-profile.sh`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `profiles/coder/SOUL.md`
- `docs/INSTALL.md`
- `agentops/tasks/done/TASK-0092-package-hermetic-orchestrator-skill.md`
- `agentops/results/TASK-0092-package-hermetic-orchestrator-skill-result.md`

## Write scope

- `scripts/install-coder-profile.sh`
- `docs/INSTALL.md`
- optional narrow troubleshooting note in `docs/DOCUMENTATION-MAP.md`

## Requirements

TBD

Candidate requirements:

- Preserve existing installer behavior outside the proven gap.
- Keep fix idempotent.
- Keep skill name/invocation/marker unchanged.
- Do not modify runtime helper behavior.

## Non-goals

- No skill rename.
- No runtime helper behavior changes.
- No lifecycle helper changes.
- No observability packaging work.

## Open questions

- What exact installer gap was confirmed by `skill-00`?
- Can docs-only clarification solve it without script changes?

## Promotion decision

Decision: keep_planned

Reason:
This task is conditional on `skill-00` findings and may be unnecessary.

Next action:
Promote only if `skill-00` reports a real installer gap requiring a narrow fix.

## Promotion criteria

- `skill-00` result explicitly reports installer classification `narrow installer fix needed`
- exact failing install path/profile wiring is identified
- write scope is narrowed to minimal files
- verification commands are concrete

## Verification

```bash
git status --short --branch
git diff --stat
```

Add task-specific installer verification when promoted.

## Accept criteria

- Installer fix is limited to proven gap.
- No unrelated workflow behavior changes.
- Verification confirms install/preserve behavior works.

## Notes

This is intentionally conditional and may be discarded if `skill-00` concludes
installer classification is `no change needed` or `docs-only clarification needed`.
