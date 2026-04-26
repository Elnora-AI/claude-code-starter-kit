# Elnora Starter Kit

One-command setup that installs and connects [Elnora AI](https://elnora.ai),
Claude Code, Python, Node.js, and supporting dev tools into a single
workflow for generating preclinical lab protocols. Targeted at users who have not used a
terminal before.

## Requirements

- macOS or Windows 10/11
- Active Claude Pro or Max subscription ([upgrade](https://claude.com/upgrade))
- Elnora API key ([platform.elnora.ai/settings](https://platform.elnora.ai/settings))

## Install

**macOS** — open Terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/Elnora-AI/elnora-starter-kit/main/install.sh | bash
```

**Windows** — open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/Elnora-AI/elnora-starter-kit/main/install.ps1 | iex
```

Total runtime: 10–15 minutes on a fresh machine.

## Install flow

1. **Phase 1 — automated install (~5–10 min).** Clones the repo to
   `~/Documents/elnora-starter-kit/` and runs `setup-mac.sh` or
   `setup-windows.ps1`. Installs Claude Code, the Elnora CLI, Node.js, Git,
   Python, VS Code, GitHub CLI, and Obsidian. Existing installations are
   detected and skipped. Output is written to `~/claude-starter-install.log`.
2. **Claude authentication.** A browser window opens for Claude Pro/Max
   login.
3. **Phase 2 — agent handoff (~3–5 min).** Claude follows
   [`INSTALL_FOR_AGENTS.md`](INSTALL_FOR_AGENTS.md): verifies installed
   versions, prompts for the Elnora API key, runs a smoke test, and
   optionally configures an Obsidian knowledge base.
4. **Verification.** Claude generates a sample protocol to confirm the
   end-to-end setup.

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
├── docs/
│   └── getting-started.md                 # Manual setup fallback
└── .github/
    ├── dependabot.yml                     # Weekly dependency updates
    └── workflows/codeql.yml               # Weekly CodeQL scans
```

## Post-install

The install script removes the original upstream remote and preserves it as
`elnora-upstream`. The cloned directory is now an independent repository.
Verify with `git remote -v`. To pull future updates from the starter kit:

```bash
git fetch elnora-upstream
```

To publish your repo to GitHub:

```bash
gh repo create my-lab-repo --private --source=. --push
```

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
- `env.CLAUDE_CODE_NO_FLICKER=1` — enables [full-screen mode](https://code.claude.com/docs/en/fullscreen).
- `autoUpdatesChannel: "latest"` — opts into the [auto-update](https://code.claude.com/docs/en/setup#auto-updates) `latest` channel (new features as soon as released). Switch to `"stable"` for ~1-week-old builds. Ignored for Homebrew/WinGet/apt/dnf/apk installs (upgrade via the package manager).
- `remoteControlAtStartup: true` — auto-enables [Remote Control](https://code.claude.com/docs/en/remote-control) on every interactive session, so you can pick up any session from claude.ai/code or the Claude mobile app. Set to `false` to require an explicit `claude remote-control` / `--remote-control` / `/remote-control` invocation.

Remove the line or set the value to `"0"` / `false` to disable.

## Elnora components

Pre-installed and configured by the setup script:

- [Elnora CLI](https://cli.elnora.ai) — `elnora` command, available globally
- [`elnora-plugins`](https://github.com/Elnora-AI/elnora-plugins) — plugin marketplace
- Elnora MCP server — configured in `.mcp.json` (`https://mcp.elnora.ai/mcp`)

## License

MIT.
