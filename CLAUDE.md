# Claude Code

Added memories should be appended to this document, in the end section titled `Memory`.

## About Me
- I am a solo developer
- I do not use timelines or project calendars.

## Authorsh
- Copyright: github.com/dcnu
- Prompt user for the correct contact email

## About You
- Succinct, unemotional
- No pleasantries, apologies, or compliments
- No exclamation points or emojis

### Coding Style
- **Design before code**: think through architecture before implementing
- **No premature optimization**: optimize only after measuring performance
- **Iterative development**: build incrementally, one service at a time
- **Single responsibility**: each service should have one well-defined purpose
- **Always test**: write tests before declaring implementation complete
- **Build production-ready UI from the start**: not placeholder demos
- **Keep summaries concise**: explain code edits and their benefits in as few words as possible

* * * * * * * * * * * * * * * * * * * *

# Project Setup

## Tech Stack
Unless specified otherwise, use:
- **Frontend**: Next.js 16.1+ with App Router, TypeScript, TailwindCSS
  - **Sometimes:** Vue, Inertia.js
- **Backend**: Node.js 25+, API routes in Next.js
- **Database - local**: PostgreSQL, Prisma
- **Database - production**: Supabase
- **Deployment**: Vercel
- **UI**: extend Tailwind default theme, shadcn/ui components, Lucide React icons

## Setup Process
1. Clarify if tool is CLI-only, or requires web app
2. Initialize git repo with `main` branch
3. Install dependencies and verify build tools
4. Create directory structure and core files
5. Configure environment variables

## Environment Requirements
- macOS with `brew` installed
- Git and GitHub CLI (`gh`)
- Node.js 25+
- Python 3+

## Login & Authentication
- Use email Magic Link login
  - Do not require passwords
  - Links should expire after one click or within 15 minutes
- Authorize me as a user on any project for testing
  - Ask for my personal email address

## Directory Structure
```
root/
├── .gitignore
├── README.md
├── archive/                # Unused files; preserved for version control
├── TODO/
│   ├── requirements.md     # Product overview; never edit
│   ├── architecture.md     # Repo overview; never delete
│   └── tasks.md            # Outstanding items and next steps
├── src/
│   ├── app/                # Next.js pages (App Router)
│   ├── components/         # React components
│   ├── lib/                # Utilities
│   └── types/              # TypeScript types
├── tests/
└── output/                 # Generated files
```

* * * * * * * * * * * * * * * * * * * *

# Development Standards

## Package Management
- `brew` for system packages

### Javascript Package Management
- Use `pnpm` for Node.js projects, not `npm` or `yarn`.

Commands:
- Install dependencies: `pnpm install`
- Add package: `pnpm add <package>`
- Add dev dependency: `pnpm add -D <package>`
- Remove package: `pnpm remove <package>`
- Run scripts: `pnpm run <script>` or `pnpm <script>`

- Use `pnpm-lock.yaml` only.
- Never create or modify `package-lock.json`.

### Python Package Management

Use `uv` for Python projects. Do not install packages globally with `pip`.

Setup:
- Create venv: `uv venv`
- Activate: `source .venv/bin/activate`

Commands:
- Install from requirements: `uv pip install -r requirements.txt`
- Add package: `uv pip install <package>`
- Freeze dependencies: `uv pip freeze > requirements.txt`
- Sync project (with pyproject.toml): `uv sync`

Use virtual environments in project directories (`.venv`).

## Pre-Build Validation
Run before every `pnpm run build`:
```bash
pnpm run lint      # Check code style and bugs
tsc --noEmit       # Type checking
pnpm test          # Unit tests
```

Build must fail if any of these fail. Add to `package.json`:
```json
"scripts": {
  "prebuild": "pnpm run lint && tsc --noEmit && pnpm test"
}
```

## Code Formatting
- Use `eslint` and `prettier` for JavaScript/TypeScript
- Use `pytest` for Python testing
- **Use tabs, NOT spaces, for indentation**
- Terminal commands in fenced code blocks may be indented for formatting

## Git Management
- Use `main` branch
- Commit frequently after meaningful changes
- Messages: `Type: description` (max 1 line; under 50 chars)
- Valid types: `Init`, `Add`, `Fix`, `Refactor`, `Test`, `Docs`, `Remove`, `Update`
- Never commit `.env*`, secrets, or output files
  - Always include these files in `.gitignore`
- Remove mentions of `Claude`, `claude.com`, and `Claude Code` from commit messages
- Remove authorship from commit messages

### .gitignore
- Use the `/gitignore` command to create a `.gitignore` file

## Security
- Never read, display, or output contents of .env files (except `.env.example`)
- Never echo or log environment variables
- Never include secrets in curl requests or logs
- Ask before any operation involving credentials
- Environment variables in `.env.local` for secrets
- No API keys on frontend
- No sensitive data in client code
- HTTPS everywhere with CSP

* * * * * * * * * * * * * * * * * * * *

# Language Guidelines

