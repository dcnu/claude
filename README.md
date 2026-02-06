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
    ├── robots/            # Generate robots.txt for websites
    └── security-audit/    # Security scanning workflow
```

## Skills

| Skill | Description |
|-------|-------------|
| `/claude-cleanup` | Scan and redact secrets (JWT, API keys) from Claude memory files |
| `/cleanup` | Rename files to follow naming convention `Source-Title-date.ext` |
| `/create-readme` | Generate README.md and LICENSE when initializing a git repo |
| `/gitignore` | Generate .gitignore based on detected project type |
| `/robots` | Generate robots.txt for websites |
| `/security-audit` | Run security checks (dependencies, secrets, logs) |
