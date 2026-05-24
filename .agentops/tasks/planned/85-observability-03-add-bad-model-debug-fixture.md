# observability-03 — Add bad-model debug fixture for routing metadata

## Status

planned

## Goal

Add a small, safe bad-model/debug fixture that intentionally requests an invalid
or unsupported executor model and verifies that AgentOps records useful routing
metadata for the failure path.

## Background / why now

The routing metadata writer is now in place.

Executor runs can write local key/value metadata under:

`.agentops-runs/<run-id>/routing.txt`

The happy path has been verified. The next useful slice is to prove that failure
paths are also observable without parsing raw logs or exporting sensitive data.

This follows the design intent from `docs/AGENTOPS-ROUTING-METADATA.md`.

## Problem statement

A routing metadata writer is less useful if it only works for successful runs.

AgentOps needs a boring, repeatable fixture that answers:

- what model did the workflow request?
- did the run fail as expected?
- did `routing.txt` still get written?
- was the exit code captured?
- was the outcome/debug state safe and useful?
- did the workflow avoid copying raw logs, prompt text, payloads, or secrets?

Without this, bad model/provider issues still require manual log inspection.

## Smallest useful slice

Add a dedicated bad-model smoke/debug fixture for routing metadata.

The fixture should intentionally request an invalid model/provider and verify
that the executor failure still writes safe partial routing metadata.

Expected failure is success for the fixture.

## Executor

Harness: OpenCode or shell helper, depending on the existing test/helper shape
Model source: fixture-controlled invalid model
Fallback: disabled

## Read scope

- `docs/AGENTOPS-ROUTING-METADATA.md`
- `docs/AGENTOPS-OBSERVABILITY.md` if it exists
- `docs/RUN-AUDIT.md`
- `docs/RUN-OBSERVABILITY.md`
- `scripts/run-opencode-executor.sh`
- existing smoke/test/helper scripts for AgentOps run auditing
- `.gitignore`

## Write scope

Preferred minimal write scope:

- one small fixture/helper script, for example:
  - `scripts/smoke-agentops-bad-model-routing.sh`

Optional docs update only if needed:

- `docs/AGENTOPS-ROUTING-METADATA.md`
- `docs/RUN-OBSERVABILITY.md`

Do not modify lifecycle helpers unless absolutely necessary.

Do not change routing policy, model selection behavior, Hermes profile config,
OpenCode auth/config, or `.agentops/` lifecycle semantics.

## Requirements

- Add a repeatable bad-model fixture.
- The fixture must intentionally request an invalid/unsupported model.
- The fixture must use a dedicated run id, for example:
  - `TASK-xxxx-bad-model-routing-smoke`
- The fixture must expect the executor command to fail.
- The fixture must fail if the executor unexpectedly succeeds.
- The fixture must verify that:
  - `.agentops-runs/<run-id>/metadata.txt` exists
  - `.agentops-runs/<run-id>/routing.txt` exists
  - `routing.txt` contains all required routing fields
  - `requested_model` records the invalid requested model
  - `exit_code` is non-zero
  - `final_outcome` is `blocked` or `unknown`, depending on current writer semantics
  - `error_class`, `error_reason`, or `debug_hint` contains safe failure context when available
- The fixture must not require real provider credentials if a local failing
  executor command can exercise the failure path.
- The fixture must not use fallback.
- The fixture must not parse or print secrets.
- The fixture must not export prompt text.
- The fixture must not copy stdout/stderr/raw logs into committed files.
- `.agentops-runs/` must remain gitignored and untracked.
- Existing successful executor behavior must remain unchanged.

## Suggested fixture behavior

Prefer a deterministic local failure path if it exercises the same metadata
writer.

Example shape:

```bash
AGENTOPS_RUN_ID=TASK-xxxx-bad-model-routing-smoke \
AGENTOPS_EXECUTOR_MODEL='invalid-provider/invalid-model' \
AGENTOPS_EXECUTOR_COMMAND='printf "simulated bad model failure\n" >&2; exit 42' \
scripts/run-opencode-executor.sh /tmp/agentops-bad-model-routing.prompt.md
```

The fixture should treat this non-zero exit as expected.

If the existing runner cannot record `requested_model` from
`AGENTOPS_EXECUTOR_MODEL` when `AGENTOPS_EXECUTOR_COMMAND` is overridden, update
the fixture or writer minimally so the requested model is still recorded safely.

Do not call a real provider only to make the test fail unless that is already
the established smoke-test pattern.

## Required routing fields

The fixture should check all fields currently required by the routing metadata
contract:

```text
timestamp
run_id
task_id
phase
role
harness
requested_model
resolved_provider
resolved_model
token_counts_prompt
token_counts_completion
token_counts_total
duration_ms
retry_reason
fallback_reason
exit_code
final_outcome
error_class
error_reason
debug_hint
```

## Safety expectations

Allowed in `routing.txt`:

- run id
- task id
- phase/role/harness
- requested model string
- resolved provider/model if safely known
- token counts or `unknown`
- duration
- exit code
- final outcome
- safe error class/reason
- safe debug hint pointing to a local artifact path

Not allowed in `routing.txt` or committed docs:

- full prompt text
- stdout/stderr contents
- raw provider request payloads
- raw provider response payloads
- API keys
- auth/config contents
- secrets
- environment dumps

## Non-goals

