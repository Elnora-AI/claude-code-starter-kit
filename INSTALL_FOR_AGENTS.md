# INSTALL_FOR_AGENTS.md — Phase 2 Setup

> **Step 0 — Identity gate.** If you are NOT an autonomous coding agent (Claude
> Code, Codex, Gemini, etc.), stop reading this file and open `README.md`
> instead. This file gives an agent permission to run shell commands on the
> user's machine; humans should follow `docs/getting-started.md`.

You are Claude (or another agent) handing off from the install script. The
script (`setup-mac.sh` or `setup-windows.ps1`) just finished Phase 1 — it
installed Claude Code, the Elnora CLI, Node.js, Git, Python, VS Code, GitHub
CLI, and Obsidian. Your job (Phase 2) is to verify what's installed, collect
the user's Elnora API key, run a smoke test, and hand them a working
environment.

Be transparent: announce each step before you run it, show the output, and
explain what you found. The user is likely a lab scientist who has never
coded before — keep your language plain and your steps small.

### Non-interactive / test mode

If your environment has `ELNORA_HANDOFF_MODE=headless` set, you are running
inside the `handoff-e2e` test workflow. There is no human to talk to. In that
mode, follow these adjustments:

- **Skip every "ask the user" step.** If a step says "ask the user X",
  resolve X from the environment or filesystem instead, or skip the step.
- **Step 3-4 (Elnora API key):** if `ELNORA_API_KEY` is already set in the
  environment, use it directly. Skip the "Open the dashboard, click Create
  key, paste it back" instructions. Still write `.env` and run `elnora auth
  whoami`.
- **Step 8 (Knowledge base):** the test stages a fake Obsidian vault at
  `~/Documents/test-vault/` (or `%USERPROFILE%\Documents\test-vault\` on
  Windows). Auto-detect it and proceed. If you don't find a vault, skip the
  step rather than asking.
- **Step 9 (Sample protocol):** skip — there is no user to wow.
- **At the end:** print the literal string `HANDOFF_COMPLETE` on its own
  line. The test runner uses it as the completion marker.

---

## Phase 2 — finish setup

### 1. Read the install log

```
cat ~/claude-starter-install.log | tail -100
```

(On Windows: `Get-Content $env:USERPROFILE\claude-starter-install.log -Tail 100`.)

Tell the user: "I'm reading the install log to see what got installed and
whether anything failed." Note any `FAILED` markers — you'll fix them in step 2.

### 2. Verify versions; fix gaps

Run each of these and report the output to the user:

```
claude --version
node --version
git --version
python3 --version || python --version
elnora --version
gh --version | head -1
```

If any tool is missing, install it now (use the matching command from the
setup script, or fall back to the official installer URL):

- **Claude Code**: `curl -fsSL https://claude.ai/install.sh | bash` (Mac/Linux) or `irm https://claude.ai/install.ps1 | iex` (Win)
- **Node.js**: download the LTS `.pkg` / `.msi` from `https://nodejs.org/`
- **Git**: `xcode-select --install` (Mac), `winget install Git.Git` (Win)
- **Elnora CLI**: `npm install -g @elnora/cli` (or whatever the current canonical install is)

If a tool is at the wrong version (e.g. Node < 20), tell the user, suggest
upgrading, and offer to do it. Don't silently overwrite system tools.

### 3. Elnora account check

Ask the user: **"Do you already have an Elnora account?"**

- **Yes** → continue to step 4.
- **No / not sure** → tell them to open `https://platform.elnora.ai` and
  sign up. Wait. Once they confirm they're signed in, continue.

### 4. Collect the Elnora API key

Tell the user exactly what to do, in this order:

1. Open `https://platform.elnora.ai/settings`.
2. Click the **API Keys** tab.
3. Click **Create key**, name it after their machine (e.g. "carmens-mbp").
4. Copy the key — it starts with `elnora_live_`.
5. Paste it back to you in this chat.

Once you have it, write it to `.env` at the repo root with mode 600:

```
echo "ELNORA_API_KEY=<paste-key-here>" > .env
chmod 600 .env
```

(Windows: write `.env` and skip `chmod`; the `.gitignore` already protects it.)

Confirm the file is correct:

```
ls -la .env  # mode should be -rw-------
grep -c '^ELNORA_API_KEY=elnora_live_' .env  # should print 1
```

### 5. Verify the key works

```
elnora auth whoami
```

This should return the user's email. If it errors with 401/403, the key is
wrong — go back to step 4. If it errors with a network message, see
`RECOVERY.md` → "Network blocked".

### 6. Make this a git repo (seed-repo step)

The kit reaches the user's machine as files extracted from a tarball — there
is no `.git/` directory by default (the bootstrap can't `git clone` because
git isn't always installed yet at that point). Initialize a fresh repo here
and wire in our upstream so the user can `git fetch elnora-upstream` for
future updates, while `origin` stays free for their own remote.

If `.git/` already exists (rare — the user manually `git clone`'d the kit
instead of using the one-liner), just rename the existing origin instead.

```
if [ -d .git ]; then
    git remote rename origin elnora-upstream
else
    git init -q
    git symbolic-ref HEAD refs/heads/main
    git remote add elnora-upstream https://github.com/Elnora-AI/elnora-starter-kit.git
fi
git remote -v   # should show "elnora-upstream" (fetch + push), no "origin"
```

Tell the user: "This is now your own git repo. Our upstream is preserved as
`elnora-upstream` so you can `git fetch elnora-upstream` for future updates.
`origin` is free for you to point at your own GitHub repo whenever you create
one."

Optionally offer: "Want me to create a private GitHub repo for this and push
it? Run `gh repo create <name> --private --source=. --push`."

### 7. Smoke test — confirm Elnora API is reachable

```
elnora protocol list | head -3
```

Should return at least a header line and one or two protocol entries. If it
returns nothing or errors, see `RECOVERY.md` → "Elnora auth fails".

### 8. Knowledge base setup (Obsidian) — optional but recommended

Ask the user: **"Do you already have an Obsidian vault, or want to set one up
now? It's the recommended way to keep notes that I can read."**

- **Yes, I have one / want to set one up** → trigger the **First-run setup**
  flow documented in `CLAUDE.md` → "Knowledge Base" section. That flow:
  1. Auto-detects vaults in iCloud, Google Drive, OneDrive, Dropbox, Documents
     using `Glob` for `.obsidian/`.
  2. Asks the user to pick or paste a path.
  3. Copies `.claude/knowledge-base.local.md.template` → `.claude/knowledge-base.local.md`.
  4. Verifies the path exists.
  5. Self-deletes the First-run setup block from `CLAUDE.md`.
- **No, skip** → tell the user "No problem. Whenever you want to set this up
  later, just ask me 'help me set up my knowledge base' and I'll walk through
  it."

### 9. Guided first task

Offer the user a wow moment: **"Want me to generate a sample protocol so you
can see what Elnora does? Just tell me what you're trying to do — e.g.
'extract DNA from yeast' — and I'll generate it for you."**

If they say yes, run the appropriate `elnora` command (or use the elnora MCP
tools), show the output, and explain what they're looking at.

### 10. Done

Tell the user:

- ✅ Setup complete.
- The repo lives at `<repo-path>`.
- Their Elnora API key is in `.env` (mode 600, gitignored).
- The Elnora CLI works globally — `elnora --help` from any terminal.
- This is now their own repo (`origin` is free; `elnora-upstream` points at
  ours for future updates).
- Next: try asking Claude to do something — generate another protocol, write
  notes, plan an experiment.

If anything in this flow failed, point them at `RECOVERY.md`.
