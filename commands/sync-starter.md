# Sync to Starter Template

Extract lessons learned from the current project and sync improvements back to the starter template repository.

**Argument:** $ARGUMENTS

**Default behavior:** Compare current project against remote starter repo and show diffs for approval.

**Modifiers:**
- `--dry-run` or `-n`: Show what would change without modifying
- `--gitignore`: Only sync .gitignore changes
- `--robots`: Only sync robots.txt changes
- `--claude`: Only sync CLAUDE.md Memory section changes
- `--no-push`: Apply changes locally but don't push to remote

## Configuration

- **Starter repo:** `dcnu/starter` (GitHub)
- **Files to sync:** `.gitignore`, `robots.txt`, `CLAUDE.md`
- **Cascade updates:** CLAUDE.md changes trigger README.md updates
- **Local clone path:** `/tmp/starter-sync-$$` (temporary, cleaned up after)

## Sync Flow

The sync follows a cascading update pattern:

```
Current Project → CLAUDE.md → README.md → Remote Repo
```

1. **CLAUDE.md** is the source of truth for tech stack and standards
2. **README.md** derives its tech stack section from CLAUDE.md
3. Changes flow in one direction: CLAUDE.md → README.md → push to remote

## Execution Steps

### 1. Validate Environment

Check current directory is not the starter repo itself:
```bash
git remote get-url origin 2>/dev/null | grep -q "dcnu/starter"
```

If match found, abort: "Cannot sync starter to itself. Run this from a project directory."

### 2. Collect Current Project Files

Read the following files from current project (skip if missing):
- `.gitignore`
- `robots.txt`
- `CLAUDE.md`

### 3. Fetch Starter Template from Remote

Fetch files directly from GitHub using `gh`:
```bash
gh api repos/dcnu/starter/contents/.gitignore --jq '.content' | base64 -d
gh api repos/dcnu/starter/contents/robots.txt --jq '.content' | base64 -d
gh api repos/dcnu/starter/contents/CLAUDE.md --jq '.content' | base64 -d
gh api repos/dcnu/starter/contents/README.md --jq '.content' | base64 -d
```

This avoids needing a local clone for comparison.

### 4. Analyze Differences

For each file type, identify additions that could improve the starter:

#### .gitignore Analysis
- Extract all non-comment lines from both files
- Identify patterns in current project not in starter
- Filter out project-specific patterns (paths containing project name, etc.)
- Group additions by category (dependencies, build, IDE, env, etc.)

#### robots.txt Analysis
- Extract User-agent blocks from both files
- Identify new User-agents blocked in current project
- These are likely new AI bots discovered during development

#### CLAUDE.md Analysis
- Focus on the "Memory" section (content after "# Memory" heading)
- Extract bullet points from current project's Memory section
- Identify entries not present in starter's Memory section
- Skip entries that reference specific project names or paths

### 5. Filter Modifier Arguments

If `$ARGUMENTS` contains a specific modifier:
- `--gitignore`: Only process .gitignore differences
- `--robots`: Only process robots.txt differences
- `--claude`: Only process CLAUDE.md differences
- `--dry-run`: Set flag to skip modifications and push
- `--no-push`: Set flag to skip push step

### 6. Present Differences for Approval

For each file with changes, display:

