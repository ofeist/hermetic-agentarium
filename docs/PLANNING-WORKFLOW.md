# Planning Workflow for AgentOps Tasks

This document describes the lightweight planning and promotion process for AgentOps tasks. This is not a Scrum/Jira/Taskplane process and not a Jira clone.

## Directory Roles

- **agentops/IDEAS.md**: Raw brainstormed ideas and high-level inspirations. A flat list of prospective work.
- **agentops/tasks/planned/**: Refinement space for fleshing out ideas into candidate tasks. Defines scope, context, and entry criteria before turning into executable work.
- **agentops/tasks/ready/**: Approved, scoped, and detailed tasks ready for execution by AgentOps or delegated agents.
- **agentops/tasks/done/**: Completed tasks with recorded outcomes, results, and any follow-up notes.
- **agentops/results/**: Safe committed result summaries for completed tasks.

## Planned/ Directory Purpose

The **planned/** area serves as the middle ground between raw ideas and executable ready tasks. It is where team members refine concepts, clarify requirements, and prepare minimal, actionable work units that can later be promoted.

## Planned Task Structure

Each planned task should include the following sections:

- **Problem**: A concise statement of the issue or opportunity.
- **Why now**: Rationale for priority or timing.
- **Smallest useful slice**: The minimal deliverable that provides value or feedback.
- **Non-goals**: Explicitly out-of-scope items.
- **Open questions**: Unresolved uncertainties or dependencies.
- **Candidate ready task**: A draft of the ready-style task that could be moved to agentops/tasks/ready/ once criteria are met.

## Promotion Criteria

A planned task is eligible for promotion to ready when:

1. Problem and Why Now are clear and documented.
2. Smallest useful slice is defined and scoped narrowly.
3. Non-goals and open questions have no blockers or are explicitly handed off.
4. Candidate ready task is written in the ready-task format.
5. It has been selected as the next useful slice.

Once these criteria are satisfied, move the file from **agentops/tasks/planned/** to **agentops/tasks/ready/**.

---

*Note: This is not a Scrum/Jira/Taskplane process and is intentionally lightweight.*
