# TOOLS.md — Tool & Extension Catalog

This file catalogs the tools, plugins, MCP servers, and integrations configured for this project.
Update this file as you add or remove tools so Claude always knows what's available.

---

## Installed Plugins

### From claude-code-plugins (Anthropic Official)

| Plugin | What it provides |
|--------|-----------------|
| **commit-commands** | `/commit` and `/commit-push-pr` slash commands for Git workflow |
| **feature-dev** | Guided feature development with codebase understanding |
| **plugin-dev** | Tools for creating your own plugins |
| **security-guidance** | Security best practices and vulnerability checks |

### From claude-code-workflows (Community)

| Plugin | What it provides |
|--------|-----------------|
| **security-compliance** | Security compliance auditing |
| **security-scanning** | SAST, threat modeling, and security hardening |
| **code-documentation** | Technical documentation and tutorial generation |
| **business-analytics** | KPI dashboards and data storytelling |
| **hr-legal-compliance** | HR, legal docs, and GDPR compliance |

### From claude-plugins-official (Anthropic Extras)

| Plugin | What it provides |
|--------|-----------------|
| **claude-md-management** | Audit and improve CLAUDE.md files |
| **superpowers** | Planning, brainstorming, TDD, systematic debugging, subagent-driven development skills |
| **context7** | Fetch up-to-date library/framework documentation via MCP |
| **playwright** | Browser automation and web testing via MCP |
| **claude-code-setup** | Analyze a codebase and recommend hooks, subagents, skills, plugins, MCP servers |

### From anthropic-agent-skills (Document Processing)

| Plugin | What it provides |
|--------|-----------------|
| **document-skills** | `/pdf`, `/docx`, `/xlsx`, `/pptx` — read and create office documents |

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

Provided automatically by installed plugins:

| MCP Server | Source Plugin | What it provides |
|-----------|---------------|------------------|
| **context7** | context7 | `query-docs`, `resolve-library-id` — fetch current library/framework documentation |
| **playwright** | playwright | Full browser automation suite (navigate, click, type, screenshot, network, console) |

Wired directly via `.mcp.json` (project-scoped, not plugin-provided):

| MCP Server | Endpoint | What it provides |
|-----------|----------|------------------|
| **context7** | `https://mcp.context7.com/mcp` | Same as above, available even without the plugin installed |
| **grep** | `https://mcp.grep.app` | Semantic code search across public repos |
| **elnora** | `https://mcp.elnora.ai/mcp` | Elnora platform tools — bioprotocol generation, task/file/project management. OAuth 2.1 browser flow on first use (no manual config). |

_Add project-specific MCP servers to `.mcp.json` as needed._

---

## Elnora CLI

Installed globally by `setup-mac.sh` / `setup-windows.ps1` (step [2/N], right after Claude Code).
The binary lives in `~/.local/bin/elnora` on macOS and `%USERPROFILE%\.elnora\bin\elnora.exe` on Windows.

Headline commands:

| Command | What it does |
|---------|-------------|
| `elnora auth login` | OAuth browser login (caches credentials in `~/.elnora/`) |
| `elnora setup-claude` | Post-auth helper — wires Elnora into your current Claude Code config |
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

