# AgentOps Ideas

Raw inbox for unrefined AgentOps ideas, bug suspicions, follow-ups, and one-liners.

This file is intentionally lightweight and informal.

Items here are not ready tasks.
Do not execute directly from this file.

## Purpose

Use this file when an idea is worth remembering but not yet worth turning into a planned or ready task.

Good examples:

- rough improvement ideas
- bug suspicions
- follow-ups from completed tasks
- one-line reminders
- maybe-later ideas
- small workflow annoyances
- possible documentation gaps

## Inbox

- document the canonical Hermes/coder minimal execution prompt in SOUL or SKILL
- investigate coordinator model / Codex subscription options
- maybe add a helper for result summary creation
- maybe add a lifecycle closeout helper for ready/review/done/result movement
- bug? remember that untracked files do not appear in plain `git diff --stat`
- later: define planned task promotion format
- later: add ready task template
- later: add planned task template

## Promotion path

When an idea becomes actionable, promote it gradually:

    IDEAS.md
      -> agentops/tasks/planned/
      -> agentops/tasks/ready/
      -> agentops/tasks/running/
      -> agentops/tasks/review/
      -> agentops/tasks/done/
      -> agentops/results/

Meaning:

- `IDEAS.md` = do not forget this
- `planned/` = think this through
- `ready/` = executor can do this
- `done/` + `results/` = reviewed outcome

Keep this simple. Do not turn this file into a Jira clone.
