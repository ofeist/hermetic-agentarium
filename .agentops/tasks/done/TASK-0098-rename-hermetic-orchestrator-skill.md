# TASK-0098 — Rename hermetic-coding-orchestrator skill to agentops-coder

## Status

done

## Goal

Rename the canonical skill identity to `agentops-coder` with canonical slash
invocation `/agentops-coder` and canonical audit marker
`USING_SKILL: agentops-coder`, while preserving backward compatibility for
`/hermetic-coding-orchestrator` during a defined transition window.

## Background / why now

The `.agentops/` structure migration is complete and bootstrap is in place, so
the remaining naming migration can proceed against stable paths.

The current canonical contract is still:

- skill name: `hermetic-coding-orchestrator`
- slash invocation: `/hermetic-coding-orchestrator`
- audit marker: `USING_SKILL: hermetic-coding-orchestrator`

The shorter canonical name is now decided:

- skill name: `agentops-coder`
- slash invocation: `/agentops-coder`
- audit marker: `USING_SKILL: agentops-coder`

## Problem statement

The current name is long and referenced across installer docs, templates,
prompt renderers, and profile guidance. A hard cut with no transition would
break existing slash-invocation habits and make historical comparisons harder
during rollout.

Hermes slash commands are registered from installed skills by each skill's
`SKILL.md` frontmatter `name`. A compatibility alias is not implicit just
because docs mention one. Compatibility must be represented as a real installed
skill entrypoint.

## Smallest useful slice

Execute a staged rename with compatibility:

1. Introduce `agentops-coder` as canonical skill name, slash invocation, and
   audit marker.
2. Keep `/hermetic-coding-orchestrator` working as a compatibility bridge skill
   during transition.
3. Update active generators/templates/docs/scripts to emit/use canonical
   `/agentops-coder` + `USING_SKILL: agentops-coder`.
4. Document compatibility window and explicit removal criteria.

Compatibility removal is a separate follow-up task and not in this slice.

## Executor

Harness: OpenCode
Model source: runner configuration (`AGENTOPS_EXECUTOR_MODEL`)
Fallback: disabled

## Read scope

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `.agentops/tasks/ready/TASK-0092-package-hermetic-orchestrator-skill.md`
- `.agentops/templates/PLANNED-TASK-TEMPLATE.md`
- `.agentops/templates/READY-TASK-TEMPLATE.md`
- `scripts/render-collection-prompt.sh`
- `scripts/render-opencode-prompt.sh`
- `scripts/install-coder-profile.sh`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `README.md`
- `.agentops/USAGE.md`
- `profiles/coder/SOUL.md`

## Write scope

- `skills/hermetic-coding-orchestrator/SKILL.md` (compatibility bridge content)
- `skills/hermetic-coding-orchestrator/README.md`
- `skills/agentops-coder/SKILL.md` (new canonical skill entrypoint)
- `skills/agentops-coder/README.md` (new canonical package docs)
- `scripts/render-collection-prompt.sh`
- `scripts/render-opencode-prompt.sh`
- `scripts/install-coder-profile.sh`
- `.agentops/templates/PLANNED-TASK-TEMPLATE.md`
- `.agentops/templates/READY-TASK-TEMPLATE.md`
- `profiles/coder/SOUL.md`
- `docs/INSTALL.md`
- `docs/DOCUMENTATION-MAP.md`
- `README.md`
- `.agentops/USAGE.md`
- `.agentops/tasks/ready/` (promotion file move if this planned task becomes ready)
- `.agentops/tasks/done/` and `.agentops/results/` during lifecycle closeout only

## Requirements

- Canonical skill name becomes `agentops-coder`.
- Canonical slash invocation becomes `/agentops-coder`.
- Canonical audit marker becomes `USING_SKILL: agentops-coder`.
- Implement compatibility as two installed skills:
  - `skills/agentops-coder/SKILL.md` with `name: agentops-coder` (canonical).
  - `skills/hermetic-coding-orchestrator/SKILL.md` with
    `name: hermetic-coding-orchestrator` (deprecated bridge entrypoint).
