# Claude Code Settings

Personal configuration for [Claude Code](https://claude.ai/code).

## Structure

```
├── CLAUDE.md              # Global instructions for all projects
├── settings.json          # Tool permissions and model preferences
└── commands/              # Custom slash commands
    ├── kill-ports.md      # Find and kill processes on ports
    ├── security-audit.md  # Security scanning workflow
    └── sync-starter.md    # Sync improvements to starter template
```

## Commands

| Command | Description |
|---------|-------------|
| `/kill-ports` | Find and kill processes listening on TCP ports |
| `/security-audit` | Run security checks (dependencies, secrets, logs) |
| `/sync-starter` | Push improvements back to starter template |
