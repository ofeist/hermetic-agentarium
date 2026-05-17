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

## Expected install locations

After running `./scripts/install-coder-profile.sh`, the skill lands in two
expected locations:

```text
~/.hermes/skills/hermetic-coding-orchestrator/
~/.hermes/profiles/coder/skills/hermetic-coding-orchestrator/
```

- The first location (`~/.hermes/skills/`) is the global Hermes skill path.
- The second location (`~/.hermes/profiles/coder/skills/`) is the coder
  profile-local skill path.

Default Hermes can load the skill from the global path. The `coder` profile may
require the skill to exist under the profile-local path. The installer copies
`SKILL.md` into both locations for full coverage.

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

## Activation and troubleshooting

### Activation checks

Verify the skill is discoverable from **default Hermes**:

```bash
test -f ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md

hermes
# then in the Hermes session invoke:
# /hermetic-coding-orchestrator
```

Verify the skill is discoverable from the **coder profile**:

```bash
test -f ~/.hermes/profiles/coder/skills/hermetic-coding-orchestrator/SKILL.md

hermes --profile coder
# then in the Hermes session invoke:
# /hermetic-coding-orchestrator
```

### Expected marker output

Successful invocation includes:

```text
USING_SKILL: hermetic-coding-orchestrator
```

Slash invocation (`/hermetic-coding-orchestrator`) is the practical acceptance
test. `hermes skills list` may be useful, but it should not be the only
verification mechanism — CLI listing behavior can differ by mode.

### Common failure: `Unknown command`

If `/hermetic-coding-orchestrator` returns:

```text
Unknown command: /hermetic-coding-orchestrator
```

Fastest checks:

1. **Skill file missing**: verify both install paths exist:

   ```bash
   test -f ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
   test -f ~/.hermes/profiles/coder/skills/hermetic-coding-orchestrator/SKILL.md
   ```

2. **Restart needed**: Hermes may need a restart to pick up a newly installed
   skill. Did you restart after running the installer?

3. **Default works, coder profile does not**: If `hermes` can invoke the skill
   but `hermes --profile coder` returns `Unknown command`, check whether the
   skill exists under the coder profile-local path. If missing, rerun the
   installer and restart Hermes:

   ```bash
   ./scripts/install-coder-profile.sh
   # then restart hermes --profile coder and test:
   # /hermetic-coding-orchestrator
   ```

4. **Custom install path**: if you used `HERMES_INSTALL_HOME`, adjust the
   expected paths accordingly (replace `~` with the custom install root).

### Rerun the installer safely

The installer is idempotent. After changing install paths or profile wiring,
rerun it:

```bash
./scripts/install-coder-profile.sh
```

This does not change runtime helper behavior, lifecycle helpers, or observability
packaging.

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
