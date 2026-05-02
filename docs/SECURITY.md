# Security

This repository must not contain secrets.

Do not commit:

- `.env`
- `.env.*`
- `auth.json`
- `config.yaml`
- API keys
- SSH keys
- tokens
- request dumps
- Hermes sessions
- Hermes logs

## Working with real repositories

Hermes agents may technically read any file accessible to the current operating-system user.

For agent testing, use a clean clone without secret files.

Recommended pattern:

```bash
git clone <repo> ~/tmp/<repo>-agent-test
cd ~/tmp/<repo>-agent-test
rm -f .env .env.* auth.json config.yaml
coder
```

## Rule

Agent instructions are not a security boundary.

Do not rely only on prompts to protect secrets. Use clean clones, file permissions, containers, or separate users for stronger isolation.
