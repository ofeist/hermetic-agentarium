# TASK-0094 - Document skill activation and troubleshooting flow

## Status

ready

## Goal

Define a focused documentation slice for verifying Hermes skill activation and
troubleshooting missing-skill issues after installation, especially for the
`coder` profile.

## Background / why now

`skill-00` packaged `skills/hermetic-coding-orchestrator/` as a Hermes-native
local skill package.

`skill-01` then improved installer support after manual validation showed an
important profile-specific behavior:

- default `hermes` can load the skill from the global Hermes skill path
- `hermes --profile coder` may require the skill to exist under the coder
  profile-local skill path

The current operational expectation is that installation preserves the skill in
both relevant locations:

```text
~/.hermes/skills/hermetic-coding-orchestrator/
~/.hermes/profiles/coder/skills/hermetic-coding-orchestrator/
```

This task documents how operators verify both activation paths and troubleshoot
`Unknown command` failures.

## Problem statement

Without explicit activation checks, users can install the skill but fail to
confirm visibility, slash invocation behavior, or expected marker output.

The most important real-world failure mode is:

```text
Unknown command: /hermetic-coding-orchestrator
```

This can happen when the skill exists for default Hermes but is not installed or
discoverable for the `coder` profile.

## Smallest useful slice

Add concise activation/troubleshooting docs for core usage:

- expected install locations
- default Hermes activation check
- `coder` profile activation check
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
- `scripts/install-coder-profile.sh`
- `agentops/tasks/done/TASK-0092-package-hermetic-orchestrator-skill.md`
- `agentops/results/TASK-0092-package-hermetic-orchestrator-skill-result.md`
- `agentops/tasks/done/TASK-0093-improve-installer-support-if-needed.md`
- `agentops/results/TASK-0093-improve-installer-support-if-needed-result.md`

## Write scope

- `skills/hermetic-coding-orchestrator/README.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`

## Requirements

- Document the expected global Hermes skill path:

```text
~/.hermes/skills/hermetic-coding-orchestrator/
```

- Document the expected coder profile-local skill path:

```text
~/.hermes/profiles/coder/skills/hermetic-coding-orchestrator/
```

- Include a default Hermes activation check.
- Include a `hermes --profile coder` activation check.
- Include `/hermetic-coding-orchestrator` invocation example.
- Include expected marker output:

```text
USING_SKILL: hermetic-coding-orchestrator
```

- Explain that slash invocation is the practical acceptance test.
- Explain that `hermes skills list` may be useful, but should not be the only
  verification mechanism if CLI/list behavior differs by mode.
- Document the `Unknown command` failure mode and the fastest checks to diagnose it.
- Document that the installer should be rerun after changing install paths or profile wiring.
- Do not change installer behavior in this task.
- Do not change runtime helper behavior in this task.

## Documentation ownership decision

Use this split:

- `docs/INSTALL.md` gets the short operator checklist.
- `skills/hermetic-coding-orchestrator/README.md` gets the fuller activation and
  troubleshooting section.
- `docs/DOCUMENTATION-MAP.md` points readers to both.

## Suggested troubleshooting content

Document a short flow similar to this:

```bash
test -f ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md

test -f ~/.hermes/profiles/coder/skills/hermetic-coding-orchestrator/SKILL.md

hermes
# then invoke:
# /hermetic-coding-orchestrator

hermes --profile coder
# then invoke:
# /hermetic-coding-orchestrator
```

Expected successful invocation includes:

```text
USING_SKILL: hermetic-coding-orchestrator
```

If `hermes` works but `hermes --profile coder` returns `Unknown command`, check
whether the skill exists under the coder profile-local skill path and rerun:

```bash
./scripts/install-coder-profile.sh
```

## Non-goals

- No skill rename.
- No installer behavior changes.
- No runtime helper behavior changes.
- No lifecycle helper changes.
- No observability packaging changes.
- No `agentops/` to `.agentops/` migration.
- No AgentOps folder-structure bootstrap work.

## Open questions

None blocking promotion.

Resolved documentation ownership:

- short checklist in `docs/INSTALL.md`
- full troubleshooting in `skills/hermetic-coding-orchestrator/README.md`
- pointers in `docs/DOCUMENTATION-MAP.md`

## Promotion decision

Decision: promote_to_ready

Reason:
`skill-00` and `skill-01` have landed, and the activation behavior is now
understood well enough to document. The important operational distinction is
that default Hermes and the `coder` profile may require separate skill install
locations. This task should document the verified behavior and the troubleshooting
flow for `Unknown command` failures.

Next action:
Promote this task to `ready/` as a docs-only slice.

## Promotion criteria

This task can be promoted to ready when:

- `skill-00` is complete
- `skill-01` is complete
- final install paths are known
- documentation ownership is decided
- verification examples are concrete
- no installer changes are included in this task

## Verification

Planning-only verification:

```bash
git status --short --branch
git diff --stat
```

Implementation verification when promoted:

```bash
git status --short --branch
git diff --stat
test -f skills/hermetic-coding-orchestrator/README.md
test -f docs/INSTALL.md
test -f docs/DOCUMENTATION-MAP.md
grep -q '/hermetic-coding-orchestrator' skills/hermetic-coding-orchestrator/README.md
grep -q 'USING_SKILL: hermetic-coding-orchestrator' skills/hermetic-coding-orchestrator/README.md
grep -q '~/.hermes/profiles/coder/skills/hermetic-coding-orchestrator' skills/hermetic-coding-orchestrator/README.md
grep -q '~/.hermes/skills/hermetic-coding-orchestrator' docs/INSTALL.md
scripts/check-agentops-lifecycle.sh
```

Manual verification guidance to document, not necessarily execute in CI:

```text
1. Run ./scripts/install-coder-profile.sh
2. Start default Hermes and invoke /hermetic-coding-orchestrator
3. Start hermes --profile coder and invoke /hermetic-coding-orchestrator
4. Confirm output includes USING_SKILL: hermetic-coding-orchestrator
```

## Accept criteria

- Activation and troubleshooting steps are explicit and runnable.
- Docs clearly distinguish default Hermes activation from `coder` profile activation.
- Expected global and profile-local skill paths are documented.
- Marker and slash invocation expectations are documented.
- `Unknown command` troubleshooting is documented.
- Docs are consistent across README and install docs.
- Documentation map points to the correct docs.
- No installer, runtime helper, lifecycle helper, rename, or observability changes are made.

## Hermes/coder collection prompt

Synchronized copy policy:
- This block is an ergonomics copy of the canonical prompt in
  `skills/hermetic-coding-orchestrator/SKILL.md`
  (`### Canonical ready task invocation prompt`).
- Keep wording aligned with the canonical SKILL prompt and rendered helper output
  (`scripts/render-collection-prompt.sh`).
- Replace `TASK-xxxx-short-slug.md` with the actual ready task path.

```text
/hermetic-coding-orchestrator

Execute AgentOps ready task:

agentops/tasks/ready/TASK-0094-document-skill-activation-troubleshooting.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Workflow requirements:
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
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:

Also note: task-specific paths, verification commands, or constraints can be added below this prompt when needed
```

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

This task intentionally follows the installer/profile-local skill fix. It should
only document the final activation and troubleshooting behavior.

Recommended follow-up order after this task:

- `agentops-structure-bootstrap`
- `skill-04-rename-hermetic-orchestrator-skill`
- `skill-03-package-optional-agentops-observability`
- `agentops-root-migrate-to-dot-agentops`

Observability packaging remains intentionally deferred because the expected
operator experience and package boundary still need more design work.

Assign a TASK-XXXX ID only when promoting to `ready/`.
