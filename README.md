# Claude Code Starter Kit

A project scaffold for [Claude Code](https://claude.ai/code), Anthropic's AI coding agent. Ships with project instructions, permission defaults, and a curated plugin list.

## What's inside

```
claude-code-starter-kit/
├── CLAUDE.md                             # Project instructions — Claude reads this automatically
├── TOOLS.md                              # Catalog of tools, plugins, and integrations you add over time
├── README.md                             # You are here
├── marketplace-plugins.md                # Curated list of safe plugin marketplaces and recommendations
├── install.sh                            # One-liner bootstrap for macOS (downloads + runs setup-mac.sh)
├── install.ps1                           # One-liner bootstrap for Windows (downloads + runs setup-windows.ps1)
├── setup-mac.sh                          # Full install script for macOS
├── setup-windows.ps1                     # Full install script for Windows
├── .gitignore                            # Keeps secrets, OS files, and build artifacts out of Git
├── LICENSE                               # MIT
├── .env.template                         # Template for environment variables (copy to .env)
├── .mcp.json                             # Project MCP servers (context7, grep, elnora)
├── .github/
│   ├── dependabot.yml                   # Weekly dependency update PRs (github-actions, npm, pip)
│   ├── workflows/codeql.yml             # CodeQL scans workflow files on push, PR, and weekly cron
│   └── workflows/ci.yml.disabled        # CI template — rename to enable when you add a toolchain
├── .claude/
│   ├── settings.json                     # Plugin marketplaces, enabled plugins, and permission defaults
│   ├── knowledge-base.local.md.template  # Template for per-user knowledge-base config (gitignored once filled in)
│   └── commands/
│       └── commit.md                     # Example custom slash command (/commit)
├── docs/
│   └── getting-started.md                # First steps after install
└── cache/                                # Runtime scratch — gitignored, for logs/state/downloads
```

> **Knowledge base**: point Claude at your own Obsidian vault (or any local folder) by copying
> `.claude/knowledge-base.local.md.template` to `.claude/knowledge-base.local.md` and filling in
> the YAML frontmatter. See `CLAUDE.md` for details.

> **Experimental flag**: `.claude/settings.json` sets `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`,
> which enables Claude Code's multi-agent teams feature (lets you spawn named subagents that can
> message each other). If you'd rather stay on stock behavior, remove the `env` block from
> `.claude/settings.json`.

## Powered by Elnora AI

Pre-installed and pre-wired by the setup script:

- [Elnora CLI](https://cli.elnora.ai)
- [`elnora-plugins`](https://github.com/Elnora-AI/elnora-plugins) marketplace (auto-updating)
- Elnora MCP server in `.mcp.json`

Elnora is an AI platform for generating, optimizing, and managing bioprotocols for wet-lab experiments.

Authenticate with:

```bash
elnora auth login
```

OAuth also triggers automatically on first use of an `elnora_*` MCP tool inside Claude Code.

## Quick start

### 1. Install the toolchain

The one-liner downloads the starter kit (no git required) and installs Claude Code, the Elnora CLI, Node.js, Git, Python, VS Code, GitHub CLI, and Obsidian. It skips anything already present and tees output to `~/claude-starter-install.log`.

**macOS** (Terminal):

```bash
curl -fsSL https://raw.githubusercontent.com/Elnora-AI/claude-code-starter-kit/main/install.sh | bash
```

**Windows** (PowerShell):

```powershell
irm https://raw.githubusercontent.com/Elnora-AI/claude-code-starter-kit/main/install.ps1 | iex
```

If you already cloned the repo, run the setup script directly.

**macOS:**

```bash
./setup-mac.sh
```

**Windows** (when running `setup-windows.ps1` directly, first set the execution policy):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

```powershell
.\setup-windows.ps1
```

Restart your shell after the script completes. If you ran it from VS Code's terminal, quit VS Code fully before restarting.

### 2. Copy this kit into your project

**Option A** — clone and copy (run from inside your project directory):

```bash
git clone https://github.com/Elnora-AI/claude-code-starter-kit.git temp-starter
rsync -a --exclude '.git' temp-starter/ .
rm -rf temp-starter
```

**Option B** — open your project in VS Code, start Claude Code, and say: *"Clone the starter kit repo and copy its contents into this project."*

### 3. Set up your environment

Copy the template:

```bash
cp .env.template .env
```

Then edit `.env` with your values.

### 4. Customize CLAUDE.md

Open `CLAUDE.md` and fill in your project name, tech stack, commands, and team conventions. Claude reads this file automatically at the start of every session.

### 5. (Optional) Wire up your knowledge base

Copy the template:

```bash
cp .claude/knowledge-base.local.md.template .claude/knowledge-base.local.md
```

Edit the YAML frontmatter to point at your vault. The `.local.md` file is gitignored, so each teammate keeps their own copy.

### 6. Install plugins

Open Claude Code and run `/plugins`. See `marketplace-plugins.md` for the recommended starter set.

## Security & automation on this repo

Everything below is free for public repos. If you fork into a public repo of your own, the YAML-based parts (Dependabot, CodeQL) come along automatically; the repo-level toggles (secret scanning, branch protection) you enable once in your own Settings.

| Feature | How it's enabled | What it does |
|---------|------------------|--------------|
| **Dependabot alerts + security updates** | GitHub repo setting | Flags and auto-PRs fixes for known CVEs in dependencies |
| **Dependabot version updates** | `.github/dependabot.yml` | Weekly PRs bumping `github-actions`, `npm`, `pip` ecosystems |
| **CodeQL scanning** | `.github/workflows/codeql.yml` | Scans workflow files for injection / unpinned actions on push, PR, and weekly cron |
| **Secret scanning + push protection** | GitHub repo setting | Blocks committed or pushed provider tokens (AWS, GitHub, Stripe, etc.) |
| **Branch protection ruleset on `main`** | Repo → Rules | Blocks force-push and branch deletion on `main` |

## What is Claude Code?

Claude Code is an AI agent by Anthropic that:

- Lives in your terminal and VS Code
- Reads, writes, and edits files
- Runs commands and uses tools
- Reads your `CLAUDE.md` for project context
- Extends via plugins, skills, and MCP servers

Learn more: [claude.ai/code](https://claude.ai/code)

## License

MIT License.
