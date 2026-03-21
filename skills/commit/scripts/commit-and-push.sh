#!/bin/bash
# Commit and push script. Two modes:
#   commit-and-push.sh "Type: description"  — stage all, commit, push
#   commit-and-push.sh --push-only          — push existing commits only

set -euo pipefail

PUSH_ONLY=false
MSG=""

if [[ "${1:-}" == "--push-only" ]]; then
	PUSH_ONLY=true
elif [[ -n "${1:-}" ]]; then
	MSG="$1"
else
	echo "Usage: commit-and-push.sh \"Type: description\" | --push-only"
	exit 1
fi

BRANCH=$(git branch --show-current)
REMOTE=$(git remote | head -1)

if [[ "$PUSH_ONLY" == true ]]; then
	# Push only mode
	UPSTREAM=$(git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null || echo "")
	if [[ -z "$UPSTREAM" ]]; then
		echo "No upstream tracking branch. Pushing with -u..."
		git push -u "$REMOTE" "$BRANCH"
	else
		git push
	fi
	exit 0
fi

# --- Validate commit message ---

if [[ ${#MSG} -gt 50 ]]; then
	echo "ERROR: Commit message exceeds 50 characters (${#MSG} chars)"
	exit 1
fi

if ! echo "$MSG" | grep -qE '^(Init|Add|Fix|Refactor|Test|Docs|Remove|Update): .+'; then
	echo "ERROR: Invalid commit message format."
	echo "Must match: Type: description"
	echo "Valid types: Init, Add, Fix, Refactor, Test, Docs, Remove, Update"
	exit 1
fi

if echo "$MSG" | grep -qi 'claude'; then
	echo "ERROR: Commit message must not mention Claude"
	exit 1
fi

# --- Stage, commit, push ---

git add -A
git commit -m "$MSG"

UPSTREAM=$(git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null || echo "")
if [[ -z "$UPSTREAM" ]]; then
	echo "No upstream tracking branch. Pushing with -u..."
	git push -u "$REMOTE" "$BRANCH"
else
	git push
fi
