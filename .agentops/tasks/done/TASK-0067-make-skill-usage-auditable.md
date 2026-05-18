# TASK-0067 — Make hermetic orchestrator skill usage auditable

## Status

done

## Goal

Make usage of the custom `hermetic-coding-orchestrator` skill visibly auditable in AgentOps runs.

## Background

In TASK-0066, the run behaved correctly, but the visible Hermes trace showed skills like:

- `agentops-task-helper-scripts`
- `opencode`

It did not clearly show:

- `hermetic-coding-orchestrator`

Add lightweight documentation/profile/skill guidance so future AgentOps runs can prove the canonical custom orchestrator skill was intentionally invoked.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `profiles/coder/SOUL.md`
- `README.md`
- `docs/`
- `agentops/templates/`
- `agentops/tasks/ready/TASK-0067-make-skill-usage-auditable.md`

## Write scope

Allowed files only:

- `skills/hermetic-coding-orchestrator/SKILL.md`
- `profiles/coder/SOUL.md`
- `docs/*`
- `README.md`
- `agentops/templates/*`

Do not modify workflow helper scripts unless clearly necessary. This task is expected to be documentation/config-only.

## Requirements

1. Update the custom skill instructions so that when `/hermetic-coding-orchestrator` is invoked, the agent must include this visible marker near the beginning of its Plan or final output:

       USING_SKILL: hermetic-coding-orchestrator

2. Add guidance that AgentOps execution prompts should start with:

       /hermetic-coding-orchestrator

3. Add or update a reusable prompt example for executing a ready task with the skill explicitly invoked.

4. Keep the change small and documentation/config-only unless a script change is clearly justified.

5. Do not commit.

## Non-goals

- No workflow helper script changes unless clearly justified.
- No change to AgentOps lifecycle state beyond this ready task being processed by the normal workflow.
- No commit or push.
- No broad rewrite of the profile or skill.

## Verification

Run:

    grep -R "USING_SKILL: hermetic-coding-orchestrator" skills profiles docs README.md agentops/templates 2>/dev/null
    grep -R "/hermetic-coding-orchestrator" skills profiles docs README.md agentops/templates 2>/dev/null
    git diff --stat
    git diff

## Accept criteria

- There is a durable instruction requiring the visible skill marker.
- There is at least one reusable prompt example that explicitly starts with `/hermetic-coding-orchestrator`.
- The change does not introduce new workflow state.
- No scripts are modified unless justified.
- No commit is made.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
