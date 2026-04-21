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
├── install.sh                            # One-liner bootstrap for macOS/Linux (downloads + runs setup-mac.sh)
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

> **Knowledge base**: this kit no longer ships example notes. Point Claude at your own Obsidian
> vault (or any local folder) by copying `.claude/knowledge-base.local.md.template` to
> `.claude/knowledge-base.local.md` and filling in the YAML frontmatter. See `CLAUDE.md` for details.

## Powered by Elnora AI

This starter kit ships with the [Elnora CLI](https://cli.elnora.ai) pre-installed
by the setup script, the [`elnora-plugins`](https://github.com/Elnora-AI/elnora-plugins)
marketplace pre-registered (auto-updating), and the Elnora MCP server wired into
`.mcp.json`. Elnora is an AI platform for generating, optimizing, and managing
bioprotocols for wet-lab experiments.

After setup, run `elnora auth login` in any terminal — a browser window handles
the rest. First use of an `elnora_*` MCP tool in Claude Code also triggers OAuth
automatically, so there's nothing to configure by hand.

## Quick start

### 1. Install the toolchain

On a fresh machine, run the one-liner for your OS. It downloads the starter kit (no git required),
installs Claude Code first (zero dependencies), the Elnora CLI second (also zero dependencies),
then installs Node.js, Git, Python, VS Code, GitHub CLI, and Obsidian — skipping anything already
present. Output streams live AND tees to `~/claude-starter-install.log` so you can paste it in
support chats.

**macOS / Linux** (from Terminal):
```bash
curl -fsSL https://raw.githubusercontent.com/Elnora-AI/claude-code-starter-kit/main/install.sh | bash
```

**Windows** (from PowerShell):
```powershell
irm https://raw.githubusercontent.com/Elnora-AI/claude-code-starter-kit/main/install.ps1 | iex
```

If you already cloned the repo, run the setup script directly:
```bash
./setup-mac.sh                # macOS
.\setup-windows.ps1           # Windows (ExecutionPolicy Bypass is set by install.ps1; if running
                              # setup-windows.ps1 directly, first run: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass)
```

Restart your shell afterwards — the setup script also tells you this at the end, including the
"quit VS Code fully" warning if you ran inside VS Code's terminal.

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

## Security & automation on this repo

Everything below is free for public repos. If you fork into a public repo of your own, the YAML-based parts (Dependabot, CodeQL) come along automatically; the repo-level toggles (secret scanning, branch protection) you enable once in your own Settings.

| Feature | How it's enabled | What it does |
|---------|------------------|--------------|
| **Dependabot alerts + security updates** | GitHub repo setting | Flags and auto-PRs fixes for known CVEs in dependencies |
| **Dependabot version updates** | `.github/dependabot.yml` | Weekly PRs bumping `github-actions`, `npm`, `pip` ecosystems |
| **CodeQL scanning** | `.github/workflows/codeql.yml` | Scans workflow files for injection / unpinned actions on push, PR, and weekly cron |
| **Secret scanning + push protection** | GitHub repo setting | Blocks committed or pushed provider tokens (AWS, GitHub, Stripe, etc.) |
| **Branch protection ruleset on `main`** | Repo → Rules | Blocks force-push and branch deletion on `main`. No PR or review requirement — Elnora-AI members push directly. |

External contributors can fork, open issues, and open PRs — that's GitHub's default model for public repos. They cannot push or merge.

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
