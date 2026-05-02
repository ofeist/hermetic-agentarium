# DeepSeek Provider Setup for Hermes Delegation

## Purpose

This document describes how to configure Hermes so the parent agent can stay on OpenAI while delegated child agents use DeepSeek.

The repository must not contain real API keys or runtime secrets.

## Security rules

Never commit:

- `.env`
- `.env.*`
- `auth.json`
- `config.yaml`
- session files
- logs
- request dumps
- API keys or tokens

Use environment variables for secrets.

## Local `.env`

Example only:

```bash
DEEPSEEK_API_KEY="sk-..."
DEEPSEEK_BASE_URL="https://api.deepseek.com"
```

Do not commit this file.

Recommended permissions:

```bash
chmod 600 ~/.hermes/profiles/coder/.env
```

## Hermes config pattern

Parent model can stay on OpenAI:

```yaml
model:
  default: o4-mini
  provider: custom
  base_url: https://api.openai.com/v1
  api_key: ${OPENAI_API_KEY}
```

Delegation should use the native DeepSeek provider:

```yaml
delegation:
  model: deepseek-chat
  provider: deepseek
  base_url: ''
  api_key: ''
```

## Important note

For DeepSeek delegation, prefer:

```yaml
provider: deepseek
```

Do not use this for DeepSeek child delegation unless verified in your Hermes version:

```yaml
provider: custom
```

Using `provider: custom` may result in the child model being set to `deepseek-chat` while the endpoint still points to the parent OpenAI base URL.

Symptom:

```text
Provider: custom
Model: deepseek-chat
Endpoint: https://api.openai.com/v1
Error: model_not_found
```

Expected working routing:

```text
Provider: deepseek
Model: deepseek-chat
Endpoint: https://api.deepseek.com
```

## Smoke test

Start the coder profile:

```bash
coder
```

Use this prompt:

```text
Use delegate_task for a tiny smoke test.

Goal:
Ask the child agent to reply with exactly: deepseek child ok

Scope:
No files.

Constraints:
- Do not read files.
- Do not modify files.
- Do not print secrets.

Return:
- exact child response
```

Expected result:

```text
deepseek child ok
```

## Troubleshooting

### HTTP 402: Insufficient Balance

The provider routing and API key are likely working, but the DeepSeek account has no available balance.

Add balance on the DeepSeek platform and retry.

### Child still uses OpenAI endpoint

If the log shows:

```text
Provider: custom
Model: deepseek-chat
Endpoint: https://api.openai.com/v1
```

then the child model changed, but the child endpoint did not.

Use:

```yaml
delegation:
  model: deepseek-chat
  provider: deepseek
  base_url: ''
  api_key: ''
```

and make sure the local `.env` contains:

```bash
DEEPSEEK_API_KEY="sk-..."
DEEPSEEK_BASE_URL="https://api.deepseek.com"
```

### Request debug dumps

Hermes may write request dumps after API errors.

Remove them before committing anything:

```bash
rm -f ~/.hermes/profiles/coder/sessions/request_dump_*.json
```

Never commit request dumps.
