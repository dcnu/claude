# Claude Code Settings

Personal configuration for [Claude Code](https://claude.ai/code).

## Structure

```
├── CLAUDE.md              # Global instructions for all projects
├── settings.json          # Tool permissions and model preferences
├── plugins/               # Plugin configuration
└── skills/                # Custom slash commands
    ├── claude-cleanup/    # Scan and redact secrets from memory files
    ├── cleanup/           # Rename files to naming convention
    ├── create-readme/     # Generate README.md for new repos
    ├── gitignore/         # Generate .gitignore based on project type
    ├── plan-review/       # Review plan files before approval
    ├── robots/            # Generate robots.txt for websites
    ├── security/          # Global git pre-commit hook and quarantine tools
    ├── security-audit/    # Security scanning workflow
    └── worktree/          # Create git worktrees for parallel development
```

## Skills

| Skill | Description |
|-------|-------------|
| `/claude-cleanup` | Scan and redact secrets (JWT, API keys) from Claude memory files |
| `/cleanup` | Rename files to follow naming convention `Source-Title-date.ext` |
| `/create-readme` | Generate README.md and LICENSE when initializing a git repo |
| `/gitignore` | Generate .gitignore based on detected project type |
| `/plan-review` | Review a plan file and provide feedback before approval |
| `/robots` | Generate robots.txt for websites |
| `/security-audit` | Run security checks (dependencies, secrets, logs) |
| `/worktree` | Create git worktrees for parallel development |

## Security

System-level secret protection via a global git pre-commit hook. Runs on every commit across all repos.

### What it scans

- Staged `.env` files
- Known API key prefixes (OpenAI, Anthropic, Stripe, Supabase, GitHub, Slack, Shopify, Resend, AWS, JWT)
- Connection strings with embedded credentials (`user:pass@host`)
- Credential variable assignments with literal values
- Inline `PGPASSWORD` / `MYSQL_PWD` assignments

### Scripts

| Script | Purpose |
|--------|---------|
| `security/scripts/pre-commit` | Source of truth for the global pre-commit hook |
| `security/scripts/install-hooks.sh` | Copies pre-commit to `~/.config/git/hooks/` |
| `security/scripts/quarantine-scan.sh` | Scans Claude data dirs for exposed secrets |

### Usage

```sh
# Install/update the pre-commit hook
bash ~/.claude/skills/security/scripts/install-hooks.sh

# Scan for secrets in Claude session data (dry-run)
bash ~/.claude/skills/security/scripts/quarantine-scan.sh --dry-run

# Move flagged files to ~/.claude/quarantine/ for review
bash ~/.claude/skills/security/scripts/quarantine-scan.sh

# Bypass pre-commit hook for a single commit
git commit --no-verify -m "Type: message"
```
