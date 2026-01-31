#!/bin/bash
# PreToolUse hook wrapper for gitignore validation
# Only activates for git commit commands
# Returns JSON response for Claude Code hook system

# Read the tool input from stdin
INPUT=$(cat)

# Check if this is a Bash tool call
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//' | sed 's/".*//')

if [[ "$TOOL_NAME" != "Bash" ]]; then
	# Not a Bash command, allow it
	echo '{"decision": "allow"}'
	exit 0
fi

# Extract the command
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"//' | sed 's/".*//')

# Check if it's a git commit command
if [[ ! "$COMMAND" =~ ^git[[:space:]]+commit ]]; then
	# Not a git commit, allow it
	echo '{"decision": "allow"}'
	exit 0
fi

# Run the gitignore check
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_RESULT=$("$SCRIPT_DIR/check-gitignore.sh" 2>/dev/null)

if [[ $? -ne 0 ]]; then
	# Script failed, allow the commit but warn
	echo '{"decision": "allow"}'
	exit 0
fi

# Parse the status from the check result
STATUS=$(echo "$CHECK_RESULT" | grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"status"[[:space:]]*:[[:space:]]*"//' | sed 's/".*//')

case "$STATUS" in
	"ok")
		echo '{"decision": "allow"}'
		;;
	"warning")
		# Extract warning message
		MESSAGE=$(echo "$CHECK_RESULT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"message"[[:space:]]*:[[:space:]]*"//' | sed 's/".*//')
		echo "{\"decision\": \"ask\", \"message\": \"Warning: $MESSAGE. Continue with commit?\"}"
		;;
	"error")
		# Extract error message
		MESSAGE=$(echo "$CHECK_RESULT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"message"[[:space:]]*:[[:space:]]*"//' | sed 's/".*//')
		echo "{\"decision\": \"block\", \"message\": \"Blocked: $MESSAGE. Run /gitignore to fix.\"}"
		;;
	*)
		# Unknown status, allow
		echo '{"decision": "allow"}'
		;;
esac
