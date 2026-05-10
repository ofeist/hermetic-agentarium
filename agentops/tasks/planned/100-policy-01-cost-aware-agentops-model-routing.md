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

Add a short policy document describing:

- default orchestrator model
- executor/coder model
- helper model role
- senior reviewer model role
- how the operator explicitly requests senior review
- where this policy lives: repo docs, Hermes profile, task metadata, or a combination

## Non-goals

- no automatic model classifier
- no mandatory GPT-5.5 review for every task
- no pricing dashboard
- no provider lock-in

## Open questions

- Should `senior_review_required: true` become task metadata later?
- Should senior review be requested via helper script, rendered prompt, or Hermes command?
- Should this policy be repo-local or profile-local?

## Promotion criteria

Promote to ready when the target doc location is chosen.

## Suggested verification

```bash
grep -R "senior reviewer\|model routing\|GPT-5.5" docs profiles skills agentops 2>/dev/null || true
```
