# AgentOps Packaging Boundaries

## Decision

Near term, keep Hermetic Agentarium as a repo-based toolkit:

- `repo/.agentops/` is the canonical project-local AgentOps source of truth.
- `scripts/` remains the executable helper layer while the workflow is still changing.
- `skills/agentops-coder/` remains the Hermes orchestration entrypoint and packageable skill.
- `profiles/coder/` remains the recommended Hermes coordinator profile template.
- Do not move helper scripts into the skill package yet.
- Keep `$HOME/.agentops/` optional and non-canonical.

This is intentionally simple. It preserves the current working model and avoids
creating three competing products at once: a Hermes skill, a helper-script
bundle, and a standalone CLI.

## Hermes Packaging Check

Official Hermes documentation supports a skill directory with required
`SKILL.md` and optional supporting directories such as `references/`,
`templates/`, `scripts/`, and `assets`.

Relevant Hermes behavior checked on 2026-05-20:

- Skills are discovered from `~/.hermes/skills/` by default.
- A skill directory must contain `SKILL.md` with frontmatter such as `name`,
  `description`, and optional Hermes metadata.
- Supporting files under `references/`, `templates/`, `scripts/`, and `assets/`
  are normal for directory-style skills and taps.
- External skill directories can be scanned with `skills.external_dirs`, but
  Hermes writes created/edited skills to local `~/.hermes/skills/`.
- Direct URL installs of a single `SKILL.md` are single-file only; multi-file
  skills need a directory/package source rather than only a raw `SKILL.md`.
- Hermes profiles are separate Hermes homes. A profile such as `coder` has its
  own skills directory under its profile-local `HERMES_HOME`.

Sources:

- https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/skills.md
- https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/profiles.md

Practical conclusion: helper scripts inside a Hermes skill package are supported
as a packaging shape, but that does not mean AgentOps should move its active,
stateful helper layer there now. The current helpers mutate repo-local lifecycle
state, create worktrees, inspect diffs, and invoke OpenCode; they are better kept
repo-local until their contracts stabilize.

## Current Repo-Based Model

Hermetic Agentarium currently distributes a working system as a repository:

- installable Hermes skills under `skills/`
- coder profile template under `profiles/coder/`
- executable helper scripts under `scripts/`
- project-local lifecycle state under `.agentops/`
- examples, docs, and templates

The installer copies the Hermes-facing pieces into the local Hermes runtime, but
the full AgentOps workflow still depends on the repository checkout. Installing
only `SKILL.md` may expose a slash command, but it is not enough to provide the
helper scripts, task layout, templates, lifecycle checks, worktree helpers, or
review conventions.

## Product Boundaries

### Hermetic Agentarium

The repository/toolkit that carries the skill, profile, docs, helper scripts,
templates, and current development workflow.

### AgentOps

The workflow/lifecycle model:

- planned, ready, running, review, done task states
- parent/executor/reviewer handoff
- explicit verification and result notes
- repo-local audit trail

### `agentops-coder`

The Hermes skill entrypoint. It should describe orchestration rules, lifecycle
expectations, compatibility guarantees, and where to find the helper layer. It
should not become the canonical store for task state.

### `repo/.agentops/`

The project-local AgentOps source of truth for a repository. This is the state
that should move with the project and be reviewed in git.

### `scripts/`

The current executable helper layer. Scripts stay here for now because they are
repo-stateful, still evolving, and easier to review as normal source files.

## What Stays In `repo/.agentops/`

The target repository's `.agentops/` should contain project-local lifecycle
state and templates:

- `.agentops/README.md`
- `.agentops/USAGE.md`
- `.agentops/TASK-LIFECYCLE.md`
- `.agentops/tasks/planned/`
- `.agentops/tasks/ready/`
- `.agentops/tasks/running/`
- `.agentops/tasks/review/`
- `.agentops/tasks/done/`
- `.agentops/results/`
- `.agentops/templates/`
- `.agentops/lifecycle/`

Canonical task and result state should remain here because it is project-specific
and reviewable with the code it describes.

Do not move canonical task files, lifecycle state, or committed result notes to
`$HOME/.agentops/`.

## What Remains In `scripts/` For Now

