# workflow-02 — Add Hermes/coder collection prompt helper

## Status

planned

## Goal

Add a helper that renders the canonical Hermes/coder collection prompt for a ready AgentOps task.

## Background / why now

Ready tasks include enough information to start work, but the operator still manually copy/pastes the handoff prompt. `IDEAS.md` notes that repeated prompt text can drift and miss details such as skill invocation, branch safety, environment preservation, model fallback rules, and no-commit behavior.

This helper renders the **collection/handoff** prompt — the text a human pastes into Hermes/coder to start the parent orchestrator. It is distinct from `scripts/render-opencode-prompt.sh`, which renders the **executor** prompt that the parent then feeds into the OpenCode child. The two layers must not be merged into a single helper.

## Problem statement

Manual prompt construction is a workflow footgun. The collection prompt is part of the execution contract, so it should come from one canonical source.

## Smallest useful slice

Add a small script that renders the canonical Hermes/coder collection prompt for one existing ready task path and prints it to stdout.

## Executor

Harness: TBD.
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- canonical Hermes/coder execution prompt source, once chosen
- `agentops/tasks/ready/`
- existing AgentOps ready task files that already contain collection prompts
- `scripts/`, especially `scripts/render-opencode-prompt.sh` to confirm role separation between collection and executor prompts
- relevant workflow/profile/skill documentation

## Write scope

- one helper script, likely `scripts/render-collection-prompt.sh` (shorter form chosen to fit the existing `render-*.sh` family; final name confirmed at promotion)
- minimal docs update only if needed to document the helper
- minimal tests or shell syntax checks if present

## Requirements

The helper should:

- accept one ready task path, for example:

  ```bash
  scripts/render-collection-prompt.sh agentops/tasks/ready/TASK-XXXX-slug.md
  ```

- require the input path to be under `agentops/tasks/ready/` and reject paths outside that directory with a non-zero exit code
- render `/hermetic-coding-orchestrator`
- include the ready task path
- include branch or worktree safety requirements
- include runtime environment preservation requirements for `OPENCODE_XDG_CONFIG_HOME`, `OPENCODE_XDG_DATA_HOME`, and `AGENTOPS_EXECUTOR_MODEL`
- include no silent model fallback
- include no commit behavior
- include independent verification requirements
- print the prompt to stdout

## Non-goals

- Do not automatically invoke Hermes.
- Do not change executor behavior.
- Do not hardcode a model.
- Do not add commit or push behavior.
- Do not implement a full task scheduler.

## Open questions

- Should task-specific extra requirements be parsed later from a stable marker?
- Should this reuse a template file or keep the prompt inside the shell script first?
- Should this wait until the canonical prompt source from `profile-01` is finalized?

## Verification

```bash
git status --short --branch
bash -n scripts/render-collection-prompt.sh
git diff --stat
```

When promoted, replace the path placeholder with a real ready-task fixture and add both a positive and a negative path-validation check, e.g.:

```bash
# happy path: helper renders prompt to stdout and exits 0
scripts/render-collection-prompt.sh agentops/tasks/ready/<real-or-fixture>.md > /dev/null

# negative path: helper rejects paths outside agentops/tasks/ready/
! scripts/render-collection-prompt.sh agentops/tasks/done/whatever.md 2>/dev/null
```

Do not use `|| true` to mask failures.

## Accept criteria

TBD during promotion.

## Promotion decision

Decision: keep_planned.

Reason:
The canonical prompt source is not yet finalized. Promoting this helper before the prompt contract is stable could bake duplicated prompt text into a script.

Next action:
Finalize or accept the canonical prompt source, then promote this helper task.

## Promotion criteria

Promote to `ready` when:

- the canonical prompt source is documented or accepted as stable enough for the first helper
- the helper name is confirmed
- input validation behavior is decided
- read/write scope is confirmed

## Hermes/coder collection prompt

TBD during promotion.

## Return format

TBD during promotion.

## Notes

This task should follow the canonical prompt documentation task. Keep the first helper mechanical and stdout-only.
