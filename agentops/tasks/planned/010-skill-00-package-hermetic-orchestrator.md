# skill-00-package-hermetic-orchestrator - Package hermetic orchestrator as a Hermes-native skill

## Status

planned

## Goal

Plan the packaging work needed to turn `skills/hermetic-coding-orchestrator/`
from a repo-local skill file into a proper Hermes-native local skill package
without changing the existing skill name, invocation contract, or AgentOps
runtime behavior.

## Background / why now

`agentops/IDEAS.md` captures the need to package
`skills/hermetic-coding-orchestrator/` as a Hermes-native skill. The current
skill is operationally useful, but it needs clearer package documentation,
install guidance, and verification steps.

Official Hermes skill creation guidance confirms that a normal/local Hermes
skill is primarily:

```text
~/.hermes/skills/<category>/<skill-name>/SKILL.md
```

The required entrypoint is `SKILL.md`, and the package metadata contract for
this slice is the YAML frontmatter in `SKILL.md`.

Packaging should make installation and verification explicit while preserving
the existing slash invocation and audit marker:

- `/hermetic-coding-orchestrator`
- `USING_SKILL: hermetic-coding-orchestrator`

## Problem statement

The current skill has a valid `SKILL.md` entrypoint, but the package boundary,
install path, and verification procedure are not documented as a clean
Hermes-native local skill package.

Without scope narrowing, implementation risks mixing core packaging,
observability packaging, installer rewrites, docs reconciliation, runtime
behavior changes, and future rename work into one large change.

## Smallest useful slice

Create a core-packaging-only plan and then implement the smallest useful
documentation/package metadata update that preserves current behavior:

- keep the current skill name and invocation unchanged
- treat `SKILL.md` frontmatter as the Hermes skill metadata contract
- add or improve README/install/verification docs around the existing `SKILL.md`
- do not add `manifest.json` unless official Hermes docs or Hermes CLI behavior requires it
- keep observability packaging as a follow-up task
- do not rename the skill in this slice

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/IDEAS.md`
- `agentops/USAGE.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `scripts/install-coder-profile.sh`
- `scripts/render-collection-prompt.sh`
- `.gitignore`

## Write scope

Core packaging implementation should be limited to:

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `skills/hermetic-coding-orchestrator/README.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`

Optional write scope only if needed:

- `scripts/install-coder-profile.sh`

Only modify `scripts/install-coder-profile.sh` if inspection proves the current
installer cannot install or preserve the skill layout or coder profile wiring
required for `/hermetic-coding-orchestrator`.

Do not modify task lifecycle helpers or executor helpers in this slice.

## Installer handling

`scripts/install-coder-profile.sh` is not part of the Hermes-native skill
package metadata contract, but it may be part of the Hermetic Agentarium install
contract.

For this slice:

- inspect the installer
- classify current installer behavior as one of: no change needed, docs-only clarification needed, or narrow installer fix needed
- document whether it already installs or preserves the skill directory, coder profile, `SOUL.md`/profile wiring, and required setup for `/hermetic-coding-orchestrator`
- modify it only if it currently fails to install or preserve the required skill/profile wiring and the fix is narrow
- defer broader installer work to `skill-01-improve-installer-support-if-needed`
- do not change runtime helper behavior
- do not change OpenCode executor behavior
- do not change task lifecycle helper behavior

## Step-by-step packaging plan

Step 1: Define the package contract.

Files:
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `skills/hermetic-coding-orchestrator/README.md`

Work:
- state that the core local Hermes skill package is the skill directory plus `SKILL.md`
- treat `SKILL.md` YAML frontmatter as the package metadata contract
- document install target and expected load path
- document required invocation and audit marker
- state that packaging does not rename the skill

Step 2: Freeze the current behavior contract.

Read/verify only:
- `scripts/render-collection-prompt.sh`
- `agentops/templates/READY-TASK-TEMPLATE.md`
- `agentops/templates/PLANNED-TASK-TEMPLATE.md`

Work:
- verify all generated prompts still start with `/hermetic-coding-orchestrator`
- verify audit marker remains `USING_SKILL: hermetic-coding-orchestrator`
- do not modify these files in this slice unless verification exposes a concrete contradiction with the package docs

Step 3: Normalize `SKILL.md` frontmatter if needed.

Files:
- `skills/hermetic-coding-orchestrator/SKILL.md`

Work:
- preserve `name: hermetic-coding-orchestrator`
- preserve the existing description unless it needs a narrow packaging clarification
- add `version` and Hermes metadata tags/category only if consistent with official Hermes guidance
- do not add `manifest.json` unless official Hermes docs or Hermes CLI behavior explicitly requires it

Step 4: Add core package README.

Files:
- `skills/hermetic-coding-orchestrator/README.md`

Work:
- document when to use the skill
- document local install path
- document verification commands
- document compatibility guarantees for the name, slash invocation, and audit marker
- mention optional observability as a follow-up, not part of this package slice

Step 5: Wire install documentation.

Files:
- `docs/INSTALL.md`
- `skills/hermetic-coding-orchestrator/README.md`
- `scripts/install-coder-profile.sh` only if needed

Work:
- document core local skill install
- document verification commands after install
- inspect and classify installer behavior as one of: no change needed, docs-only clarification needed, or narrow installer fix needed
- preserve existing profile installation behavior unless inspection proves it is broken

Step 6: Reconcile repo docs.

Files:
- `docs/DOCUMENTATION-MAP.md`
- `docs/INSTALL.md`

Work:
- remove contradictory install or invocation guidance
- point to the packaged skill README as the package authority
- avoid broad AgentOps lifecycle docs rewrites

Step 7: Add verification.

