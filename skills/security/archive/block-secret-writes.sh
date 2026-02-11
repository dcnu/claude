#!/usr/bin/env bash
# PreToolUse hook: block Write/Edit operations that contain literal secrets.
# Exit 0 = allow, Exit 2 = block (with stderr message).

set -euo pipefail

# Read JSON from stdin, extract content to check
INPUT=$(cat)
CONTENT=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
# Write uses 'content', Edit uses 'new_string'
print(ti.get('content', '') or ti.get('new_string', ''))
" 2>/dev/null || true)

# Nothing to check
if [[ -z "$CONTENT" ]]; then
	exit 0
fi

# --- Connection strings with embedded credentials ---
if echo "$CONTENT" | grep -qE '://[^/:@]+:[^/@]+@'; then
	echo "BLOCKED: content contains connection string with embedded credentials" >&2
	exit 2
fi

# --- Known API key prefixes ---
API_KEY_PREFIXES=(
	'sk-[A-Za-z0-9]'
	'sk_live_'
	'sk_test_'
	'sb_secret_'
	'ghp_'
	'gho_'
	'ghs_'
	'ghr_'
	'xoxb-'
	'xoxp-'
	'shpat_'
	'rk_live_'
	'rk_test_'
	'whsec_'
)

for prefix in "${API_KEY_PREFIXES[@]}"; do
	if echo "$CONTENT" | grep -qE "$prefix"; then
		echo "BLOCKED: content contains what appears to be an API key (prefix: ${prefix%%[*})" >&2
		exit 2
	fi
done

# --- Credential assignments (not in .env files, which are already denied) ---
# Match PASSWORD=, SECRET=, TOKEN=, API_KEY= followed by a value
if echo "$CONTENT" | grep -qiE '(PASSWORD|SECRET|TOKEN|API_KEY)\s*=\s*["\x27]?[A-Za-z0-9]'; then
	echo "BLOCKED: content contains credential assignment (PASSWORD/SECRET/TOKEN/API_KEY)" >&2
	exit 2
fi

# No secrets found
exit 0
