# workflow-03 — Add Hermes/coder collection prompt helper

## Status

planned

## Goal

Add a helper that renders the canonical Hermes/coder collection prompt for a ready AgentOps task.

## Background / why now

Ready tasks include enough information to start work, but the operator still manually copy/pastes the handoff prompt. `IDEAS.md` notes that repeated prompt text can drift and miss details such as skill invocation, branch safety, environment preservation, model fallback rules, and no-commit behavior.

## Problem statement

Manual prompt construction is a workflow footgun. The collection prompt is part of the execution contract, so it should come from one canonical source.

## Smallest useful slice

Add a script such as:

```bash
scripts/render-hermes-coder-collection-prompt.sh agentops/tasks/ready/TASK-XXXX-slug.md
```

The helper should:

- require the input path to be under `agentops/tasks/ready/`
- render `/hermetic-coding-orchestrator`
- include the ready task path
- include branch, env preservation, no fallback, no commit, and independent verification requirements
- print the prompt to stdout

## Non-goals

- no automatic Hermes invocation
- no executor behavior change
- no model hardcoding
- no commit/push behavior

## Open questions

- Should task-specific extra requirements be parsed later from a stable marker?
- Should this reuse a template file or keep the prompt inside the shell script first?

## Promotion criteria

Promote to ready after the canonical prompt source is documented or accepted as stable enough for the first helper.

## Suggested verification

```bash
bash -n scripts/render-hermes-coder-collection-prompt.sh
scripts/render-hermes-coder-collection-prompt.sh agentops/tasks/ready/TASK-0000-example.md || true
```
