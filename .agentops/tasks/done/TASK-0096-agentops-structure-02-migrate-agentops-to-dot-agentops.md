# TASK-0096 - agentops-structure-02-migrate-agentops-to-dot-agentops

## Status

done

## Goal

Execute the atomic repo-local AgentOps path migration from `agentops/` to
`.agentops/`, using `docs/AGENTOPS-PATH-MIGRATION.md` and the TASK-0095
migration plan as the implementation source of truth.

## Background / why now

TASK-0095 produced and accepted a concrete migration plan. The repository has
also been tagged before the structural move:
`pre-dot-agentops-migration-2026-05-18`.

The actual migration should happen before bootstrap, user-level AgentOps home
design, skill rename work, or observability work so those follow-up tasks target
the new canonical repo-local structure.

## Problem statement

The AgentOps lifecycle currently lives under `agentops/`, while the accepted
structure plan makes `.agentops/` the canonical repo-local metadata directory.
Leaving the old path in place means bootstrap and later structure work would be
built against a directory layout we already intend to replace.

## Smallest useful slice

Perform only the atomic path migration:

- move `agentops/` to `.agentops/`
- update active path references that must resolve against the new layout
- preserve historical `done/` and `results/` file contents
- verify the migrated helper scripts and lifecycle checks

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `docs/AGENTOPS-PATH-MIGRATION.md`
- `agentops/tasks/planned/010-agentops-structure-00-plan-dot-agentops-repo-migration.md`
- `agentops/`
- `scripts/`
- `docs/`
- `README.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `profiles/coder/SOUL.md`

## Write scope

- `agentops/`
- `.agentops/`
- `scripts/submit-agentops-task.sh`
- `scripts/accept-agentops-task.sh`
- `scripts/check-agentops-lifecycle.sh`
- `scripts/next-agentops-task-id.sh`
- `scripts/render-collection-prompt.sh`
- `scripts/render-verification-notes.sh`
- `scripts/run-ready-task.sh`
- `scripts/new-ready-task.sh`
- `scripts/revise-agentops-task.sh`
- `scripts/test-submit-agentops-task.sh`
- `scripts/render-review-prompt.sh`
- `scripts/render-revision-prompt.sh`
- `scripts/render-opencode-prompt.sh`
- `README.md`
- `docs/PLANNING-WORKFLOW.md`
- `docs/POC-STATUS.md`
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `docs/DEBUGGING.md`
- `docs/AGENTOPS-HELPERS.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `docs/AGENTOPS-PATH-MIGRATION.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `profiles/coder/SOUL.md`

## Requirements

- The execution prompt MUST start with `/hermetic-coding-orchestrator` to
  explicitly invoke the custom skill.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near the
  beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration, not by task
  prompt text.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking
  OpenCode.
- Use `docs/AGENTOPS-PATH-MIGRATION.md` as the implementation source of truth.
- Run `git mv agentops .agentops`.
- Update runtime-critical scripts to use `.agentops/` paths.
- Update root `README.md` links and relevant docs to use `.agentops/` paths.
- Update templates under `.agentops/templates/`.
- Update `skills/hermetic-coding-orchestrator/SKILL.md`.
- Update `profiles/coder/SOUL.md`.
- Update active workflow files under `.agentops/tasks/planned/`,
  `.agentops/tasks/ready/`, `.agentops/tasks/running/`, and
  `.agentops/tasks/review/`.
- Leave `.agentops/tasks/done/` file contents unchanged as historical records.
- Leave `.agentops/results/` file contents unchanged as historical records.
- Update `scripts/check-agentops-lifecycle.sh` so checks that inspect
  historical records accept old `agentops/` task-path references where needed.
- Do not change `.agentops-runs/`.
- Do not rename the skill.
- Do not mix in bootstrap work.
- Do not mix in user-level `$HOME/.agentops` design.
- Do not mix in observability work.

## Non-goals

- No skill rename work.
- No bootstrap implementation.
- No user-level AgentOps home design or migration.
- No optional observability packaging.
- No `.agentops-runs/` changes.
- No helper behavior changes beyond required path migration and historical
  compatibility in the lifecycle checker.
- No rewriting historical done task contents.
- No rewriting historical result note contents.

## Open questions

None.

## Promotion decision

Decision: already_ready

Reason:
TASK-0095 accepted the migration plan and recommended an atomic cutover. The
pre-migration tag exists, and this task is the implementation slice for that
accepted plan.

Next action:
Execute through the Hermes/coder collection prompt.

## Promotion criteria

Already promoted to ready.

## Verification

Run:

```bash
git status --short --branch

test -d .agentops && test ! -d agentops

for d in tasks/planned tasks/ready tasks/running tasks/review tasks/done results templates lifecycle; do
  test -d ".agentops/$d" || exit 1
done

for f in scripts/*.sh; do bash -n "$f"; done

scripts/check-agentops-lifecycle.sh

scripts/next-agentops-task-id.sh

scripts/new-ready-task.sh TEST-9999 "test migration"
test -f .agentops/tasks/ready/TEST-9999.md
rm .agentops/tasks/ready/TEST-9999.md

scripts/render-opencode-prompt.sh .agentops/tasks/ready/TASK-0096-agentops-structure-02-migrate-agentops-to-dot-agentops.md > /dev/null

scripts/test-submit-agentops-task.sh

git diff --stat
```

Also audit remaining `agentops/` path literals:

```bash
rg -n 'agentops/' scripts docs README.md skills profiles .agentops
```

Remaining `agentops/` references are acceptable only when they are historical
records, migration documentation, compatibility patterns, or script names. Any
runtime path literal, active workflow path, template path, skill path, profile
path, or normal documentation link that should resolve to the current lifecycle
directory must use `.agentops/`.

## Accept criteria

- `agentops/` has been moved to `.agentops/` with `git mv`.
- Runtime-critical scripts use `.agentops/` paths.
- Docs and root README links point at `.agentops/` where they describe current
  repo structure.
- Templates use `.agentops/` paths.
- The skill and coder profile use `.agentops/` paths.
- Active workflow files under planned/ready/running/review use `.agentops/`
  paths.
- Historical done task contents and result note contents are not rewritten.
- Lifecycle checks accept old historical `agentops/` references where needed.
- `.agentops-runs/` is unchanged.
- Skill name and invocation are unchanged.
- Bootstrap, user-home design, and observability work are not included.
- Verification commands pass or failures are explained.
- No unrelated files are modified.

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

.agentops/tasks/ready/TASK-0096-agentops-structure-02-migrate-agentops-to-dot-agentops.md

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

Expected executor return format:

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

After this migration lands, promote/run `agentops-structure-bootstrap` against
the new canonical `.agentops/` structure.