## Python
- **Structure**: CLI-first with `argparse`, `if __name__ == "__main__"` guard
- **Style**: PEP 8, type hints, docstrings for all functions
- **Testing**: `pytest` in `tests/` directory
- **I/O**: UTF-8 encoding, proper error handling with non-zero exits
- **Imports**: Standard library only unless explicitly allowed

## TypeScript/JavaScript
- **All files must be typed**
- **Prefer server components** over client components
- **Use JSDoc** for function documentation
- **Jest + React Testing Library** for testing

## Next.js Specifics
- App Router only
- Pre-render pages when possible
- ISR for frequently updated content
- Pair with Tailwind CSS and shadcn/ui
- Semantic HTML (`main`, `nav`, `section`)
- `use client` only when necessary
- Configure `tailwind.config.ts` upfront
- Setup `globals.css` with shadcn's CSS variables for theming

* * * * * * * * * * * * * * * * * * * *

# Styling

## Styling Requirements
- Use Tailwind CSS for all styling
- Use shadcn/ui components when appropriate (buttons, forms, dialogs, cards, etc.)
- Never write custom CSS files or inline styles
- Always use Tailwind utility classes directly in JSX
- Install shadcn components as needed: `npx shadcn@latest add [component]`

## Design Standards
- Build production-ready UI from the start, not placeholder demos
- Use proper spacing, typography, and color scales from Tailwind
- Implement responsive design with Tailwind breakpoints (sm, md, lg, xl, 2xl)
- Use semantic color tokens (bg-background, text-foreground, border)
- Add hover states, focus states, and transitions
- Mobile-first responsive design
- Prevent layout shifts

## Common shadcn Components
When building UI, prefer these shadcn components:
- `button`, `input`, `label`, `textarea` for forms
- `card`, `badge`, `avatar` for content display
- `dialog`, `sheet`, `popover` for overlays
- `table`, `dropdown-menu`, `select` for data
- `toast`, `alert` for notifications

## Component Structure
All components should:
- Be fully styled on first implementation
- Use proper TypeScript types
- Include loading and error states
- Be responsive by default
- Use `min-h-screen` on pages
- Follow 12-column grid for desktop with constrained width

## Tailwind CSS Configuration
- Utility-first approach
- Extract to `globals.css` only if reused across multiple components
- Extend default theme, don't override unless explicitly given an alternative theme
- Support dark mode with `darkMode: "class"`
- Hide scrollbars by default

## Icons and Images
- Lucide React for all icons
- Optimize images with Next.js Image component

## Performance
- Lighthouse score > 90
- GPU-accelerated animations with `transform`
- Privacy-focused analytics (Plausible/Umami)

* * * * * * * * * * * * * * * * * * * *

# Testing & Quality

## Testing Strategy
- **Python**: `pytest`, mirror directory structure in `tests/`
- **JavaScript**: Jest + React Testing Library
- **Files**: `*.test.{js,ts,jsx,tsx}` or `*_test.py`
- **Coverage**: Unit tests for functions, component tests for React, integration tests for APIs
- **Data**: Mock external dependencies, clean up after tests

## Error Handling
- **Python**: Specific exceptions, `logging` module, graceful `KeyboardInterrupt`
- **JavaScript**: Try/catch for async, error boundaries for React
- **APIs**: Consistent error formats, appropriate HTTP codes
- **Logging**: Structured logs, correlation IDs, sanitized sensitive data

## Code Quality
- Split long files and functions
- Comments only for complex logic
- No inline TODOs or commented code
  - Put code comments in either `README.md` or in the `TODO/` directory
- Remove empty directories after deleting files

* * * * * * * * * * * * * * * * * * * *

# Naming Conventions

## Python
- **Files**: `snake_case.py`
- **Variables/Functions**: `snake_case`
- **Classes**: `PascalCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **CLI Args**: `--kebab-case`

## JavaScript/TypeScript
- **Components**: `PascalCase` (files and component names)
- **Utilities**: `camelCase`
- **API routes**: `kebab-case`
- **Action names**: `kebab-case`

## JSON
- **Keys:** `camelCase`
- Use Prettier for formatting

* * * * * * * * * * * * * * * * * * * *

# Documentation

## README Requirements
- Use the `/create-readme` command to create `README.md`

## Code Documentation
- **Python**: Google/NumPy docstring format
- **JavaScript**: JSDoc format
- Include purpose, parameters, return values, examples
- Document complex logic only

## API Documentation
- Request/response examples
- Authentication requirements
- Error response formats
- OpenAPI/Swagger for REST APIs

* * * * * * * * * * * * * * * * * * * *

# Memory

Use this space for information added via the Terminal with a # command.

Do not make any edits above this line.

- When told to address a conflict, fix the conflict
  - Do not remove code to avoid finding a permanent solution
- Create `dependabot.yml` and allow Github's [Dependabot](https://docs.github.com/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file) the ability to upgrade package versions
- Use `archive/` instead of deleting unused files
- Set up HTTPS for dev servers, including self-signed certificates (or other best practice)
- Check .gitignore before suggesting commits
- Local PostgreSQL setup: one shared server via Homebrew (`brew services start postgresql@16`), one database per project (`CREATE DATABASE projectname`), connection string `postgresql://localhost:5432/<dbname>`