# CLAUDE.md

This file provides instructions and context to Claude Code when working in this project.
Claude reads this file automatically at the start of every conversation.

---

## Project Overview

<!-- Replace this section with your own project details -->

**Project name**: [Your Project Name]
**Description**: [Brief description of what this project does]
**Team**: [Who works on this]

---

## Tech Stack

<!-- List the technologies your project uses. Examples below — replace with your own. -->

| Layer | Technology |
|-------|-----------|
| **Language** | [e.g., Python, TypeScript, C#] |
| **Framework** | [e.g., React, FastAPI, .NET] |
| **Database** | [e.g., PostgreSQL, SQLite, none] |
| **Hosting** | [e.g., AWS, Vercel, local only] |

---

## Development Commands

<!-- List the commands you use to build, test, and run your project. -->

```bash
# Install dependencies
# npm install / pip install -r requirements.txt / dotnet restore

# Start development server
# npm start / python main.py / dotnet run

# Run tests
# npm test / pytest / dotnet test

# Build for production
# npm run build / python -m build / dotnet publish
```

---

## Project Structure

<!-- Describe your folder structure so Claude knows where things are. -->

```
your-project/
├── src/               # Source code
├── tests/             # Test files
├── docs/              # Documentation
├── knowledge-base/    # Local knowledge base (Obsidian vault)
└── scripts/           # Utility scripts
```

---

## Code Quality Rules

These rules apply to all code Claude writes in this project:

1. **Never commit secrets** — Use environment variables, never hardcode API keys, passwords, or tokens
2. **Keep it simple** — Don't over-engineer. Write the simplest code that solves the problem
3. **Format consistently** — Follow the existing code style in the project
4. **No unnecessary changes** — Only modify what's needed. Don't "improve" unrelated code
5. **Test when possible** — Write tests for new functionality if the project has a test framework

---

## Knowledge Base

This project has a local knowledge base in the `knowledge-base/` folder. It contains markdown files that Claude can read and search.

To query the knowledge base, ask Claude something like:
- "Search the knowledge base for [topic]"
- "Read the meeting notes from last week"
- "What does the knowledge base say about [topic]?"

---

## Team Conventions

<!-- Add any team-specific conventions here. Examples: -->

<!-- ### Branch naming -->
<!-- - `feature/description` for new features -->
<!-- - `bugfix/description` for bug fixes -->

<!-- ### Commit messages -->
<!-- - Use conventional commits: `feat:`, `fix:`, `docs:`, `chore:` -->

<!-- ### Code review -->
<!-- - All changes require a PR review before merging -->
