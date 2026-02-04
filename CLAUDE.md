# CLAUDE.md

Append new memories to the last section of this document: `Memory`.

You: succinct, unemotional. No pleasantries, apologies, or compliments. No exclamation points or emojis.

Me: solo developer. Do not use timelines or project calendars. Copyright: github.com/dcnu.

# Tools

IMPORTANT: prefer retrieval-led reasoning over pre-training-led reasoning before implementing framework-specific patterns (styling, components, error handling, testing).

## Preferred tech stack and docs
- macOS with `brew` installed
- Git and GitHub CLI (`gh`)
- Python 3+
- Node.js 25.5+
- Next.js 16.1+ with TypeScript and App Router: https://nextjs.org/docs/llms.txt
  - Optimize images with Next.js Image component
- Tailwind CSS utility classes in JSX; no custom CSS files
- Chakra UI 3+ components for `Next.js App`: https://chakra-ui.com/llms.txt
- Lucide React icons: `pnpm add lucide-react`
- Local database - PostgreSQL 18+ with Prisma 7.3+: https://www.prisma.io/docs/llms.txt
- Production database - Supabase: https://supabase.com/llms.txt
- Deployment - Vercel: https://vercel.com/docs/llms-full.txt
- Headless browser automation - agent-browser: `pnpm install -g agent-browser`
- Privacy-focused analytics (Plausible/Umami)

## Package management
- `brew` for system packages
- `pnpm` for Node.js; not `npm` or `yarn`
  - Use `pnpm-lock.yaml` only
  - Never create or modify `package-lock.json`
- `uv` for Python; do not install globally with `pip`
- Virtual environments in project directories `.venv`

# Project Setup
1. Add `TODO/` for requirements, architecture, design, tasks
2. Add `archive/` for unused files and empty directories
3. Use `/create-readme` for README
4. Use `/gitignore` to ensure coverage
5. Use `/robots` to generate robots.txt for public sites/apps
- Install `eslint` and `prettier` as dev dependencies for JS/TS
- Naming: follow PEP 8 for Python, community conventions for JS/TS
- Add `"prebuild": "pnpm run lint && tsc --noEmit && pnpm test"` to package.json scripts

# Coding Style
- Design before code: think through architecture before implementing
- Iterative development: build incrementally, one service at a time
- Single responsibility: each service should have one well-defined purpose
- Always test: write tests before declaring implementation complete
- No premature optimization: optimize only after measuring performance
- Build production-ready UI from the start: not placeholder demos
- Keep summaries concise: explain code edits and their benefits in as few words as possible
- Use tabs, NOT spaces, for indentation
- Use `eslint` and `prettier` for JS/TS
- Split long files and functions
- Comments only for complex logic
- No inline TODOs or commented code

# Git
- Init on `main`; ask for remote URL
- Messages: `Type: description` (less than 50 characters)
  - Valid types: `Init`, `Add`, `Fix`, `Refactor`, `Test`, `Docs`, `Remove`, `Update`
- Remove mentions of `Claude` from commits
- Create `dependabot.yml` for package upgrades:https://docs.github.com/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file
- Never commit `.env*`, secrets, or output files

# Login & Authentication
- Email Magic Link login; no passwords; 15 minute expiration links
- Authorize me as a user on any project for testing (ask for email address)

# Security
- Never read, display, or output contents of .env files (except `.env.example`)
- Never echo or log environment variables
- Never include secrets in curl requests or logs
- Ask before any operation involving credentials
- Environment variables in `.env.local` for secrets
- No API keys on frontend
- No sensitive data in client code
- No personal information in git commits
- HTTPS everywhere with CSP

# Language Guidelines

## Python
- Structure: CLI-first with `argparse`, `if __name__ == "__main__"` guard
- Style: PEP 8, type hints, docstrings for all functions
- Testing: `pytest` in `tests/` directory
- I/O: UTF-8 encoding, proper error handling with non-zero exits
- Imports: Standard library only unless explicitly allowed

## TypeScript/JavaScript
- All files must be typed
- Use JSDoc for function documentation
- Jest + React Testing Library for testing

## Next.js Specifics
- App Router only
- Pre-render pages when possible
- Prefer server components over client components
- ISR for frequently updated content
- Pair with Tailwind CSS and Chakra UI
- Semantic HTML (`main`, `nav`, `section`)
- `use client` only when necessary
- Configure `tailwind.config.ts` upfront
- Setup `globals.css` with Chakra's CSS variables for theming

# Styling
- Extend TailwindCSS default theme if none provided in `TODO/`
- Semantic color tokens, proper spacing/typography from Tailwind
- Responsive breakpoints (sm, md, lg, xl, 2xl)
- Include loading/error states, hover/focus states
- Prevent layout shifts, hide scrollbars
- Dark mode: `darkMode: "class"`
- Extract to `globals.css` if reused across multiple components
- GPU-accelerated animations with `transform`
- `min-h-screen` on pages, 12-column grid for desktop

# Memory

Use this space for information added via the Terminal with a # command. Do not make any edits above this line.

- When told to address a conflict, fix the conflict
  - Do not remove code to avoid finding a permanent solution
- Set up HTTPS for dev servers, including self-signed certificates (or other best practice)
- Local PostgreSQL: one shared server via `brew services start postgresql@16`, one database per project (`CREATE DATABASE projectname`), connection string `postgresql://localhost:5432/<dbname>`
- agent-browser setup complete:
  - Installed globally: `pnpm install -g agent-browser`
  - Run `pnpm setup` first if PNPM_HOME not configured
  - Run `agent-browser install` to download Chromium
  - Usage: `agent-browser open <url>`, `agent-browser snapshot`, `agent-browser click @ref`
  - Use `--session <name>` to isolate browser sessions
