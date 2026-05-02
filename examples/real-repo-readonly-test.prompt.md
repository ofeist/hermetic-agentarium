Use the hermetic-coding-orchestrator skill.

Task:
Inspect this repository and summarize:
- project type
- main languages/tools
- how to run tests if discoverable
- whether it is safe for a small docs-only delegated edit

Constraints:
- Read-only inspection only.
- Do not modify files.
- Do not read secret files.
- Do not commit.
- Use delegate_task for repository inspection.
- Parent must independently verify:
  - git status --short --branch
  - git diff --stat

Return:
Plan:
Implementation:
Verification:
Review:
Changed files:
