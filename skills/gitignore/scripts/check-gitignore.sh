#!/bin/bash
# Fast pre-commit gitignore validation
# Outputs JSON with status and issues

set -e

# Critical patterns that should never be committed
CRITICAL_PATTERNS=(
	".env"
	".env.local"
	".env.development.local"
	".env.production.local"
	".env.test.local"
	"*.pem"
	"*.key"
	"credentials.json"
	"service-account*.json"
	"id_rsa"
	"id_ed25519"
)

# Get staged files
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")

if [[ -z "$STAGED_FILES" ]]; then
	echo '{"status": "ok", "issues": []}'
	exit 0
fi

# Check if .gitignore exists
if [[ ! -f ".gitignore" ]]; then
	echo '{"status": "warning", "issues": [{"severity": "warning", "message": "No .gitignore file found", "pattern": null}]}'
	exit 0
fi

ISSUES=""
STATUS="ok"

# Check each critical pattern against staged files
for pattern in "${CRITICAL_PATTERNS[@]}"; do
	# Use git check-ignore to see if pattern is ignored
	# Then check if any staged file matches the pattern

	# For exact matches
	if [[ "$pattern" == *"*"* ]]; then
		# Wildcard pattern - use grep with pattern conversion
		GREP_PATTERN=$(echo "$pattern" | sed 's/\./\\./g' | sed 's/\*/.*/')
		MATCHED_FILES=$(echo "$STAGED_FILES" | grep -E "^${GREP_PATTERN}$" || true)
	else
		# Exact match
		MATCHED_FILES=$(echo "$STAGED_FILES" | grep -E "^${pattern}$" || true)
	fi

	if [[ -n "$MATCHED_FILES" ]]; then
		# Check if it would be ignored by .gitignore
		while IFS= read -r file; do
			if [[ -n "$file" ]]; then
				# File is staged but should be ignored
				if [[ -n "$ISSUES" ]]; then
					ISSUES="$ISSUES,"
				fi
				ISSUES="$ISSUES{\"severity\": \"critical\", \"message\": \"$file would be committed (secrets at risk)\", \"pattern\": \"$pattern\"}"
				STATUS="error"
			fi
		done <<< "$MATCHED_FILES"
	fi
done

# Check for common accidental commits
# Large files (> 10MB)
for file in $STAGED_FILES; do
	if [[ -f "$file" ]]; then
		SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
		if [[ "$SIZE" -gt 10485760 ]]; then
			if [[ -n "$ISSUES" ]]; then
				ISSUES="$ISSUES,"
			fi
			ISSUES="$ISSUES{\"severity\": \"warning\", \"message\": \"$file is larger than 10MB\", \"pattern\": null}"
			if [[ "$STATUS" == "ok" ]]; then
				STATUS="warning"
			fi
		fi
	fi
done

# Output JSON
if [[ -z "$ISSUES" ]]; then
	echo '{"status": "ok", "issues": []}'
else
	echo "{\"status\": \"$STATUS\", \"issues\": [$ISSUES]}"
fi
