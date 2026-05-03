# TASK-0035 — Install coder profile runtime env defaults

Status: ready

## Goal

Improve installation usability so `./scripts/install-coder-profile.sh` creates or updates a local Hermes coder profile `.env` with OpenCode runtime home defaults.

This removes the need to manually export `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` before every Hermes/coder run.

## Read scope

The executor may read only:

- scripts/install-coder-profile.sh
- docs/INSTALL.md
- docs/OPENCODE-CONFIGURATION.md
- docs/FIRST-RUN.md
- profiles/coder/SOUL.md

## Write scope

The executor may only create or modify:

- profiles/coder/.env.example
- scripts/install-coder-profile.sh
- docs/INSTALL.md
- docs/OPENCODE-CONFIGURATION.md
- docs/FIRST-RUN.md

## Constraints

- Do not commit.
- Do not modify unrelated files.
- Do not read other repository files unless explicitly listed in Read scope.
- Do not read, print, modify, or search for secrets.
- Do not touch real `.env` files outside the explicit install script behavior described below.
- Do not print existing `.env` contents.
- Do not overwrite existing local `.env` files.
- Do not remove existing local `.env` values.
- Do not add real API keys or secrets.
- Do not hardcode `/home/splinter` or any user-specific path into committed files.
- Keep the diff minimal.
- If the requested executor model/provider is unavailable, stop and report blocked. Do not fallback to another model unless explicitly allowed by the task.
- Parent will independently verify git diff and checks.

## Executor

Harness: OpenCode
Model: deepseek/deepseek-chat
Allow fallback: false

## Implementation requirements

### 1. Add `profiles/coder/.env.example`

Create a safe committed template with:

- short comment explaining it is copied/used for local Hermes coder profile runtime environment
- `OPENCODE_XDG_CONFIG_HOME=`
- `OPENCODE_XDG_DATA_HOME=`
- commented examples for optional provider keys, without real values:
  - `# OPENAI_API_KEY=`
  - `# DEEPSEEK_API_KEY=`

The file must not contain secrets.

### 2. Update `scripts/install-coder-profile.sh`

Update the install script so it:

- keeps existing behavior for installing `SOUL.md` and skill files
- ensures local profile directory exists:
  - `~/.hermes/profiles/coder`
- creates local file if missing:
  - `~/.hermes/profiles/coder/.env`
- appends these lines only if they are missing:
  - `OPENCODE_XDG_CONFIG_HOME=<absolute-user-home>/.config`
  - `OPENCODE_XDG_DATA_HOME=<absolute-user-home>/.local/share`
- uses the current install user's `$HOME` to write absolute paths
- does not overwrite existing `.env`
- does not print `.env` contents
- prints only a short safe status message such as:
  - `Ensured coder profile .env runtime defaults`

Implementation hint:

Use `grep -q '^OPENCODE_XDG_CONFIG_HOME=' "$ENV_FILE"` before appending.

### 3. Update documentation

Update `docs/INSTALL.md` to mention:

- the installer creates/updates local `~/.hermes/profiles/coder/.env`
- the `.env` is local runtime config and must not be committed
- OpenCode runtime home variables are added automatically if missing

Update `docs/OPENCODE-CONFIGURATION.md` to mention:

- manual export is optional if installer has populated the local coder profile `.env`
- the variables may live in `~/.hermes/profiles/coder/.env`

Update `docs/FIRST-RUN.md` to mention:

- if `./scripts/install-coder-profile.sh` has been run, the OpenCode runtime env vars may already be configured in the local coder profile `.env`
- manual export remains useful for debugging

## Verification

Run:

    bash -n scripts/install-coder-profile.sh
    git status --short --branch
    git diff --stat
    git diff -- profiles/coder/.env.example scripts/install-coder-profile.sh docs/INSTALL.md docs/OPENCODE-CONFIGURATION.md docs/FIRST-RUN.md

Do not run the installer as part of this task unless explicitly asked by the parent.

## Decision states

- accept
- revise
- revert
- no-op / nothing to accept
- blocked
