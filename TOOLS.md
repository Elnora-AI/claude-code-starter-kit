# TOOLS.md — Tool & Extension Catalog

This file catalogs the tools, plugins, MCP servers, and integrations configured for this project.
Update this file as you add or remove tools so Claude always knows what's available.

---

## Installed Plugins

<!-- List plugins you've installed via /plugins. Example: -->
<!-- | Plugin | Source | What it provides | -->
<!-- |--------|--------|------------------| -->
<!-- | document-skills | anthropic-agent-skills | PDF, DOCX, XLSX, PPTX reading and creation | -->
<!-- | commit-commands | claude-code-plugins | /commit, /commit-push-pr slash commands | -->

_No plugins installed yet. Run `/plugins` in Claude Code to browse and install._

---

## MCP Servers

<!-- List any MCP servers configured in .mcp.json. Example: -->
<!-- | Server | Purpose | -->
<!-- |--------|---------- | -->
<!-- | Context7 | Library documentation lookup | -->
<!-- | Slack | Send/read Slack messages | -->

_No MCP servers configured yet._

---

## Custom Slash Commands

| Command | Description |
|---------|-------------|
| `/commit` | Commit changes with a conventional commit message (example included in .claude/commands/) |

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

_Last updated: [date]_
