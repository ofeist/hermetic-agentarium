# skill-01-improve-installer-support-if-needed - Fix coder-profile skill installation/discovery

## Status

planned

## Goal

Implement a narrow installer/profile-wiring fix so that
`/hermetic-coding-orchestrator` works when Hermes is launched with the `coder`
profile, not only when Hermes is launched with the default profile.

Do this without changing the skill name, slash invocation, audit marker, runtime
helper behavior, OpenCode executor behavior, or AgentOps lifecycle behavior.

## Background / why now

`skill-00-package-hermetic-orchestrator` packaged the existing
`skills/hermetic-coding-orchestrator/` as a Hermes-native local skill and kept
the existing compatibility contract:

- `name: hermetic-coding-orchestrator`
- `/hermetic-coding-orchestrator`
- `USING_SKILL: hermetic-coding-orchestrator`

After running the installer and restarting the `coder` profile, invoking the
skill from the `coder` profile failed with:

```text
Unknown command: /hermetic-coding-orchestrator
```

However, invoking the same skill from the default Hermes profile worked and
loaded the skill from:

```text
/home/splinter/.hermes/skills/hermetic-coding-orchestrator
```

This means the skill package itself is valid and discoverable by default Hermes,
but the `coder` profile does not currently see the same installed skill or does
not have equivalent skill-discovery wiring.

Hermes profiles are intentionally isolated. A profile may have its own config,
environment, `SOUL.md`, sessions, state, and skills. Therefore this is not a
core skill-package failure. It is a profile installation/discovery gap.

## Problem statement

The current install/profile setup makes the skill visible to default Hermes, but
not reliably visible when using the `coder` profile.

The installer must either:

1. install/sync the skill into the `coder` profile's discoverable skills path, or
2. configure the `coder` profile to discover the shared/local skill location, or
3. document and implement the repo's chosen supported install mode clearly.

The fix must be narrow and idempotent.

## Smallest useful slice

Make the existing `scripts/install-coder-profile.sh` install or preserve the
minimum required skill/profile wiring so this command works after install and
restart:

```text
/hermetic-coding-orchestrator
```

when Hermes is launched with the `coder` profile.

The expected response must include:

```text
USING_SKILL: hermetic-coding-orchestrator
```

## Design decision to make in this slice

Inspect the current Hermes/profile layout and choose one supported install
strategy for this repo:

### Option A: profile-local skill copy

Copy/sync the repo skill directory into the `coder` profile's skills directory,
if Hermes stores skills per profile.

Pros:
- strongest profile isolation
- predictable for the `coder` profile
- no dependency on global/default Hermes skill state

Cons:
- duplicated skill copy
- updates must keep profile-local copy in sync

### Option B: shared/global skill plus profile discovery wiring

Install the skill once into the shared/default Hermes skills directory and wire
the `coder` profile to discover it, if Hermes supports this cleanly in the
profile config.

Pros:
- single skill copy
- easier updates

Cons:
- profile config is slightly more complex
- risk of confusion if global/default and profile-local skill versions diverge

### Option C: external skill directory

Configure the `coder` profile to scan the repo's `skills/` directory as an
external skill directory, if this is supported cleanly by Hermes profile config.

Pros:
- no copy step
- repo remains source of truth
- useful during local development

Cons:
- requires the repo path to exist
- may be less portable for users who move the repo
- must be documented clearly

The task should choose the smallest reliable approach after inspecting the
actual local/profile config behavior.

## Executor

Harness: TBD (default in this repo: OpenCode)  
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)  
Fallback: disabled

## Read scope

