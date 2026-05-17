# TASK-0093 - Improve installer support for coder-profile skill discovery

## Status

ready

## Goal

Implement the smallest installer and documentation fix needed so that the packaged
`hermetic-coding-orchestrator` skill is discoverable and usable from the `coder`
Hermes profile, not only from the default Hermes profile.

The task must preserve the existing skill name, slash invocation, audit marker,
and AgentOps runtime behavior.

## Background / why now

`skill-00-package-hermetic-orchestrator` packaged the existing
`skills/hermetic-coding-orchestrator/` directory as a Hermes-native local skill.
After running the installer and restarting Hermes, the skill was verified to work
from the default Hermes profile:

```text
/hermetic-coding-orchestrator
USING_SKILL: hermetic-coding-orchestrator
[Skill directory: /home/splinter/.hermes/skills/hermetic-coding-orchestrator]
```

However, the same slash command failed in the normal `coder` workflow with:

```text
Unknown command: /hermetic-coding-orchestrator
```

This confirms a real installer/profile discovery gap:

```text
The skill package exists and works in default Hermes, but it is not reliably
available from the coder profile after running the install script.
```

The next slice should fix only that gap.

## Problem statement

The Hermetic Agentarium workflow is intended to run through the `coder` profile,
because that profile carries the coding-oriented `SOUL.md`, provider/runtime
environment, OpenCode-related environment preservation, and AgentOps workflow
rules.

Currently, installation is not proven to make `/hermetic-coding-orchestrator`
available from `hermes --profile coder`.

The installer must reliably install or wire the skill so that the `coder` profile
can discover it after restart, without changing the skill's runtime behavior.

## Smallest useful slice

Inspect and minimally adjust `scripts/install-coder-profile.sh` and install docs
so that:

- default Hermes can still see the skill
- the `coder` profile can also see and invoke the skill
- the install path/profile wiring is documented
- the fix is idempotent
- no runtime helper behavior changes are made

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `scripts/install-coder-profile.sh`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `skills/hermetic-coding-orchestrator/README.md`
- `profiles/coder/SOUL.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `agentops/tasks/done/TASK-0092-package-hermetic-orchestrator-skill.md`
- `agentops/results/TASK-0092-package-hermetic-orchestrator-skill-result.md`

## Write scope

Allowed:

- `scripts/install-coder-profile.sh`
- `docs/INSTALL.md`

Optional, only if needed for a narrow cross-reference:

- `docs/DOCUMENTATION-MAP.md`
- `skills/hermetic-coding-orchestrator/README.md`

Do not modify runtime helper scripts or task lifecycle helpers in this slice.

## Requirements

- Preserve existing installer behavior outside the confirmed profile-discovery gap.
- Keep the installer idempotent.
- Preserve the existing skill name:

```text
hermetic-coding-orchestrator
```

- Preserve the slash invocation:

```text
/hermetic-coding-orchestrator
```

- Preserve the audit marker:

```text
USING_SKILL: hermetic-coding-orchestrator
```

- Ensure the skill is discoverable from the `coder` profile after installation and restart.
- Document where the skill is installed or how the `coder` profile is wired to discover it.
- Do not change OpenCode executor behavior.
- Do not change AgentOps task lifecycle helper behavior.
- Do not introduce `manifest.json`.
- Do not redesign the skill package layout unless inspection proves the current layout is incompatible with Hermes profile discovery.

## Design decision to resolve during implementation

Choose the smallest safe installer approach after inspecting actual Hermes profile/skill discovery behavior.

Candidate approaches:

1. Copy or sync the skill into a Hermes-discoverable global skill location used by the `coder` profile.
2. Wire the `coder` profile config to include the repo skill directory or installed skill directory.
3. Preserve the current default-Hermes install location and add the missing profile-specific discovery configuration.

The chosen approach must be documented in `docs/INSTALL.md`.

Prefer the approach that is:

- simplest
- idempotent
- least surprising for users
- least likely to create divergent copies of the skill
- compatible with the existing `coder` profile workflow

## Non-goals

- No skill rename.
- No change to `/hermetic-coding-orchestrator`.
- No change to `USING_SKILL: hermetic-coding-orchestrator`.
- No runtime helper behavior changes.
- No lifecycle helper changes.
- No OpenCode executor behavior changes.
- No observability packaging work.
- No `agentops/` to `.agentops/` migration.
- No broad profile redesign.
- No secrets handling changes.

## Promotion decision

Decision: promote_to_ready

Reason:
A real installer/profile discovery gap has now been observed: the skill works
from default Hermes, but `/hermetic-coding-orchestrator` is not available in the
normal `coder` profile session after running the installer and restarting.

Next action:
Promote this task to `ready/` and implement the smallest installer/docs fix that
makes the skill discoverable from the `coder` profile.

## Promotion criteria

This task can be promoted to ready when:

- the observed failure is recorded as the concrete trigger
- the goal is implementation-oriented
- open questions are resolved or moved into requirements/design decisions
- verification commands are concrete and do not mask failures
- write scope remains limited to installer/docs files

## Verification

Required verification:

```bash
git status --short --branch
git diff --stat
bash -n scripts/install-coder-profile.sh
```

After running the installer:

```bash
./scripts/install-coder-profile.sh
```

Verify default Hermes skill discovery if supported by the local CLI:

```bash
hermes skills list | grep 'hermetic-coding-orchestrator'
```

Verify coder-profile skill discovery if supported by the local CLI:

```bash
hermes --profile coder skills list | grep 'hermetic-coding-orchestrator'
```

Verify slash invocation manually or with the available Hermes CLI mode:

```text
/hermetic-coding-orchestrator Summarize your workflow rules in 3 bullets.
```

Expected response includes:

```text
USING_SKILL: hermetic-coding-orchestrator
```

Run lifecycle check:

```bash
scripts/check-agentops-lifecycle.sh
```

## Optional observations

If the local Hermes CLI does not support non-interactive skill listing or chat
invocation for profiles, record that as an observation rather than masking the
failure with `|| true`.

Example wording for a result note:

```text
Could not run `hermes --profile coder skills list` because this Hermes version
or local CLI mode does not expose that command. Manual interactive verification
was used instead.
```

Do not use `|| true` in required verification commands.

## Accept criteria

- Installer behavior remains idempotent.
- The skill remains installed or wired in a Hermes-discoverable location.
- `/hermetic-coding-orchestrator` works from the `coder` profile after install/restart.
- Documentation explains the install/discovery path.
- Skill name, invocation, and audit marker are unchanged.
- No unrelated runtime helper behavior changes are made.
- Verification commands are recorded without masking failures.

## Return format

```text
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
```

## Notes

This task was originally conditional, but it is no longer merely hypothetical.
The observed behavior confirms the gap:

- default Hermes can load the skill
- `coder` profile did not recognize the slash command in the user's normal workflow

Keep the fix narrow. If inspection reveals that the correct fix requires a
larger profile/skill architecture decision, report `blocked` or defer the larger
work to a follow-up task rather than broadening this slice.

Potential follow-up idea, not part of this task:

```text
agentops-structure-bootstrap
```

Goal for that future task:
Ensure a fresh clone has or can initialize the required AgentOps directory
structure, such as:

```text
agentops/tasks/planned/
agentops/tasks/ready/
agentops/tasks/running/
agentops/tasks/review/
agentops/tasks/done/
agentops/results/
agentops/templates/
```

Do not combine that with this installer/profile discovery fix.
