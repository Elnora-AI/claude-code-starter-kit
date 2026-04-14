# ============================================================
# Claude Code Setup — Windows
# ============================================================
# Installs everything from the AI Agent Workshop Installation Guide.
# Run from PowerShell:
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
    Write-Host "[WARNING] winget not found. Install 'App Installer' from the Microsoft Store:" -ForegroundColor Yellow
    Write-Host "          https://apps.microsoft.com/detail/9nblggh4nns1" -ForegroundColor Yellow
    Read-Host "Press Enter after installing winget, or Ctrl+C to exit"
}

# --- [1/8] Node.js ---
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[1/8] Installing Node.js..." -ForegroundColor Green
    winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
    Write-Host "  Done. Restart PowerShell for 'node' to be on PATH." -ForegroundColor Yellow
} else {
    Write-Host "[1/8] Node.js already installed: $(node --version). Skipping." -ForegroundColor Gray
}

# --- [2/8] Git + user config ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[2/8] Installing Git..." -ForegroundColor Green
    winget install Git.Git --accept-package-agreements --accept-source-agreements
    Write-Host "  Done. Restart PowerShell for 'git' to be on PATH." -ForegroundColor Yellow
} else {
    Write-Host "[2/8] Git already installed: $(git --version). Skipping." -ForegroundColor Gray
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitName  = git config --global user.name
    $gitEmail = git config --global user.email
    if (-not $gitName)  { $gitName  = Read-Host "  Enter your full name for git commits"; git config --global user.name  "$gitName" }
    if (-not $gitEmail) { $gitEmail = Read-Host "  Enter your email for git commits";     git config --global user.email "$gitEmail" }
    Write-Host "  git user: $(git config --global user.name) <$(git config --global user.email)>" -ForegroundColor Gray
}

# --- [3/8] Python 3.12 ---
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "[3/8] Installing Python 3.12..." -ForegroundColor Green
    winget install Python.Python.3.12 --version 3.12.10 --accept-package-agreements --accept-source-agreements
    Write-Host "  Done. Restart PowerShell for 'python' to be on PATH." -ForegroundColor Yellow
} else {
    Write-Host "[3/8] Python already installed: $(python --version). Skipping." -ForegroundColor Gray
}

# --- [4/8] VS Code ---
$codePaths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
    "$env:ProgramFiles\Microsoft VS Code\Code.exe",
    "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
)
$codeInstalled = (Get-Command code -ErrorAction SilentlyContinue) -or ($codePaths | Where-Object { Test-Path $_ } | Select-Object -First 1)
if (-not $codeInstalled) {
    Write-Host "[4/8] Installing VS Code..." -ForegroundColor Green
    winget install Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
    Write-Host "  Done." -ForegroundColor Yellow
} else {
    Write-Host "[4/8] VS Code already installed. Skipping." -ForegroundColor Gray
}

# --- [5/8] Claude Code CLI ---
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "[5/8] Installing Claude Code..." -ForegroundColor Green
    irm https://claude.ai/install.ps1 | iex
    Write-Host "  If 'claude' is not found after this, add %USERPROFILE%\.local\bin to PATH and restart VS Code." -ForegroundColor Yellow
} else {
    Write-Host "[5/8] Claude Code already installed: $(claude --version). Skipping." -ForegroundColor Gray
}

# --- [6/8] GitHub CLI ---
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[6/8] Installing GitHub CLI..." -ForegroundColor Green
    winget install --id GitHub.cli --accept-package-agreements --accept-source-agreements
    Write-Host "  Done. Restart PowerShell for 'gh' to be on PATH." -ForegroundColor Yellow
} else {
    Write-Host "[6/8] GitHub CLI already installed: $(gh --version | Select-Object -First 1). Skipping." -ForegroundColor Gray
}

# --- [7/8] Obsidian (optional — knowledge base) ---
$obsidianPath = "$env:LOCALAPPDATA\Obsidian\Obsidian.exe"
if (-not (Test-Path $obsidianPath)) {
    Write-Host "[7/8] Installing Obsidian (optional)..." -ForegroundColor Green
    winget install Obsidian.Obsidian --accept-package-agreements --accept-source-agreements
    Write-Host "  Done." -ForegroundColor Yellow
} else {
    Write-Host "[7/8] Obsidian already installed. Skipping." -ForegroundColor Gray
}

# --- [8/8] Projects folder ---
$projectsDir = "$env:USERPROFILE\Documents\Projects"
if (-not (Test-Path $projectsDir)) {
    Write-Host "[8/8] Creating Projects folder at $projectsDir..." -ForegroundColor Green
    New-Item -ItemType Directory -Path $projectsDir | Out-Null
    Write-Host "  Done." -ForegroundColor Yellow
} else {
    Write-Host "[8/8] Projects folder already exists. Skipping." -ForegroundColor Gray
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Setup complete!" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  IMPORTANT: Restart PowerShell (or VS Code) so PATH changes take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Verify:" -ForegroundColor White
Write-Host "    node --version" -ForegroundColor Gray
Write-Host "    git --version" -ForegroundColor Gray
Write-Host "    python --version" -ForegroundColor Gray
Write-Host "    claude --version" -ForegroundColor Gray
Write-Host "    gh --version" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps (interactive — these need your browser/input):" -ForegroundColor White
Write-Host "  1. Authenticate Claude Code:  claude          (log in, then /exit)"
Write-Host "  2. Authenticate GitHub CLI:   gh auth login   (GitHub.com -> HTTPS -> browser)"
Write-Host "  3. Create your workshop repo:"
Write-Host "       cd `$env:USERPROFILE\Documents\Projects"
Write-Host "       gh repo create my-workshop-project --private --add-readme --clone"
Write-Host "       cd my-workshop-project; code ."
Write-Host "  4. In VS Code terminal:  claude   then   /install-github-app"
Write-Host "  5. Copy starter kit into your repo:"
Write-Host "       git clone https://github.com/Elnora-AI/claude-code-starter-kit.git temp-starter"
Write-Host "       robocopy temp-starter . /E /XD .git"
Write-Host "       Remove-Item temp-starter -Recurse -Force"
Write-Host "  6. (Optional) Create an Obsidian vault inside your OneDrive\knowledge-base folder."
Write-Host ""
