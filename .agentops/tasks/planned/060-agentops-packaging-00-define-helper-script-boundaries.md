# agentops-packaging-00-define-helper-script-boundaries - Define AgentOps helper packaging boundaries

## Status

planned

## Goal

Decide how AgentOps helper scripts should be packaged and used when the
`agentops-coder` Hermes skill is used with repositories other than
`hermetic-agentarium`.

The decision should clarify which parts belong in:

- the target repository under `.agentops/`
- the installed Hermes skill package
- the Hermes `coder` profile
- a future standalone AgentOps CLI/tooling layer
- optional user-level state such as `$HOME/.agentops/`

No helper migration or packaging implementation should be performed in this task.

## Background / why now

The project now has a clearer split:

- `.agentops/` is the repo-local AgentOps lifecycle/state directory.
- `agentops-coder` is the canonical Hermes skill entrypoint.
- `hermetic-coding-orchestrator` remains as a temporary compatibility bridge.
- `profiles/coder/` provides the recommended Hermes coordinator profile.
- `scripts/` currently contains the executable AgentOps helper layer.

The next architecture question is not only whether `$HOME/.agentops/` should
exist. The broader question is:

> What is the product boundary of AgentOps when used from another repository?

Today, `hermetic-agentarium` is still a repo-based toolkit. A user clones this
repo and uses its installer, skill, profile, helper scripts, templates, and task
lifecycle files together.

For broader use, we need to decide which helper scripts should remain repo-local,
which should be bundled into the `agentops-coder` skill package, and whether a
future standalone CLI is needed.

## Problem statement

AgentOps currently mixes several concerns in one repository:

- Hermes skill instructions (`skills/agentops-coder/`)
- Hermes profile template (`profiles/coder/`)
- executable helper scripts (`scripts/`)
- project-local lifecycle state (`.agentops/`)
- documentation and examples

This works for developing the toolkit itself, but it is not yet obvious how a
user should apply AgentOps to another repository.

Possible product models include:

1. **Repo-based toolkit**
   - user clones `hermetic-agentarium`
   - helper scripts stay in this repo
   - target repositories are operated on manually or through explicit paths

2. **Skill-packaged helpers**
   - stable helper scripts/templates live inside the installed Hermes skill
   - the skill can bootstrap or operate on `.agentops/` in the current project

3. **Standalone AgentOps CLI**
   - user installs a CLI such as `agentops`
   - commands like `agentops init`, `agentops check`, `agentops run` operate on
     the current repository
   - Hermes skill remains the orchestration entrypoint, not the whole product

4. **Hybrid model**
   - `.agentops/` remains project-local source of truth
   - stable helpers move into the skill or CLI
   - `$HOME/.agentops/` is reserved only for optional user-level cache,
     preferences, project registry, or global indexes

Without a clear boundary, future work can accidentally turn the Hermes skill,
profile, repository, and helper scripts into overlapping packaging mechanisms.

## Smallest useful slice

Produce an architecture/design decision document that answers:

- what `.agentops/` means in a target repository
- which helper scripts must stay repo-local
- which helper scripts could later move into `skills/agentops-coder/scripts/`
- which helper scripts should instead become a future CLI layer
- whether `$HOME/.agentops/` should exist at all, and if yes, for what limited
  purpose
- what the recommended near-term product model is

No path migrations, script moves, or CLI implementation in this task.

## Executor

Harness: TBD (default in this repo: OpenCode)
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `README.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `docs/AGENTOPS-PATH-MIGRATION.md`
- `skills/agentops-coder/SKILL.md`
- `skills/agentops-coder/README.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `profiles/coder/SOUL.md`
- `scripts/`
- `.agentops/README.md`
- `.agentops/USAGE.md`
- `.agentops/TASK-LIFECYCLE.md`
- `.agentops/templates/`

## Write scope

Planning/design output only:

- this planned task file, or
- optional new design note:
  - `docs/AGENTOPS-PACKAGING-BOUNDARIES.md`

Optional cross-reference only if needed:

- `docs/DOCUMENTATION-MAP.md`

Do not move helper scripts, create a CLI, change installer behavior, or migrate
state in this slice.

## Requirements

