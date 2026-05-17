# skill-02-document-skill-activation-troubleshooting - Document skill activation and troubleshooting flow

## Status

planned

## Goal

Define a focused documentation slice for verifying skill activation and
troubleshooting missing-skill issues after installation.

## Background / why now

After `skill-00` packages the core skill, activation checks and troubleshooting
should be documented in one predictable place for operators using Hermes coder
profiles.

## Problem statement

Without explicit activation checks, users can install the skill but fail to
confirm visibility, slash invocation behavior, or expected marker output.

## Smallest useful slice

Add concise activation/troubleshooting docs for core usage:

- skill visibility check
- slash invocation check
- expected `USING_SKILL` marker
- common failure modes and quick fixes

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `skills/hermetic-coding-orchestrator/README.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `profiles/coder/SOUL.md`

## Write scope

- `skills/hermetic-coding-orchestrator/README.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`

## Requirements

TBD

Candidate requirements:

- Include `hermes skills list` visibility check.
- Include `/hermetic-coding-orchestrator` invocation example.
- Include expected `USING_SKILL: hermetic-coding-orchestrator` marker.
- Document common failure modes and recovery steps.

## Non-goals

- No skill rename.
- No installer behavior changes.
- No runtime helper behavior changes.
- No observability packaging changes.

## Open questions

- Should troubleshooting live primarily in skill README or `docs/INSTALL.md`?

## Promotion decision

Decision: keep_planned

Reason:
Should follow `skill-00` so docs reflect actual packaged installation behavior.

Next action:
Promote after `skill-00` lands.

## Promotion criteria

- `skill-00` is complete
- final install path/flow is known
- doc ownership is decided
- verification examples are concrete

## Verification

```bash
git status --short --branch
git diff --stat
```

## Accept criteria

- Activation and troubleshooting steps are explicit and runnable.
- Docs are consistent across README and install docs.
- Marker and slash invocation expectations are documented.
