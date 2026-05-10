# policy-01 — Cost-aware AgentOps model routing

## Status

planned

## Goal

Define a simple, lifecycle-based model routing policy that reduces expensive model usage without hiding review quality behind magic heuristics.

## Background / why now

`IDEAS.md` proposes cheaper default orchestration, OpenCode plus a configured coder model for implementation, cheap helper models for mechanical work, and GPT-5.5 as an explicit senior reviewer.

The important principle is that deterministic workflow should be lifecycle-based, not based on guessing whether a task is small or large.

## Problem statement

If every review or orchestration step uses the most expensive model, the workflow becomes costly. If model choice is hidden behind vague size classification, the workflow becomes non-deterministic and hard to reason about.

## Smallest useful slice

Add a short policy document describing deterministic, lifecycle-based model routing roles and how the operator explicitly requests senior review.

## Executor

Harness: TBD.
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`).
Fallback: disabled.

## Read scope

- AgentOps workflow documentation
- `profiles/coder/SOUL.md`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- relevant task templates
- relevant model/provider configuration documentation, without reading secrets

## Write scope

- one policy or workflow documentation file
- optional references from profile/skill docs only if needed
- no runtime configuration changes in this slice

## Requirements

The policy document should describe:

- default orchestrator model role
- executor/coder model role
- helper model role
- senior reviewer model role
- how the operator explicitly requests senior review
- where this policy lives: repo docs, Hermes profile, task metadata, or a combination

The policy should be deterministic and lifecycle-based rather than based on vague task-size guessing.

## Non-goals

- Do not add an automatic model classifier.
- Do not require GPT-5.5 review for every task.
- Do not build a pricing dashboard.
- Do not introduce provider lock-in.
- Do not change runtime model configuration in this slice.

## Open questions

- Should `senior_review_required: true` become task metadata later?
- Should senior review be requested via helper script, rendered prompt, or Hermes command?
- Should this policy be repo-local or profile-local?
- Which document should own the first version of the policy?

## Verification

```bash
git status --short --branch
grep -R "senior reviewer\|model routing\|GPT-5.5" docs profiles skills agentops 2>/dev/null || true
git diff --stat
```

If profile or skill files are touched, verify the relevant installation or documentation checks if available.

## Accept criteria

TBD during promotion.

## Promotion decision

Decision: keep_planned.

Reason:
The target doc location and request mechanism for senior review are not yet chosen.

Next action:
Choose the target doc location and decide how senior review is requested in v1.

## Promotion criteria

Promote to `ready` when:

- the target doc location is chosen
- the v1 senior-review request mechanism is chosen or explicitly deferred
- the lifecycle-based routing roles are bounded
- read/write scope is confirmed

## Hermes/coder collection prompt

TBD during promotion.

## Return format

TBD during promotion.

## Notes

Keep this as a policy/design slice. Avoid implicit heuristics such as “small task” unless they are made deterministic and observable.
