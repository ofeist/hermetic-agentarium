# skill-00-package-hermetic-orchestrator - Package hermetic orchestrator as a Hermes-native skill

## Status

planned

## Goal

Plan the packaging work needed to turn `skills/hermetic-coding-orchestrator/`
from a repo-local skill file into a proper Hermes-native skill package without
changing the existing skill name, invocation contract, or AgentOps runtime
behavior.

## Background / why now

`agentops/IDEAS.md` captures the need to package
`skills/hermetic-coding-orchestrator/` as a Hermes-native skill and optionally
include AgentOps observability support. The current skill is operationally useful
but consists of a single `SKILL.md` file with repo-coupled docs and helper
assumptions.

Packaging should make installation and verification explicit while preserving
the existing slash invocation and audit marker:

- `/hermetic-coding-orchestrator`
- `USING_SKILL: hermetic-coding-orchestrator`

## Problem statement

The current skill has no package boundary, install contract, package metadata,
or optional-component layout. AgentOps observability helpers exist in the repo,
but there is no clear packaging distinction between the core orchestration skill
and optional local run inspection support.

Without a packaging plan, implementation risks mixing behavior changes, docs
reconciliation, optional observability wiring, and future rename work into one
large change.

## Smallest useful slice

Create a packaging-only plan and then implement the smallest package structure
that preserves current behavior:

- keep the current skill name and invocation unchanged
- add package/install metadata and docs around the existing `SKILL.md`
- define core vs optional observability assets
- add verification steps for core-only and core-plus-observability installs
- do not rename the skill in this slice

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `agentops/IDEAS.md`
- `agentops/USAGE.md`
- `docs/AGENTOPS-HELPERS.md`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `scripts/install-coder-profile.sh`
- `scripts/render-collection-prompt.sh`
- `scripts/run-opencode-executor.sh`
- `scripts/render-agentops-run-summary.sh`
- `scripts/record-agentops-outcome.sh`
- `scripts/export-agentops-prometheus-metrics.sh`
- `.gitignore`

## Write scope

Packaging implementation should be limited to files like:

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `skills/hermetic-coding-orchestrator/README.md`
- `skills/hermetic-coding-orchestrator/manifest.json` or equivalent package metadata, depending on the chosen Hermes package contract
- `skills/hermetic-coding-orchestrator/observability/README.md`
- `skills/hermetic-coding-orchestrator/observability/manifest.json` or equivalent optional-component metadata, if needed
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `agentops/USAGE.md`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `scripts/install-coder-profile.sh` only if it is the existing local installer entry point that should learn the packaged skill layout

Do not modify task lifecycle helpers unless packaging verification proves a path
assumption is broken.

## Step-by-step packaging plan

Step 1: Define the package contract.

Files:
- `skills/hermetic-coding-orchestrator/README.md`
- optional package metadata file under `skills/hermetic-coding-orchestrator/`

Work:
- describe what counts as the core skill package
- document install target and expected load path
- document required invocation and audit marker
- state that packaging does not rename the skill

Step 2: Freeze the current behavior contract.

Files:
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `scripts/render-collection-prompt.sh`
- `agentops/templates/READY-TASK-TEMPLATE.md`
- `agentops/templates/PLANNED-TASK-TEMPLATE.md`

Work:
- verify all generated prompts still start with `/hermetic-coding-orchestrator`
- verify audit marker remains `USING_SKILL: hermetic-coding-orchestrator`
- do not change canonical prompt text except to clarify packaging/install notes

Step 3: Add package metadata.

Files:
- `skills/hermetic-coding-orchestrator/manifest.json` or equivalent

Work:
- include package name, description, version, entry file, and optional component declarations
- keep metadata local and static
- do not add runtime dependencies unless required by Hermes

Step 4: Separate optional observability support.

