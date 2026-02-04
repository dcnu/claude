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

Perform a security audit of the current repository.

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

### Step 1: Mode Selection

Use AskUserQuestion:
- Header: "Scan mode"
- Question: "What type of security scan?"
- Options:
  1. "Dependabot alerts (Recommended)" - Fix GitHub-reported vulnerabilities only
  2. "Comprehensive scan" - Full audit including outdated deps, OSV, breach detection

### Step 2: Setup (both modes)

```bash
mkdir -p .security-audit/audit-logs
```

Detect project type from `package.json` / `pyproject.toml`.

Load history from `.security-audit/`:
- `known-issues.json` - Previously identified vulnerabilities
- `fixed-issues.json` - Resolved issues with fix timestamps

If files don't exist, initialize with empty arrays `[]`.

### Step 3a: Dependabot Mode

1. Fetch alerts:
```bash
gh api /repos/{owner}/{repo}/dependabot/alerts --jq '.[] | select(.state == "open") | {number: .number, package: .security_vulnerability.package.name, severity: .security_advisory.severity, cve: .security_advisory.cve_id, fix_version: .security_vulnerability.first_patched_version.identifier}'
```

2. For each alert with `security_vulnerability.first_patched_version`:

**Node.js:**
```bash
pnpm add <package>@<first_patched_version>
pnpm test  # revert if fails
git add pnpm-lock.yaml package.json && git commit -m "Fix: Update <package> to <version> (<CVE-ID>)"
```

**Python:**
```bash
uv pip install <package>==<fix_version>
pytest  # revert if fails
git add pyproject.toml uv.lock && git commit -m "Fix: Update <package> to <version> (<CVE-ID>)"
```

3. Skip to Step 4.

### Step 3b: Comprehensive Mode

1. **Run Dependabot fixes** (same as Step 3a)

2. **Run package audit:**
```bash
~/.claude/skills/security-audit/scripts/scan-packages.sh "$TARGET_DIR"
```

For each vulnerability NOT already fixed in Step 3a.1:
- Check if fix version is available
- Check if update is patch/minor (not major)
- If both true: apply fix, test, commit

3. **Check outdated packages (interactive):**

**Node.js:**
```bash
pnpm outdated --format=json
```

**Python:**
```bash
pip list --outdated --format=json
```

Categorize into minor/patch vs major updates.

Use AskUserQuestion for minor/patch selection:
```
Header: "Updates"
Question: "Select minor/patch updates to apply:"
Options: [list each package as "package (current → latest)"]
multiSelect: true
```

For each selected package:
1. Apply update: `pnpm add <package>@<latest>` or `uv pip install <package>==<latest>`
2. Run tests
3. If pass: commit `Update: <package> to <version>`
4. If fail: revert, report failure

For major updates, use separate AskUserQuestion per package:
```
Header: "Major update"
Question: "<package> has a major update (<current> → <latest>). How would you like to proceed?"
Options:
  1. "Add to TODO/tasks.md" - Create migration task with checklist
  2. "Skip" - Track in known-issues.json for future
  3. "Update anyway" - Apply update (may cause breaking changes)
```

4. **Query OSV for each direct dependency:**
```bash
~/.claude/skills/security-audit/scripts/query-osv.sh <ecosystem> <package> [version]
```

Where `<ecosystem>` is `npm` for Node.js or `PyPI` for Python.

5. **Run breach detection:**
```bash
~/.claude/skills/security-audit/scripts/check-logs.sh "$TARGET_DIR"
git log -p --all | grep -iE "(api[_-]?key|secret|password|token|credential)" | head -100
```

Also scan for hardcoded credentials:
```bash
grep -rE "(api[_-]?key|password|secret)\s*[:=]\s*['\"][^'\"]+['\"]" --include="*.js" --include="*.ts" --include="*.py" .
```

### Step 4: Gitignore Check (both modes)

Invoke `/gitignore` skill to ensure coverage after any package changes.

### Step 5: Report (both modes)

Write results to `.security-audit/audit-logs/YYYYMMDD-HHMMSS.json`.

Update tracking files:
- `known-issues.json` - Add new vulnerabilities with id, package, version, severity, discoveredAt, source, description
- `fixed-issues.json` - Move resolved issues with fixedAt, fixedVersion, fixMethod

Display summary:
```
## Security Audit Summary - YYYY-MM-DD

### Mode
Dependabot / Comprehensive

### Project Type
Node.js / Python / Mixed

### Results
| Check | Found | Fixed | Manual |
|-------|-------|-------|--------|
| Dependabot alerts | X | Y | Z |
| Package audit | X | Y | Z |
| Version updates | X | Y | Z |

### Findings by Severity
- Critical: X
- High: X
- Medium: X
- Low: X

### Critical Issues
1. [CVE-XXXX] package@version - Status

### Recommendations
1. Priority actions

Results saved to: .security-audit/audit-logs/YYYYMMDD-HHMMSS.json
```

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `scripts/scan-packages.sh` | Run package manager audit |
| `scripts/query-osv.sh` | Query OSV database for vulnerabilities |
| `scripts/check-logs.sh` | Check Vercel/Supabase logs for anomalies |

For output JSON formats, see [templates.md](templates.md).