```
## .gitignore

**New patterns to add:**
```diff
+ pattern1
+ pattern2
```

Use AskUserQuestion tool to get approval for each file's changes:
- Options: "Yes, add all", "Let me select", "Skip this file"
- If "Let me select", present each addition individually

### 7. Stop If Dry Run

If `--dry-run` flag was set:
- Display what would be changed
- End with message: "Dry run complete. No changes made."
- Skip all remaining steps

### 8. Clone and Apply Changes

Clone the starter repo to a temp directory:
```bash
TEMP_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/dcnu/starter.git "$TEMP_DIR"
cd "$TEMP_DIR"
```

For each approved change:

#### .gitignore
- Append new patterns to appropriate section
- Add comment header if creating new category
- Maintain alphabetical order within sections

#### robots.txt
- Append new User-agent blocks to appropriate section
- Follow existing format (User-agent line, then Disallow line)
- Add to appropriate category section (AI Companies, Search Engines, etc.)

#### CLAUDE.md
- Append new Memory entries to end of Memory section
- Preserve existing formatting (bullet points with `-`)

### 9. Cascade: Update README.md from CLAUDE.md

After updating CLAUDE.md, check if README.md needs updates to stay in sync:

**Extract from CLAUDE.md Tech Stack section:**
- Next.js version
- Node.js version
- Package managers (pnpm, uv)
- Database (Supabase, PostgreSQL)
- Deployment target (Vercel)

**Update README.md sections:**
- "Features" section: Update Next.js version
- "Tech Stack" section: Sync all versions and tools
- "Environment Setup" section: Update Node.js version and required tools

**README sections that derive from CLAUDE.md:**
```
CLAUDE.md "Tech Stack"     → README.md "Tech Stack"
CLAUDE.md "Tech Stack"     → README.md "Features" (version numbers)
CLAUDE.md "Environment"    → README.md "Environment Setup"
CLAUDE.md "Package Mgmt"   → README.md "Environment Setup" (tools list)
```

Only update README if CLAUDE.md tech stack differs from current README values.

### 10. Determine Project Visibility

Check if the current project is public or private:
```bash
gh repo view --json isPrivate --jq '.isPrivate'
```

- If `true` (private): Use generic commit message without project name
- If `false` (public): Include project name in commit message
- If no GitHub remote: Treat as private (use generic message)

### 11. Commit Changes

Stage and commit all changes:
```bash
cd "$TEMP_DIR"
git add .gitignore robots.txt CLAUDE.md README.md
```

**Commit message format based on visibility:**
- **Public project:** `Update: Sync improvements from <project-name>`
- **Private project:** `Update: Sync template improvements`

### 12. Push to Remote

If `--no-push` flag is NOT set:

Ask for confirmation before pushing:
```
Ready to push changes to dcnu/starter?
- X file(s) modified
- Commit: "<commit message>"
```

Use AskUserQuestion:
- Options: "Yes, push now", "No, keep local only"

If approved:
```bash
cd "$TEMP_DIR"
git push origin main
```

### 13. Cleanup

Remove temporary clone:
```bash
rm -rf "$TEMP_DIR"
```

### 14. Summary Report

Display:

```
## Sync Complete

**Changes pushed to dcnu/starter:**
- .gitignore: +X patterns
- robots.txt: +X user-agents
- CLAUDE.md: +X memory entries
- README.md: Updated tech stack (if changed)

**Commit:** <commit-hash>
**View:** https://github.com/dcnu/starter/commit/<commit-hash>

**Skipped:**
- [list any skipped changes with reason]
```

If `--no-push` was used:
```
## Sync Complete (Local Only)

Changes committed locally in: $TEMP_DIR
To push manually: cd $TEMP_DIR && git push origin main
```

## Output Format

Present findings clearly:

```
## Starter Template Sync - $CWD

Comparing against: github.com/dcnu/starter

### .gitignore
[X new patterns found]
- pattern1 (category)
- pattern2 (category)

### robots.txt
[X new user-agents found]
- UserAgent1 (AI Company)
- UserAgent2 (Crawler)

### CLAUDE.md Memory
[X new entries found]
- Entry 1
- Entry 2

### README.md (cascaded from CLAUDE.md)
[Tech stack updates needed]
- Next.js: 15.4+ → 16.0+
- Node.js: 18+ → 25+

---

Ready to sync? Approve changes to commit and push to remote.
```

## Edge Cases

- **No differences found:** Report "Starter template is up to date with this project."
- **File missing in project:** Skip that file silently
- **File missing in starter:** Create the file with project's content (after confirmation)
- **Duplicate entries:** Skip patterns/entries that already exist (case-insensitive match)
- **Project-specific content:** Filter out entries containing the project directory name
- **Push fails:** Display error, keep temp directory for manual recovery
- **GitHub API rate limit:** Fall back to cloning repo for comparison
- **README already matches CLAUDE.md:** Skip README update, report "README already in sync"
