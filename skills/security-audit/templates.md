# Security Audit - Output Templates

## Audit Log Format

Save to `.security-audit/audit-logs/YYYYMMDD-HHMMSS.json`:

```json
{
  "timestamp": "ISO-8601",
  "projectType": "nodejs|python|mixed",
  "summary": {
    "critical": 0,
    "high": 0,
    "medium": 0,
    "low": 0
  },
  "phases": {
    "githubAlerts": {
      "checked": 0,
      "fixed": 0,
      "manual": 0
    },
    "packageAudit": {
      "found": 0,
      "fixed": 0,
      "manual": 0
    },
    "versionUpdates": {
      "minorApplied": 0,
      "majorPlanned": 0,
      "skipped": 0
    },
    "securityResearch": {
      "osvChecked": 0,
      "newVulns": 0
    },
    "breachDetection": {
      "secretsFound": 0,
      "gitignoreOk": true,
      "hardcodedCreds": 0
    }
  },
  "newIssues": [],
  "resolvedIssues": [],
  "packagesUpdated": [],
  "majorUpdatesPending": [],
  "recommendations": []
}
```

## Known Issues Format

File: `.security-audit/known-issues.json`

```json
[
  {
    "id": "CVE-2024-XXXXX",
    "package": "package-name",
    "version": "1.0.0",
    "severity": "critical|high|medium|low",
    "discoveredAt": "ISO-8601",
    "source": "dependabot|pnpm-audit|osv|web-search",
    "description": "Brief description of the vulnerability"
  }
]
```

## Fixed Issues Format

File: `.security-audit/fixed-issues.json`

```json
[
  {
    "id": "CVE-2024-XXXXX",
    "package": "package-name",
    "version": "1.0.0",
    "severity": "high",
    "discoveredAt": "ISO-8601",
    "source": "dependabot",
    "description": "Brief description",
    "fixedAt": "ISO-8601",
    "fixedVersion": "1.0.1",
    "fixMethod": "auto|manual"
  }
]
```

## Major Update Tracking

When a major update is skipped, add to `known-issues.json`:

```json
{
  "type": "major_update_available",
  "package": "package-name",
  "currentVersion": "1.0.0",
  "availableVersion": "2.0.0",
  "skippedAt": "ISO-8601"
}
```

## TODO Task Format

When creating migration tasks in `TODO/tasks.md`:

```markdown
## Migration: <package> v<current> → v<latest>

- [ ] Review changelog: https://github.com/<owner>/<repo>/releases
- [ ] Check for breaking changes
- [ ] Update code as needed
- [ ] Test thoroughly
- [ ] Apply update: `pnpm add <package>@<latest>`
```
