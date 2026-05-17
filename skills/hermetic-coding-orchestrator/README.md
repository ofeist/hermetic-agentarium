# hermetic-coding-orchestrator

Hermes-native local skill for controlled coding orchestration with bounded
delegation, dirty-worktree protection, parent verification, and no-op/revise/revert
review decisions.

## When to use

Use this skill for AgentOps coding tasks that are more than a trivial one-line
edit. The skill enforces:

- git worktree isolation (no executor work on `main`)
- bounded single-attempt delegation guardrails
- independent parent verification after every executor run
- explicit review decisions: accept / revise / revert / no-op / blocked

## Install

The core local Hermes package is the skill directory plus `SKILL.md`. Install
via the repo installer:

```bash
./scripts/install-coder-profile.sh
```

This copies `SKILL.md` to the Hermes-native load path:

```text
~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
```

The `SKILL.md` YAML frontmatter is the package metadata contract. The install
target follows the standard Hermes local skill layout:

```text
~/.hermes/skills/<category>/<skill-name>/SKILL.md
```

This README is source-repo package documentation only and is not copied to
`~/.hermes` by the installer.

## Verify

After install, verify the package is intact:

```bash
test -f ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
grep -q '^name: hermetic-coding-orchestrator$' ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
grep -q 'USING_SKILL: hermetic-coding-orchestrator' ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
```

If Hermes CLI is available, verify the skill is visible:

```bash
hermes --profile coder chat -q "/hermetic-coding-orchestrator Summarize your workflow rules in 3 bullets"
```

## Compatibility

| Property | Value | Guarantee |
|---|---|---|
| Skill name | `hermetic-coding-orchestrator` | Unchanged |
| Slash invocation | `/hermetic-coding-orchestrator` | Unchanged |
| Audit marker | `USING_SKILL: hermetic-coding-orchestrator` | Unchanged |
| Generated collection prompt | Starts with `/hermetic-coding-orchestrator` | Unchanged |
| Installer behavior | `scripts/install-coder-profile.sh` preserves profile + skill layout | Unchanged |

## Follow-up tasks

Optional AgentOps observability packaging is deferred to a follow-up task
(`skill-03-package-optional-agentops-observability`). It is not part of this
package slice.

## Package layout

```text
skills/hermetic-coding-orchestrator/
  SKILL.md      # Hermes skill entrypoint and metadata contract
  README.md     # Source-repo package documentation (this file)
```
