# TOOLS.md — Tool & Extension Catalog

This file catalogs the tools, plugins, MCP servers, and integrations configured for this project.
Update this file as you add or remove tools so Claude always knows what's available.

---

## Enabled Plugins

These four plugins are turned on by default in `.claude/settings.json`. Everything
else has to be installed via `/plugins` — see `marketplace-plugins.md` for the
full catalog.

| Plugin | Marketplace | What it provides |
|--------|-------------|------------------|
| **commit-commands** | claude-code-plugins | `/commit` and `/commit-push-pr` slash commands for Git workflow |
| **claude-md-management** | claude-plugins-official | Audit and improve CLAUDE.md files |
| **context7** | claude-plugins-official | Fetch up-to-date library/framework documentation via MCP |
| **elnora** | elnora-plugins | 8 bioprotocol skills (`elnora-platform`, `-orgs`, `-projects`, `-tasks`, `-files`, `-folders`, `-search`, `-admin`) wired to the Elnora MCP server |

---

## Configured Marketplaces

These marketplaces are configured in `.claude/settings.json`. Browse them with `/plugins`.

| Marketplace | Source | What's in it |
|-------------|--------|-------------|
| **claude-code-plugins** | [anthropics/claude-code](https://github.com/anthropics/claude-code) | Official Anthropic plugins |
| **claude-code-workflows** | [wshobson/agents](https://github.com/wshobson/agents) | Community workflow plugins |
| **claude-plugins-official** | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | More official plugins |
| **anthropic-agent-skills** | [anthropics/skills](https://github.com/anthropics/skills) | Document processing skills |
| **knowledge-work-plugins** | [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins) | Knowledge-work plugins (sales, finance, legal, HR, marketing, product, support, data, design, bio-research, etc.) — registered, no plugins enabled by default |
| **elnora-plugins** | [Elnora-AI/elnora-plugins](https://github.com/Elnora-AI/elnora-plugins) | The `elnora` plugin — bioprotocol generation, task/file/project management for wet-lab work. Registered with `autoUpdate: true`, no plugins enabled by default |

---

## MCP Servers

Wired directly via `.mcp.json` (project-scoped):

| MCP Server | Endpoint | What it provides |
|-----------|----------|------------------|
| **context7** | `https://mcp.context7.com/mcp` | `query-docs`, `resolve-library-id` — fetch current library/framework documentation. Also surfaced through the `context7` plugin (same tools, same namespace), so you get it whether or not the plugin is enabled. |
| **grep** | `https://mcp.grep.app` | Semantic code search across **public** GitHub repos. **Privacy note:** queries (and by extension your search terms) are sent to the third-party `grep.app` service. Don't use it for proprietary code or anything you wouldn't paste into a public search engine. |
| **elnora** | `https://mcp.elnora.ai/mcp` | Elnora platform tools — bioprotocol generation, task/file/project management. OAuth 2.1 browser flow on first use (no manual config). |
| **chrome-devtools** | `npx chrome-devtools-mcp@latest --autoConnect` | Take over your real Chrome via the Chrome DevTools Protocol — list tabs, navigate, screenshot, run JS, read network/console, run Lighthouse. Setup + recipes in [`docs/chrome-devtools-mcp-setup.md`](docs/chrome-devtools-mcp-setup.md). Requires Chrome 144+ running. Windows users: `setup-windows.ps1` writes a user-level override that wraps `npx` in `cmd /c`. |

(Other plugins like `playwright` ship their own MCP servers, but they're
not enabled by default — install via `/plugins` if you need them.)

_Add project-specific MCP servers to `.mcp.json` as needed._

---

## Elnora CLI

Installed globally by `setup-mac.sh` / `setup-windows.ps1` (step [2/N], right after Claude Code).
The binary lives in `~/.local/bin/elnora` on macOS and `%USERPROFILE%\.elnora\bin\elnora.exe` on Windows.

Headline commands:

| Command | What it does |
|---------|-------------|
| `elnora auth login --api-key <key>` | Save an API key to `~/.elnora/profiles.toml` (mode 600). Every new shell stays authenticated. |
| `elnora whoami` | Show current authenticated identity |
| `elnora doctor` | Verify config, auth, and API connectivity in one shot |
| `elnora setup claude` | Post-auth helper — wires Elnora into your current Claude Code config |
| `elnora tasks` | Create, list, update wet-lab tasks |
| `elnora projects` | Project management |
| `elnora files` | Upload, version, search files |
| `elnora mcp serve --stdio` | Run the MCP server locally (fallback for offline/local use; the hosted HTTP endpoint is what's pre-wired in `.mcp.json`) |

Docs: [cli.elnora.ai](https://cli.elnora.ai).

---

## Custom Slash Commands

| Command | Description |
|---------|-------------|
| `/commit` | Commit changes with a conventional commit message (from commit-commands plugin) |
| `/commit-push-pr` | Commit, push, and open a pull request in one step |

---

## Built-in Tools (always available)

These tools are built into Claude Code — no setup needed.

| Tool | What it does |
|------|-------------|
| **Read** | Read any file (text, images, PDFs, notebooks) |
| **Write** | Create or overwrite files |
| **Edit** | Find-and-replace in files |
| **Glob** | Find files by pattern (e.g., `**/*.py`) |
| **Grep** | Search file contents with regex |
| **Bash** | Run terminal commands |
| **WebFetch** | Fetch content from a URL |
| **WebSearch** | Search the web |
| **Task** | Create and track tasks |
| **Monitor** | Stream events from background processes |

---

## Useful Keyboard Shortcuts

| Shortcut | What it does |
|----------|-------------|
| `Shift+Tab` (x2) | Toggle Plan Mode (Claude plans before coding) |
| `Escape` | Cancel current generation |
| `/help` | Show all available commands |
| `/plugins` | Browse and install plugins |
| `/clear` | Clear conversation history |

---

_Last updated: 2026-04-21_