All current helper scripts remain repo-local for now. The main reason is
stability: these scripts encode active workflow behavior and path assumptions.
Moving them into a skill package or global CLI before the contracts settle would
make upgrades, debugging, and target-repo behavior harder to reason about.

The near-term rule:

- keep scripts in this repository
- document which scripts are future packaging candidates
- do not duplicate scripts into target repositories automatically yet
- do not make the skill package responsible for lifecycle mutation yet

## Helper Script Classification

| Helper | Current role | Likely future home |
|--------|--------------|--------------------|
| `scripts/accept-agentops-task.sh` | review to done lifecycle move and result note creation | candidate for future CLI |
| `scripts/agentops-tmp-dir.sh` | local temp directory helper | internal development helper |
| `scripts/bootstrap-agentops-structure.sh` | initialize/check `.agentops/` layout | target-repo bootstrap helper, later CLI `agentops init/check` |
| `scripts/check-agentops-lifecycle.sh` | validate lifecycle consistency | candidate for future CLI |
| `scripts/export-agentops-prometheus-metrics.sh` | experimental metrics export from local run artifacts | repo-local for now, observability workstream |
| `scripts/install-coder-profile.sh` | install Hermes profile and skills into local runtime | internal distribution/install helper |
| `scripts/new-ready-task.sh` | create ready task from template | candidate for future CLI |
| `scripts/next-agentops-task-id.sh` | allocate next task id from lifecycle dirs | candidate for future CLI |
| `scripts/record-agentops-outcome.sh` | write safe outcome metadata | repo-local for now, observability workstream |
| `scripts/render-agentops-run-summary.sh` | summarize raw run artifacts | repo-local for now, observability workstream |
| `scripts/render-collection-prompt.sh` | render canonical skill invocation for a ready task | candidate for skill package after stabilization |
| `scripts/render-opencode-prompt.sh` | render bounded executor prompt | candidate for skill package or future CLI |
| `scripts/render-review-prompt.sh` | render parent review prompt | candidate for skill package or future CLI |
| `scripts/render-revision-prompt.sh` | render revision prompt | candidate for skill package or future CLI |
| `scripts/render-verification-notes.sh` | create parent verification notes scaffold | candidate for future CLI |
| `scripts/review-executor-result.sh` | inspect executor result state | candidate for future CLI |
| `scripts/revise-agentops-task.sh` | create revision task from review feedback | candidate for future CLI |
| `scripts/run-opencode-executor.sh` | invoke OpenCode and record local run artifacts | repo-local for now; possible future CLI wrapper |
| `scripts/run-ready-task.sh` | execute ready-task flow through prompt rendering/executor | candidate for future CLI |
| `scripts/start-agentops-task.sh` | older branch-based task start helper | internal development helper or future deprecation |
| `scripts/start-agentops-worktree.sh` | create task worktree and branch | candidate for future CLI |
| `scripts/submit-agentops-task.sh` | ready to review lifecycle move | candidate for future CLI |
| `scripts/test-submit-agentops-task.sh` | helper test fixture | internal development helper |

### Repo-Local For Now

Keep all helpers in `scripts/` until the packaging surface is clearer.

Especially keep these repo-local because they touch worktrees, external tools,
runtime artifacts, or mutable lifecycle state:

- `scripts/run-opencode-executor.sh`
- `scripts/run-ready-task.sh`
- `scripts/start-agentops-worktree.sh`
- `scripts/review-executor-result.sh`
- observability helpers

### Candidate For Skill Package

Later, stable read-only helpers and prompt assets could move into the skill
package if the installed skill needs to carry its own templates:

- prompt renderers
- reusable reference docs
- stable prompt templates

Good candidates after stabilization:

- `scripts/render-collection-prompt.sh`
- `scripts/render-opencode-prompt.sh`
- `scripts/render-review-prompt.sh`
- `scripts/render-revision-prompt.sh`

Do not move them yet. They still assume repository paths and are easier to test
inside the repo.

### Candidate For Future CLI

Stateful lifecycle commands are better CLI candidates than skill-package scripts:

