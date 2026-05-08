# TASK-0068 — Dogfood revise loop

## Status

ready

## Goal

Improve `scripts/agentops-tmp-dir.sh` help output by adding a short `Example:` section.

## Background

This task intentionally supports dogfooding the AgentOps revise loop. The initial implementation should make only the small requested help-output change. A parent coordinator may later provide synthetic reviewer feedback to exercise the revision prompt and executor flow.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- `scripts/agentops-tmp-dir.sh`
- `agentops/tasks/ready/TASK-0068-dogfood-revise-loop.md`

## Write scope

- `scripts/agentops-tmp-dir.sh`

Do not modify unrelated files.

## Requirements

- The execution prompt MUST start with `/hermetic-coding-orchestrator` to explicitly invoke the custom skill.
- The agent MUST include `USING_SKILL: hermetic-coding-orchestrator` near the beginning of its Plan or output.
- Keep the change minimal.
- Only modify `scripts/agentops-tmp-dir.sh`.
- Preserve existing behavior.
- `-h` and `--help` still exit `0`.
- Missing argument still exits non-zero.
- Bad slug still exits non-zero.
- Normal use still prints `.agentops-runs/<task-id>/tmp`.
- Do not read or print secrets.
- Do not commit or push.
- Preserve `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if invoking OpenCode.

## Non-goals

- No changes to AgentOps workflow helper behavior beyond help text.
- No changes to other scripts.
- No reviewer invocation.
- No commit or push.

## Verification

Run:

    git status --short --branch
    git diff --stat
    git diff -- scripts/agentops-tmp-dir.sh
    bash -n scripts/agentops-tmp-dir.sh
    scripts/agentops-tmp-dir.sh --help
    scripts/agentops-tmp-dir.sh -h
    tmp_dir="$(scripts/agentops-tmp-dir.sh TASK-0068-dogfood-revise-loop)"
    test "$tmp_dir" = ".agentops-runs/TASK-0068-dogfood-revise-loop/tmp"

Verify bad slug exits non-zero:

    set +e
    scripts/agentops-tmp-dir.sh bad/slug >/tmp/TASK-0068-badslug.out 2>/tmp/TASK-0068-badslug.err
    badslug_exit=$?
    set -e
    echo "badslug_exit=$badslug_exit"

Expected:

    badslug_exit=1

## Accept criteria

- `scripts/agentops-tmp-dir.sh --help` and `-h` include a short `Example:` section.
- `-h` and `--help` exit `0`.
- Missing argument exits non-zero.
- Bad slug exits non-zero.
- Normal use prints `.agentops-runs/<task-id>/tmp`.
- Diff stays limited to `scripts/agentops-tmp-dir.sh`.
- No unrelated files are modified.
- No commit or push is made.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
