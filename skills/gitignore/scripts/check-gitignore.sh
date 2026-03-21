#!/bin/bash
# Fast pre-commit gitignore validation
# Checks staged files against .gitignore patterns and hardcoded protected paths.
# Outputs JSON with status and issues.

set -e

# Protected patterns — blocked even without a .gitignore
# Secrets
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
# Directories
PROTECTED_DIRS=(
	"TODO/"
	"archive/"
)

# Get staged files
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")

if [[ -z "$STAGED_FILES" ]]; then
	echo '{"status": "ok", "issues": []}'
	exit 0
fi

ISSUES=""
STATUS="ok"

add_issue() {
	local severity="$1" message="$2"
	if [[ -n "$ISSUES" ]]; then
		ISSUES="$ISSUES,"
	fi
	# Escape double quotes in message for valid JSON
	message=$(echo "$message" | sed 's/"/\\"/g')
	ISSUES="$ISSUES{\"severity\": \"$severity\", \"message\": \"$message\"}"
}

# --- Check 1: Protected file patterns (hardcoded, always enforced) ---
for pattern in "${PROTECTED_PATTERNS[@]}"; do
	if [[ "$pattern" == *"*"* ]]; then
		GREP_PATTERN=$(echo "$pattern" | sed 's/\./\\./g' | sed 's/\*/.*/')
		MATCHED=$(echo "$STAGED_FILES" | grep -E "(^|/)${GREP_PATTERN}$" || true)
	else
		MATCHED=$(echo "$STAGED_FILES" | grep -E "(^|/)${pattern}$" || true)
	fi
	while IFS= read -r file; do
		if [[ -n "$file" ]]; then
			add_issue "critical" "$file matches protected pattern ($pattern)"
			STATUS="error"
		fi
	done <<< "$MATCHED"
done

# --- Check 2: Protected directories (hardcoded, always enforced) ---
for dir in "${PROTECTED_DIRS[@]}"; do
	MATCHED=$(echo "$STAGED_FILES" | grep -E "^${dir}" || true)
	while IFS= read -r file; do
		if [[ -n "$file" ]]; then
			add_issue "critical" "$file is inside protected directory (${dir})"
			STATUS="error"
		fi
	done <<< "$MATCHED"
done

# --- Check 3: Staged files that match .gitignore rules ---
# Catches force-added or previously tracked files that .gitignore now covers.
if [[ -f ".gitignore" ]]; then
	while IFS= read -r file; do
		if [[ -n "$file" ]]; then
			# --no-index checks against ignore rules regardless of index state
			if git check-ignore --no-index -q "$file" 2>/dev/null; then
				# Avoid duplicating issues already caught above
				ALREADY_REPORTED=false
				for pattern in "${PROTECTED_PATTERNS[@]}"; do
					if [[ "$pattern" == *"*"* ]]; then
						GP=$(echo "$pattern" | sed 's/\./\\./g' | sed 's/\*/.*/')
						echo "$file" | grep -qE "(^|/)${GP}$" && ALREADY_REPORTED=true && break
					else
						echo "$file" | grep -qE "(^|/)${pattern}$" && ALREADY_REPORTED=true && break
					fi
				done
				for dir in "${PROTECTED_DIRS[@]}"; do
					echo "$file" | grep -qE "^${dir}" && ALREADY_REPORTED=true && break
				done
				if [[ "$ALREADY_REPORTED" == false ]]; then
					add_issue "critical" "$file is ignored by .gitignore but staged for commit"
					STATUS="error"
				fi
			fi
		fi
	done <<< "$STAGED_FILES"
else
	# No .gitignore at all — warn
	add_issue "warning" "No .gitignore file found"
	if [[ "$STATUS" == "ok" ]]; then
		STATUS="warning"
	fi
fi

# --- Check 4: Large files (> 10MB) ---
while IFS= read -r file; do
	if [[ -f "$file" ]]; then
		SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
		if [[ "$SIZE" -gt 10485760 ]]; then
			add_issue "warning" "$file is larger than 10MB"
			if [[ "$STATUS" == "ok" ]]; then
				STATUS="warning"
			fi
		fi
	fi
done <<< "$STAGED_FILES"

# Output JSON
if [[ -z "$ISSUES" ]]; then
	echo '{"status": "ok", "issues": []}'
else
	echo "{\"status\": \"$STATUS\", \"issues\": [$ISSUES], \"message\": \"Protected files or ignored files are staged\"}"
fi
