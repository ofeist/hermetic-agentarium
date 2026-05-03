# Task

{task_description}

# Goal

{goal_description}

# Read scope

You may read:
{read_scope}

# Write scope

You may only create or modify:
{write_scope}

# Constraints

- Do not commit.
- Do not modify unrelated files.
- Do not read, print, modify, or search for secrets.
- Do not touch .env files, API keys, auth files, SSH keys, tokens, credentials, or private config.
- Do not inspect ~/.config, ~/.local/share, or any auth/config locations outside this repository.
- Keep the diff minimal.
- Parent will independently verify git diff and tests.

# Implementation requirements

- {implementation_requirement_1}
- {implementation_requirement_2}

# Verification

- Run: git status --short --branch
- Run: git diff --stat
- Run: git diff -- {write_scope_files}

# Return format

Return exactly this structure:

Plan:
Implementation:
Verification:
Changed files:
Uncertainty:
