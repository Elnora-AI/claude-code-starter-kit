#!/bin/bash
# ============================================================
# Claude Code Setup — macOS
# ============================================================
# Installs a complete Claude Code development environment:
# Claude Code CLI, Elnora CLI, Homebrew, Node.js, Git, Python,
# VS Code, GitHub CLI, and Obsidian.
#
# Run from Terminal (or VS Code terminal):
#   chmod +x setup-mac.sh && ./setup-mac.sh
#
# Error handling: the script CONTINUES on failure. Each step is
# isolated — if one install fails (network, permissions, broken
# formula, etc.), remaining steps still run. On any failure you
# get a structured FAILURE box with the exit code, last 10 lines
# of captured stderr, and a remediation hint. At the end of the
# run a recap block prints remediation for each failed step.
# ============================================================

# NOTE: deliberately NOT using `set -e` so one failure does not abort the rest.
set -u

# Default-on logging. Tee everything (stdout + stderr) to a log file in $HOME.
# Overwrites on each run — re-runs are idempotent, so keeping old logs around
# isn't useful. Users hitting problems can paste the file path in support chats.
LOG_FILE="$HOME/claude-starter-install.log"
exec > >(tee "$LOG_FILE") 2>&1

FAILED_STEPS=()

# ------------------------------------------------------------
# remediation_hint "<step label>"
# ------------------------------------------------------------
# Returns a multi-line, step-specific remediation message. Used by
# run_step (immediate failure context) AND by the end-of-run recap
# (so the user gets a full punch list of what to do next).
remediation_hint() {
    local label="$1"
    case "$label" in
        Homebrew*)
            cat <<'EOF'
Common causes:
  - Corporate firewall blocking github.com or raw.githubusercontent.com
  - Xcode Command Line Tools not fully installed (check: xcode-select -p)
  - Less than ~1 GB free disk space
  - Keychain prompt was dismissed during install
Manual install:
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
If the install finishes but 'brew' is not on PATH, add one of these lines
to ~/.zprofile based on your Mac:
  eval "$(/opt/homebrew/bin/brew shellenv)"       # Apple Silicon (M1/M2/M3/M4)
  eval "$(/usr/local/bin/brew shellenv)"          # Intel Macs
Then open a NEW terminal and re-run this script.
EOF
            ;;
        Node.js*)
            cat <<'EOF'
Try manually:
  brew install node@22
  brew link --force --overwrite node@22
Verify in a NEW terminal window:
  node --version       # should print v22.x.x
  npm --version
node@22 is keg-only on Homebrew — the `brew link --force --overwrite` step
is required for `node` to appear in /opt/homebrew/bin. If you prefer the
latest Node instead of the pinned LTS, run `brew install node` — but your
Node major may then differ from the Windows workshop script's pin.
If 'brew: command not found', brew itself isn't on PATH — fix that first
(see the Homebrew remediation above) and re-run this script.
EOF
            ;;
        Git*)
            cat <<'EOF'
Try manually:
  brew install git
Verify:
  git --version
  which git            # should be /opt/homebrew/bin/git or /usr/local/bin/git
macOS ships a system git at /usr/bin/git that may be older. If brew's git
isn't being used, your PATH has /usr/bin before Homebrew — fix the order
in ~/.zprofile (the brew shellenv line should come AFTER any PATH exports).
EOF
            ;;
        "Git config"*)
            cat <<'EOF'
Set the values manually:
  git config --global user.name  "Your Full Name"
  git config --global user.email "you@example.com"
  git config --global init.defaultBranch main
Verify all three at once:
  git config --global --list | grep -E 'user\.|init\.'
EOF
            ;;
        "Python 3"*)
            cat <<'EOF'
Try manually:
  brew install python@3.12
  brew link --force --overwrite python@3.12
Verify:
  python3 --version      # should print "Python 3.12.x"
  which python3          # should NOT be /usr/bin/python3 (that's the Xcode stub)
python@3.12 is keg-only on Homebrew — the `brew link --force --overwrite`
step is required for `python3` to appear in /opt/homebrew/bin.
If python3 still resolves to /usr/bin/python3 or a stale version after install:
  1. Open a NEW terminal (or: eval "$(/opt/homebrew/bin/brew shellenv)")
  2. Run `which python3` again
  3. If still wrong, your PATH has /usr/bin (or another prefix with an old
     python3) BEFORE /opt/homebrew/bin — fix the order in ~/.zprofile. The
     brew shellenv line should be the LAST PATH-modifying line in the file.
