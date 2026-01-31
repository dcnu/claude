---
name: create-readme
description: Generate or update README.md and LICENSE. Use when initializing repos, after major changes, or when user asks about documentation.
allowed-tools: Bash(~/.claude/skills/create-readme/scripts/*), Read, Write
---

# Create README

Generate a comprehensive README.md for the current project.

## Workflow

1. Run the detection script to identify project type and metadata:
   ```bash
   bash $CLAUDE_PROJECT_DIR/skills/create-readme/scripts/detect-project.sh
   ```

2. Review the detected information and prompt user for any missing details:
   - Project description (required)
   - License - select one:
     - **MIT** - permissive, attribution required
     - **GPL 3.0** - copyleft, derivatives must be open source
     - **All rights reserved** - no LICENSE file generated
   - Author (default: `github.com/dcnu`)

3. Generate README with these sections:
   - **Project Title** - from package.json/pyproject.toml name field
   - **Description** - infer from codebase
   - **Features** - infer from codebase
   - **Tech Stack** - from detected project type
   - **Prerequisites** - based on project type (Node.js version, Python version, etc.)
   - **Installation** - package manager commands based on detection
   - **Environment Setup** - if `.env.example` exists, document required variables
   - **Usage** - CLI commands, local server, or public URL (if applicable)
   - **Testing** - test commands based on project type
   - **Code Documentation** - standards based on project type (if code files exist)
   - **API Documentation** - request/response examples (if API routes detected)
   - **Project Structure** - generate from directory tree
   - **License** - user-selected

4. If README.md already exists, prompt user:
   - **Update**: Refresh dynamic sections, preserve static sections
   - **Replace**: Overwrite with new README
   - **Cancel**: Abort operation

   **Auto-Update Mode** (when updating existing README):
   - **Static sections** (preserve user content):
     - Description
     - Features
     - Usage
     - License
   - **Dynamic sections** (regenerate automatically):
     - Project Structure
     - Tech Stack
     - Prerequisites
     - Installation
     - Testing
     - Environment Setup

   Use section markers in generated READMEs:
   ```markdown
   <!-- AUTO:START Project Structure -->
   ...content...
   <!-- AUTO:END Project Structure -->
   ```

5. Generate LICENSE file (if license is not "All rights reserved"):
   - Check if LICENSE file already exists
   - If exists, prompt: **Replace** / **Skip**
   - Generate LICENSE file with full license text
   - Include copyright line: `Copyright (c) [YEAR] [Author]`

## Detection Script Output

The script outputs JSON with detected project metadata:
```json
{
  "type": "nextjs|node|python|unknown",
  "name": "project-name",
  "version": "1.0.0",
  "description": "existing description if any",
  "packageManager": "pnpm|npm|yarn|uv|pip",
  "framework": "next|express|fastapi|flask|none",
  "database": "postgresql|mysql|sqlite|mongodb|none",
  "hasTests": true,
  "testCommand": "pnpm test",
  "hasPrisma": false,
  "hasEnvExample": true
}
```

## Template Sections

### Prerequisites
- **Node.js**: Node.js 25+ and pnpm
- **Python**: Python 3.x and uv
- **Next.js**: Node.js 25+, pnpm, and PostgreSQL (if database detected)

### Installation Commands
- **pnpm**: `pnpm install`
- **uv**: `uv venv && source .venv/bin/activate && uv pip install -r requirements.txt`

### Test Commands
- **Node.js**: `pnpm test`
- **Python**: `pytest`

### Code Documentation
Include only if code files exist in the project.

- **Python projects**: Google/NumPy docstring format
- **JavaScript/TypeScript projects**: JSDoc format
- Guidelines: purpose, parameters, return values, examples
- Document complex logic only

### API Documentation
Include only if API routes are detected (`src/app/api/`, `pages/api/`, or framework is fastapi/flask/express).

- Request/response examples
- Authentication requirements
- Error response formats
- OpenAPI/Swagger for REST APIs

## License Templates

### MIT License

```
MIT License

Copyright (c) [YEAR] [AUTHOR]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### GPL 3.0 License

Use the official GPL 3.0 license text from: https://www.gnu.org/licenses/gpl-3.0.txt

Add copyright header at the top of the LICENSE file:
```
Copyright (C) [YEAR] [AUTHOR]

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
```
