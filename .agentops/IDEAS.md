# AgentOps Ideas

Raw inbox for unrefined AgentOps ideas, bug suspicions, follow-ups, and one-liners.

This file is intentionally lightweight and informal.

Items here are not ready tasks.
Do not execute directly from this file.

## Inbox

- investigate coordinator model / Codex subscription options
- package `skills/hermetic-coding-orchestrator/` as a proper Hermes-native
  skill and include AgentOps observability as an optional install component:
  - install skill instructions plus optional support files for safe local run
    inspection
  - possible components: `.agentops-runs/` contract docs, run metadata capture
    helpers, run summary helper, prompt-hash metadata support, outcome metadata
    writer, optional Prometheus exporter, future Grafana example
  - guardrails: observability remains optional, do not export raw prompts, do
    not commit raw logs, prefer metadata/hashes/counts/sizes/summaries, keep
    Prometheus/Grafana as an optional later layer
- reconcile `.agentops/USAGE.md` lines 47–94 ("Minimal task file") with the
  templates. The inline sketch uses section names (`Constraints`,
  `Implementation requirements`, `Decision states`) that don't match either
  `PLANNED-TASK-TEMPLATE.md` or `READY-TASK-TEMPLATE.md`. Replace the
  duplicated skeleton with a pointer to the templates so there is one source
  of truth for ready-task structure.
- improve review packet separation of lifecycle state and implementation diff:
  recent TASK-0083 review showed that a stateless reviewer can mistake the
  expected `ready/ -> review/` lifecycle move for implementation scope drift
  - review packets should explicitly separate lifecycle state changes,
    implementation diff, and verification evidence
  - reviewer prompt should explicitly evaluate implementation diff and
    verification evidence, while treating expected lifecycle moves as workflow
    state
  - guardrails: do not hide lifecycle moves, do not ignore unexpected file
    changes, and only mark known lifecycle moves as expected
- agentops-structure-bootstrap: helper that scaffolds a fresh AgentOps
  layout in a target repo:
  - install the `coder` profile (e.g. into `profiles/coder/` or
    `~/.hermes/profiles/coder/`, mirroring `scripts/install-coder-profile.sh`)
  - create the AgentOps lifecycle directory tree:
    - `.agentops/tasks/planned/`
    - `.agentops/tasks/ready/`
    - `.agentops/tasks/running/`
    - `.agentops/tasks/review/`
    - `.agentops/tasks/done/`
    - `.agentops/results/`
    - `.agentops/templates/`
  - intent: turn "set up AgentOps in a new repo" from a manual checklist
    into one command
  - open questions: idempotency (refuse vs reuse existing dirs), whether
    to seed the templates dir, profile install scope (repo-local vs
    `~/.hermes/`), interaction with `scripts/install-coder-profile.sh`
- fix `scripts/accept-agentops-task.sh` to update done task status:
  recent TASK-0084, TASK-0085, and TASK-0086 closeouts had the same lifecycle
  drift: task file moved to `.agentops/tasks/done/` but internal `## Status`
  remained `review`
  - on accept, update moved task status from `review` to `done`
  - verification:
    - create temp review task fixture
    - run accept helper
    - assert file moved to `done/`
    - assert internal status is `done`
    - run `scripts/check-agentops-lifecycle.sh`
- investigate failing AgentOps fixture demo:
  - Goal:
    Check whether the current workflow already demonstrates failed verification handling.
    If not, add a small deterministic fixture showing:
    bad patch -> failing test -> narrow fix or blocked result with diff + rerun command.
  - Non-goal:
    Do not redesign the whole loop before inspecting what already exists.

## Result note replayability after lifecycle closeout

Problem:
Some verification commands are valid only before lifecycle closeout, while the
task file is still under `.agentops/tasks/ready/`. After closeout, the task is
moved to `.agentops/tasks/done/`, and those commands may no longer be replayable.

Example:
`scripts/render-collection-prompt.sh` accepts ready-task paths, but a result
note may later record or rewrite the command with an `.agentops/tasks/done/...`
path.

Goal:
Clarify result note conventions so audit notes distinguish between:
- pre-closeout verification
- post-closeout replayable verification

Possible implementation:
- update result note template/conventions
- document that ready-path-only helpers must not be recorded as post-closeout
  replayable checks
- optionally add a lifecycle/result checker warning for patterns like:
  `render-collection-prompt.sh .agentops/tasks/done/`

Non-goals:
- do not change `render-collection-prompt.sh` behavior unless separately
  justified
- do not reopen completed task implementations just to rewrite old audit notes

## Commit boundary after task enters review

Goal: explore whether there should be an optional commit boundary after a coder
task is ready for review.

Idea:

- After executor/coder work is complete and the task is moved to `review/`,
  optionally create a local commit containing the implementation diff.
- The review then happens against a stable commit instead of a loose worktree
  diff.
- Final acceptance can merge, squash, cherry-pick, or rework that commit
  depending on the chosen workflow.

Why:

- A commit can make review cleaner and easier to revert.
- It can preserve executor output before reviewer edits.
- It may help separate "implementation produced by coder" from "review fixes by
  parent/operator".

Open questions:

- Should this be optional or mandatory?
- Should the commit be local-only until accepted?
- Should the commit message include the task id?
- Should the parent be allowed to amend the executor commit, or should review
  fixes become a second commit?

## Remove deprecated hermetic-coding-orchestrator bridge

After at least one full follow-up task cycle with `/agentops-coder` as canonical,
remove the deprecated `/hermetic-coding-orchestrator` bridge to avoid duplicated
skill-body drift.

Until removal, canonical edits must be made in `skills/agentops-coder/SKILL.md`
and mirrored into `skills/hermetic-coding-orchestrator/SKILL.md`.

## Promotion path

When an idea becomes actionable, promote it gradually:

    IDEAS.md
      -> .agentops/tasks/planned/
      -> .agentops/tasks/ready/
      -> .agentops/tasks/running/
      -> .agentops/tasks/review/
      -> .agentops/tasks/done/
      -> .agentops/results/

Meaning:

- `IDEAS.md` = do not forget this
- `planned/` = think this through
- `ready/` = executor can do this
- `done/` + `results/` = reviewed outcome

Keep this simple. Do not turn this file into a Jira clone.
