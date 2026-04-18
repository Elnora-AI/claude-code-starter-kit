#!/bin/bash
# ============================================================
# Claude Code Starter Kit — One-liner Installer (macOS / Linux)
# ============================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Elnora-AI/claude-code-starter-kit/main/install.sh | bash
#
# Downloads the starter kit tarball (no git required), extracts it to
# ~/Documents/claude-code-starter-kit, and runs setup-mac.sh.
# ============================================================

set -euo pipefail

REPO_OWNER="Elnora-AI"
REPO_NAME="claude-code-starter-kit"
BRANCH="main"
TARGET_DIR="$HOME/Documents/claude-code-starter-kit"

echo "==========================================="
echo "  Claude Code Starter Kit — Bootstrap"
echo "==========================================="
echo ""
echo "This will:"
echo "  1. Download the starter kit to ~/Documents/claude-code-starter-kit"
echo "  2. Run setup-mac.sh (installs Claude Code + dev tools)"
echo ""

if [ -d "$TARGET_DIR" ]; then
    echo "Starter kit already exists at $TARGET_DIR"
    echo "Re-running setup from existing copy. Remove the folder to re-download."
else
    echo "Downloading starter kit tarball..."
    TARBALL_URL="https://github.com/$REPO_OWNER/$REPO_NAME/archive/refs/heads/$BRANCH.tar.gz"
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    if curl -fsSL "$TARBALL_URL" | tar xz -C "$TMP_DIR"; then
        mkdir -p "$(dirname "$TARGET_DIR")"
        mv "$TMP_DIR/$REPO_NAME-$BRANCH" "$TARGET_DIR"
        echo "Extracted to $TARGET_DIR"
    else
        echo "[!] Failed to download starter kit from $TARBALL_URL" >&2
        echo "    Check your internet connection and retry:" >&2
        echo "      curl -fsSL https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/install.sh | bash" >&2
        exit 1
    fi
fi

cd "$TARGET_DIR"
chmod +x setup-mac.sh
echo ""

# Redirect stdin from /dev/tty so the setup script's `read` prompts (git
# config name/email) still work — otherwise stdin would be the closed pipe
# from curl, and the prompts would silently skip.
exec ./setup-mac.sh < /dev/tty