- `agentops init`
- `agentops check`
- `agentops next-id`
- `agentops new-ready`
- `agentops submit`
- `agentops accept`
- `agentops revise`
- `agentops run`
- `agentops worktree`

Likely source scripts:

- `scripts/bootstrap-agentops-structure.sh`
- `scripts/check-agentops-lifecycle.sh`
- `scripts/next-agentops-task-id.sh`
- `scripts/new-ready-task.sh`
- `scripts/submit-agentops-task.sh`
- `scripts/accept-agentops-task.sh`
- `scripts/revise-agentops-task.sh`
- `scripts/run-ready-task.sh`
- `scripts/start-agentops-worktree.sh`

### Target-Repo Bootstrap Helper

`scripts/bootstrap-agentops-structure.sh` is the clearest target-repo bootstrap
helper. It may eventually become `agentops init` or `agentops check`, but for
now it stays in `scripts/`.

### Internal Development Helpers

Keep these internal unless a concrete user workflow requires packaging them:

- `scripts/install-coder-profile.sh`
- `scripts/test-submit-agentops-task.sh`
- `scripts/agentops-tmp-dir.sh`
- legacy `scripts/start-agentops-task.sh`

## `$HOME/.agentops/`

`$HOME/.agentops/` may exist in the future, but it must not be canonical task or
result storage.

Allowed future uses:

- cross-repo index/cache
- user preferences
- local project registry
- cached dashboard state
- derived observability indexes

Disallowed uses:

- canonical task files
- canonical result notes
- authoritative lifecycle state
- project-local templates
- secrets or provider auth

The rule is simple: if the data must be reviewed with the project, keep it under
`repo/.agentops/`. If it is derived, disposable, or user-specific, it may later
belong under `$HOME/.agentops/`.

## Observability Locations

Reserve these locations:

- `.agentops-runs/` for raw local run artifacts. This stays local and
  gitignored.
- `.agentops/results/` for safe committed summaries and audit notes.
- `$HOME/.agentops/` only for optional future cross-repo index, cache,
  preference, or dashboard state.

Do not make `$HOME/.agentops/` part of the required workflow yet.

## Packaging Options Considered

### Repo-Based Toolkit

Recommended now.

Pros:

- simple
- already works
- diffs and scripts are reviewable
- avoids premature CLI design
- avoids hiding mutable behavior inside installed skill directories

Cons:

- applying AgentOps to another repo still requires clear instructions
- helper scripts are not yet a polished external product

### Skill-Packaged Helpers

Viable later for stable read-only helpers, references, and templates.

Not recommended now for mutable lifecycle helpers because installed skill
directories are the wrong place to store project state or fast-changing workflow
logic.

### Standalone CLI

Likely the clean long-term home for lifecycle operations.

Not recommended now because the command contracts are still being proven through
shell helpers.

### Hybrid

Recommended long-term direction:

- `.agentops/` remains project-local source of truth
- Hermes skill remains the orchestration entrypoint
- stable references/templates may live in the skill package
- stateful helpers eventually become CLI commands
- `$HOME/.agentops/` remains optional and non-canonical

## Follow-Up Tasks

Suggested future tasks:

- Define target-repo bootstrap/install workflow for applying AgentOps to another repository.
- Decide which prompt templates, if any, should be bundled under `skills/agentops-coder/`.
- Draft a future `agentops` CLI command map without implementing it.
- Document how external repositories should reference the central toolkit checkout.
- Keep observability packaging deferred until routing/run metadata boundaries are settled.

## Verification

This document is planning-only. Verifying this slice should not move scripts,
change installer behavior, migrate state, or alter lifecycle semantics.

Expected checks:

```bash
git status --short --branch
git diff --stat
test -f docs/AGENTOPS-PACKAGING-BOUNDARIES.md
grep -q 'repo/.agentops' docs/AGENTOPS-PACKAGING-BOUNDARIES.md
grep -q 'skills/agentops-coder' docs/AGENTOPS-PACKAGING-BOUNDARIES.md
grep -q 'scripts/' docs/AGENTOPS-PACKAGING-BOUNDARIES.md
grep -q '.agentops-runs' docs/AGENTOPS-PACKAGING-BOUNDARIES.md
scripts/check-agentops-lifecycle.sh
```
