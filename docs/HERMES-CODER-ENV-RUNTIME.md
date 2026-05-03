# Hermes Coder Profile Env Runtime

The local Hermes coder profile `.env` (at `~/.hermes/profiles/coder/.env`) can
provide runtime environment variables such as `OPENCODE_XDG_CONFIG_HOME` and
`OPENCODE_XDG_DATA_HOME`.  When defined there, the variables are loaded
automatically when Hermes/coder starts, avoiding the need for manual shell
exports before each normal run.

The `.env` file may contain sensitive values.  Its contents must never be
printed, inspected, or committed to version control.

OpenCode tasks are still dispatched through
`scripts/run-opencode-executor.sh`, which reads the forwarded environment
variables and passes them through to the `opencode` process.
