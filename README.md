# Elnora Starter Kit

One-command setup that installs and wires together [Elnora AI](https://elnora.ai),
Claude Code, and the supporting dev tools (Python, Node.js, Git, GitHub CLI,
VS Code, Obsidian) needed to use them productively from the terminal.

## Who this is for

**Primarily: Elnora customers — biologists, scientists, and non-technical
founders** who haven't used Claude Code in the terminal yet and want the
fastest path from "I have an Elnora account" to "I'm generating protocols
and automating my day-to-day lab work from the command line." This kit is
the batteries-included version of that setup so you don't have to chase
down installers, configure MCP servers, or learn what `brew` is on day one.

**Also welcome:** anyone — engineers included — who wants to:

- **Bootstrap their first Claude Code project** with a known-good baseline
  (settings, plugins, MCP wiring, knowledge-base config) instead of an empty
  directory.
- **Validate or debug an existing Claude Code setup** — re-run the install
  to see what's missing, what's misconfigured, or what's worth turning on.
- **Evaluate different setups and configurations** — the kit documents what
  each piece does and why, so it's a useful reference even if you don't
  install it.
- **Use it as a template** to start building your own repo, agents, plugins,
  and skills on top of a working foundation.

You don't need to be an Elnora customer to use the kit. The Elnora pieces
are the default flavor, but the rest of the workflow (Claude Code, plugins,
knowledge base, GitHub repo) stands on its own.

## Requirements

- A computer running macOS or Windows 10/11 — one you control and have
  administrator rights on (the install needs to run privileged commands
  like Homebrew/Xcode CLT on macOS or WinGet on Windows).
- Active Claude Pro or Max subscription ([upgrade](https://claude.com/upgrade))
- GitHub account ([sign up](https://github.com/signup)) — used in Phase 2 to
  create your private starter-kit repo.
- Elnora API key ([platform.elnora.ai/settings](https://platform.elnora.ai/settings))
  — only needed if you want the Elnora CLI/MCP flow. Skip it if you're using
  the kit purely as a Claude Code starter template; the rest of the install
  still works.

## Install

**macOS** — open Terminal (press `Cmd+Space`, type `Terminal`, hit Enter)
and paste this:

```bash
curl -fsSL https://raw.githubusercontent.com/Elnora-AI/elnora-starter-kit/main/install.sh | bash
```

**Windows** — open PowerShell (press the Start key, type `PowerShell`, hit
Enter) and paste this:

```powershell
irm https://raw.githubusercontent.com/Elnora-AI/elnora-starter-kit/main/install.ps1 | iex
```

What to expect while it runs:

- The window will print a lot of output — that's normal. Don't close it.
- macOS will ask for your **Mac login password** when Homebrew installs.
  Characters won't appear as you type — that's normal too.
- A **browser window** will pop open at the end so you can log into Claude
  Pro/Max. Sign in, then come back to the terminal.
- Claude will then take over and ask you to paste your **Elnora API key**.

Total runtime: 15–25 minutes on a fresh machine (Xcode CLT can take 5–10
minutes on its own, plus first-run Homebrew/Node/etc.). Re-runs on a partly
set up machine are much faster — already-installed tools are skipped.

These bootstrap commands and the setup scripts they invoke download installers
over HTTPS and execute them without separate checksum verification. Running
the kit means trusting `raw.githubusercontent.com/Elnora-AI/elnora-starter-kit`,
`claude.ai`, and `cli.elnora.ai`.

## Install flow

1. **Phase 1 — automated install (~5–10 min).** Clones the repo to
   `~/Documents/elnora-starter-kit/` and runs `setup-mac.sh` or
   `setup-windows.ps1`. Installs Claude Code, the Elnora CLI, Node.js, Git,
   Python, VS Code, GitHub CLI, and Obsidian. Also creates an empty
   `~/Documents/Projects/` folder as a default home for future repos you
   build with Claude. Existing installations are detected and skipped.
   Output is written to `~/claude-starter-install.log` (macOS) or
   `%USERPROFILE%\claude-starter-install.log` (Windows).
2. **Authenticate services.** The script signs you into three accounts
   sequentially before handing off to Claude:
   - **Claude Pro/Max** — browser OAuth (required to continue).
   - **GitHub CLI** — browser OAuth (skip allowed; Phase 2 will prompt
     again if needed).
   - **Elnora CLI** — paste your API key from
     [platform.elnora.ai/settings](https://platform.elnora.ai/settings) → **API
     Keys** tab (skip allowed; the Elnora MCP will prompt on first use).
3. **Phase 2 — agent handoff (~3–5 min).** Claude follows
   [`INSTALL_FOR_AGENTS.md`](INSTALL_FOR_AGENTS.md): verifies installed
   versions, **creates your private GitHub repo and pushes the starter
   kit to it**, runs a smoke test, and optionally configures an Obsidian
   knowledge base.
4. **Verification.** Claude generates a sample protocol to confirm the
   end-to-end setup.

## What gets installed and why

Each component plays a distinct role in the workflow:

- **Claude Code** — the orchestrating agent. Interprets natural-language
  instructions, plans the work, and invokes the Elnora CLI and other tools
  to execute it. This is the interface you interact with.
- **Elnora CLI and MCP server** — the domain executor. Generates
  preclinical lab protocols and performs the substantive scientific
  reasoning. Claude calls `elnora` commands and the MCP server (configured
  in `.mcp.json`); Elnora does the work.
- **Python 3 and Node.js** — runtimes for the supporting tooling. Most
  Claude Code plugins and MCP servers ship as Node packages; several
  utility scripts run on Python. Both are required for the kit to function.
- **Git and GitHub CLI** — version control and GitHub integration. Phase 2
  uses these to create your private GitHub repo, push the starter kit to
  it, and track every change you make from there on.
- **VS Code** — editor for reviewing and editing the files Claude
  produces, alongside the terminal session.
- **Obsidian** — knowledge-base viewer. Renders the markdown files in your
  vault as a navigable graph so you can browse generated protocols, notes,
  and references outside the terminal.

## Repository layout

```
elnora-starter-kit/
├── README.md                              # This file
├── INSTALL_FOR_AGENTS.md                  # Phase 2 sequence executed by Claude
├── RECOVERY.md                            # Failure modes and remediation steps
├── CLAUDE.md                              # Project instructions loaded by Claude
├── TOOLS.md                               # Installed tools, plugins, and integrations
├── marketplace-plugins.md                 # Recommended plugin marketplaces
├── install.sh / install.ps1               # Bootstrap entry points
├── setup-mac.sh / setup-windows.ps1       # Phase 1 setup scripts
├── .env.template                          # ELNORA_API_KEY placeholder
├── .mcp.json                              # MCP server configuration
├── .gitignore
├── LICENSE                                # MIT
├── .claude/
│   ├── settings.json                      # Plugins, permissions, env defaults
│   └── knowledge-base.local.md.template   # Per-user knowledge-base config
└── docs/
    └── getting-started.md                 # Daily-workflow guide + manual fallback
```

## Post-install

When Phase 2 finishes you have a **private** GitHub repo on your account
containing the starter kit's user-facing contents. Internal CI/test
scaffolding is stripped during install — your repo holds only what you
need: `CLAUDE.md`, `.claude/`, `docs/`, install scripts, MCP config,
templates.

The repo's `origin` remote points at your GitHub account. Verify with
`git remote -v`. From here on it's **your** repo: commit, push, branch,
and rename it however you like.

If you'd like a separate public version later (e.g. to share a sample
protocol), create a fresh repo for that — don't flip this one. This one
can hold credentials, vault paths, and personal notes safely because it
stays private.

## Knowledge base (optional)

The kit can connect Claude to a local knowledge base (Obsidian vault or any
directory). During Phase 2, Claude auto-detects vaults in iCloud, Google
Drive, OneDrive, Dropbox, and `~/Documents`. Configuration is stored in
`.claude/knowledge-base.local.md` (gitignored). See `CLAUDE.md` →
"Knowledge Base".

## Troubleshooting

Common failures and fixes are documented in [`RECOVERY.md`](RECOVERY.md).
For unresolved issues, attach `~/claude-starter-install.log` when requesting
support.

## Manual setup

If the automated flow is unavailable (no Claude Pro/Max, install failure),
`docs/getting-started.md` documents the equivalent manual procedure.

## Configuration

Defaults enabled in `.claude/settings.json`:

- `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` — enables [multi-agent teams](https://code.claude.com/docs/en/agent-teams).
- `env.CLAUDE_CODE_NO_FLICKER=1` — opts into Claude Code's [full-screen alt-buffer renderer](https://code.claude.com/docs/en/fullscreen), which removes the per-keystroke flicker some terminals show during long sessions.
- `autoUpdatesChannel: "latest"` — opts into the [auto-update](https://code.claude.com/docs/en/setup#auto-updates) `latest` channel (new features as soon as released). Switch to `"stable"` for ~1-week-old builds. Ignored for Homebrew/WinGet/apt/dnf/apk installs (upgrade via the package manager).
- `remoteControlAtStartup: true` — auto-enables [Remote Control](https://code.claude.com/docs/en/remote-control) on every interactive session, so you can pick up any session from claude.ai/code or the Claude mobile app. Set to `false` to require an explicit `claude remote-control` / `--remote-control` / `/remote-control` invocation. **Heads-up:** Remote Control sessions are reachable from any device signed into your Claude account — review before enabling it on machines that handle proprietary data.

Remove the line or set the value to `"0"` / `false` to disable.

## Elnora components

Pre-installed and configured by the setup script:

- [Elnora CLI](https://cli.elnora.ai) — `elnora` command, available globally
- [`elnora-plugins`](https://github.com/Elnora-AI/elnora-plugins) — plugin marketplace
- Elnora MCP server — configured in `.mcp.json` (`https://mcp.elnora.ai/mcp`)

## License

MIT.
