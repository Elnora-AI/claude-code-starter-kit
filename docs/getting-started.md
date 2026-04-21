# Getting Started — First Steps After Install

You've got Claude Code installed and running. Here's how to make the most of it.

---

## Daily workflow

1. **Open your project** in VS Code
2. **Open the terminal** (`` Ctrl+` `` or View > Terminal)
3. **Start Claude** by typing `claude` and pressing Enter
4. **Ask Claude to help** with whatever you're working on

Claude remembers context within a conversation. When you start a new conversation (`/clear` or close the terminal), Claude reads `CLAUDE.md` again for project context but doesn't remember what you discussed before.

---

## Things to try this week

### Talk to Claude like a colleague

You don't need special syntax. Just describe what you want in plain English:

- "Read the file `report.docx` and summarize the key findings"
- "Create a new markdown file with meeting notes from today"
- "Search all files in this project for mentions of 'budget'"
- "Help me write an email to the team about the Q2 timeline"

### Use your knowledge base

Put `.md` (markdown) files in your `knowledge-base/` folder. Then ask Claude:

- "What's in my knowledge base about [topic]?"
- "Search the knowledge base for [keyword]"
- "Read the meeting notes from April 14"

The more files you add, the more useful this becomes. Think of it as Claude's memory for your project.

### Try the plugins you installed

If you installed `document-skills`:
- "Read this PDF and summarize it" (drag a PDF into VS Code or give Claude the file path)
- "Create a Word document with [content]"
- "Create an Excel spreadsheet tracking [data]"
- "Make a PowerPoint presentation about [topic]"

### Use Plan Mode for bigger tasks

Press `Shift+Tab` twice to toggle Plan Mode. In this mode, Claude plans out the steps before doing anything. Good for:
- Multi-file changes
- Tasks you want to review before executing
- Complex projects where you want to see the approach first

### Customize your CLAUDE.md

The more context you give Claude in `CLAUDE.md`, the better it performs. Add:
- Your project's specific terminology
- Folder structure explanations
- Preferred coding style or formatting
- Links to documentation
- Team conventions

---

## Useful commands

| Command | What it does |
|---------|-------------|
| `claude` | Start a new Claude Code conversation |
| `/help` | Show all available commands |
| `/plugins` | Browse and install plugins |
| `/commit` | Commit your changes (if commit-commands plugin is installed) |
| `/clear` | Clear conversation and start fresh |
| `Shift+Tab` (x2) | Toggle Plan Mode |
| `Escape` | Stop Claude's current response |

---

## Keeping your setup up to date

Claude Code updates automatically. For plugins:

1. Run `/plugins`
2. Check for updates in your installed plugins
3. Update as needed

Marketplaces registered in this starter kit have `autoUpdate: true`, so Claude
Code pulls the latest definitions at session start. The Elnora CLI nags you
in its own output when a new version ships — re-running the setup script is
idempotent and upgrades in place.

---

## Authenticate Elnora AI

The setup script installs the Elnora CLI and pre-wires the hosted MCP server at
`https://mcp.elnora.ai/mcp`. To authenticate once for every surface (CLI + MCP
tools in Claude Code):

```bash
elnora auth login
```

This opens a browser, completes OAuth, and caches credentials in `~/.elnora/`.
Switch profiles later with `elnora auth profiles`.

If you haven't run `elnora auth login` and Claude Code needs an Elnora MCP tool,
the first call opens a browser OAuth flow automatically — nothing to configure.

---

## Getting help

- **Claude Code documentation**: https://docs.anthropic.com/en/docs/claude-code
- **Report issues**: https://github.com/anthropics/claude-code/issues
- **Anthropic support**: https://support.anthropic.com
- **Community**: https://github.com/anthropics/claude-code/discussions

---

## Keep going

The best way to learn is to use Claude Code for your daily work. As you get comfortable, explore more plugins, MCP servers, and custom workflows.