EOF
            ;;
        "VS Code"*)
            cat <<'EOF'
Try manually:
  brew install --cask visual-studio-code
Or download the installer directly:
  https://code.visualstudio.com/download
If the 'code' command doesn't work in terminal after install:
  1. Open VS Code
  2. Press Cmd+Shift+P
  3. Run: "Shell Command: Install 'code' command in PATH"
  4. Open a new terminal and try `code --version`
EOF
            ;;
        "Claude Code"*)
            cat <<'EOF'
Try manually:
  brew install --cask claude-code
If brew fails, use Anthropic's installer script:
  curl -fsSL https://claude.ai/install.sh | bash
Or install via npm (requires Node.js):
  npm install -g @anthropic-ai/claude-code
Docs: https://docs.claude.com/en/docs/claude-code/overview
Verify in a NEW terminal:
  claude --version
EOF
            ;;
        "Elnora CLI"*)
            cat <<'EOF'
Try manually:
  curl -fsSL https://cli.elnora.ai/install.sh | bash
npm fallback (requires Node.js, already installed later in this script):
  npm install -g @elnora-ai/cli
The installer writes a binary to ~/.local/bin/elnora. If the install finished
but 'elnora' is not found, either open a NEW terminal (Claude Code's step
adds ~/.local/bin to your shell profile) or add this to ~/.zprofile yourself:
  export PATH="$HOME/.local/bin:$PATH"
Docs: https://cli.elnora.ai
Verify in a NEW terminal:
  elnora --version
EOF
            ;;
        "GitHub CLI"*)
            cat <<'EOF'
Try manually:
  brew install gh
Verify:
  gh --version
Then authenticate:
  gh auth login       # choose GitHub.com, HTTPS, then browser login
EOF
            ;;
        Obsidian*)
            cat <<'EOF'
Try manually:
  brew install --cask obsidian
Or download the installer:
  https://obsidian.md/download
This step is OPTIONAL — you can skip it if you don't plan to use a
knowledge base. Nothing else in this setup depends on Obsidian.
EOF
            ;;
        "Projects folder"*)
            cat <<'EOF'
Try manually:
  mkdir -p "$HOME/Documents/Projects"
If mkdir fails, check your Documents folder:
  ls -ld "$HOME/Documents"
It should exist and be owned by your user. If ownership is wrong (e.g.,
after a Migration Assistant restore), repair it with:
  sudo chown -R "$(whoami)":staff "$HOME/Documents"
EOF
            ;;
        *)
            echo "No specific remediation available — scroll up to see the captured output."
            ;;
    esac
}

# ------------------------------------------------------------
# run_step "<label>" <command> [args...]
# ------------------------------------------------------------
# Runs a command with live output. On failure prints a structured FAILURE
# box with the exit code, the exact command, the last 10 lines of captured
# stderr, and a step-specific remediation hint.
#
# Stream-splitting: the `{ ... } 3>&1` + tee trick lets us capture stderr
# (for post-failure quoting) while still streaming stdout AND stderr live
# to the terminal. PIPESTATUS[0] preserves the command's exit code through
# the pipe (otherwise we'd get tee's exit code, which is always 0).
run_step() {
    local label="$1"; shift
    local errfile code
    errfile="$(mktemp 2>/dev/null)" || errfile="/tmp/claude-setup-err.$$"
    { "$@" 2>&1 >&3 | tee "$errfile" >&2; code=${PIPESTATUS[0]}; } 3>&1
    if [ "$code" -eq 0 ]; then
        rm -f "$errfile"
        return 0
    fi
    echo "" >&2
    echo "  ┌─ FAILURE: $label" >&2
    echo "  │ Exit code: $code" >&2
    echo "  │ Command:   $*" >&2
    if [ -s "$errfile" ]; then
        echo "  │" >&2
        echo "  │ Captured stderr (last 10 lines):" >&2
        tail -n 10 "$errfile" 2>/dev/null | sed 's/^/  │   /' >&2
    fi
    echo "  │" >&2
    echo "  │ What to do:" >&2
    remediation_hint "$label" | sed 's/^/  │   /' >&2
    echo "  └──────────────────────────────────────────────────────────" >&2
    echo "" >&2
    FAILED_STEPS+=("$label (exit $code)")
    rm -f "$errfile"
    return "$code"
}

echo "==========================================="
echo "  Claude Code Setup for macOS"
echo "==========================================="
echo "  Log: $LOG_FILE"
echo ""

# --- Prerequisite: Xcode Command Line Tools ---
# Homebrew depends on these. On a fresh Mac the first `brew install` triggers a
# blocking GUI dialog — we check upfront so the user isn't surprised mid-script.
if ! xcode-select -p &>/dev/null; then
    echo "[pre] Xcode Command Line Tools are REQUIRED but not installed."
    echo ""
    echo "  A system dialog should appear asking you to install them."
    echo "    - Click 'Install' (NOT 'Get Xcode' — the full Xcode is ~12 GB"
    echo "      and is not needed; we only want the Command Line Tools)"
    echo "    - Wait for the install to finish (~5-10 minutes on fast internet)"
    echo "    - Re-run this script AFTER the install completes"
    echo ""
    echo "  Triggering the install prompt now..."
    xcode-select --install 2>/dev/null || true
    echo ""
    echo "  TROUBLESHOOTING:"
    echo "    - No dialog appeared?  Run manually:  xcode-select --install"
    echo "    - Already have full Xcode.app? Confirm the CLT path exists:"
    echo "        xcode-select -p"
    echo "      It should return something like /Applications/Xcode.app/Contents/Developer"
    echo "      or /Library/Developer/CommandLineTools. If it does, re-run this script."
    echo "    - Corporate laptop blocking CLT install? Ask IT to install"
    echo "      \"Command Line Tools for Xcode\" from Apple's Developer Downloads:"
    echo "        https://developer.apple.com/download/all/?q=command%20line%20tools"
    echo ""
    # Exit non-zero so the curl | bash bootstrap (and any wrapping terminal)
    # surfaces this as a failure. Exiting 0 here made the one-liner appear
    # to succeed while no real setup had happened — the user would close the
    # terminal, open VS Code, and find nothing worked.
    exit 1
fi

# --- [1/10] Claude Code CLI (installed FIRST — zero dependencies) ---
# Using Anthropic's native installer rather than the brew cask so Claude Code
# is the very first thing on the machine. Works before brew exists, writes a
# self-contained binary to ~/.local/bin/claude, and auto-updates itself.
if ! command -v claude &> /dev/null; then
    echo "[1/10] Installing Claude Code..."
    echo "  Using Anthropic's native installer (no prerequisites required)."
    # `set -o pipefail` — without it, a failed curl (404, DNS, network hiccup)
    # would send empty stdin to bash, which then exits 0 and the whole step
    # looks like a silent success. pipefail propagates curl's non-zero exit
    # through the pipe so run_step can catch and remediate it.
    if run_step "Claude Code" /bin/bash -c "set -o pipefail; curl -fsSL https://claude.ai/install.sh | bash"; then
        # Make `claude` visible in THIS shell without requiring a new terminal.
        # The installer persists this to the user's shell profile for future
        # sessions, but we also export it here so the rest of this run sees it.
        export PATH="$HOME/.local/bin:$PATH"
        echo "  Done. Version: $(claude --version 2>/dev/null || echo 'installed — restart terminal')"
    fi
else
    echo "[1/10] Claude Code already installed: $(claude --version). Skipping."
fi

# --- [2/10] Elnora CLI (installed SECOND — also zero dependencies) ---
# Elnora's installer downloads a pre-built binary from GitHub releases into
# ~/.local/bin/elnora (same dir as Claude Code), so no Node/brew required.
# We deliberately run this before Homebrew / Node so the order stays
# "AI surfaces first, toolchain second" and so the Elnora binary is ready
# the moment a user opens Claude Code.
if ! command -v elnora &> /dev/null; then
    echo "[2/10] Installing Elnora CLI..."
    echo "  Using Elnora's native installer (no prerequisites required)."
    # pipefail — see matching comment in the Claude Code block above.
    if run_step "Elnora CLI" /bin/bash -c "set -o pipefail; curl -fsSL https://cli.elnora.ai/install.sh | bash"; then
        # Claude Code's step already exported PATH above, but be explicit in case
        # this script is ever re-ordered.
        export PATH="$HOME/.local/bin:$PATH"
        echo "  Done. Version: $(elnora --version 2>/dev/null || echo 'installed — restart terminal')"
        echo "  Next: run 'elnora auth login' after setup to authenticate (browser OAuth)."
    fi
