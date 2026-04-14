#!/bin/bash
# ============================================================
# Claude Code Setup — macOS
# ============================================================
# Installs everything from the AI Agent Workshop Installation Guide.
# Run from Terminal (or VS Code terminal):
#   chmod +x setup-mac.sh && ./setup-mac.sh
# ============================================================

set -e

echo "==========================================="
echo "  Claude Code Setup for macOS"
echo "==========================================="
echo ""

# --- [1/8] Homebrew ---
if ! command -v brew &> /dev/null; then
    echo "[1/8] Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo "  Done."
else
    echo "[1/8] Homebrew already installed. Skipping."
fi

# --- [2/8] Node.js ---
if ! command -v node &> /dev/null; then
    echo "[2/8] Installing Node.js..."
    brew install node
    echo "  Done. Version: $(node --version)"
else
    echo "[2/8] Node.js already installed: $(node --version). Skipping."
fi

# --- [3/8] Git + user config ---
if ! command -v git &> /dev/null; then
    echo "[3/8] Installing Git..."
    brew install git
    echo "  Done. Version: $(git --version)"
else
    echo "[3/8] Git already installed: $(git --version). Skipping."
fi

GIT_NAME="$(git config --global user.name || true)"
GIT_EMAIL="$(git config --global user.email || true)"
if [ -z "$GIT_NAME" ]; then
    read -r -p "  Enter your full name for git commits: " input_name
    git config --global user.name "$input_name"
fi
if [ -z "$GIT_EMAIL" ]; then
    read -r -p "  Enter your email for git commits: " input_email
    git config --global user.email "$input_email"
fi
echo "  git user: $(git config --global user.name) <$(git config --global user.email)>"

# --- [4/8] Python 3.12 ---
if ! command -v python3 &> /dev/null; then
    echo "[4/8] Installing Python 3.12..."
    brew install python@3.12
    echo "  Done. Version: $(python3 --version)"
else
    echo "[4/8] Python already installed: $(python3 --version). Skipping."
fi

# --- [5/8] VS Code ---
if ! command -v code &> /dev/null && [ ! -d "/Applications/Visual Studio Code.app" ]; then
    echo "[5/8] Installing VS Code..."
    brew install --cask visual-studio-code
    echo "  Done."
else
    echo "[5/8] VS Code already installed. Skipping."
fi

# --- [6/8] Claude Code CLI ---
if ! command -v claude &> /dev/null; then
    echo "[6/8] Installing Claude Code..."
    brew install --cask claude-code
    echo "  Done. Version: $(claude --version 2>/dev/null || echo 'installed — restart terminal')"
else
    echo "[6/8] Claude Code already installed: $(claude --version). Skipping."
fi

# --- [7/8] GitHub CLI ---
if ! command -v gh &> /dev/null; then
    echo "[7/8] Installing GitHub CLI..."
    brew install gh
    echo "  Done. Version: $(gh --version | head -1)"
else
    echo "[7/8] GitHub CLI already installed: $(gh --version | head -1). Skipping."
fi

# --- [8/8] Obsidian (optional — knowledge base) ---
if [ ! -d "/Applications/Obsidian.app" ]; then
    echo "[8/8] Installing Obsidian (optional)..."
    brew install --cask obsidian
    echo "  Done."
else
    echo "[8/8] Obsidian already installed. Skipping."
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
echo "Next steps (interactive — these need your browser/input):"
echo "  1. Authenticate Claude Code:     claude         (log in, then /exit)"
echo "  2. Authenticate GitHub CLI:      gh auth login  (GitHub.com → HTTPS → browser)"
echo "  3. Create your workshop repo:"
echo "       mkdir -p ~/Documents/Projects && cd ~/Documents/Projects"
echo "       gh repo create my-workshop-project --private --add-readme --clone"
echo "       cd my-workshop-project && code ."
echo "  4. In VS Code terminal:  claude   then   /install-github-app"
echo "  5. Copy starter kit into your repo:"
echo "       git clone https://github.com/Elnora-AI/claude-code-starter-kit.git temp-starter"
echo "       rsync -a --exclude '.git' temp-starter/ ."
echo "       rm -rf temp-starter"
echo "  6. (Optional) Create an Obsidian vault in your OneDrive/knowledge-base folder."
echo ""
