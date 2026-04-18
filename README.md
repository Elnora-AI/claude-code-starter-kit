# Claude Code Starter Kit

A ready-to-use project scaffold for working with [Claude Code](https://claude.ai/code) — Anthropic's AI coding agent that lives in your terminal and editor.

This kit gives you a solid starting point: project instructions for Claude, sensible permissions, a curated plugin list, and an example knowledge base folder you can use with Obsidian.

## What's inside

```
claude-code-starter-kit/
├── CLAUDE.md                             # Project instructions — Claude reads this automatically
├── TOOLS.md                              # Catalog of tools, plugins, and integrations you add over time
├── README.md                             # You are here
├── marketplace-plugins.md                # Curated list of safe plugin marketplaces and recommendations
├── setup-mac.sh                          # One-command install for macOS
├── setup-windows.ps1                     # One-command install for Windows
├── .gitignore                            # Keeps secrets, OS files, and build artifacts out of Git
├── .env.template                         # Template for environment variables (copy to .env)
├── .mcp.json                             # Project MCP servers (context7, grep)
├── .github/                              # Dependabot, CI, CodeQL (disabled by default — rename to enable)
├── .claude/
│   ├── settings.json                     # Plugin marketplaces, enabled plugins, and permission defaults
│   ├── knowledge-base.local.md.template  # Template for per-user knowledge-base config (gitignored once filled in)
│   └── commands/
│       └── commit.md                     # Example custom slash command (/commit)
├── docs/
│   └── getting-started.md                # First steps after install
└── cache/                                # Runtime scratch — gitignored, for logs/state/downloads
```

> **Knowledge base**: this kit no longer ships example notes. Point Claude at your own Obsidian
> vault (or any local folder) by copying `.claude/knowledge-base.local.md.template` to
> `.claude/knowledge-base.local.md` and filling in the YAML frontmatter. See `CLAUDE.md` for details.

## Quick start

### 1. Install the toolchain

On a fresh machine, run the setup script for your OS. It installs Node.js, Git, Python, VS Code,
Claude Code, GitHub CLI, and (optionally) Obsidian, skipping anything that's already present.

**macOS** (from Terminal):
```bash
./setup-mac.sh
```

**Windows** (from an Administrator PowerShell):
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup-windows.ps1
```

Restart your shell afterwards so PATH changes take effect.

### 2. Copy this kit into your project

```bash
# Option A: Clone and copy
git clone https://github.com/Elnora-AI/claude-code-starter-kit.git
cp -r claude-code-starter-kit/* claude-code-starter-kit/.* your-project/

# Option B: Have Claude do it
# Open your project in VS Code, start Claude Code, and say:
# "Clone the starter kit repo and copy its contents into this project"
```

### 3. Set up your environment

```bash
cp .env.template .env
# Edit .env with your actual values (if any)
```

### 4. Customize CLAUDE.md

Open `CLAUDE.md` and fill in your project name, tech stack, commands, and team conventions.
This is the most important file — it tells Claude everything about your project.

### 5. (Optional) Wire up your knowledge base

If you want Claude to read your Obsidian vault or a local notes folder:

```bash
cp .claude/knowledge-base.local.md.template .claude/knowledge-base.local.md
# Edit the YAML frontmatter to point at your vault
```

The `.local.md` file is gitignored, so each teammate keeps their own copy.

### 6. Install plugins

Open Claude Code and run `/plugins`. See `marketplace-plugins.md` for our recommended starter set.

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