else
    echo "[2/10] Elnora CLI already installed: $(elnora --version 2>/dev/null || echo 'installed'). Skipping."
fi

# --- [3/10] Homebrew ---
# Always try to load brew shellenv if a brew binary exists — VS Code's terminal
# can inherit a stale PATH that doesn't include brew's prefix, which would make
# `command -v brew` return false and send us down the wrong branch.
for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$candidate" ]; then
        eval "$("$candidate" shellenv)"
        break
    fi
done

# Helper: append brew shellenv to the user's shell profile so new terminals pick
# up brew automatically. Homebrew's own installer does NOT do this reliably —
# without it, every future terminal shows `claude: command not found` & friends.
persist_brew_path() {
    local brew_prefix="$1"
    local shell_profile="$HOME/.zprofile"
    [ "$(basename "${SHELL:-}")" = "bash" ] && shell_profile="$HOME/.bash_profile"
    local brew_eval="eval \"\$($brew_prefix/bin/brew shellenv)\""
    if ! grep -Fq "$brew_eval" "$shell_profile" 2>/dev/null; then
        {
            echo ""
            echo "# Added by Elnora Starter Kit setup-mac.sh"
            echo "$brew_eval"
        } >> "$shell_profile"
        echo "  Added Homebrew PATH to $shell_profile (takes effect in new terminals)."
    fi
}

if ! command -v brew &> /dev/null; then
    echo "[3/10] Installing Homebrew..."
    echo "  Heads-up: this takes 5-15 min and will prompt for your Mac login"
    echo "  password. Password characters won't show as you type — that's normal."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        if [ -x /opt/homebrew/bin/brew ]; then
            BREW_PREFIX="/opt/homebrew"
        elif [ -x /usr/local/bin/brew ]; then
            BREW_PREFIX="/usr/local"
        else
            echo "" >&2
            echo "  ┌─ FAILURE: Homebrew (binary missing after install)" >&2
            echo "  │ The installer reported success but no brew binary was found at" >&2
            echo "  │ /opt/homebrew/bin/brew (Apple Silicon) or /usr/local/bin/brew (Intel)." >&2
            echo "  │" >&2
            echo "  │ This usually means the installer exited early — e.g. a keychain" >&2
            echo "  │ prompt was dismissed, a sudo password timed out, or the network" >&2
            echo "  │ call to fetch the tap failed. Scroll up to see the installer output." >&2
            echo "  │" >&2
            echo "  │ What to do:" >&2
            remediation_hint "Homebrew" | sed 's/^/  │   /' >&2
            echo "  └──────────────────────────────────────────────────────────" >&2
            echo "" >&2
            FAILED_STEPS+=("Homebrew (binary missing after install)")
            BREW_PREFIX=""
        fi
        if [ -n "$BREW_PREFIX" ]; then
            eval "$("$BREW_PREFIX/bin/brew" shellenv)"
            persist_brew_path "$BREW_PREFIX"
            echo "  Done."
        fi
    else
        brew_code=$?
        echo "" >&2
        echo "  ┌─ FAILURE: Homebrew (installer exited $brew_code)" >&2
        echo "  │ The Homebrew install script did not complete successfully." >&2
        echo "  │ Scroll up — the installer's own error output above explains why." >&2
        echo "  │" >&2
        echo "  │ Later brew-dependent steps (Node, Git, Python, VS Code, Claude Code," >&2
        echo "  │ GitHub CLI, Obsidian) will also fail until Homebrew is installed." >&2
        echo "  │" >&2
        echo "  │ What to do:" >&2
        remediation_hint "Homebrew" | sed 's/^/  │   /' >&2
        echo "  └──────────────────────────────────────────────────────────" >&2
        echo "" >&2
        FAILED_STEPS+=("Homebrew (installer exit $brew_code)")
    fi
else
    echo "[3/10] Homebrew already installed. Skipping."
    # Persist the PATH even on skip — prior runs may have installed brew without
    # editing the shell profile.
    if [ -x /opt/homebrew/bin/brew ]; then
        persist_brew_path "/opt/homebrew"
    elif [ -x /usr/local/bin/brew ]; then
        persist_brew_path "/usr/local"
    fi
fi