- Do not change old skill frontmatter name to `agentops-coder`; old slash
  command must remain registered via its own skill name.
- Preserve backward compatibility for `/hermetic-coding-orchestrator` via the
  bridge skill during transition.
- Compatibility policy:
  - Keep old slash invocation functional for at least one full follow-up task
    cycle after this rename lands.
  - Old invocation must route to the same behavior contract as canonical.
  - During transition, output may include both markers, but canonical marker
    `USING_SKILL: agentops-coder` must be present.
  - Define explicit alias-removal criteria in docs (no silent removal).
- Update generators/templates/scripts/docs so newly generated prompts use
  `/agentops-coder` and canonical marker.
- Preserve behavior contract (worktree policy, lifecycle ownership, executor
  constraints); this is a naming migration, not a workflow redesign.
- Keep historical `.agentops/tasks/done/` and `.agentops/results/` file
  contents unchanged.
- Do not change `.agentops-runs/`.

## Non-goals

- No observability changes.
- No lifecycle redesign.
- No user-level `$HOME/.agentops` design or migration.
- No `.agentops/` structure migration work (already done).
- No removal of the compatibility alias in this slice.

## Open questions

None.

## Promotion decision

Decision: already_ready

Reason:
Canonical rename target and compatibility policy are now defined; scope is
implementation-ready once write-scope boundaries are confirmed.

Next action:
Execute the staged rename with compatibility.

## Promotion criteria

Already promoted to ready.

## Verification

```bash
git status --short --branch
git diff --stat

test -f skills/agentops-coder/SKILL.md
grep -q '^name: agentops-coder$' skills/agentops-coder/SKILL.md
grep -q 'USING_SKILL: agentops-coder' skills/agentops-coder/SKILL.md

grep -q '/agentops-coder' scripts/render-collection-prompt.sh
grep -q '/agentops-coder' scripts/render-opencode-prompt.sh
grep -q 'USING_SKILL: agentops-coder' scripts/render-opencode-prompt.sh

grep -q '/agentops-coder' .agentops/templates/READY-TASK-TEMPLATE.md
grep -q '/agentops-coder' .agentops/templates/PLANNED-TASK-TEMPLATE.md

grep -q '/agentops-coder' profiles/coder/SOUL.md
grep -q '/agentops-coder' docs/INSTALL.md

# Compatibility checks (old invocation still documented/supported in this slice)
grep -q '/hermetic-coding-orchestrator' skills/hermetic-coding-orchestrator/SKILL.md
grep -q '/hermetic-coding-orchestrator' docs/INSTALL.md
grep -q '^name: hermetic-coding-orchestrator$' skills/hermetic-coding-orchestrator/SKILL.md
grep -q 'USING_SKILL: agentops-coder' skills/hermetic-coding-orchestrator/SKILL.md

# Installer includes canonical skill path
grep -q 'skills/agentops-coder' scripts/install-coder-profile.sh

# Hermes acceptance after install
./scripts/install-coder-profile.sh

# Fresh coder-profile session: canonical command
hermes --profile coder chat -q "/agentops-coder Summarize your workflow rules in 3 bullets"
# Expect: USING_SKILL: agentops-coder

# Fresh coder-profile session: compatibility bridge command
hermes --profile coder chat -q "/hermetic-coding-orchestrator Summarize your workflow rules in 3 bullets"
# Expect: USING_SKILL: agentops-coder
```

## Accept criteria

- Canonical references use `agentops-coder` / `/agentops-coder` /
  `USING_SKILL: agentops-coder`.
- Canonical and bridge skills are both installable and discoverable in coder
  profile runtime.
- Old slash invocation remains functional/documented during transition.
- New generated prompts and templates use canonical naming.
- Installer/docs/profile guidance are updated to canonical naming.
- Backward compatibility policy and alias-removal criteria are documented.
- No observability, lifecycle redesign, or `$HOME/.agentops` scope is mixed in.
