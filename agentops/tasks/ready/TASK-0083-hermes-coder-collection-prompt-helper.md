# TASK-0083 — Add Hermes/coder collection prompt helper

## Status

ready

## Goal

Add a helper that renders the canonical Hermes/coder collection prompt for a ready AgentOps task.

## Background / why now

Ready tasks include enough information to start work, but the operator still manually copy/pastes the handoff prompt. `IDEAS.md` notes that repeated prompt text can drift and miss details such as skill invocation, branch safety, environment preservation, model fallback rules, and no-commit behavior.

This helper renders the **collection/handoff** prompt — the text a human pastes into Hermes/coder to start the parent orchestrator. It is distinct from `scripts/render-opencode-prompt.sh`, which renders the **executor** prompt that the parent then feeds into the OpenCode child. The two layers must not be merged into a single helper.

TASK-0082 resolved the upstream blocker: `skills/hermetic-coding-orchestrator/SKILL.md` is the canonical source for the Hermes/coder execution prompt, and the model wording stays runner-configured via `AGENTOPS_EXECUTOR_MODEL`.

## Problem statement

Manual prompt construction is a workflow footgun. The collection prompt is part of the execution contract, so it should come from one canonical source.

## Smallest useful slice

Add a small script that renders the canonical Hermes/coder collection prompt for one existing ready task path and prints it to stdout.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `skills/hermetic-coding-orchestrator/SKILL.md` (canonical prompt source per TASK-0082)
- `agentops/tasks/ready/`
- existing AgentOps ready task files that already contain collection prompts
- `scripts/`, especially `scripts/render-opencode-prompt.sh` to confirm role separation between collection and executor prompts
- relevant workflow/profile/skill documentation

## Write scope

- `scripts/render-collection-prompt.sh`
- minimal docs update only if needed to document the helper
- minimal tests or shell syntax checks if present

## Requirements

The helper:

- accepts exactly one ready task path, for example:

  ```bash
  scripts/render-collection-prompt.sh agentops/tasks/ready/TASK-XXXX-slug.md
  ```

- requires the input path to be under `agentops/tasks/ready/` and rejects paths outside that directory with a non-zero exit code
- renders `/hermetic-coding-orchestrator`
- includes the ready task path
- includes branch or worktree safety requirements
- includes runtime environment preservation requirements for `OPENCODE_XDG_CONFIG_HOME`, `OPENCODE_XDG_DATA_HOME`, and `AGENTOPS_EXECUTOR_MODEL`
- includes no silent model fallback
- includes no commit behavior
- includes independent verification requirements
- prints the prompt to stdout
- does not invoke Hermes
- does not invoke OpenCode
- does not commit

V1 implementation note:

- Render the canonical prompt shape directly from the script.
- Do not parse `skills/hermetic-coding-orchestrator/SKILL.md` dynamically in this slice.
- Treat SKILL.md as the documented canonical source. Reconciliation of any future prompt drift is a separate task, not this helper's job.

Workflow requirements:

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

## Non-goals

- Do not automatically invoke Hermes.
- Do not change executor behavior.
- Do not hardcode a model.
- Do not add commit or push behavior.
- Do not implement a full task scheduler.
- Do not parse `SKILL.md` dynamically in this slice.
- Do not introduce a third canonical source for the prompt.

## Open questions

None.

Resolved:
- Canonical prompt source: `skills/hermetic-coding-orchestrator/SKILL.md` (per TASK-0082).
- Helper name: `scripts/render-collection-prompt.sh`.
- Input: exactly one path under `agentops/tasks/ready/`.
- Invalid input: reject paths outside `agentops/tasks/ready/` with a non-zero exit.
- Output: print the Hermes/coder collection prompt to stdout.
- No-invoke rule: do not invoke Hermes or OpenCode.
- No-commit rule: helper must not commit.
- Template strategy for v1: render the canonical prompt shape from the script; do not parse SKILL.md dynamically.

## Promotion decision

Decision: promote_to_ready.

Reason:
The canonical prompt source-of-truth direction was resolved by TASK-0082
(`skills/hermetic-coding-orchestrator/SKILL.md` is canonical, model stays
runner-configured). Helper name, input/output contract, and
no-invoke/no-commit rules are decided. The v1 implementation strategy
(render from script, do not parse SKILL.md dynamically) is explicit.

Next action:
Execute through the Hermes/coder collection prompt.

## Promotion criteria

Already promoted to ready.

## Verification

```bash
git status --short --branch
bash -n scripts/render-collection-prompt.sh
# happy path: helper renders prompt to stdout and exits 0
scripts/render-collection-prompt.sh agentops/tasks/ready/TASK-0083-hermes-coder-collection-prompt-helper.md > /dev/null
# negative path: helper rejects paths outside agentops/tasks/ready/
! scripts/render-collection-prompt.sh agentops/tasks/done/whatever.md 2>/dev/null
git diff --stat
```

Do not use `|| true` to mask failures.

## Accept criteria

- Change is limited to write scope.
- Helper renders the canonical collection prompt for a valid ready task path.
- Helper rejects paths outside `agentops/tasks/ready/`.
- Prompt output includes the ready task path and required workflow guardrails.
- Verification commands pass.
- No Hermes or OpenCode process is invoked by this helper.
- Helper does not commit.
- Helper does not parse `SKILL.md` dynamically in this slice.

## Hermes/coder collection prompt

/hermetic-coding-orchestrator

Start working on the ready AgentOps task:

agentops/tasks/ready/TASK-0083-hermes-coder-collection-prompt-helper.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
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
Review:
Changed files:
Uncertainty:

## Return format

Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:

## Notes

This task follows the canonical prompt reconciliation task (TASK-0082).

Keep the first helper mechanical and stdout-only. Dynamic extraction from
SKILL.md is deferred — if prompt drift between SKILL.md and this helper
becomes a real problem, address it in a separate task rather than expanding
this slice.