# --- [4/10] Node.js 22 LTS (pinned for Mac/Windows parity) ---
# Pinned to the 22.x LTS line so Mac and Windows workshop attendees land on the
# same major. node@22 is keg-only on Homebrew — without `brew link --force
# --overwrite` no `node` symlink appears in /opt/homebrew/bin and the rest of
# this script's `command -v node` checks fail.
node_major_ok=false
if command -v node &> /dev/null; then
    node_major="$(node --version 2>/dev/null | sed -E 's/^v([0-9]+).*/\1/')"
    if [ -n "$node_major" ] && [ "$node_major" -ge 22 ]; then
        node_major_ok=true
    fi
fi
if ! $node_major_ok; then
    echo "[4/10] Installing Node.js 22 LTS..."
    if run_step "Node.js" brew install node@22; then
        brew link --force --overwrite node@22 &>/dev/null || true
        hash -r 2>/dev/null || true
        echo "  Done. Version: $(node --version 2>/dev/null || echo 'installed — restart terminal')"
    fi
else
    echo "[4/10] Node.js already installed: $(node --version). Skipping."
fi

# --- [5/10] Git + user config ---
if ! command -v git &> /dev/null; then
    echo "[5/10] Installing Git..."
    run_step "Git" brew install git && echo "  Done. Version: $(git --version)"
else
    echo "[5/10] Git already installed: $(git --version). Skipping."
    # Apple's Xcode CLT ships /usr/bin/git, which is typically a few minor
    # versions behind brew. Works fine for clone/commit/push — tell users how
    # to upgrade if they want the latest.
    if [[ "$(command -v git)" == "/usr/bin/git" ]]; then
        echo "  Note: using Apple's Xcode CLT git at /usr/bin/git (older)."
        echo "  To get the latest git:  brew install git"
        echo "  Then ensure brew's PATH comes before /usr/bin in ~/.zprofile."
    fi
fi

if command -v git &> /dev/null; then
    GIT_NAME="$(git config --global user.name 2>/dev/null || true)"
    GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"
    if [ -z "$GIT_NAME" ]; then
        read -r -p "  Enter your full name for git commits: " input_name || input_name=""
        if [ -n "$input_name" ]; then
            if ! git config --global user.name "$input_name" 2>/dev/null; then
                echo "  [!] 'git config --global user.name' failed — run it manually:" >&2
                echo "      git config --global user.name \"$input_name\"" >&2
                FAILED_STEPS+=("Git config (user.name)")
            fi
        fi
    fi
    if [ -z "$GIT_EMAIL" ]; then
        read -r -p "  Enter your email for git commits: " input_email || input_email=""
        if [ -n "$input_email" ]; then
            if ! git config --global user.email "$input_email" 2>/dev/null; then
                echo "  [!] 'git config --global user.email' failed — run it manually:" >&2
                echo "      git config --global user.email \"$input_email\"" >&2
                FAILED_STEPS+=("Git config (user.email)")
            fi
        fi
    fi
    echo "  git user: $(git config --global user.name 2>/dev/null || echo 'not set') <$(git config --global user.email 2>/dev/null || echo 'not set')>"

    if [ -z "$(git config --global init.defaultBranch 2>/dev/null || true)" ]; then
        git config --global init.defaultBranch main && echo "  git init.defaultBranch: main"
    fi
else
    echo "  [!] git not available — skipping git config." >&2
    echo "      See the Git remediation in the recap at the end of this run." >&2
fi

# --- [6/10] Python 3.12 (pinned for Mac/Windows parity) ---
# Pinned to match the Windows script's `Python.Python.3.12` winget package so
# workshop attendees on different OSes end up on the same minor. python@3.12 is
# keg-only on Homebrew, but `brew link --force --overwrite` creates the
# /opt/homebrew/bin/python3 symlink the rest of this script's `command -v`
# checks rely on. A version-floor probe (not just `command -v`) catches stale
# python3 binaries on PATH (old python.org installer, leftover 3.8, etc.).
python_version_ok=false
if command -v python3 &> /dev/null && [[ "$(command -v python3)" != "/usr/bin/python3" ]]; then
    if python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 12) else 1)' 2>/dev/null; then
        python_version_ok=true
    fi
