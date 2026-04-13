#!/bin/bash
# ============================================================
# Claude Code Setup — macOS
# ============================================================
# This script installs everything you need to use Claude Code.
# Run it from Terminal:
#   chmod +x setup-mac.sh && ./setup-mac.sh
# ============================================================

set -e

echo "==========================================="
echo "  Claude Code Setup for macOS"
echo "==========================================="
echo ""

# --- Check for Homebrew ---
if ! command -v brew &> /dev/null; then
    echo "[1/6] Installing Homebrew (macOS package manager)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "  Done."
else
    echo "[1/6] Homebrew already installed. Skipping."
fi

# --- Install Node.js ---
if ! command -v node &> /dev/null; then
    echo "[2/6] Installing Node.js..."
    brew install node
    echo "  Done. Version: $(node --version)"
else
    echo "[2/6] Node.js already installed: $(node --version). Skipping."
fi

# --- Install Git ---
if ! command -v git &> /dev/null; then
    echo "[3/6] Installing Git..."
    brew install git
    echo "  Done. Version: $(git --version)"
else
    echo "[3/6] Git already installed: $(git --version). Skipping."
fi

# --- Install Python ---
if ! command -v python3 &> /dev/null; then
    echo "[4/6] Installing Python 3.12..."
    brew install python@3.12
    echo "  Done. Version: $(python3 --version)"
else
    echo "[4/6] Python already installed: $(python3 --version). Skipping."
fi

# --- Install VS Code ---
if ! command -v code &> /dev/null; then
    echo "[5/6] Installing VS Code..."
    brew install --cask visual-studio-code
    echo "  Done."
else
    echo "[5/6] VS Code already installed. Skipping."
fi

# --- Install Claude Code ---
if ! command -v claude &> /dev/null; then
    echo "[6/6] Installing Claude Code..."
    brew install --cask claude-code
    echo "  Done. Version: $(claude --version)"
else
    echo "[6/6] Claude Code already installed: $(claude --version). Skipping."
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
echo ""
echo "Next steps:"
echo "  1. Open VS Code:           code ."
echo "  2. Start Claude Code:      claude"
echo "  3. Log in when prompted (opens browser)"
echo "  4. Connect GitHub:         type /install-github-app in Claude"
echo ""
