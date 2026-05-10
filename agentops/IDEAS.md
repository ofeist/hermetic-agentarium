# AgentOps Ideas

Raw inbox for unrefined AgentOps ideas, bug suspicions, follow-ups, and one-liners.

This file is intentionally lightweight and informal.

Items here are not ready tasks.
Do not execute directly from this file.

## Inbox

- document the canonical Hermes/coder minimal execution prompt in SOUL or SKILL
- investigate coordinator model / Codex subscription options
- consider adding a helper for task ID allocation tracking on planned -> ready promotion

## Observability plan

Goal: make the Hermes / coder / OpenCode AgentOps workflow observable without
increasing model context or token usage.

Core principle:

> Observe to local files first. Export later. Never paste full observability
> logs into model prompts by default.

Why this matters:

- one task may involve Hermes parent context, OpenCode executor prompt,
  executor stdout/stderr, review prompt, git diff/test output, repeated
  revise/review rounds, and long-running session history
- we need to know where time, prompt size, output size, and token pressure are
  coming from

Existing foundation:

- ready task files under `agentops/tasks/ready/`
- bounded executor prompt generation
- OpenCode invocation via `scripts/run-opencode-executor.sh`
- local run artifacts under `.agentops-runs/<run-id>/`
- independent review via `scripts/review-executor-result.sh`
- explicit review outcomes: accept, revise, revert, no-op / nothing to accept, blocked

Suggested next observability ideas:

### observability-next — Add AgentOps run outcome metadata

Goal: connect executor run cost signals with the value of the result.

Idea:

- record a small outcome file or extend run metadata after review
- capture fields such as `decision`, `changed_files_count`, `diff_bytes`,
  `diff_stat_lines`, and `verification_exit_code`
- make it possible to distinguish useful accepted runs from no-op, blocked,
  revise, or revert outcomes

Why:

Prompt size, duration, stdout/stderr size, and exit code show activity. Outcome
metadata shows whether that activity produced useful value. This is the first
step toward detecting waste such as large prompts that lead to no diff, repeated
revise loops, or successful executor runs that are later rejected.

Non-goals:

- no dashboard
- no token accounting
- no raw log parsing
- no automatic judgment beyond recording review outcome

### observability-next — Add prompt hash to executor metadata

Goal: detect repeated or duplicated executor prompts without reading full prompt
files.

Idea:

- add `prompt_sha256` to `.agentops-runs/<run-id>/metadata.txt`
- keep existing `prompt_bytes` and `prompt_lines` fields
- later, add an aggregate helper that can show duplicate prompt hashes across
  runs and tasks

Why:

If the same prompt is sent multiple times, especially after failed or no-op
runs, the workflow may be wasting model calls without changing the input. A
prompt hash makes duplicate detection cheap and safe because summaries can show
hashes and counts instead of pasting prompt content.

Non-goals:

- no semantic prompt diffing
- no prompt content export
- no model-token calculation
- no automatic rerun prevention

Final target architecture:

```text
Hermes / coder
  -> AgentOps scripts
  -> .agentops-runs/<run-id>/metadata.txt
  -> local summary helper
  -> Prometheus textfile export or /metrics exporter
  -> Prometheus
  -> Grafana
```

Invariants:

- Observability must not significantly increase token usage.
- Raw logs stay local by default.
- Prompts should contain paths, counts, hashes, and short summaries, not full logs.
- Full stdout/stderr should only be read when debugging.
- Prometheus/Grafana are export layers, not the first source of truth.
- Local `.agentops-runs/` artifacts remain the canonical run record.
- The first implementation should be shell-script simple.

## Task ID allocation tracking

Goal: make the next `TASK-XXXX` ID explicit when a planned task is promoted to
`ready/`.

Problem:

- planned tasks intentionally use soft workstream-local names
- the exact `TASK-XXXX` ID is assigned only at promotion time
- without a small tracking mechanism, agents must infer the next ID by scanning
  lifecycle folders
- inference can race with concurrent work or miss a task in another lifecycle
  directory

Possible task:

- add a small task ID allocation helper or ledger
- determine the next available `TASK-XXXX` across lifecycle folders
- reserve or assign the ID during planned-to-ready promotion
- make collisions explicit instead of relying on filename guessing

Possible shapes:

- `scripts/next-agentops-task-id.sh`
- `scripts/promote-agentops-task.sh <planned-file>`
- `agentops/task-id-ledger.txt`

Policy:

- planned tasks keep soft names
- `TASK-XXXX` IDs become authoritative only in `ready/` and later lifecycle
  states
- promotion should be the moment where the ID is assigned and recorded

## Hermes/coder collection prompt helper idea

Goal: formalize the prompt used to hand a ready AgentOps task to the
Hermes/coder orchestrator.

Problem:

- ready tasks include a collection prompt, but humans still copy/paste and
  adapt it manually
- repeated prompt text increases the chance of drift
- missing details can break the workflow, especially:
  - not invoking `/hermetic-coding-orchestrator`
  - running executor work on `main`
  - losing `OPENCODE_XDG_CONFIG_HOME`, `OPENCODE_XDG_DATA_HOME`, or
    `AGENTOPS_EXECUTOR_MODEL`
  - accidentally allowing model fallback
  - committing from the executor instead of returning results for review

