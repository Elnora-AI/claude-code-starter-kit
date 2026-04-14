# Claude Code Starter Kit

A ready-to-use project scaffold for working with [Claude Code](https://claude.ai/code) — Anthropic's AI coding agent that lives in your terminal and editor.

This kit gives you a solid starting point: project instructions for Claude, sensible permissions, a curated plugin list, and an example knowledge base folder you can use with Obsidian.

## What's inside

```
claude-code-starter-kit/
├── CLAUDE.md                 # Project instructions — Claude reads this automatically
├── TOOLS.md                  # Catalog of tools, plugins, and integrations you add over time
├── .gitignore                # Keeps secrets, OS files, and build artifacts out of Git
├── .env.template             # Template for environment variables (copy to .env)
├── .mcp.json                 # Project MCP servers (context7, grep)
├── .github/                  # Dependabot, CI, CodeQL, PR/issue templates (disabled by default)
├── .claude/
│   ├── settings.json         # Plugin marketplaces, enabled plugins, and permission defaults
│   └── commands/
│       └── commit.md         # Example custom slash command (/commit)
├── docs/
│   └── getting-started.md    # What to do after the workshop
├── knowledge-base/           # Example Obsidian vault / local knowledge base
│   ├── README.md             # How this folder works with Claude and Obsidian
│   └── example-notes/
│       ├── meeting-notes-2026-04-14.md
│       └── project-brief-example.md
├── marketplace-plugins.md    # Curated list of safe plugin marketplaces and recommendations
├── cache/                    # Runtime scratch — gitignored, for logs/state/downloads
└── scripts/
    ├── setup-mac.sh          # One-command install for macOS
    └── setup-windows.ps1     # One-command install for Windows
```

## Quick start

### 1. Copy this into your project

If you cloned this repo, copy its contents into your own project folder:

```bash
# Option A: Clone and copy
git clone https://github.com/your-org/claude-code-starter-kit.git
cp -r claude-code-starter-kit/* claude-code-starter-kit/.* your-project/

# Option B: Have Claude do it
# Open your project in VS Code, start Claude Code, and say:
# "Clone the starter kit repo and copy its contents into this project"
```

### 2. Set up your environment

```bash
# Copy the environment template
cp .env.template .env

# Edit .env with your actual values (if any)
```

### 3. Customize CLAUDE.md

Open `CLAUDE.md` and fill in:
- Your project name and description
- Your tech stack
- Your build/test/run commands
- Any team conventions

This is the most important file — it tells Claude everything about your project.

### 4. Install plugins

Open Claude Code and run:
```
/plugins
```

See `marketplace-plugins.md` for our recommended starter plugins.

## What is Claude Code?

Claude Code is an AI agent by Anthropic that:
- Lives in your terminal and VS Code
- Can read, write, and edit files
- Can run commands and use tools
- Reads your `CLAUDE.md` for project context
- Can be extended with plugins, skills, and MCP servers

Learn more: [claude.ai/code](https://claude.ai/code)

## License

MIT License. Use freely.