- Clearly define the current product boundary:
  - `Hermetic Agentarium` as repo/toolkit
  - `AgentOps` as workflow/lifecycle model
  - `agentops-coder` as Hermes skill entrypoint
  - `.agentops/` as project-local source of truth
  - `scripts/` as current executable helper layer
- Evaluate helper packaging options:
  - keep scripts in central repo
  - copy scripts into target repos
  - bundle stable scripts inside `skills/agentops-coder/`
  - create a standalone AgentOps CLI
  - hybrid approach
- Classify existing helper scripts by likely future home:
  - keep repo-local for now
  - candidate for skill package
  - candidate for future CLI
  - target-repo bootstrap helper
  - internal development helper
- Define which state must remain project-local under `repo/.agentops/`.
- Define whether `$HOME/.agentops/` should exist, and if yes, restrict it to
  user-level runtime/cache/index/preferences rather than canonical task/result
  storage.
- Recommend a near-term default model and rationale.
- Identify follow-up tasks that should be created from the decision.

## Non-goals

- No filesystem path migration in this task.
- No helper script moves in this task.
- No bootstrap implementation in this task.
- No standalone CLI implementation in this task.
- No installer behavior changes in this task.
- No skill rename work in this task.
- No observability packaging work in this task.
- No change to `.agentops/` lifecycle semantics in this task.

## Open questions

- Should the near-term product remain repo-based?
- Which helper scripts are stable enough to package inside the Hermes skill?
- Which helper scripts must operate from the target repository's current working
  directory?
- Is a future `agentops` CLI needed, or is the Hermes skill plus repo scripts
  enough for now?
- Should `$HOME/.agentops/` exist at all?
- If `$HOME/.agentops/` exists, what exact data categories belong there?
- How should users apply AgentOps to a different repository without cloning the
  whole toolkit into that repository?

## Promotion decision

Decision: keep_planned

Reason:
This is an architecture/design task. It should replace the narrower
`evaluate-user-level-agentops-home` question with the broader packaging-boundary
decision, because the `$HOME/.agentops/` question depends on how helper scripts
and target-repo state are packaged.

Next action:
Promote when the team wants to decide the AgentOps product boundary before
moving helpers into skills, adding a CLI, or designing `$HOME/.agentops/`.

## Promotion criteria

- evaluation criteria are explicit
- design artifact path is chosen
- write scope is concrete
- no implementation or migration actions are included
- expected output includes a recommended near-term model and follow-up task list

## Verification

Planning-only verification:

```bash
git status --short --branch
git diff --stat
```

If a design note is added:

```bash
test -f docs/AGENTOPS-PACKAGING-BOUNDARIES.md
grep -q 'repo/.agentops' docs/AGENTOPS-PACKAGING-BOUNDARIES.md
grep -q 'skills/agentops-coder' docs/AGENTOPS-PACKAGING-BOUNDARIES.md
grep -q 'scripts/' docs/AGENTOPS-PACKAGING-BOUNDARIES.md
```

## Accept criteria

- The decision clearly separates:
  - project-local state
  - Hermes skill behavior
  - Hermes profile configuration
  - executable helper tooling
  - optional user-level state
- The recommended near-term product model is explicit.
- Existing helper scripts are classified by likely future home.
- `$HOME/.agentops/` is either rejected for now or limited to clearly defined
  non-canonical user-level state.
- No path migration, helper move, CLI implementation, or installer change is
  performed in this slice.
- Follow-up tasks are proposed for any implementation work.

## Notes

Recommended default decision to evaluate:

```text
Keep `.agentops/` in the target repository as the canonical source of truth for
tasks, results, templates, and lifecycle state.

Keep helper scripts repo-local for now while the workflow is still changing.

Design toward a future split:
- stable bootstrap/check/render helpers may move into the `agentops-coder` skill
  package later
- heavier lifecycle automation may become a standalone `agentops` CLI
- `$HOME/.agentops/` may exist later only for global preferences, cache, project
  registry, or optional run indexes
```

Possible follow-up tasks after this decision:

- `agentops-packaging-01-classify-helper-scripts`
- `agentops-packaging-02-design-agentops-init`
- `agentops-packaging-03-evaluate-skill-bundled-helper-scripts`
- `agentops-packaging-04-evaluate-agentops-cli`
- `agentops-structure-02-evaluate-user-level-agentops-home` if still needed as
  a narrower follow-up