Possible task:

- add a helper such as `scripts/render-hermes-coder-collection-prompt.sh`
- input: `agentops/tasks/ready/TASK-xxxx-slug.md`
- output: the canonical Hermes/coder collection prompt
- optionally validate that the task is under `agentops/tasks/ready/`
- optionally include task-specific extra requirements from the task body if a
  stable marker is introduced later

Initial canonical prompt shape:

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-XXXX-short-title.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- create/switch to an appropriate task branch
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
Review:
Changed files:
Uncertainty:
```

Non-goals:

- no model hardcoding in prompts
- no executor behavior changes
- no automatic commit/push
- no replacement for the review prompt flow

Why:

The collection prompt is part of the workflow contract. It should be generated
from one canonical source instead of being manually reconstructed each time.

## Promotion path

When an idea becomes actionable, promote it gradually:

    IDEAS.md
      -> agentops/tasks/planned/
      -> agentops/tasks/ready/
      -> agentops/tasks/running/
      -> agentops/tasks/review/
      -> agentops/tasks/done/
      -> agentops/results/

Meaning:

- `IDEAS.md` = do not forget this
- `planned/` = think this through
- `ready/` = executor can do this
- `done/` + `results/` = reviewed outcome

Keep this simple. Do not turn this file into a Jira clone.

## Cost-aware AgentOps model routing

Goal: reduce expensive model usage while keeping review quality available when
it actually matters.

Idea:

- Use a cheaper/default Hermes coordinator model for normal orchestration, for
  example GPT-5.3.
- Use OpenCode plus the configured coder model for implementation work, for
  example DeepSeek Pro 4.
- Use a fast/cheap helper model for small mechanical helper work, for example
  DeepSeek Flash.
- Keep GPT-5.5 available as an explicit senior reviewer, not as an always-on
  default step.

Important distinction:

- Do not try to classify tasks as "small" or "large" too early.
- The deterministic workflow should be lifecycle-based, not model-guess based.
- Every task should go through the same basic states:
  `ready/ -> running/ -> review/ -> done/`.
- Expensive senior review should be an explicit operator action or a
  repo-specific policy decision, not hidden magic.

Possible future shape:

```text
Default:
- orchestrator: GPT-5.3
- coder: OpenCode + DeepSeek Pro 4
- helper runner: DeepSeek Flash
- senior reviewer: GPT-5.5 on demand
```

Principle:

> cheap models do work, scripts verify reality, expensive models review
> compressed evidence only when explicitly requested or when policy requires it.

Open questions:

- How should the operator request senior review?
- Should senior review be triggered by a helper script, a rendered prompt, or a
  Hermes command?
- Should the task file include `senior_review_required: true` later?
- Should this routing live in repo policy, Hermes profile config, or task
  metadata?

## Review-folder lifecycle after executor completion

Goal: make the post-coder handoff explicit by moving completed executor tasks
into `agentops/tasks/review/` before final acceptance.

Idea:

- When a coder/executor finishes a ready task, the task should move from
  `ready/` or `running/` into `review/`.
- `review/` becomes the canonical place for human/parent/reviewer inspection.
- Acceptance then moves the task from `review/` to `done/`.
- This should reduce ambiguity around tasks that have implementation output but
  have not yet been accepted.

Open questions:

- Should moving to `review/` happen before or after local verification?
- Should failed executor runs also move to `review/`, or stay in `running/`
  with a blocked status?
- Should `review/` include a generated review packet or summary file?

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

## Branches vs worktrees for AgentOps execution

Goal: evaluate whether AgentOps should standardize on normal git branches, git
worktrees, or support both.

Idea:

- Current thinking around per-worktree execution may make isolation cleaner, but
  it can also make merging back to main more confusing.
- Normal branches may be simpler as the default:
  - create/switch task branch
  - run executor
  - review diff
  - merge/squash into main after acceptance
- Worktrees may still be useful for parallel executor runs, large repos, or when
  the operator wants multiple tasks open at once.

Open questions:

- Is branch-only enough for the MVP workflow?
- When is a worktree actually worth the added complexity?
- How should a task branch map to a task id?
- If the repo is large, do worktrees save time or create operational friction?
- What is the cleanest path from reviewed task branch back to main?

## Helper scripts for workflow improvements

Goal: identify small helper scripts that make the AgentOps lifecycle more
deterministic without overbuilding a full task platform.

Candidate helpers:

- move task to `review/`
- render review packet from task + diff + verification output
- request senior review with an explicit model
- check lifecycle consistency across `ready/`, `running/`, `review/`, and
  `done/`
- summarize executor run artifacts without exposing raw logs/secrets
- prepare merge/accept checklist for a reviewed task
- optionally create a local review commit after executor completion

Principle:

- helpers should automate boring mechanical steps
- helpers should not hide review decisions
- parent/operator remains responsible for accept/revise/revert/no-op/blocked