- Do not implement automatic cost optimization.
- Do not change routing policy.
- Do not change model selection behavior.
- Do not build a dashboard.
- Do not introduce `$HOME/.agentops/` as canonical storage.
- Do not redesign lifecycle states.
- Do not make observability mandatory for core AgentOps usage.
- Do not move helper scripts into the skill package.
- Do not create a standalone CLI.
- Do not add provider-specific integration tests unless explicitly required.

## Open questions

These can be resolved during promotion:

- Should the fixture be a standalone script under `scripts/`, or a documented
  verification command only?
- Should `final_outcome` be updated to `blocked` on executor failure in this
  slice, or should it remain `unknown` until outcome helpers handle it?
- Should the fixture use only a local failing command, or also support a real
  invalid-provider smoke mode behind an explicit flag?

Preferred near-term answer:

- use a standalone script
- keep it deterministic/local
- avoid real provider calls by default
- accept `final_outcome=unknown` if current writer semantics require that, but
  verify non-zero `exit_code` and safe error/debug fields

## Promotion decision

Decision: keep_planned

Reason:
This is the correct follow-up after the routing metadata writer, but the exact
fixture shape should be confirmed before promotion.

Next action:
Decide whether this is a standalone helper script or verification-only fixture.
Then promote to ready.

## Promotion criteria

This task can be promoted to ready when:

- fixture location is decided
- expected `final_outcome` behavior for failure is decided
- local-vs-real-provider failure mode is decided
- verification commands are concrete
- write scope is concrete

## Verification

Base verification:

```bash
git status --short --branch
git diff --stat
bash -n scripts/run-opencode-executor.sh
# If the fixture is implemented as a script:
bash -n scripts/smoke-agentops-bad-model-routing.sh
scripts/check-agentops-lifecycle.sh
```

Fixture verification, if implemented as script:

```bash
scripts/smoke-agentops-bad-model-routing.sh
```

Manual verification shape, if no standalone script is added:

```bash
printf 'test prompt\n' > /tmp/agentops-bad-model-routing.prompt.md

set +e
AGENTOPS_RUN_ID=TASK-xxxx-bad-model-routing-smoke \
AGENTOPS_EXECUTOR_MODEL='invalid-provider/invalid-model' \
AGENTOPS_EXECUTOR_COMMAND='printf "simulated bad model failure\n" >&2; exit 42' \
scripts/run-opencode-executor.sh /tmp/agentops-bad-model-routing.prompt.md
rc=$?
set -e

if [ "$rc" -eq 0 ]; then
  echo 'FAIL: bad-model fixture unexpectedly succeeded'
  exit 1
fi

test -f .agentops-runs/TASK-xxxx-bad-model-routing-smoke/metadata.txt
test -f .agentops-runs/TASK-xxxx-bad-model-routing-smoke/routing.txt

for k in timestamp run_id task_id phase role harness requested_model resolved_provider resolved_model token_counts_prompt token_counts_completion token_counts_total duration_ms retry_reason fallback_reason exit_code final_outcome error_class error_reason debug_hint; do
  grep -q "^${k}=" .agentops-runs/TASK-xxxx-bad-model-routing-smoke/routing.txt
done

grep -q '^requested_model=invalid-provider/invalid-model$' .agentops-runs/TASK-xxxx-bad-model-routing-smoke/routing.txt

if grep -q '^exit_code=0$' .agentops-runs/TASK-xxxx-bad-model-routing-smoke/routing.txt; then
  echo 'FAIL: routing metadata recorded success exit code for expected failure'
  exit 1
fi

if git status --short | grep '.agentops-runs/'; then
  echo 'FAIL: .agentops-runs contains tracked changes'
  exit 1
fi
```

Do not use `|| true` to mask required verification failures.

## Accept criteria

- A repeatable bad-model/debug fixture exists.
- The fixture intentionally exercises a failure path.
- The fixture treats failure as expected and unexpected success as a test
  failure.
- `.agentops-runs/<run-id>/metadata.txt` is still written.
- `.agentops-runs/<run-id>/routing.txt` is still written.
- `routing.txt` contains all required routing fields.
- `requested_model` records the invalid requested model.
- `exit_code` records a non-zero failure.
- Failure metadata is safe and does not export prompt text, raw logs, payloads,
  auth/config contents, or secrets.
- `.agentops-runs/` remains untracked.
- Existing successful executor behavior remains compatible.
- No routing policy, model selection, lifecycle, profile, or auth/config changes
  are introduced.

## Hermes/coder collection prompt

```text
/agentops-coder

Execute AgentOps ready task: .agentops/tasks/ready/<READY_TASK_FILENAME>.md

Use the Hermes/OpenCode executor workflow from your profile/skill.

Requirements:
- create/switch appropriate task branch or worktree
- do not run executor work on main
- preserve OPENCODE_XDG_CONFIG_HOME and OPENCODE_XDG_DATA_HOME
- use task-specified model
- do not fallback
- do not commit
- independently verify

Return:
Plan
Implementation
Verification
Review
Changed files
Uncertainty
```

## Return format

```text
Plan:
Implementation:
Verification:
Review: accept / revise / revert / no-op / blocked
Changed files:
Uncertainty:
```

## Notes

This task should remain small.

The point is not to build full error analytics. The point is to prove that
routing metadata remains useful when the executor path fails.