fi
if ! $python_version_ok; then
    echo "[6/10] Installing Python 3.12..."
    if run_step "Python 3.12" brew install python@3.12; then
        brew link --force --overwrite python@3.12 &>/dev/null || true
        hash -r 2>/dev/null || true
        echo "  Done. Version: $(python3 --version 2>/dev/null || echo 'installed — restart terminal')"
    fi
else
    echo "[6/10] Python already installed: $(python3 --version). Skipping."
fi

# --- [7/10] VS Code ---
if ! command -v code &> /dev/null && [ ! -d "/Applications/Visual Studio Code.app" ]; then
    echo "[7/10] Installing VS Code..."
    run_step "VS Code" brew install --cask visual-studio-code && echo "  Done."
else
    echo "[7/10] VS Code already installed. Skipping."
fi

# Install the `code` CLI shim so `code .` works from terminal. The cask does not
# do this automatically — normally users have to run "Shell Command: Install
# 'code' command in PATH" from VS Code's command palette. We symlink directly.
VSCODE_SHIM="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
if [ -x "$VSCODE_SHIM" ] && ! command -v code &> /dev/null; then
    if command -v brew &> /dev/null && BREW_BIN="$(brew --prefix 2>/dev/null)/bin" && [ -d "$BREW_BIN" ] && [ -w "$BREW_BIN" ]; then
        if ln_err="$(ln -sf "$VSCODE_SHIM" "$BREW_BIN/code" 2>&1)"; then
            echo "  Linked 'code' CLI: $BREW_BIN/code -> $VSCODE_SHIM"
        else
            echo "  [!] Could not symlink 'code' into $BREW_BIN." >&2
            echo "      ln said: $ln_err" >&2
            echo "      Workaround: open VS Code, press Cmd+Shift+P, and run" >&2
            echo "        \"Shell Command: Install 'code' command in PATH\"" >&2
        fi
    else
        echo "  [!] brew bin directory not writable — skipping automatic 'code' CLI shim." >&2
        echo "      Workaround: open VS Code, press Cmd+Shift+P, and run" >&2
        echo "        \"Shell Command: Install 'code' command in PATH\"" >&2
    fi
fi

# --- [8/10] GitHub CLI ---
if ! command -v gh &> /dev/null; then
    echo "[8/10] Installing GitHub CLI..."
    run_step "GitHub CLI" brew install gh && echo "  Done. Version: $(gh --version 2>/dev/null | head -1)"
else
    echo "[8/10] GitHub CLI already installed: $(gh --version | head -1). Skipping."
fi

# --- [9/10] Obsidian (optional — knowledge base) ---
if [ ! -d "/Applications/Obsidian.app" ]; then
    echo "[9/10] Installing Obsidian (optional)..."
    run_step "Obsidian" brew install --cask obsidian && echo "  Done."
else
    echo "[9/10] Obsidian already installed. Skipping."
fi

# --- [10/10] Projects folder ---
PROJECTS_DIR="$HOME/Documents/Projects"
if [ ! -d "$PROJECTS_DIR" ]; then
    echo "[10/10] Creating Projects folder at $PROJECTS_DIR..."
    if mkdir_err="$(mkdir -p "$PROJECTS_DIR" 2>&1)"; then
        echo "  Done."
    else
        echo "" >&2
        echo "  ┌─ FAILURE: Projects folder" >&2
        echo "  │ Could not create $PROJECTS_DIR" >&2
        echo "  │ mkdir said: ${mkdir_err:-(no output)}" >&2
        echo "  │" >&2
        echo "  │ What to do:" >&2
        remediation_hint "Projects folder" | sed 's/^/  │   /' >&2
        echo "  └──────────────────────────────────────────────────────────" >&2
        echo "" >&2
        FAILED_STEPS+=("Projects folder")
    fi
else
    echo "[10/10] Projects folder already exists. Skipping."
fi

echo ""
echo "==========================================="
echo "  Setup complete!"
echo "==========================================="
echo ""
# Refresh shell command lookup cache so newly-installed binaries are visible.
hash -r 2>/dev/null || true

# VS Code: `code` may not be on PATH until the user runs
# "Shell Command: Install 'code' command in PATH" from VS Code's palette.
# Check for the .app bundle as a fallback so the summary isn't misleading.
vscode_version() {
    if command -v code &> /dev/null; then
        code --version 2>/dev/null | head -1
    elif [ -d "/Applications/Visual Studio Code.app" ]; then
        local plist="/Applications/Visual Studio Code.app/Contents/Info.plist"
        if [ -f "$plist" ]; then
            /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist" 2>/dev/null \
                | awk '{print "installed (" $0 ") — run \"Shell Command: Install code command in PATH\" from VS Code"}'
        else
            echo "installed — run \"Shell Command: Install code command in PATH\" from VS Code"
        fi
    else
        echo "not found"
    fi
}

