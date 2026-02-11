#!/usr/bin/env bash
# Install the pre-commit hook to the global git hooks directory.
# Source of truth: ~/.claude/skills/security/scripts/pre-commit

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="${SCRIPT_DIR}/pre-commit"
HOOKS_DIR="${HOME}/.config/git/hooks"
TARGET="${HOOKS_DIR}/pre-commit"

if [[ ! -f "$SOURCE" ]]; then
	echo "Error: source pre-commit hook not found at ${SOURCE}" >&2
	exit 1
fi

mkdir -p "$HOOKS_DIR"

if [[ -f "$TARGET" ]]; then
	echo "Warning: existing pre-commit hook at ${TARGET} will be overwritten"
fi

cp "$SOURCE" "$TARGET"
chmod +x "$TARGET"

echo "Installed pre-commit hook to ${TARGET}"
echo "Global hooks path: $(git config --global core.hooksPath 2>/dev/null || echo 'not set')"
