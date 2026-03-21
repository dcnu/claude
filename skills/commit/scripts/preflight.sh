#!/bin/bash
# Pre-commit validation and context gathering.
# Checks repo state, protected patterns, gitignore rules, large files, upstream status.
# Outputs structured plain text for Claude to parse.

set -euo pipefail

# --- Repo checks ---

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
	echo "STATUS: error"
	echo ""
	echo "ISSUES:"
	echo "- Not a git repository"
	exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [[ -z "$BRANCH" ]]; then
	echo "STATUS: error"
	echo "BRANCH: (detached HEAD)"
	echo ""
	echo "ISSUES:"
	echo "- Detached HEAD state; checkout a branch first"
	exit 0
fi

REMOTE=$(git remote 2>/dev/null | head -1)
if [[ -z "$REMOTE" ]]; then
	echo "STATUS: error"
	echo "BRANCH: $BRANCH"
	echo ""
	echo "ISSUES:"
	echo "- No remote configured"
	exit 0
fi

# Merge conflicts
CONFLICTS=$(git diff --name-only --diff-filter=U 2>/dev/null || echo "")
if [[ -n "$CONFLICTS" ]]; then
	echo "STATUS: error"
	echo "BRANCH: $BRANCH"
	echo "REMOTE: $REMOTE"
	echo ""
	echo "ISSUES:"
	echo "- Merge conflicts in:"
	echo "$CONFLICTS" | sed 's/^/  /'
	exit 0
fi

# --- Upstream tracking ---

HAS_UPSTREAM=false
UNPUSHED=0
UPSTREAM=$(git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null || echo "")
if [[ -n "$UPSTREAM" ]]; then
	HAS_UPSTREAM=true
	git fetch --quiet "$REMOTE" "$BRANCH" 2>/dev/null || true
	UNPUSHED=$(git rev-list --count "$UPSTREAM..HEAD" 2>/dev/null || echo "0")
fi

# --- Pending changes ---

CHANGES=$(git status --porcelain 2>/dev/null || echo "")

if [[ -z "$CHANGES" && "$UNPUSHED" -eq 0 && "$HAS_UPSTREAM" == true ]]; then
	echo "STATUS: nothing"
	echo "BRANCH: $BRANCH"
	echo "REMOTE: $REMOTE"
	echo "HAS_UPSTREAM: $HAS_UPSTREAM"
	echo "UNPUSHED: 0"
	exit 0
fi

if [[ -z "$CHANGES" ]]; then
	echo "STATUS: push_only"
	echo "BRANCH: $BRANCH"
	echo "REMOTE: $REMOTE"
	echo "HAS_UPSTREAM: $HAS_UPSTREAM"
	echo "UNPUSHED: $UNPUSHED"
	exit 0
fi

# --- Protected patterns ---

PROTECTED_PATTERNS=(
	".env"
	".env.*"
	"*.pem"
	"*.key"
	"credentials.json"
	"service-account*.json"
	"id_rsa"
	"id_ed25519"
)

PROTECTED_DIRS=(
	"TODO/"
	"archive/"
)

# Extract file paths from porcelain output (skip deletions)
PENDING_FILES=$(echo "$CHANGES" | grep -v '^.D ' | grep -v '^ D ' | sed 's/^...//' | sed 's/ -> .*//')

ISSUES=""

add_issue() {
	if [[ -n "$ISSUES" ]]; then
		ISSUES="$ISSUES"$'\n'
	fi
	ISSUES="${ISSUES}- $1"
}

HAS_ERROR=false

# Check protected file patterns
for pattern in "${PROTECTED_PATTERNS[@]}"; do
	if [[ "$pattern" == *"*"* ]]; then
		GREP_PATTERN=$(echo "$pattern" | sed 's/\./\\./g' | sed 's/\*/.*/')
		MATCHED=$(echo "$PENDING_FILES" | grep -E "(^|/)${GREP_PATTERN}$" || true)
	else
		MATCHED=$(echo "$PENDING_FILES" | grep -E "(^|/)${pattern}$" || true)
	fi
	while IFS= read -r file; do
		if [[ -n "$file" ]]; then
			add_issue "BLOCKED: $file matches protected pattern ($pattern)"
			HAS_ERROR=true
		fi
	done <<< "$MATCHED"
done

# Check protected directories
for dir in "${PROTECTED_DIRS[@]}"; do
	MATCHED=$(echo "$PENDING_FILES" | grep -E "^${dir}" || true)
	while IFS= read -r file; do
		if [[ -n "$file" ]]; then
			add_issue "BLOCKED: $file is inside protected directory (${dir})"
			HAS_ERROR=true
		fi
	done <<< "$MATCHED"
done

# Check .gitignore rules
if [[ -f ".gitignore" ]]; then
	while IFS= read -r file; do
		if [[ -n "$file" && -e "$file" ]]; then
			if git check-ignore --no-index -q "$file" 2>/dev/null; then
				add_issue "BLOCKED: $file matches .gitignore rule"
				HAS_ERROR=true
			fi
		fi
	done <<< "$PENDING_FILES"
fi

# Check large files (warning only)
while IFS= read -r file; do
	if [[ -n "$file" && -f "$file" ]]; then
		SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
		if [[ "$SIZE" -gt 10485760 ]]; then
			add_issue "WARNING: $file is larger than 10MB ($(( SIZE / 1048576 ))MB)"
		fi
	fi
done <<< "$PENDING_FILES"

# --- Output ---

if [[ "$HAS_ERROR" == true ]]; then
	STATUS="error"
else
	STATUS="ok"
fi

echo "STATUS: $STATUS"
echo "BRANCH: $BRANCH"
echo "REMOTE: $REMOTE"
echo "HAS_UPSTREAM: $HAS_UPSTREAM"
echo "UNPUSHED: $UNPUSHED"
echo ""
if [[ -n "$ISSUES" ]]; then
	echo "ISSUES:"
	echo "$ISSUES"
	echo ""
fi
echo "CHANGES:"
echo "$CHANGES"
echo ""
echo "DIFF_STAT:"
git diff --stat HEAD 2>/dev/null || echo "(no diff)"