obsidian_version() {
    if [ -d "/Applications/Obsidian.app" ]; then
        local plist="/Applications/Obsidian.app/Contents/Info.plist"
        if [ -f "$plist" ]; then
            /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist" 2>/dev/null \
                | awk '{print "installed (" $0 ")"}'
        else
            echo "installed"
        fi
    else
        echo "not found"
    fi
}

echo "  Node.js:     $(node --version 2>/dev/null || echo 'not found')"
echo "  Git:         $(git --version 2>/dev/null || echo 'not found')"
echo "  Python:      $(python3 --version 2>/dev/null || echo 'not found')"
echo "  VS Code:     $(vscode_version)"
echo "  Claude Code: $(claude --version 2>/dev/null || echo 'not found')"
echo "  Elnora CLI:  $(elnora --version 2>/dev/null || echo 'not found')"
echo "  GitHub CLI:  $(gh --version 2>/dev/null | head -1 || echo 'not found')"
echo "  Obsidian:    $(obsidian_version)"
echo ""

if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
    echo "==========================================="
    echo "  ⚠  ${#FAILED_STEPS[@]} step(s) failed — remediation below"
    echo "==========================================="
    for step_entry in "${FAILED_STEPS[@]}"; do
        # Strip trailing "(exit N)" or "(...)" to recover the bare label for lookup.
        step_label="${step_entry% (*}"
        echo ""
        echo "── $step_entry ──"
        remediation_hint "$step_label"
    done
    echo ""
    echo "Once you've fixed the issue(s), re-run:  ./setup-mac.sh"
    echo "The script is idempotent — already-installed steps are skipped."
    echo "==========================================="
    echo ""
fi

echo "-------------------------------------------"
echo "  IMPORTANT — to see the new PATH in VS Code:"
echo "  Quit VS Code FULLY (Cmd+Q — not just closing the terminal)"
echo "  and reopen it. VS Code caches its PATH at app launch time."
echo "  If you ran this in Terminal.app, just open a new window."
echo "-------------------------------------------"
echo ""

echo "==========================================="
echo "  Phase 1 complete — handing off to Claude"
echo "==========================================="
echo ""

if command -v claude >/dev/null 2>&1; then
    if [ "${ELNORA_SKIP_HANDOFF:-}" = "1" ]; then
        # CI/test escape hatch: print what would happen and exit cleanly. Used
        # by .github/workflows/install-smoke-test.yml so the smoke test doesn't
        # hang on Claude trying to open a browser for first-run auth.
        echo "ELNORA_SKIP_HANDOFF=1 set — would exec claude with the Phase 2 prompt. Skipping for non-interactive run."
        exit 0
    fi
    echo "Starting Claude — it will read INSTALL_FOR_AGENTS.md and finish setup."
    echo "On first run, your browser will open to log into your Claude Pro/Max account."
    echo ""
    # exec replaces this shell — Claude takes over with the initial prompt loaded.
    # If exec fails (no TTY, broken install), the lines below print as a fallback.
    exec claude "Phase 1 of the Elnora Starter Kit install just completed. Please read INSTALL_FOR_AGENTS.md in this directory and finish Phase 2 setup. The Phase 1 install log is at ~/claude-starter-install.log."
fi

# Fallback: claude not on PATH (install of Claude Code itself failed) — show
# the manual continuation path so the user can recover after fixing the issue.
echo "  ⚠  'claude' command not found — Claude Code install may have failed."
echo ""
echo "  See the remediation hints above. Once you've fixed it, re-run:"
echo "      ./setup-mac.sh"
echo ""
echo "  Or continue manually:"
echo "      cd $(pwd)"
echo "      claude"
echo "      Then say: 'Read INSTALL_FOR_AGENTS.md and finish setup.'"
echo ""

# Exit 0 even if some steps failed — the remediation recap tells the user exactly
# what to do, and a non-zero exit would trip callers (e.g. IDE terminals that
# highlight failures) in ways that can hide the remediation text above.
exit 0
