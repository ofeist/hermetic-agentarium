# TASK-0064 — Include untracked files in verification notes

## Status

done

## Goal

Improve `scripts/render-verification-notes.sh` so reviewer context includes untracked files.

## Background

Several AgentOps tasks create new files such as ready task files or helper scripts.

Plain `git diff --stat` and `git diff --name-only` do not show untracked files. This can confuse the reviewer agent, which may treat expected untracked task files as scope violations.

TASK-0060 added `scripts/render-verification-notes.sh`.

This task improves it by adding an explicit untracked files section.

## Executor

OpenCode

## Model

deepseek/deepseek-chat

Do not fallback to another model unless explicitly allowed by this task.

## Read scope

- scripts/render-verification-notes.sh
- agentops/tasks/ready/TASK-0064-untracked-files-in-verification-notes.md

## Write scope

- scripts/render-verification-notes.sh

Do not modify unrelated files.

## Requirements

Update:

    scripts/render-verification-notes.sh

The script should:

- stay shell-only
- keep `set -euo pipefail`
- preserve existing usage:

      scripts/render-verification-notes.sh <task-id-slug>

- preserve `-h` and `--help`
- preserve unsafe task id validation
- preserve existing sections:
  - `# Parent verification / context notes`
  - `## Ready task`
  - `## Verification commands / output`
  - `## Git status`
  - `## Diff stat`
  - `## Changed files`
- add a new section:

      ## Untracked files

- the untracked files section should include output from:

      git ls-files --others --exclude-standard

- if there are no untracked files, print a clear placeholder such as:

      No untracked files.

- do not modify files
- do not invoke Hermes/coder
- do not invoke OpenCode
- do not read or print secrets

## Non-goals

- No lifecycle state changes
- No result summaries
- No reviewer invocation
- No OpenCode invocation
- No parser for task metadata
- No attempt to classify untracked files automatically

## Verification

Run:

    bash -n scripts/render-verification-notes.sh
    scripts/render-verification-notes.sh --help
    scripts/render-verification-notes.sh -h

Create an untracked test file and render notes:

    tmp_dir="$(scripts/agentops-tmp-dir.sh TASK-0064-untracked-files-in-verification-notes)"
    test_file="agentops/tasks/ready/TASK-9999-untracked-test.md"
    cp agentops/templates/READY-TASK-TEMPLATE.md "$test_file"

    scripts/render-verification-notes.sh TASK-0064-untracked-files-in-verification-notes > "$tmp_dir/verification-notes.md"

    grep -q "## Untracked files" "$tmp_dir/verification-notes.md"
    grep -q "TASK-9999-untracked-test.md" "$tmp_dir/verification-notes.md"

    rm "$test_file"

Invalid task id should fail:

    set +e
    scripts/render-verification-notes.sh bad/slug > "$tmp_dir/badslug.out" 2> "$tmp_dir/badslug.err"
    badslug_exit=$?
    set -e
    echo "badslug_exit=$badslug_exit"

Then run:

    git status --short --branch
    git diff --stat

Expected:

    badslug_exit=1

## Accept criteria

- Existing behavior is preserved.
- Verification notes include an `## Untracked files` section.
- Untracked files are listed when present.
- A clear placeholder is printed when no untracked files exist.
- Unsafe task ids still fail.
- Implementation only changes `scripts/render-verification-notes.sh`.

## Return format

Return:

- changed files
- diff summary
- verification output
- uncertainty or risks
