---
name: gitignore
description: Generate or update .gitignore for the current project. Use when initializing repos, adding new dependencies, or when user asks about ignoring files.
allowed-tools: Bash(python3 ~/.claude/skills/gitignore/scripts/*), Bash(~/.claude/skills/gitignore/scripts/*), Read, Write
---

# Generate .gitignore

Generate and maintain a comprehensive .gitignore file for the current project.

## Overview

This skill operates in three modes:
1. **Generate** - Interactive `/gitignore` command for creating/updating .gitignore
2. **Pre-commit Check** - Automatic validation before git commits (via hook)
3. **Update** - Guided remediation when issues are detected

## Mode 1: Generate (`/gitignore`)

### Workflow

1. **Run analysis script**:
   ```bash
   python3 ~/.claude/skills/gitignore/scripts/analyze-project.py "$(pwd)"
   ```

2. **Parse JSON output** which contains:
   - `projectTypes`: Detected project types (nodejs, nextjs, python, etc.)
   - `existingGitignore`: Current patterns if file exists
   - `recommended`: Mandatory and project-specific patterns
   - `tradeoffs`: User preference questions
   - `missing`: Critical patterns not currently ignored

3. **Show summary to user**:
   - Detected project types
   - Number of existing patterns
   - Critical missing patterns (if any)

4. **If critical issues exist** (missing patterns for secrets):
   - Alert user immediately
   - Prompt to add missing patterns before continuing

5. **Present tradeoffs via AskUserQuestion**:
   - IDE files preference (VS Code only / All IDEs / None)
   - OS files preference (macOS only / All OS)

6. **Generate .gitignore content**:
   - Start with mandatory patterns from `templates/base.gitignore`
   - Add project-specific patterns from detected templates
   - Add macOS patterns from `templates/macos.gitignore`
   - Add user-selected tradeoff patterns

7. **If .gitignore exists, prompt user**:
   - **Merge**: Add only missing patterns to existing file
   - **Replace**: Overwrite with generated content
   - **Review diff**: Show differences before deciding

8. **Write the file** and confirm completion

### Template Files

Located in `~/.claude/skills/gitignore/templates/`:
- `base.gitignore` - Always included (env files, AI tools, logs)
- `nodejs.gitignore` - Node.js projects
- `nextjs.gitignore` - Next.js projects
- `python.gitignore` - Python projects
- `prisma.gitignore` - Prisma ORM
- `macos.gitignore` - macOS system files
- `docker.gitignore` - Docker projects
- `go.gitignore` - Go projects
- `rust.gitignore` - Rust projects

## Mode 2: Pre-commit Check (Automatic)

This mode is triggered automatically when a git commit is attempted, via the PreToolUse hook.

### Hook Configuration

The hook is configured in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/skills/gitignore/scripts/precommit-hook.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### Validation Script

The hook runs `scripts/check-gitignore.sh` which:
1. Gets list of staged files
2. Checks for critical patterns (secrets, keys, credentials)
3. Returns JSON with status and issues

### Hook Responses

- **status: ok** → Allow commit silently
- **status: warning** → Ask user to confirm
- **status: error** → Block commit with reason

## Mode 3: Update (Remediation)

When pre-commit blocks a commit, guide the user to fix:

### Workflow

1. **Parse the block message** to identify the issue

2. **Present quick fixes**:
   - Add specific pattern to .gitignore
   - Unstage the problematic file
   - Run full `/gitignore` to regenerate

3. **Apply selected fix**:
   - If adding pattern: append to .gitignore
   - If unstaging: run `git reset HEAD <file>`

4. **Re-run validation** via check script

5. **Resume commit** if validation passes

### Example Remediation

User attempts commit with `.env.local` staged:

```
Blocked: .env.local would be committed (secrets at risk)

Quick fixes:
1. Add `.env*` to .gitignore and unstage file
2. Run /gitignore to regenerate with proper patterns
3. Unstage file only (keep it locally)

Which fix would you like to apply?
```

## Hook Auto-Enable

When `/gitignore` is first run in a project:

1. Check if PreToolUse hook exists in `~/.claude/settings.json`
2. If not present, offer to add the hook configuration:
   ```
   Enable automatic pre-commit validation?
   This will check for secrets before each commit.
   ```
3. If user accepts, update settings.json with hook config
4. Inform user that pre-commit checks are now active

## Critical Patterns

These patterns are checked during pre-commit validation:

| Pattern | Reason |
|---------|--------|
| `.env` | Environment secrets |
| `.env.local` | Local secrets |
| `.env.*.local` | Environment-specific secrets |
| `*.pem` | Private keys |
| `*.key` | Private keys |
| `credentials.json` | API credentials |
| `service-account*.json` | Service account credentials |
| `id_rsa`, `id_ed25519` | SSH keys |

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `analyze-project.py` | Comprehensive project analysis, outputs JSON |
| `scripts/check-gitignore.sh` | Fast pre-commit validation (< 500ms) |
| `precommit-hook.sh` | Hook wrapper for PreToolUse system |
