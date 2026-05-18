# agentops-coder

Canonical AgentOps coding orchestrator skill for controlled coding orchestration
with bounded delegation, dirty-worktree protection, parent verification, and
no-op/revise/revert review decisions.

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
~/.hermes/skills/agentops-coder/SKILL.md
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
~/.hermes/skills/agentops-coder/
~/.hermes/profiles/coder/skills/agentops-coder/
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
test -f ~/.hermes/skills/agentops-coder/SKILL.md
grep -q '^name: agentops-coder$' ~/.hermes/skills/agentops-coder/SKILL.md
grep -q 'USING_SKILL: agentops-coder' ~/.hermes/skills/agentops-coder/SKILL.md
```

If Hermes CLI is available, verify the skill is visible:

```bash
hermes --profile coder chat -q "/agentops-coder Summarize your workflow rules in 3 bullets"
```

## Activation and troubleshooting

### Activation checks

Verify the skill is discoverable from **default Hermes**:

```bash
test -f ~/.hermes/skills/agentops-coder/SKILL.md

hermes
# then in the Hermes session invoke:
# /agentops-coder
```

Verify the skill is discoverable from the **coder profile**:

```bash
test -f ~/.hermes/profiles/coder/skills/agentops-coder/SKILL.md

hermes --profile coder
# then in the Hermes session invoke:
# /agentops-coder
```

### Expected marker output

Successful invocation includes:

```text
USING_SKILL: agentops-coder
```

Slash invocation (`/agentops-coder`) is the practical acceptance test.
`hermes skills list` may be useful, but it should not be the only verification
mechanism — CLI listing behavior can differ by mode.

### Common failure: `Unknown command`

If `/agentops-coder` returns:

```text
Unknown command: /agentops-coder
```

Fastest checks:

1. **Skill file missing**: verify both install paths exist:

   ```bash
   test -f ~/.hermes/skills/agentops-coder/SKILL.md
   test -f ~/.hermes/profiles/coder/skills/agentops-coder/SKILL.md
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
   # /agentops-coder
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
| Skill name | `agentops-coder` | Canonical |
| Slash invocation | `/agentops-coder` | Canonical |
| Audit marker | `USING_SKILL: agentops-coder` | Canonical |
| Generated collection prompt | Starts with `/agentops-coder` | Canonical |
| Installer behavior | `scripts/install-coder-profile.sh` installs both canonical and deprecated bridge skills | Unchanged |

The deprecated `/hermetic-coding-orchestrator` slash command is kept functional
through a compatibility bridge skill during the transition window. See
`skills/hermetic-coding-orchestrator/README.md` for bridge documentation and
removal criteria.

## Follow-up tasks

Optional AgentOps observability packaging is deferred to a follow-up task
(`skill-03-package-optional-agentops-observability`). It is not part of this
package slice.

## Package layout

```text
skills/agentops-coder/
  SKILL.md      # Hermes skill entrypoint and metadata contract
  README.md     # Source-repo package documentation (this file)
```
