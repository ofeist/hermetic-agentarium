Task:
TASK-0014 — create or update docs/EXAMPLE.md

Goal:
Add a minimal documentation file describing what this project does at a high level.

Read scope:
You may read:
- README.md
- docs/OPENCODE-EXECUTOR-WORKFLOW.md

Write scope:
You may only create or modify:
- docs/EXAMPLE.md

Constraints:
- Do not commit.
- Do not modify unrelated files.
- Do not read, print, modify, or search for secrets.
- Do not touch .env files, API keys, auth files, SSH keys, tokens, credentials, or private config.
- Do not inspect ~/.config, ~/.local/share, or any auth/config locations outside this repository.
- Keep the diff minimal.
- Parent will independently verify git diff and tests.

Implementation requirements:
- Create docs/EXAMPLE.md with a 3-5 sentence project overview based on README.md.
- Do not add code blocks, badges, or external links.
- No tasks, no frameworks, no setup instructions.

Verification:
- Run: git status --short --branch
- Run: git diff --stat
- Run: git diff -- docs/EXAMPLE.md

Return exactly this structure:

Plan:
Implementation:
Verification:
Changed files:
Uncertainty:
