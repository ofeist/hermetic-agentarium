# TASK-0072 — Reduce historical lifecycle warnings

## Status

ready

## Goal

Reduce lifecycle checker noise from known historical done tasks without hiding
future lifecycle drift.

## Background

TASK-0071 added `scripts/check-agentops-lifecycle.sh`. The checker exits
successfully on the current repository, but it reports repeated warnings for
historical done tasks without result notes.

Those tasks predate consistent result-note creation. We should not create fake
retroactive result notes that imply a proper closeout happened at the time.
Instead, document the known historical drift in an explicit baseline so the
checker remains quiet for known history and strict for future drift.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- scripts/check-agentops-lifecycle.sh
- agentops/tasks/done/
- agentops/results/
- agentops/tasks/ready/TASK-0072-reduce-historical-lifecycle-warnings.md

## Write scope

- scripts/check-agentops-lifecycle.sh
- agentops/lifecycle/historical-baseline.txt

Do not modify docs or other task lifecycle files unless a verification failure
proves it is necessary.

## Requirements

- The execution prompt MUST start with `/hermetic-coding-orchestrator` to explicitly invoke the custom skill.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near the beginning of its Plan or output.
- Keep the change minimal.
- Do not commit.
- Do not modify unrelated files.
- Do not read or print secrets.
- Executor model selection is controlled by runner configuration, not by task prompt text.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking OpenCode.

Add an explicit historical lifecycle baseline file:

```text
agentops/lifecycle/historical-baseline.txt
```

The baseline should clearly explain:

- listed tasks predate consistent result-note creation
- listed tasks are tolerated as historical drift only
- new done tasks should not be added without explicit review

Update `scripts/check-agentops-lifecycle.sh` so:

- a done task missing a result note and listed in the baseline does not produce a repeated warning
- a done task missing a result note and not listed in the baseline still produces a warning
- checker output stays compact and trustworthy
- checker exits zero when there are no errors and only baselined historical missing-result cases

Optional output example:

```text
Historical baseline entries tolerated: 13
Errors: 0
Warnings: 0
```

The baseline should include the currently known historical done tasks without
result notes as reported by `scripts/check-agentops-lifecycle.sh`.

## Non-goals

- No synthetic result notes.
- No lifecycle semantic changes.
- No task renumbering.
- No executor behavior changes.
- No observability work.
- No broad queue reconciliation.
- No Prometheus/Grafana work.

## Verification

Run:

```bash
bash -n scripts/check-agentops-lifecycle.sh
scripts/check-agentops-lifecycle.sh
git status --short --branch
git diff --stat
```

If practical, also run a synthetic negative check:

- create a temporary done task missing a result note and not listed in the baseline
- verify `scripts/check-agentops-lifecycle.sh` still reports a warning for it
- remove the temporary task before returning

## Accept criteria

- `agentops/lifecycle/historical-baseline.txt` exists and explains the policy.
- Known historical done tasks without result notes no longer create repeated noisy warnings.
- A missing result note for a non-baselined done task is still detected as a warning.
- `scripts/check-agentops-lifecycle.sh` exits successfully on the current repository state.
- No synthetic result notes are created.
- No task IDs are renumbered.
- No executor or observability behavior is changed.
- Diff stays within write scope.

## Hermes/coder collection prompt

Use this prompt to collect and execute the task through the Hermes/coder
orchestrator.

```text
/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0072-reduce-historical-lifecycle-warnings.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- create/switch to an appropriate task branch
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME, OPENCODE_XDG_DATA_HOME, and AGENTOPS_EXECUTOR_MODEL
- use the runner-configured executor model
- do not silently fallback to another model
- do not commit
- independently verify the result
- do not create synthetic result notes
- do not perform broad ready queue reconciliation

Return:
Plan:
Implementation:
Verification:
Review:
Changed files:
Uncertainty:
```

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
