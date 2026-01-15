# Claude Code Settings

Personal configuration for [Claude Code](https://claude.ai/code).

## Structure

```
├── CLAUDE.md              # Global instructions for all projects
├── settings.json          # Tool permissions and model preferences
├── commands/              # Custom slash commands
│   ├── commit.md          # Git commit helper
│   ├── security-audit.md  # Security scanning workflow
│   └── sync-starter.md    # Sync improvements to starter template
└── plugins/               # Plugin configuration
```

## Commands

| Command | Description |
|---------|-------------|
| `/commit` | Guided git commit |
| `/security-audit` | Run security checks (dependencies, secrets, logs) |
| `/sync-starter` | Push improvements back to starter template |
