#!/bin/bash
# ============================================================
# Handoff E2E — post-state assertions (macOS / Linux)
# ============================================================
# Run AFTER the headless handoff completes. Verifies on disk
# that Claude actually did the Phase 2 work — independent of
# what the transcript says.
#
# Usage:
#   tests/handoff/assert.sh <repo-dir> <transcript-path>
#
# Exits 0 if all assertions pass, 1 if any fail. Each failure
# prints what was expected vs. found so the workflow log is
# useful for debugging.
# ============================================================

set -u

REPO_DIR="${1:-$PWD}"
TRANSCRIPT="${2:-$HOME/handoff-transcript.jsonl}"

PASS=0
FAIL=0
FAIL_MSGS=()

ok()   { echo "  ✓ $1"; PASS=$((PASS+1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL+1)); FAIL_MSGS+=("$1"); }

cd "$REPO_DIR" || { echo "FATAL: cannot cd to $REPO_DIR"; exit 2; }

echo "==========================================="
echo "  Handoff E2E assertions"
echo "==========================================="
echo "  Repo:       $REPO_DIR"
echo "  Transcript: $TRANSCRIPT"
echo ""

# --- Elnora CLI auth ---
# The CLI persists credentials to ~/.elnora/profiles.toml via
# `elnora auth login --api-key …`. Verify Claude actually authenticated
# the CLI (not just exported a useless .env file — the CLI doesn't read
# .env, so writing it does nothing for future shells).
echo "[elnora auth]"
if [ -f "$HOME/.elnora/profiles.toml" ]; then
    ok "~/.elnora/profiles.toml exists"
    mode=$(stat -f '%Lp' "$HOME/.elnora/profiles.toml" 2>/dev/null || stat -c '%a' "$HOME/.elnora/profiles.toml" 2>/dev/null || echo "?")
    if [ "$mode" = "600" ]; then
        ok "profiles.toml mode is 600"
    else
        # The CLI writes 600 itself; warn but don't fail in case of umask quirks.
        echo "  ⚠ profiles.toml mode is $mode (expected 600 — CLI usually sets this)"
    fi
    if grep -q '^api_key = "elnora_live_' "$HOME/.elnora/profiles.toml"; then
        ok "profiles.toml contains api_key = elnora_live_*"
    else
        fail "profiles.toml missing api_key = \"elnora_live_*\" line"
    fi
else
    fail "~/.elnora/profiles.toml was not created (Claude did not run 'elnora auth login --api-key …')"
fi
if elnora auth status >/dev/null 2>&1; then
    ok "elnora auth status returns success"
else
    fail "elnora auth status failed (CLI is not authenticated)"
fi

# --- git repo ---
echo ""
echo "[git]"
if [ -d .git ]; then
    ok ".git directory exists"
    if git remote get-url elnora-upstream >/dev/null 2>&1; then
        upstream=$(git remote get-url elnora-upstream)
        ok "elnora-upstream remote is set ($upstream)"
    else
        fail "elnora-upstream remote was not configured"
    fi
else
    fail ".git directory was not created"
fi

# --- Knowledge base config ---
echo ""
echo "[knowledge base]"
if [ -f .claude/knowledge-base.local.md ]; then
    ok ".claude/knowledge-base.local.md exists"
    # Should NOT contain the placeholder.
    if grep -q '<ABSOLUTE_PATH_TO_YOUR_VAULT>' .claude/knowledge-base.local.md; then
        fail "knowledge-base.local.md still contains <ABSOLUTE_PATH_TO_YOUR_VAULT> placeholder"
    else
        ok "knowledge-base.local.md placeholder was replaced"
    fi
else
    # Skipped is acceptable in headless mode if the test fixture didn't
    # stage a vault — but we DO stage one, so this should exist.
    fail ".claude/knowledge-base.local.md was not created"
fi

# --- CLAUDE.md self-cleanup ---
echo ""
echo "[CLAUDE.md self-cleanup]"
if grep -q '### First-run setup' CLAUDE.md; then
    fail "CLAUDE.md still contains '### First-run setup' block (should have self-deleted)"
else
    ok "CLAUDE.md '### First-run setup' block was removed"
fi

# --- HANDOFF_COMPLETE marker in transcript ---
echo ""
echo "[transcript]"
if [ -f "$TRANSCRIPT" ]; then
    ok "transcript file exists ($(wc -l < "$TRANSCRIPT" | tr -d ' ') lines)"
    if grep -q 'HANDOFF_COMPLETE' "$TRANSCRIPT"; then
        ok "transcript contains HANDOFF_COMPLETE marker"
    else
        fail "transcript does not contain HANDOFF_COMPLETE marker"
    fi
    # Sanity check: did Claude actually authenticate + verify the Elnora CLI?
    # Match the auth/verification commands from INSTALL_FOR_AGENTS.md (steps 4-7).
    # We grep for any of: `elnora whoami`, `elnora doctor`, or `elnora auth login`
    # so the test fails if Claude only ran `elnora --version` and skipped the
    # actual auth check.
    if grep -qE 'elnora (whoami|doctor|auth (login|status))' "$TRANSCRIPT"; then
        ok "transcript shows Claude invoked an elnora auth/verification command"
    else
        fail "transcript shows no elnora auth/verification command (whoami|doctor|auth login|auth status)"
    fi
else
    fail "transcript file not found at $TRANSCRIPT"
fi

# --- Summary ---
echo ""
echo "==========================================="
echo "  Result: $PASS passed, $FAIL failed"
echo "==========================================="
if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "Failures:"
    for m in "${FAIL_MSGS[@]}"; do
        echo "  - $m"
    done
    exit 1
fi
exit 0
