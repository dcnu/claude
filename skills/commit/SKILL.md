---
name: commit
description: Validate, commit, and push changes. Use when the user asks to commit, push, or ship code.
allowed-tools: Bash(bash ~/.claude/skills/commit/scripts/commit-and-push.sh *)
---

# Commit and Push

Validate pending changes against protected patterns, commit, and push in a single flow.

## Preflight Context

!`bash ~/.claude/skills/commit/scripts/preflight.sh`

## Recent Commits

!`git log --oneline -10 2>/dev/null`

## Task

Read the preflight STATUS above and follow exactly one path:

- **nothing** → Say "Nothing to commit or push." and stop. No tool calls.
- **error** → Report each ISSUES line to the user and stop. No tool calls.
- **push_only** → Call `bash ~/.claude/skills/commit/scripts/commit-and-push.sh --push-only` and stop.
- **ok** → Generate a commit message from the CHANGES and DIFF_STAT above, then call `bash ~/.claude/skills/commit/scripts/commit-and-push.sh "Type: description"`.

Commit message rules:
- Format: `Type: description` where Type is one of Init, Add, Fix, Refactor, Test, Docs, Remove, Update
- Max 50 characters total
- No mentions of Claude
- Match the style of the recent commits above

Do not use any other tools. Do not send any other text besides the tool call (or status report for nothing/error).
