#!/usr/bin/env bash
# Scan Claude Code data directories for files containing potential secrets.
# Moves matches to ~/.claude/quarantine/ preserving relative paths.
# Usage: quarantine-scan.sh [--dry-run]

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
QUARANTINE_DIR="${CLAUDE_DIR}/quarantine"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
	DRY_RUN=true
fi

# Directories/files to scan
SCAN_TARGETS=(
	"debug"
	"file-history"
	"projects"
	"history.jsonl"
)

# Patterns to match (same as pre-commit hook key patterns)
PATTERNS=(
	'sk-[A-Za-z0-9]{20,}'
	'sk_live_[A-Za-z0-9]{20,}'
	'sk_test_[A-Za-z0-9]{20,}'
	'pk_live_[A-Za-z0-9]{20,}'
	'pk_test_[A-Za-z0-9]{20,}'
	'rk_live_[A-Za-z0-9]{20,}'
	'rk_test_[A-Za-z0-9]{20,}'
	'sb_secret_[A-Za-z0-9]{20,}'
	'sbp_[A-Za-z0-9]{20,}'
	'ghp_[A-Za-z0-9]{20,}'
	'gho_[A-Za-z0-9]{20,}'
	'ghs_[A-Za-z0-9]{20,}'
	'ghr_[A-Za-z0-9]{20,}'
	'github_pat_[A-Za-z0-9]{20,}'
	'xoxb-[A-Za-z0-9-]{20,}'
	'xoxp-[A-Za-z0-9-]{20,}'
	'shpat_[A-Za-z0-9]{20,}'
	'whsec_[A-Za-z0-9]{20,}'
	'AKIA[A-Z0-9]{16}'
	'eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.'
	'://[^/:@[:space:]]+:[^/@[:space:]]+@[A-Za-z0-9]'
	'(PGPASSWORD|MYSQL_PWD)[[:space:]]*=[[:space:]]*[A-Za-z0-9]'
)

# Build combined pattern
COMBINED=""
for p in "${PATTERNS[@]}"; do
	if [[ -z "$COMBINED" ]]; then
		COMBINED="$p"
	else
		COMBINED="${COMBINED}|${p}"
	fi
done

FILES_SCANNED=0
MATCHES_FOUND=0
FILES_MOVED=0

SEEN_FILES=""

for target in "${SCAN_TARGETS[@]}"; do
	TARGET_PATH="${CLAUDE_DIR}/${target}"
	[[ ! -e "$TARGET_PATH" ]] && continue

	# Skip quarantine dir, skills dir, .git
	if [[ "$target" == "quarantine" ]] || [[ "$target" == "skills" ]]; then
		continue
	fi

	# Find files (not directories, not binary-heavy)
	while IFS= read -r -d '' file; do
		FILES_SCANNED=$((FILES_SCANNED + 1))

		# Skip binary files
		if file "$file" | grep -qE 'binary|executable|image|compressed'; then
			continue
		fi

		# Check for secret patterns
		if grep -qE "$COMBINED" "$file" 2>/dev/null; then
			RELPATH="${file#"${CLAUDE_DIR}/"}"

			# Deduplicate
			if echo "$SEEN_FILES" | grep -qF "$RELPATH"; then
				continue
			fi
			SEEN_FILES="${SEEN_FILES}${RELPATH}"$'\n'

			MATCHES_FOUND=$((MATCHES_FOUND + 1))

			if [[ "$DRY_RUN" == true ]]; then
				echo "[DRY-RUN] Match: ${RELPATH}"
				PREVIEW=$(grep -nE "$COMBINED" "$file" 2>/dev/null | head -3 || true)
				while IFS= read -r line; do
					[[ -z "$line" ]] && continue
					echo "          ${line:0:120}"
				done <<< "$PREVIEW"
			else
				DEST_DIR="${QUARANTINE_DIR}/$(dirname "$RELPATH")"
				mkdir -p "$DEST_DIR"
				mv "$file" "${QUARANTINE_DIR}/${RELPATH}"
				FILES_MOVED=$((FILES_MOVED + 1))
				echo "Moved: ${RELPATH} -> quarantine/${RELPATH}"
			fi
		fi
	done < <(find "$TARGET_PATH" -type f -print0 2>/dev/null)
done

echo ""
echo "=== Scan Summary ==="
echo "Files scanned: ${FILES_SCANNED}"
echo "Matches found: ${MATCHES_FOUND}"
if [[ "$DRY_RUN" == true ]]; then
	echo "Mode: dry-run (no files moved)"
else
	echo "Files moved to quarantine: ${FILES_MOVED}"
fi
