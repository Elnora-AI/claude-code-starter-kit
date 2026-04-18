#!/bin/bash
# ============================================================
# Claude Code Setup — macOS
# ============================================================
# Installs everything from the AI Agent Workshop Installation Guide.
# Run from Terminal (or VS Code terminal):
#   chmod +x setup-mac.sh && ./setup-mac.sh
#
# Error handling: the script CONTINUES on failure. Each step is
# isolated — if one install fails (network, permissions, broken
# formula, etc.), remaining steps still run, and a summary of
# failures is printed at the end.
# ============================================================

# NOTE: deliberately NOT using `set -e` so one failure does not abort the rest.
set -u

FAILED_STEPS=()

run_step() {
    # Usage: run_step "step label" command args...
    local label="$1"; shift
    if "$@"; then
        return 0
    else
        local code=$?
        echo "  [!] $label failed (exit $code) — continuing." >&2
        FAILED_STEPS+=("$label")
        return $code
    fi
}

echo "==========================================="
echo "  Claude Code Setup for macOS"
echo "==========================================="
echo ""

# --- Prerequisite: Xcode Command Line Tools ---
# Homebrew depends on these. On a fresh Mac the first `brew install` triggers a
# blocking GUI dialog — we check upfront so the user isn't surprised mid-script.
if ! xcode-select -p &>/dev/null; then
    echo "[pre] Installing Xcode Command Line Tools..."
    echo "  A system dialog will ask you to install Xcode Command Line Tools."
    echo "  Click 'Install' and wait for it to finish (~5 minutes)."
    xcode-select --install 2>/dev/null || true
    echo ""
    echo "  Re-run this script after the Xcode install finishes."
    exit 0
fi

# --- [1/9] Homebrew ---
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
# up brew automatically. Homebrew's own installer does NOT do this — without it,
# every future terminal shows `claude: command not found` and friends.
persist_brew_path() {
    local brew_prefix="$1"
    local shell_profile="$HOME/.zprofile"
    [ "$(basename "${SHELL:-}")" = "bash" ] && shell_profile="$HOME/.bash_profile"
    local brew_eval="eval \"\$($brew_prefix/bin/brew shellenv)\""
    if ! grep -Fq "$brew_eval" "$shell_profile" 2>/dev/null; then
        {
            echo ""
            echo "# Added by Claude Code starter kit setup-mac.sh"
            echo "$brew_eval"
        } >> "$shell_profile"
        echo "  Added Homebrew PATH to $shell_profile (takes effect in new terminals)."
    fi
}

if ! command -v brew &> /dev/null; then
    echo "[1/9] Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        if [ -x /opt/homebrew/bin/brew ]; then
            BREW_PREFIX="/opt/homebrew"
        elif [ -x /usr/local/bin/brew ]; then
            BREW_PREFIX="/usr/local"
        else
            echo "  [!] Homebrew install finished but binary not found at expected path." >&2
            FAILED_STEPS+=("Homebrew (missing after install)")
            BREW_PREFIX=""
        fi
        if [ -n "$BREW_PREFIX" ]; then
            eval "$("$BREW_PREFIX/bin/brew" shellenv)"
            persist_brew_path "$BREW_PREFIX"
            echo "  Done."
        fi
    else
        echo "  [!] Homebrew install failed — continuing, but later brew steps will also fail." >&2
        FAILED_STEPS+=("Homebrew")
    fi
else
    echo "[1/9] Homebrew already installed. Skipping."
    # Persist the PATH even on skip — prior runs may have installed brew without
    # editing the shell profile.
    if [ -x /opt/homebrew/bin/brew ]; then
        persist_brew_path "/opt/homebrew"
    elif [ -x /usr/local/bin/brew ]; then
        persist_brew_path "/usr/local"
    fi
fi

# --- [2/9] Node.js ---
if ! command -v node &> /dev/null; then
    echo "[2/9] Installing Node.js..."
    run_step "Node.js" brew install node && echo "  Done. Version: $(node --version)"
else
    echo "[2/9] Node.js already installed: $(node --version). Skipping."
fi

# --- [3/9] Git + user config ---
if ! command -v git &> /dev/null; then
    echo "[3/9] Installing Git..."
    run_step "Git" brew install git && echo "  Done. Version: $(git --version)"
else
    echo "[3/9] Git already installed: $(git --version). Skipping."
fi

if command -v git &> /dev/null; then
    GIT_NAME="$(git config --global user.name 2>/dev/null || true)"
    GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"
    if [ -z "$GIT_NAME" ]; then
        read -r -p "  Enter your full name for git commits: " input_name || input_name=""
        [ -n "$input_name" ] && git config --global user.name "$input_name"
    fi
    if [ -z "$GIT_EMAIL" ]; then
        read -r -p "  Enter your email for git commits: " input_email || input_email=""
        [ -n "$input_email" ] && git config --global user.email "$input_email"
    fi
    echo "  git user: $(git config --global user.name 2>/dev/null || echo 'not set') <$(git config --global user.email 2>/dev/null || echo 'not set')>"

    if [ -z "$(git config --global init.defaultBranch 2>/dev/null || true)" ]; then
        git config --global init.defaultBranch main && echo "  git init.defaultBranch: main"
    fi
