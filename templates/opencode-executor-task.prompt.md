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
- Do not read other repository files unless they are explicitly listed in Read scope.
- Keep the diff minimal.
- If the requested executor model/provider is unavailable, stop and report blocked. Do not fallback to another model unless explicitly allowed by the task.
- When running OpenCode from an isolated Hermes profile, pass explicit `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` if needed.
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
