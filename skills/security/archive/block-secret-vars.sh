#!/usr/bin/env bash
# PreToolUse hook: block Bash commands that reference secret environment variables.
# Exit 0 = allow, Exit 2 = block (with stderr message).

set -euo pipefail

# Read JSON from stdin, extract the command field
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
# tool_input.command is where the bash command lives
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null || true)

# Nothing to check
if [[ -z "$COMMAND" ]]; then
	exit 0
fi

# --- Known service prefixes ---
# Match $VAR or ${VAR} forms for known secret prefixes
KNOWN_PREFIXES=(
	'SUPABASE_'
	'DATABASE_URL'
	'DATABASE_PASSWORD'
	'AWS_SECRET'
	'AWS_ACCESS_KEY'
	'AWS_SESSION_TOKEN'
	'OPENAI_'
	'ANTHROPIC_'
	'STRIPE_'
	'GITHUB_TOKEN'
	'GITHUB_SECRET'
	'VERCEL_TOKEN'
	'VERCEL_SECRET'
	'SENDGRID_'
	'TWILIO_'
	'SLACK_TOKEN'
	'SLACK_SECRET'
	'REDIS_PASSWORD'
	'REDIS_URL'
	'MONGO_URI'
	'MONGODB_URI'
)

for prefix in "${KNOWN_PREFIXES[@]}"; do
	# Match $PREFIX or ${PREFIX
	if echo "$COMMAND" | grep -qE '(\$\{?'"$prefix"')'; then
		echo "BLOCKED: command references secret variable matching '$prefix'" >&2
		exit 2
	fi
done

# --- Generic secret keywords in variable names ---
# Match $ANYTHING_KEY, $ANYTHING_TOKEN, etc. (case-insensitive)
SECRET_KEYWORDS=(
	'KEY'
	'TOKEN'
	'SECRET'
	'PASSWORD'
	'CREDENTIAL'
	'AUTH'
	'PRIVATE'
)

for keyword in "${SECRET_KEYWORDS[@]}"; do
	# Match $VAR_NAME or ${VAR_NAME where VAR_NAME contains the keyword
	# Use case-insensitive grep; require the keyword to be part of a variable name
	if echo "$COMMAND" | grep -qiE '\$\{?[A-Za-z_]*'"$keyword"'[A-Za-z_]*'; then
		echo "BLOCKED: command references variable containing '$keyword' (possible secret)" >&2
		exit 2
	fi
done

# --- Literal credential patterns ---
# Inline credential env var assignments (catches values the deny rules might miss in chained commands)
if echo "$COMMAND" | grep -qE '(PGPASSWORD|MYSQL_PWD)\s*='; then
	echo "BLOCKED: command sets inline credential variable (PGPASSWORD/MYSQL_PWD)" >&2
	exit 2
fi

# Connection strings with embedded credentials (user:pass@host)
if echo "$COMMAND" | grep -qE '://[^/:@]+:[^/@]+@'; then
	echo "BLOCKED: command contains connection string with embedded credentials" >&2
	exit 2
fi

# --password= CLI flag pattern
if echo "$COMMAND" | grep -qiE '\-\-password[= ]'; then
	echo "BLOCKED: command contains --password flag with literal value" >&2
	exit 2
fi

# No secret references found
exit 0
