# Elnora Starter Kit

Batteries-included setup for [Elnora AI](https://elnora.ai), the platform for
generating, optimizing, and managing bioprotocols for wet-lab experiments.

This kit is for **lab scientists and customers who have never coded before**.
You paste one command into your terminal, walk away, and end up with a
working setup: Claude Code installed and authenticated, dev tools in place,
the Elnora CLI working, and a Claude session waiting to help you generate
your first protocol.

If something is already installed on your machine, the kit skips it. If
something is missing, the kit installs it. Everything is logged, every step
is announced, and there's a recovery path for anything that fails.

## Quick start

### macOS (Terminal)

Open Terminal (⌘+Space → "Terminal" → Enter), then paste:

```bash
curl -fsSL https://raw.githubusercontent.com/Elnora-AI/elnora-starter-kit/main/install.sh | bash
```

### Windows (PowerShell)

Open PowerShell (Start menu → "PowerShell" → Enter), then paste:

```powershell
irm https://raw.githubusercontent.com/Elnora-AI/elnora-starter-kit/main/install.ps1 | iex
```

That's it. The total flow takes about 10–15 minutes the first time.

## What happens next

1. **Phase 1 — script (~5–10 min, automatic).** The kit downloads itself
   into `~/Documents/elnora-starter-kit/`, then runs `setup-mac.sh` /
   `setup-windows.ps1`. These install (skipping anything already present):
   Claude Code, the Elnora CLI, Node.js, Git, Python, VS Code, GitHub CLI,
   and Obsidian. Everything is logged to `~/claude-starter-install.log`.

2. **Browser pops up** for Claude login. Use your existing Claude Pro/Max
   subscription. If you don't have one, visit `https://claude.com/upgrade`
   first.

3. **Phase 2 — Claude takes over (~3–5 min, interactive).** Claude reads
   [`INSTALL_FOR_AGENTS.md`](INSTALL_FOR_AGENTS.md), verifies what's
   installed, walks you through getting your Elnora API key from
   `https://platform.elnora.ai/settings`, runs a smoke test, and (optionally)
   sets up your Obsidian vault.

4. **Done.** Claude offers to generate a sample protocol so you can see
   Elnora in action.

## What's inside

```
elnora-starter-kit/
├── README.md                              # You are here
├── INSTALL_FOR_AGENTS.md                  # Phase 2 sequence Claude follows
├── RECOVERY.md                            # Common failures + 1-paragraph fixes
├── CLAUDE.md                              # Project instructions Claude reads automatically
├── TOOLS.md                               # Catalog of tools, plugins, integrations
├── marketplace-plugins.md                 # Recommended plugin marketplaces
├── install.sh / install.ps1               # One-liner bootstraps
├── setup-mac.sh / setup-windows.ps1       # Full Phase 1 setup scripts
├── .env.template                          # Just ELNORA_API_KEY= — copy to .env
├── .mcp.json                              # MCP servers (context7, grep, elnora)
├── .gitignore                             # Keeps secrets and build artifacts out of Git
├── LICENSE                                # MIT
├── .claude/
│   ├── settings.json                      # Plugins, permissions, env defaults
│   └── knowledge-base.local.md.template   # Per-user knowledge-base config (gitignored once filled in)
├── docs/
│   └── getting-started.md                 # Manual fallback flow if the agent path fails
└── .github/
    ├── dependabot.yml                     # Weekly dep updates (github-actions, npm, pip)
    └── workflows/codeql.yml               # CodeQL scans workflow files weekly
```

## After install

The install script disconnects this kit's upstream link so it becomes **your
own repo**. The original Elnora upstream is preserved as `elnora-upstream`
(run `git remote -v` to confirm), so you can `git fetch elnora-upstream`
later if you want updates.

When you're ready to push to GitHub, ask Claude or run:

```bash
gh repo create my-lab-repo --private --source=. --push
```

## Knowledge base (optional but recommended)

Plug Claude into an Obsidian vault (or any local folder) to give it access
to your notes. Claude will offer to set this up during Phase 2 — it
auto-detects existing vaults in iCloud, Google Drive, OneDrive, Dropbox, and
Documents. See `CLAUDE.md` → "Knowledge Base" for details.

## If something goes wrong

See [`RECOVERY.md`](RECOVERY.md) — the top 5 failure modes, each with a
1-paragraph fix. If your problem isn't there, send
`~/claude-starter-install.log` to whoever is supporting you.

## Manual fallback

If the agent flow doesn't work for you (no Claude Pro/Max, agent install
failed, etc.), `docs/getting-started.md` has the older 12-step manual flow
that gets you to the same place.

## Defaults set in `.claude/settings.json`

Under the `env` block:
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` — enables Claude Code's
  multi-agent teams feature.
- `CLAUDE_CODE_NO_FLICKER=1` — enables [full-screen
  mode](https://code.claude.com/docs/en/fullscreen).

To turn either off, edit `.claude/settings.json` and delete the line you
don't want, or set its value to `"0"`.

## Powered by Elnora AI

Pre-installed and pre-wired by the setup script:

- [Elnora CLI](https://cli.elnora.ai) (`elnora` command, available globally)
- [`elnora-plugins`](https://github.com/Elnora-AI/elnora-plugins) marketplace
- Elnora MCP server in `.mcp.json` (`https://mcp.elnora.ai/mcp`)

[Elnora](https://elnora.ai) is an AI platform for generating, optimizing, and
managing bioprotocols for wet-lab experiments.

## License

MIT.