else
    echo "  [!] git not available — skipping git config." >&2
fi

# --- [4/9] Python 3 ---
# Use plain `brew install python` (the "main" formula). `brew install python@3.12`
# is keg-only — it installs to /opt/homebrew/opt/python@3.12/ without creating a
# `python3` symlink in /opt/homebrew/bin, so users end up with only the Xcode stub
# at /usr/bin/python3 (which prompts for Xcode every time).
if ! command -v python3 &> /dev/null || [[ "$(command -v python3)" == "/usr/bin/python3" ]]; then
    echo "[4/9] Installing Python 3..."
    run_step "Python 3" brew install python && echo "  Done. Version: $(python3 --version 2>/dev/null)"
else
    echo "[4/9] Python already installed: $(python3 --version). Skipping."
fi

# --- [5/9] VS Code ---
if ! command -v code &> /dev/null && [ ! -d "/Applications/Visual Studio Code.app" ]; then
    echo "[5/9] Installing VS Code..."
    run_step "VS Code" brew install --cask visual-studio-code && echo "  Done."
else
    echo "[5/9] VS Code already installed. Skipping."
fi

# Install the `code` CLI shim so `code .` works from terminal. The cask does not
# do this automatically — normally users have to run "Shell Command: Install
# 'code' command in PATH" from VS Code's command palette. We symlink directly.
VSCODE_SHIM="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
if [ -x "$VSCODE_SHIM" ] && ! command -v code &> /dev/null; then
    if BREW_BIN="$(brew --prefix 2>/dev/null)/bin" && [ -d "$BREW_BIN" ] && [ -w "$BREW_BIN" ]; then
        ln -sf "$VSCODE_SHIM" "$BREW_BIN/code"
        echo "  Linked 'code' CLI: $BREW_BIN/code -> $VSCODE_SHIM"
    fi
fi

# --- [6/9] Claude Code CLI ---
if ! command -v claude &> /dev/null; then
    echo "[6/9] Installing Claude Code..."
    run_step "Claude Code" brew install --cask claude-code && \
        echo "  Done. Version: $(claude --version 2>/dev/null || echo 'installed — restart terminal')"
else
    echo "[6/9] Claude Code already installed: $(claude --version). Skipping."
fi

# --- [7/9] GitHub CLI ---
if ! command -v gh &> /dev/null; then
    echo "[7/9] Installing GitHub CLI..."
    run_step "GitHub CLI" brew install gh && echo "  Done. Version: $(gh --version 2>/dev/null | head -1)"
else
    echo "[7/9] GitHub CLI already installed: $(gh --version | head -1). Skipping."
fi

# --- [8/9] Obsidian (optional — knowledge base) ---
if [ ! -d "/Applications/Obsidian.app" ]; then
    echo "[8/9] Installing Obsidian (optional)..."
    run_step "Obsidian" brew install --cask obsidian && echo "  Done."
else
    echo "[8/9] Obsidian already installed. Skipping."
fi

# --- [9/9] Projects folder (guide Step 8 prep) ---
PROJECTS_DIR="$HOME/Documents/Projects"
if [ ! -d "$PROJECTS_DIR" ]; then
    echo "[9/9] Creating Projects folder at $PROJECTS_DIR..."
    if mkdir -p "$PROJECTS_DIR"; then
        echo "  Done."
    else
        echo "  [!] Could not create $PROJECTS_DIR — continuing." >&2
        FAILED_STEPS+=("Projects folder")
    fi
else
    echo "[9/9] Projects folder already exists. Skipping."
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
echo "  GitHub CLI:  $(gh --version 2>/dev/null | head -1 || echo 'not found')"
echo "  Obsidian:    $(obsidian_version)"
echo ""

if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
    echo "-------------------------------------------"
    echo "  ⚠  ${#FAILED_STEPS[@]} step(s) failed:"
    for step in "${FAILED_STEPS[@]}"; do
        echo "     - $step"
    done
    echo "  Re-run this script to retry, or install the failed items manually."
    echo "-------------------------------------------"
    echo ""
fi

echo "Next steps (interactive — these need your browser/input):"
echo "  1. Authenticate Claude Code:     claude         (log in, then /exit)"
echo "  2. Authenticate GitHub CLI:      gh auth login  (GitHub.com → HTTPS → browser)"
echo "  3. Create your workshop repo:"
echo "       cd ~/Documents/Projects"
echo "       gh repo create my-workshop-project --private --add-readme --clone"
echo "       cd my-workshop-project && code ."
echo "  4. In VS Code terminal:  claude   then   /install-github-app"
echo "  5. Copy starter kit into your repo:"
echo "       git clone https://github.com/Elnora-AI/claude-code-starter-kit.git temp-starter"
echo "       rsync -a --exclude '.git' temp-starter/ ."
echo "       rm -rf temp-starter"
echo "  6. (Optional) Create an Obsidian vault in your OneDrive/knowledge-base folder."
echo ""

# Exit 0 even if some steps failed — summary tells the user what to fix.
exit 0
