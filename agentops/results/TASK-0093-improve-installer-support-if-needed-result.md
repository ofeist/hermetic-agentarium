# TASK-0093-improve-installer-support-if-needed Result

## Decision

accept

## Decision note

accept: installer now installs/wires skill for both account-home and active-home contexts so coder profile slash invocation works in profile-managed sessions.

## Task file

agentops/tasks/done/TASK-0093-improve-installer-support-if-needed.md

## Changed files

- scripts/install-coder-profile.sh
- docs/INSTALL.md
- agentops/tasks/done/TASK-0093-improve-installer-support-if-needed.md (lifecycle)
- agentops/results/TASK-0093-improve-installer-support-if-needed-result.md

## Verification

```bash
bash -n scripts/install-coder-profile.sh
./scripts/install-coder-profile.sh
hermes skills list | grep 'hermetic-coding-orchestrator'
hermes --profile coder skills list | grep 'hermetic-coding-orchestrator'
hermes --profile coder chat -q "/hermetic-coding-orchestrator Summarize your workflow rules in 3 bullets"
hermes chat -q "/hermetic-coding-orchestrator Summarize your workflow rules in 3 bullets"
scripts/check-agentops-lifecycle.sh
```

Observed:
- Syntax check passed.
- Installer run succeeded and reported install targets for both account home and active HOME when they differ.
- `hermes skills list` and `hermes --profile coder skills list` grep checks exited 1 in this CLI mode.
- Slash invocation succeeded in both coder-profile and default chat commands and returned skill-driven output.
- Lifecycle checker passed with Errors: 0, Warnings: 0.

## Review

Focused independent re-review verdict: accept.

## Follow-ups

None in this slice.
