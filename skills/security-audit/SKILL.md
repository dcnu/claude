---
name: security-audit
description: Perform comprehensive security audit of the current repository
argument-hint: [directory]
disable-model-invocation: true
context: fork
agent: general-purpose
allowed-tools: Bash(gh *), Bash(pnpm *), Bash(uv *), Bash(git *), Bash(grep *), Bash(mkdir -p */.security-audit/audit-logs), Bash(~/.claude/skills/security-audit/scripts/*), WebSearch, Read, Write
---

# Security Audit

Perform a comprehensive security audit of the current repository.

**Argument:** $ARGUMENTS

**Default behavior:** Scan the current working directory (`$CWD`).

## Output Directory

All audit results are stored in `.security-audit/` within the scanned repository:

```
.security-audit/
├── audit-logs/          # Historical audit results
│   └── YYYYMMDD-HHMMSS.json
├── known-issues.json    # Currently tracked vulnerabilities
└── fixed-issues.json    # Resolved issues with timestamps
```

**Important:** Ensure `.security-audit/` is in the repository's `.gitignore`.

## Execution Flow

Execute all 7 phases in strict order. Every phase runs regardless of findings.

```
Phase 1: Setup
    ↓
Phase 2: GitHub Alerts → Fix
    ↓
Phase 3: Package Audit → Fix
    ↓
Phase 4: Version Updates (Interactive)
    ↓
Phase 5: Security Research
    ↓
Phase 6: Breach Detection
    ↓
Phase 7: Report & Persist
```

For detailed phase instructions, see [phases.md](phases.md).

For output JSON formats, see [templates.md](templates.md).

## Quick Reference

### Phase Summary

| Phase | Purpose | User Interaction |
|-------|---------|------------------|
| 1. Setup | Create output dir, detect project type | None |
| 2. GitHub Alerts | Fix Dependabot vulnerabilities | None (auto-fix) |
| 3. Package Audit | Run local audit, fix vulnerabilities | None (auto-fix) |
| 4. Version Updates | Update outdated packages | Yes (select updates) |
| 5. Security Research | Query OSV, web search for advisories | None |
| 6. Breach Detection | Scan git history, check logs | None |
| 7. Report | Generate summary, persist results | None |

### Scripts

| Script | Purpose |
|--------|---------|
| `scripts/scan-packages.sh` | Run package manager audit |
| `scripts/query-osv.sh` | Query OSV database for vulnerabilities |
| `scripts/check-logs.sh` | Check Vercel/Supabase logs for anomalies |

### Key Rules

- Every phase runs regardless of findings
- All fixes are tested before committing
- Failed fixes are reverted and flagged for manual review
- Commit format: `Fix: Update <package> to <version> (<CVE-ID>)`
