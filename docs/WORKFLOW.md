# Workflow

## Default coding workflow

1. Inspect repository state.
2. Read project instructions.
3. Plan the smallest useful change.
4. Delegate bounded implementation or investigation when useful.
5. Parent independently verifies results.
6. Parent reviews diff and decides:
   - accept
   - revise
   - revert
   - no-op / nothing to accept
   - ask user

## Verification baseline

Use at least:

```bash
git status --short --branch
git diff --stat
```

Add targeted tests when applicable.
