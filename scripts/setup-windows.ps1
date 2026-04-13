# ============================================================
# Claude Code Setup — Windows
# ============================================================
# This script installs everything you need to use Claude Code.
# Run it from PowerShell (as Administrator):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\setup-windows.ps1
# ============================================================

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Claude Code Setup for Windows" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# --- Check for winget ---
$hasWinget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $hasWinget) {
    Write-Host "[WARNING] winget not found. Please install it from the Microsoft Store (App Installer)." -ForegroundColor Yellow
    Write-Host "          https://apps.microsoft.com/detail/9nblggh4nns1" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter after installing winget to continue, or Ctrl+C to exit"
}

# --- Install Node.js ---
$hasNode = Get-Command node -ErrorAction SilentlyContinue
if (-not $hasNode) {
    Write-Host "[1/6] Installing Node.js..." -ForegroundColor Green
    winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
    Write-Host "  Done. You may need to restart PowerShell for 'node' to be available." -ForegroundColor Yellow
} else {
    Write-Host "[1/6] Node.js already installed: $(node --version). Skipping." -ForegroundColor Gray
}

# --- Install Git ---
$hasGit = Get-Command git -ErrorAction SilentlyContinue
if (-not $hasGit) {
    Write-Host "[2/6] Installing Git..." -ForegroundColor Green
    winget install Git.Git --accept-package-agreements --accept-source-agreements
    Write-Host "  Done. You may need to restart PowerShell for 'git' to be available." -ForegroundColor Yellow
} else {
    Write-Host "[2/6] Git already installed: $(git --version). Skipping." -ForegroundColor Gray
}

# --- Install Python ---
$hasPython = Get-Command python -ErrorAction SilentlyContinue
if (-not $hasPython) {
    Write-Host "[3/6] Installing Python 3.12..." -ForegroundColor Green
    winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements
    Write-Host "  Done. You may need to restart PowerShell for 'python' to be available." -ForegroundColor Yellow
} else {
    Write-Host "[3/6] Python already installed: $(python --version). Skipping." -ForegroundColor Gray
}

# --- Install VS Code ---
$hasCode = Get-Command code -ErrorAction SilentlyContinue
if (-not $hasCode) {
    Write-Host "[4/6] Installing VS Code..." -ForegroundColor Green
    winget install Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
    Write-Host "  Done." -ForegroundColor Yellow
} else {
    Write-Host "[4/6] VS Code already installed. Skipping." -ForegroundColor Gray
}

# --- Install Claude Code ---
Write-Host "[5/6] Installing Claude Code..." -ForegroundColor Green
Write-Host "  Running the official Claude Code installer..." -ForegroundColor Gray
$installCmd = "curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd"
cmd /c $installCmd
Write-Host "  Done." -ForegroundColor Yellow

# --- Install Obsidian (optional) ---
$hasObsidian = Get-Command obsidian -ErrorAction SilentlyContinue
if (-not $hasObsidian) {
    Write-Host "[6/6] Installing Obsidian (optional — for knowledge base)..." -ForegroundColor Green
    winget install Obsidian.Obsidian --accept-package-agreements --accept-source-agreements
    Write-Host "  Done." -ForegroundColor Yellow
} else {
    Write-Host "[6/6] Obsidian already installed. Skipping." -ForegroundColor Gray
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Setup complete!" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  IMPORTANT: Restart PowerShell (or VS Code) for PATH changes to take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Then verify everything works:" -ForegroundColor White
Write-Host "    node --version" -ForegroundColor Gray
Write-Host "    git --version" -ForegroundColor Gray
Write-Host "    python --version" -ForegroundColor Gray
Write-Host "    claude --version" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Restart PowerShell or VS Code"
Write-Host "  2. Open VS Code:           code ."
Write-Host "  3. Start Claude Code:      claude"
Write-Host "  4. Log in when prompted (opens browser)"
Write-Host "  5. Connect GitHub:         type /install-github-app in Claude"
Write-Host ""