Files:
- packaging README and/or docs install section

Work:
- verify skill package files exist
- verify `SKILL.md` front matter still has the expected name
- verify `SKILL.md` still contains the audit marker
- verify generated collection prompt still starts with `/hermetic-coding-orchestrator`
- run `scripts/check-agentops-lifecycle.sh`
- if Hermes CLI is available, verify the skill is visible and slash invocation works

Step 8: Keep rename work separate.

Files:
- none in this task unless adding a follow-up note

Work:
- do not rename `hermetic-coding-orchestrator`
- do not change slash invocation
- do not change audit marker
- capture rename as a later migration task with compatibility alias planning

Step 9: Keep optional observability packaging separate.

Files:
- none in this task unless adding a follow-up note

Work:
- do not package `.agentops-runs/` support in this slice
- do not modify `docs/RUN-AUDIT.md` or `docs/RUN-OBSERVABILITY.md` unless a narrow install-doc cross-reference is required
- track optional observability packaging as a follow-up task, e.g. `skill-03-package-optional-agentops-observability`

## Requirements

- Packaging must preserve current runtime behavior by default.
- Use `SKILL.md` YAML frontmatter as the Hermes skill package metadata contract for this slice.
- Do not add `manifest.json` unless official Hermes docs or Hermes CLI behavior explicitly requires it.
- Observability packaging must remain a follow-up task.
- Existing helper scripts must keep their current command-line behavior unless installer verification proves a narrowly documented path/install issue.
- The skill rename must not be included in this slice.

## Non-goals

- Do not rename the skill.
- Do not change `/hermetic-coding-orchestrator`.
- Do not change `USING_SKILL: hermetic-coding-orchestrator`.
- Do not redesign AgentOps lifecycle.
- Do not make observability mandatory.
- Do not package optional AgentOps observability support in this slice.
- Do not add Prometheus/Grafana as a default install path.
- Do not introduce `manifest.json` unless Hermes requires it.
- Do not move or rewrite runtime helper scripts unless needed for package install compatibility.
- Do not change OpenCode executor behavior.
- Do not change lifecycle helper behavior.
- Do not commit `.agentops-runs/` artifacts.

## Open questions

- Is the current `scripts/install-coder-profile.sh` path sufficient to install/preserve the skill layout?
- Should package versioning start at `0.1.0` or follow repository versioning?

## Promotion decision

Decision: ready_after_goal_rewrite

Reason:
Hermes skill packaging contract is confirmed as a skill directory with
`SKILL.md` frontmatter plus optional supporting files. No separate
`manifest.json` is required for the core local/native skill package in this
slice unless official Hermes docs or Hermes CLI behavior explicitly requires it.

The task is now properly narrowed to core packaging. It can be promoted after
rewriting the ready-task goal from planning language to implementation language.

Next action:
Promote a narrow ready task that packages the existing
`hermetic-coding-orchestrator` skill with README/install/verification
documentation only. Inspect the installer and modify it only if it fails to
install or preserve the required skill/profile wiring and the fix is narrow.
Keep observability packaging, runtime workflow changes, and rename work as
follow-up tasks.

## Promotion criteria

This task can be promoted to ready when:

- write scope is narrowed to exact files
- installer behavior has been inspected and classified as one of: no change needed, docs-only clarification needed, or narrow installer fix needed
- the ready-task goal is rewritten from planning language to implementation language
- verification commands are concrete
- rename follow-up remains explicitly out of scope

## Verification

Planning-only verification:

```bash
git status --short --branch
git diff --stat
```

Implementation verification when promoted:

```bash
git status --short --branch
test -f skills/hermetic-coding-orchestrator/SKILL.md
grep -q '^name: hermetic-coding-orchestrator$' skills/hermetic-coding-orchestrator/SKILL.md
grep -q 'USING_SKILL: hermetic-coding-orchestrator' skills/hermetic-coding-orchestrator/SKILL.md
scripts/render-collection-prompt.sh agentops/tasks/ready/<TASK-XXXX-slug>.md | head -1
scripts/check-agentops-lifecycle.sh
```

If Hermes CLI is available, also verify:

```bash
hermes skills list | grep hermetic-coding-orchestrator
hermes --profile coder chat -q "/hermetic-coding-orchestrator Summarize your workflow rules in 3 bullets"
```

Expected result: the skill is visible, slash invocation works, and the response
includes `USING_SKILL: hermetic-coding-orchestrator`.

## Accept criteria

- Packaging plan is file-by-file and step-by-step.
- Current skill name and invocation remain unchanged.
- `SKILL.md` frontmatter is treated as the package metadata contract.
- No `manifest.json` is introduced unless Hermes requires it.
- Optional observability packaging is deferred.
- Open questions identify only the blockers to promotion.
- No runtime helper behavior changes are made by this planning task.

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

agentops/tasks/ready/TASK-xxxx-short-slug.md

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

Origin: `agentops/IDEAS.md` entry to package
`skills/hermetic-coding-orchestrator/` as a proper Hermes-native skill with
optional AgentOps observability. This task narrows the first slice to core
skill packaging only.

When promoting to ready, rewrite the goal to:

```text
Implement the core packaging documentation for `skills/hermetic-coding-orchestrator/`
as a Hermes-native local skill package, without changing the existing skill name,
slash invocation, audit marker, or AgentOps runtime behavior.
```

Recommended follow-up tasks:

- `skill-01-improve-installer-support-if-needed`
- `skill-02-document-skill-activation-troubleshooting`
- `skill-03-package-optional-agentops-observability`

Estimated effort after promotion: small, bounded docs-and-verification slice.

Assign a TASK-XXXX ID only when promoting to `ready/`.