- `scripts/install-coder-profile.sh`
- `skills/hermetic-coding-orchestrator/SKILL.md`
- `skills/hermetic-coding-orchestrator/README.md`
- `profiles/coder/SOUL.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `agentops/tasks/done/TASK-0092-package-hermetic-orchestrator-skill.md`
- `agentops/results/TASK-0092-package-hermetic-orchestrator-skill-result.md`

Also inspect local Hermes/profile config paths as needed, without reading or
printing secrets:

- `~/.hermes/config.yaml`
- `~/.hermes/profiles/coder/config.yaml`
- `~/.hermes/profiles/coder/SOUL.md`
- installed skill directory paths
- skill list output

Do not read or print `.env`, auth files, tokens, API keys, SSH keys, or private
credential files.

## Write scope

Primary:

- `scripts/install-coder-profile.sh`
- `docs/INSTALL.md`

Optional, only if needed for discoverability documentation:

- `docs/DOCUMENTATION-MAP.md`
- `skills/hermetic-coding-orchestrator/README.md`

Do not modify runtime helper scripts, executor helpers, or lifecycle helpers.

## Requirements

- Fix the confirmed gap: `/hermetic-coding-orchestrator` must work from the
  `coder` profile after running the installer and restarting Hermes.
- Preserve existing installer behavior outside the proven skill/profile wiring
  gap.
- Keep the installer idempotent.
- Keep the skill name unchanged:
  `hermetic-coding-orchestrator`.
- Keep the slash invocation unchanged:
  `/hermetic-coding-orchestrator`.
- Keep the audit marker unchanged:
  `USING_SKILL: hermetic-coding-orchestrator`.
- Do not modify runtime helper behavior.
- Do not modify OpenCode executor behavior.
- Do not modify lifecycle helper behavior.
- Do not read, print, or modify secrets.
- Document the chosen install/discovery strategy clearly enough that a user can
  repeat it on a fresh machine.

## Non-goals

- No skill rename.
- No migration from `agentops/` to `.agentops/`.
- No runtime helper behavior changes.
- No lifecycle helper changes.
- No OpenCode executor behavior changes.
- No observability packaging work.
- No broad installer rewrite.
- No result-note replayability workflow hardening.
- No automatic task-directory bootstrap unless needed purely for installer
  verification; if missing task structure is discovered, capture it as a
  follow-up task instead.

## Open questions

- Does the `coder` profile use a profile-local skill directory, shared global
  skill directory, external skill directory config, or some combination?
- Should this repo prefer profile-local skill copy, shared/global discovery
  wiring, or repo `skills/` as an external skill directory?
- Should `scripts/install-coder-profile.sh` install only the profile/SOUL, or
  should it become the canonical installer for the profile plus required skills?
- Should future bootstrapping create the AgentOps task directory structure
  automatically, or should that be handled by a separate initialization helper?

## Promotion decision

Decision: promote

Reason:
A real installer/profile discovery gap has been confirmed. The skill works in
default Hermes but fails as an unknown slash command in the `coder` profile,
which is the profile normally used for this workflow.

Next action:
Promote this task to `ready/` as a narrow installer/profile-wiring fix.

## Promotion criteria

This task can be promoted to ready when:

- the ready-task goal explicitly targets the confirmed `coder` profile
  skill-discovery gap
- write scope remains limited to installer and install docs
- verification commands include both default Hermes and `coder` profile checks
- non-goals explicitly exclude runtime helper, lifecycle helper, OpenCode
  executor, rename, and observability changes

## Verification

Planning-only verification:

```bash
git status --short --branch
git diff --stat
```

Implementation verification when promoted:

```bash
git status --short --branch
bash -n scripts/install-coder-profile.sh
./scripts/install-coder-profile.sh
```

Check installed skill files without reading secrets:

```bash
find ~/.hermes -maxdepth 6 -type f -name SKILL.md | sort | grep hermetic-coding-orchestrator
grep -R "hermetic-coding-orchestrator" -n ~/.hermes/config.yaml ~/.hermes/profiles/coder/config.yaml 2>/dev/null || true
```

Check default Hermes visibility:

```bash
hermes skills list | grep hermetic-coding-orchestrator
```

Check `coder` profile visibility:

```bash
hermes --profile coder skills list | grep hermetic-coding-orchestrator
```

Manual slash invocation verification in `coder` profile:

```text
/hermetic-coding-orchestrator Summarize your workflow rules in 3 bullets.
```

Expected result:

```text
USING_SKILL: hermetic-coding-orchestrator
```

Also run:

```bash
scripts/check-agentops-lifecycle.sh
```

## Accept criteria

- Running the installer is idempotent.
- The skill remains visible to default Hermes or at least no existing default
  behavior is broken.
- The skill is visible to `hermes --profile coder`.
- `/hermetic-coding-orchestrator` works inside the `coder` profile after restart.
- The response includes `USING_SKILL: hermetic-coding-orchestrator`.
- The selected install/discovery strategy is documented.
- No unrelated workflow behavior changes are made.
- No secrets are read, printed, copied, or committed.

## Notes

This task was originally conditional on `skill-00` discovering a real installer
gap. The gap is now confirmed by manual validation:

- default Hermes can load `/hermetic-coding-orchestrator`
- `coder` profile reports `Unknown command: /hermetic-coding-orchestrator`

This makes the task actionable.

Recommended follow-up tasks:

- `skill-02-document-skill-activation-troubleshooting`
- `skill-03-package-optional-agentops-observability`
- `skill-04-rename-hermetic-orchestrator-skill`
- `agentops-structure-bootstrap`
- `agentops-rename-root-to-dot-agentops`

### Follow-up: agentops-structure-bootstrap

Possible goal:

```text
Add a small bootstrap/check helper that ensures the required AgentOps directory
structure exists for a fresh clone/profile setup.
```

Candidate directories:

```text
agentops/tasks/planned/
agentops/tasks/ready/
agentops/tasks/running/
agentops/tasks/review/
agentops/tasks/done/
agentops/results/
agentops/templates/
```

Non-goal:
Do not migrate `agentops/` to `.agentops/` in the same task. That should remain
a later migration slice with compatibility planning.