Files:
- `skills/hermetic-coding-orchestrator/observability/README.md`
- optional metadata under `skills/hermetic-coding-orchestrator/observability/`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`

Work:
- document `.agentops-runs/` as local-only
- list optional helpers:
  - `scripts/run-opencode-executor.sh`
  - `scripts/render-agentops-run-summary.sh`
  - `scripts/record-agentops-outcome.sh`
  - `scripts/export-agentops-prometheus-metrics.sh`
- keep Prometheus/Grafana support optional
- explicitly prohibit exporting raw prompts or committing raw logs

Step 5: Wire install documentation.

Files:
- `docs/INSTALL.md`
- `skills/hermetic-coding-orchestrator/README.md`
- `scripts/install-coder-profile.sh` only if needed

Work:
- document core-only install
- document core plus optional observability install
- document verification commands after install
- preserve existing profile installation behavior unless intentionally extended

Step 6: Reconcile repo docs.

Files:
- `agentops/USAGE.md`
- `docs/AGENTOPS-HELPERS.md`
- `docs/DOCUMENTATION-MAP.md`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`

Work:
- remove contradictory install or invocation guidance
- point to the packaged skill README as the package authority
- keep AgentOps lifecycle docs focused on repo workflow, not skill distribution

Step 7: Add verification.

Files:
- packaging README and/or docs install section
- optional lightweight verification helper only if existing checks are not enough

Work:
- verify skill package files exist
- verify `SKILL.md` front matter still has the expected name
- verify generated collection prompt still starts with `/hermetic-coding-orchestrator`
- run `scripts/check-agentops-lifecycle.sh`
- run relevant shell syntax checks for touched scripts

Step 8: Keep rename work separate.

Files:
- none in this task unless adding a follow-up note

Work:
- do not rename `hermetic-coding-orchestrator`
- do not change slash invocation
- do not change audit marker
- capture rename as a later migration task with compatibility alias planning

## Requirements

- Packaging must preserve current runtime behavior by default.
- Core skill install must be separable from optional observability support.
- Observability must remain opt-in.
- `.agentops-runs/` artifacts must remain local-only and gitignored.
- Packaging docs must prohibit raw prompt/log export.
- Existing helper scripts must keep their current command-line behavior unless a
  packaging path assumption requires a narrowly documented update.
- The skill rename must not be included in this slice.

## Non-goals

- Do not rename the skill.
- Do not change `/hermetic-coding-orchestrator`.
- Do not change `USING_SKILL: hermetic-coding-orchestrator`.
- Do not redesign AgentOps lifecycle.
- Do not make observability mandatory.
- Do not add Prometheus/Grafana as a default install path.
- Do not move or rewrite runtime helper scripts unless needed for package install compatibility.
- Do not commit `.agentops-runs/` artifacts.

## Open questions

- What exact metadata filename and schema does Hermes expect for native skill packaging?
- Should optional observability support be represented as package metadata, a documented install profile, or both?
- Should `scripts/install-coder-profile.sh` install the packaged skill, or should packaging provide a separate installer?
- Should package versioning start at `0.1.0` or follow repository versioning?

## Promotion decision

Decision: keep_planned

Reason:
The direction is clear, but the Hermes-native package metadata contract needs to
be confirmed before this becomes executor-ready.

Next action:
Confirm the package metadata/install contract, then promote a narrow
implementation task for package structure and install docs.

## Promotion criteria

This task can be promoted to ready when:

- Hermes package metadata filename and required fields are known
- core vs optional observability install shape is chosen
- installer ownership is decided
- write scope is narrowed to exact files
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
scripts/render-collection-prompt.sh agentops/tasks/ready/<TASK-XXXX-slug>.md | head -1
scripts/check-agentops-lifecycle.sh
```

Add any Hermes-native package validation command once the package contract is
known.

## Accept criteria

- Packaging plan is file-by-file and step-by-step.
- Current skill name and invocation remain unchanged.
- Core skill and optional observability responsibilities are separated.
- Safety guardrails for local run artifacts, prompts, logs, and metadata are explicit.
- Open questions identify the blockers to promotion.
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
optional AgentOps observability.

Estimated packaging-only effort after open questions are resolved: roughly
6-10 hours.

Assign a TASK-XXXX ID only when promoting to `ready/`.
