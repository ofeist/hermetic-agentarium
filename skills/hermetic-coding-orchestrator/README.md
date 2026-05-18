# hermetic-coding-orchestrator (DEPRECATED)

**Deprecated compatibility bridge.** The canonical skill is now `agentops-coder`
(`/agentops-coder`, `skills/agentops-coder/SKILL.md`).

This package is kept during transition so `/hermetic-coding-orchestrator` slash
invocations continue to work. Both skills route to the same behavior contract
and emit the canonical audit marker `USING_SKILL: agentops-coder`.

## When to use

**Prefer `/agentops-coder` for new invocations.** This bridge is only for
existing habits/tooling that still reference the old name.

## Install

The repo installer installs both the canonical skill and this bridge:

```bash
./scripts/install-coder-profile.sh
```

This copies both `SKILL.md` files to Hermes-native load paths:

```text
~/.hermes/skills/agentops-coder/SKILL.md
~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
```

## Expected install locations

After running `./scripts/install-coder-profile.sh`, this bridge skill lands in:

```text
~/.hermes/skills/hermetic-coding-orchestrator/
~/.hermes/profiles/coder/skills/hermetic-coding-orchestrator/
```

## Verify

After install, verify the bridge is intact:

```bash
test -f ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
grep -q '^name: hermetic-coding-orchestrator$' ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
grep -q 'USING_SKILL: agentops-coder' ~/.hermes/skills/hermetic-coding-orchestrator/SKILL.md
```

If Hermes CLI is available, verify both slash commands work:

```bash
hermes --profile coder chat -q "/agentops-coder Summarize your workflow rules in 3 bullets"
hermes --profile coder chat -q "/hermetic-coding-orchestrator Summarize your workflow rules in 3 bullets"
```

Both should return results with `USING_SKILL: agentops-coder`.

## Deprecation schedule

| Milestone | Criteria |
|---|---|
| Transition start | TASK-0098 merge |
| Minimum compatibility window | One full follow-up task cycle after TASK-0098 lands |
| Removal trigger | A dedicated removal task exists and is completed |
| Alias removal | Removed via a separate follow-up task |

There is no silent removal. The bridge stays until a dedicated alias-removal
task is explicitly planned, promoted, and executed.

## Compatibility guarantee summary

| Property | Value | Status |
|---|---|---|
| Skill name | `hermetic-coding-orchestrator` | Deprecated, kept for compatibility |
| Slash invocation | `/hermetic-coding-orchestrator` | Still functional during transition |
| Audit marker | `USING_SKILL: agentops-coder` | Canonical (emitted by both skills) |
| Canonical skill | `agentops-coder` | `/agentops-coder` |
| Removal | By dedicated follow-up task only | No silent removal |

## Package layout

```text
skills/hermetic-coding-orchestrator/
  SKILL.md      # Hermes skill entrypoint (deprecated bridge)
  README.md     # Source-repo package documentation (this file)
```
