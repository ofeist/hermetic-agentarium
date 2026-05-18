# TASK-0097 — Bootstrap/check repo-local AgentOps lifecycle structure

## Status

ready

## Goal

Add an idempotent repo-local bootstrap/check helper for the canonical `.agentops/` lifecycle layout, then run it against this repository's `.agentops/` directory.

## Background / why now

TASK-0096 migrated the repo-local AgentOps tree from `agentops/` to `.agentops/`. Fresh repositories and repaired checkouts need a narrow bootstrap command that creates or validates the required lifecycle directories and placeholder files for the final `.agentops/` path model.

## Problem statement

The repository has lifecycle checks and task helpers, but no explicit bootstrap command for initializing the `.agentops/` structure. Without one, setup remains manual and future repos can miss required directories, placeholders, or templates.

## Smallest useful slice

Create a minimal script that defaults to `.agentops/`, ensures required directories and `.gitkeep` placeholders exist, validates required template files when present, and exits cleanly when run repeatedly. Document the command briefly and run it against `.agentops/`.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `.agentops/`
- `.agentops/templates/`
- `scripts/check-agentops-lifecycle.sh`
- existing AgentOps helper scripts
- `docs/AGENTOPS-HELPERS.md`
- `.agentops/README.md`
- `.agentops/USAGE.md`

## Write scope

- `scripts/bootstrap-agentops-structure.sh`
- `docs/AGENTOPS-HELPERS.md`
- `.agentops/README.md`
- `.agentops/USAGE.md`
- `.agentops/tasks/done/TASK-0097-agentops-structure-bootstrap.md` and result note during lifecycle closeout

## Requirements

- The execution prompt MUST start with `/hermetic-coding-orchestrator`.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near the beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Preserve `OPENCODE_XDG_CONFIG_HOME`, `OPENCODE_XDG_DATA_HOME`, and `AGENTOPS_EXECUTOR_MODEL` if invoking OpenCode.
- Add `scripts/bootstrap-agentops-structure.sh` as an idempotent shell script.
- Default target must be `.agentops/` from the repository root.
- The helper may accept an optional target directory argument; if implemented, verification must run it with `.agentops` explicitly.
- Ensure these directories exist: `.agentops/tasks/planned`, `.agentops/tasks/ready`, `.agentops/tasks/running`, `.agentops/tasks/review`, `.agentops/tasks/done`, `.agentops/results`, `.agentops/templates`, `.agentops/lifecycle`.
- Ensure `.gitkeep` files exist for the lifecycle directories that are intended to be tracked when otherwise empty: task state directories and `results`.
- Validate that required templates exist: `.agentops/templates/PLANNED-TASK-TEMPLATE.md` and `.agentops/templates/READY-TASK-TEMPLATE.md`.
- Run the bootstrap helper against `.agentops/` as part of implementation verification.
- Do not introduce user-level `$HOME/.agentops` behavior.

## Non-goals

- No user-level AgentOps home design.
- No skill rename.
- No observability packaging changes.
- No broad workflow redesign.
- No changes to OpenCode/Hermes model configuration.

## Open questions

None. Bootstrap should be permissive/idempotent for required directories/placeholders and strict for required template presence.

## Promotion decision

Decision: promote_to_ready

Reason:
TASK-0096 landed the canonical `.agentops/` repo-local path. The planned bootstrap slice now has concrete path, behavior, scope, and verification.

Next action:
Execute through the Hermes/OpenCode executor workflow and run the helper against `.agentops/`.

## Promotion criteria

Already promoted to ready.

## Verification

Run:

```bash
git status --short --branch
bash -n scripts/bootstrap-agentops-structure.sh
scripts/bootstrap-agentops-structure.sh .agentops
scripts/bootstrap-agentops-structure.sh .agentops
scripts/check-agentops-lifecycle.sh
test -d .agentops/tasks/planned
test -d .agentops/tasks/ready
test -d .agentops/tasks/running
test -d .agentops/tasks/review
test -d .agentops/tasks/done
test -d .agentops/results
test -d .agentops/templates
test -d .agentops/lifecycle
test -f .agentops/templates/PLANNED-TASK-TEMPLATE.md
test -f .agentops/templates/READY-TASK-TEMPLATE.md
git diff --stat
```

## Accept criteria

- Bootstrap helper exists and targets `.agentops/` by default.
- Running the helper against `.agentops/` succeeds and is idempotent.
- Required AgentOps lifecycle directories and placeholders are present after bootstrap.
- Required templates are validated.
- Lifecycle checker passes after bootstrap.
- Docs briefly mention the bootstrap helper.
- No user-level `.agentops` behavior is added.

## Hermes/coder collection prompt

```text
/hermetic-coding-orchestrator

Execute AgentOps ready task:

.agentops/tasks/ready/TASK-0097-agentops-structure-bootstrap.md

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
```
