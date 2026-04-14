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

# --- [1/9] Homebrew ---
if ! command -v brew &> /dev/null; then
    echo "[1/9] Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        if [ -x /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -x /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        echo "  Done."
    else
        echo "  [!] Homebrew install failed — continuing, but later brew steps will also fail." >&2
        FAILED_STEPS+=("Homebrew")
    fi
else
    echo "[1/9] Homebrew already installed. Skipping."
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

# --- [4/9] Python 3.12 ---
if ! command -v python3 &> /dev/null; then
    echo "[4/9] Installing Python 3.12..."
    run_step "Python 3.12" brew install python@3.12 && echo "  Done. Version: $(python3 --version 2>/dev/null)"
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
echo "  Node.js:     $(node --version 2>/dev/null || echo 'not found')"
echo "  Git:         $(git --version 2>/dev/null || echo 'not found')"
echo "  Python:      $(python3 --version 2>/dev/null || echo 'not found')"
echo "  VS Code:     $(code --version 2>/dev/null | head -1 || echo 'not found')"
echo "  Claude Code: $(claude --version 2>/dev/null || echo 'not found')"
echo "  GitHub CLI:  $(gh --version 2>/dev/null | head -1 || echo 'not found')"
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
