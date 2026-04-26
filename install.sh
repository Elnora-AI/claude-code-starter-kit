#!/bin/bash
# ============================================================
# Elnora Starter Kit - One-liner Installer (macOS)
# ============================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Elnora-AI/elnora-starter-kit/main/install.sh | bash
#
# Downloads the starter kit tarball (no git required), extracts it to
# ~/Documents/elnora-starter-kit, and runs setup-mac.sh.
# ============================================================

set -euo pipefail

REPO_OWNER="Elnora-AI"
REPO_NAME="elnora-starter-kit"
BRANCH="main"
TARGET_DIR="$HOME/Documents/elnora-starter-kit"

echo "==========================================="
echo "  Elnora Starter Kit - Bootstrap"
echo "==========================================="
echo ""
echo "This will:"
echo "  1. Download the starter kit to ~/Documents/elnora-starter-kit"
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

    if curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 30 --max-time 300 "$TARBALL_URL" | tar xz -C "$TMP_DIR"; then
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

# Strip dev/CI scaffolding the customer can't use anyway. tests/handoff/ exists
# for our CI assertions; .github/ holds workflows + dependabot config that only
# fire on the official Elnora-AI/elnora-starter-kit repo. Both ride along in the
# tarball and would just clutter the customer's directory. rm -rf is idempotent
# so this is safe on both fresh and re-run installs.
echo "Stripping dev/CI scaffolding (tests/, .github/)..."
rm -rf "$TARGET_DIR/tests" "$TARGET_DIR/.github"
echo "  Done."

chmod +x setup-mac.sh
echo ""

# Redirect stdin from /dev/tty so the setup script's `read` prompts (git
# config name/email) still work when install.sh was invoked via
# `curl ... | bash` (curl's pipe leaves stdin closed). Fall back to the
# inherited stdin when /dev/tty isn't accessible - e.g. CI runners with no
# controlling terminal, where the redirect itself would fail with "no such
# device" and abort the script before setup-mac.sh ran.
if [ -c /dev/tty ] && (exec 3</dev/tty) 2>/dev/null; then
    exec ./setup-mac.sh < /dev/tty
else
    exec ./setup-mac.sh
fi
