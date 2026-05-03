# Hermes OpenCode Runtime

Hermes may run with an isolated `HOME` directory, meaning OpenCode's default config and data directories may not be accessible.

OpenCode config and data homes can be passed explicitly through the `OPENCODE_XDG_CONFIG_HOME` and `OPENCODE_XDG_DATA_HOME` environment variables, which are forwarded as `XDG_CONFIG_HOME` and `XDG_DATA_HOME`.

No auth/config file contents should ever be printed, logged, or inspected by the executor.

If the requested model/provider is not found in the available configuration, the executor must report the task as `blocked` and stop. A missing provider must not be silently replaced with an alternative.
