---
name: worktree
description: Create git worktree(s) for parallel development
argument-hint: worktree name or description
allowed-tools: Bash, Read, Glob
---

Create a git worktree as a sibling directory for parallel development.

## Steps

1. **Determine slug**: Convert the user's argument to kebab-case. Prefix with the git user's first name in lowercase (from `git config user.name`). Example: if user name is "Dylan Castillo" and argument is "test feature", slug is `dylan-test-feature`.

2. **Determine base branch**: Default to `main`. If the user specifies a different base branch, use that instead.

3. **Get repo root and name**:
   ```
   REPO_ROOT=$(git rev-parse --show-toplevel)
   REPO_NAME=$(basename "$REPO_ROOT")
   ```

4. **Check if branch already exists** (`git rev-parse --verify "${SLUG}"`):
   - If it exists, attach to it: `git worktree add "../${REPO_NAME}-${SLUG}" "${SLUG}"`
   - If it does not exist, create a new branch from the base: `git worktree add "../${REPO_NAME}-${SLUG}" -b "${SLUG}" "${BASE_BRANCH}"`

5. **Copy env files**: Glob for `.env*` files in the repo root. Copy each one to the new worktree, **excluding** `.env.example` and `.env.sample`.

6. **Report** to the user:
   - Full path to the new worktree
   - Branch name
   - Output of `git worktree list` so the user sees all active worktrees
   - Ready-to-use command: `cd <full-path> && claude`
   - Session tip: after starting Claude in the worktree, run `/rename <slug>` to name the session. Resume later with `claude --resume <slug>`.
   - Note: if the repo has a `.claude/` directory, project settings are git-tracked and already present in the worktree.
   - Cleanup reminders:
     - `git worktree remove <path>` when done
     - `git branch -d <slug>` to delete the branch after merging

7. **Detect package manager** in the repo and remind the user to install dependencies:
   - `pnpm-lock.yaml` → `pnpm install`
   - `package-lock.json` → `npm install`
   - `yarn.lock` → `yarn install`
   - `uv.lock` or `pyproject.toml` → `uv sync`
   - `requirements.txt` → `pip install -r requirements.txt`

## Error handling

- If the branch already exists and is already checked out in another worktree: tell the user which worktree has it and suggest picking a different slug.
- If the directory already exists: tell the user the path and suggest removing it or picking a different slug.
- Never force-delete worktrees or branches.
