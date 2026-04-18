# ============================================================
# Claude Code Setup — Windows
# ============================================================
# Installs everything from the AI Agent Workshop Installation Guide.
# Run from PowerShell:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\setup-windows.ps1
#
# Error handling: the script CONTINUES on failure. Each step is
# isolated — if one install fails (network, winget glitch, broken
# manifest, etc.), remaining steps still run, and a summary of
# failures is printed at the end.
# ============================================================

# Non-terminating errors don't stop the script (this is the PS default,
# but being explicit for clarity).
$ErrorActionPreference = "Continue"

$FailedSteps = New-Object System.Collections.ArrayList

function Update-SessionPath {
    # Reload PATH from the registry so this session sees binaries added by a
    # just-run installer. Without this, `winget install Git.Git` succeeds but
    # `Get-Command git` still fails until the user restarts PowerShell —
    # which would make the git-config block (and the verify summary) wrong.
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user    = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $parts   = @()
    if ($machine) { $parts += $machine }
    if ($user)    { $parts += $user }
    # Claude Code installer writes to %USERPROFILE%\.local\bin — ensure it's present.
    $claudeBin = Join-Path $env:USERPROFILE ".local\bin"
    if ((Test-Path $claudeBin) -and ($parts -notcontains $claudeBin)) {
        $parts += $claudeBin
    }
    $env:Path = ($parts -join ";")
}

function Invoke-Step {
    # Runs a scriptblock, catches any exception or non-zero exit code,
    # records the failure, and continues.
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][scriptblock]$Action
    )
    try {
        & $Action
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
            Write-Host "  [!] $Label failed (exit $LASTEXITCODE) — continuing." -ForegroundColor Red
            [void]$FailedSteps.Add($Label)
            $global:LASTEXITCODE = 0
        }
    } catch {
        Write-Host "  [!] $Label failed: $($_.Exception.Message) — continuing." -ForegroundColor Red
        [void]$FailedSteps.Add($Label)
    }
}

function Test-RealPython {
    # Windows ships with a Microsoft Store "app execution alias" for `python` —
    # a 0-byte stub at %LOCALAPPDATA%\Microsoft\WindowsApps\python.exe that opens
    # the Store instead of running Python. Get-Command returns true for the stub,
    # so we have to actually invoke it and check the output.
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) { return $false }
    try {
        $version = (& python --version 2>&1 | Select-Object -First 1)
        return ($version -match '^Python 3\.\d+\.\d+')
    } catch {
        return $false
    }
}

function Remove-PythonStoreAlias {
    # Deletes the 0-byte Store stub so real Python (installed via winget) wins
    # PATH lookup. We only delete if the file is actually a 0-byte stub — never
    # touch a real python.exe.
    $stub = "$env:LOCALAPPDATA\Microsoft\WindowsApps\python.exe"
    if ((Test-Path $stub) -and ((Get-Item $stub -ErrorAction SilentlyContinue).Length -eq 0)) {
        try {
            Remove-Item $stub -Force -ErrorAction Stop
            Write-Host "  Removed Python Store alias stub." -ForegroundColor Yellow
            return $true
        } catch {
            return $false
        }
    }
    return $false
}

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
    Invoke-Step "Node.js" { winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements }
    Update-SessionPath
} else {
    Write-Host "[1/8] Node.js already installed: $(node --version). Skipping." -ForegroundColor Gray
}

# --- [2/8] Git + user config ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[2/8] Installing Git..." -ForegroundColor Green
    Invoke-Step "Git" { winget install Git.Git --accept-package-agreements --accept-source-agreements }
    Update-SessionPath
} else {
    Write-Host "[2/8] Git already installed: $(git --version). Skipping." -ForegroundColor Gray
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    try {
        $gitName  = git config --global user.name
        $gitEmail = git config --global user.email
        if (-not $gitName)  { $gitName  = Read-Host "  Enter your full name for git commits"; if ($gitName)  { git config --global user.name  "$gitName" } }
        if (-not $gitEmail) { $gitEmail = Read-Host "  Enter your email for git commits";     if ($gitEmail) { git config --global user.email "$gitEmail" } }
        Write-Host "  git user: $(git config --global user.name) <$(git config --global user.email)>" -ForegroundColor Gray
        $defBranch = git config --global init.defaultBranch
        if (-not $defBranch) { git config --global init.defaultBranch main; Write-Host "  git init.defaultBranch: main" -ForegroundColor Gray }
    } catch {
        Write-Host "  [!] Git configuration step hit an error: $($_.Exception.Message) — continuing." -ForegroundColor Red
        [void]$FailedSteps.Add("Git config")
    }
} else {
    Write-Host "  [!] git not available — skipping git config." -ForegroundColor Red
}

# --- [3/8] Python 3.12 ---
# Test-RealPython rejects the Microsoft Store stub alias — Get-Command alone
# would return a false positive on a fresh Windows laptop.
if (-not (Test-RealPython)) {
    Write-Host "[3/8] Installing Python 3.12..." -ForegroundColor Green
    # Remove the Store stub BEFORE install so winget's install doesn't get shadowed.
    [void](Remove-PythonStoreAlias)
    Invoke-Step "Python 3.12" { winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements }
    Update-SessionPath
    # After install, if the Store stub is still intercepting (winget added a new
    # one, or PATH order is wrong), remove it and refresh PATH once more.
    if (-not (Test-RealPython)) {
        if (Remove-PythonStoreAlias) {
            Update-SessionPath
        }
        if (-not (Test-RealPython)) {
            Write-Host "  [!] Python install completed but `python` still doesn't resolve to real Python." -ForegroundColor Red
            Write-Host "      Disable the Store alias manually: Settings -> Apps -> Advanced app settings -> App execution aliases -> turn off 'python.exe'." -ForegroundColor Red
            [void]$FailedSteps.Add("Python 3.12 (PATH/alias issue)")
        }
    }
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
    Invoke-Step "VS Code" { winget install Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements }
    Update-SessionPath
} else {
    Write-Host "[4/8] VS Code already installed. Skipping." -ForegroundColor Gray
}

# --- [5/8] Claude Code CLI ---
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "[5/8] Installing Claude Code..." -ForegroundColor Green
    Invoke-Step "Claude Code" { irm https://claude.ai/install.ps1 | iex }
    Update-SessionPath

    # The Anthropic installer writes claude.exe to %USERPROFILE%\.local\bin and
    # updates User PATH via setx. On corporate laptops, Group Policy can silently
    # revert User PATH changes — user opens a new terminal, claude is gone.
    # Detect this and fall back to copying claude.exe into WindowsApps (already
    # in default user PATH on Win10/11, and immune to Group Policy PATH reverts).
    $claudeBinDir = Join-Path $env:USERPROFILE ".local\bin"
    $claudeExe    = Join-Path $claudeBinDir "claude.exe"
    $userPath     = [Environment]::GetEnvironmentVariable("Path", "User")
    if ((Test-Path $claudeExe) -and ($userPath -notlike "*$claudeBinDir*")) {
        Write-Host "  [!] User PATH did not persist `.local\bin` — Group Policy may be reverting." -ForegroundColor Yellow
        $windowsApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
        if (Test-Path $windowsApps) {
            try {
                Copy-Item $claudeExe (Join-Path $windowsApps "claude.exe") -Force -ErrorAction Stop
                Write-Host "  Copied claude.exe to $windowsApps (in default user PATH)." -ForegroundColor Green
                Write-Host "  Note: this copy will not auto-update. Re-run this script to refresh after Anthropic releases." -ForegroundColor Gray
            } catch {
                Write-Host "  [!] Fallback copy to WindowsApps failed: $($_.Exception.Message)" -ForegroundColor Red
                [void]$FailedSteps.Add("Claude Code PATH")
            }
        }
    }
} else {
    Write-Host "[5/8] Claude Code already installed: $(claude --version). Skipping." -ForegroundColor Gray
}

# --- [6/8] GitHub CLI ---
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[6/8] Installing GitHub CLI..." -ForegroundColor Green
    Invoke-Step "GitHub CLI" { winget install --id GitHub.cli --accept-package-agreements --accept-source-agreements }
    Update-SessionPath
} else {
    Write-Host "[6/8] GitHub CLI already installed: $(gh --version | Select-Object -First 1). Skipping." -ForegroundColor Gray
}

# --- [7/8] Obsidian (optional — knowledge base) ---
$obsidianPaths = @(
    "$env:LOCALAPPDATA\Obsidian\Obsidian.exe",
    "$env:LOCALAPPDATA\Programs\Obsidian\Obsidian.exe",
    "$env:APPDATA\Obsidian\Obsidian.exe",
    "$env:ProgramFiles\Obsidian\Obsidian.exe",
    "${env:ProgramFiles(x86)}\Obsidian\Obsidian.exe"
)
$obsidianInstalled = [bool]($obsidianPaths | Where-Object { Test-Path $_ } | Select-Object -First 1)
if (-not $obsidianInstalled) {
    # Fall back to winget — catches installs in non-standard locations.
    $wingetHas = winget list --id Obsidian.Obsidian --exact 2>$null | Select-String "Obsidian.Obsidian"
    if ($wingetHas) { $obsidianInstalled = $true }
}
if (-not $obsidianInstalled) {
    Write-Host "[7/8] Installing Obsidian (optional)..." -ForegroundColor Green
    Invoke-Step "Obsidian" { winget install Obsidian.Obsidian --accept-package-agreements --accept-source-agreements }
    Update-SessionPath
} else {
    Write-Host "[7/8] Obsidian already installed. Skipping." -ForegroundColor Gray
}

# --- [8/8] Projects folder ---
$projectsDir = "$env:USERPROFILE\Documents\Projects"
if (-not (Test-Path $projectsDir)) {
    Write-Host "[8/8] Creating Projects folder at $projectsDir..." -ForegroundColor Green
    try {
        New-Item -ItemType Directory -Path $projectsDir -ErrorAction Stop | Out-Null
        Write-Host "  Done." -ForegroundColor Yellow
    } catch {
        Write-Host "  [!] Could not create $projectsDir : $($_.Exception.Message) — continuing." -ForegroundColor Red
        [void]$FailedSteps.Add("Projects folder")
    }
} else {
    Write-Host "[8/8] Projects folder already exists. Skipping." -ForegroundColor Gray
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Setup complete!" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""
Update-SessionPath

function Get-ToolVersion {
    param([string]$Name, [string]$VersionArg = "--version")
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) { return "not found" }
    try {
        $out = & $Name $VersionArg 2>$null | Select-Object -First 1
        if ($out) { return $out } else { return "installed" }
    } catch {
        return "installed"
    }
}

function Get-AppInstalled {
    param([string]$Path, [string]$Label)
    if (Test-Path $Path) {
        try {
            $v = (Get-Item $Path).VersionInfo.ProductVersion
            if ($v) { return "installed ($v)" } else { return "installed" }
        } catch { return "installed" }
    } else {
        return "not found"
    }
}

Write-Host "  Node.js:     $(Get-ToolVersion 'node')" -ForegroundColor White
Write-Host "  Git:         $(Get-ToolVersion 'git')" -ForegroundColor White
Write-Host "  Python:      $(Get-ToolVersion 'python')" -ForegroundColor White

$vscodeExe = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
    "$env:ProgramFiles\Microsoft VS Code\Code.exe",
    "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($vscodeExe) {
    Write-Host "  VS Code:     $(Get-AppInstalled $vscodeExe 'VS Code')" -ForegroundColor White
} else {
    Write-Host "  VS Code:     $(Get-ToolVersion 'code')" -ForegroundColor White
}

Write-Host "  Claude Code: $(Get-ToolVersion 'claude')" -ForegroundColor White
Write-Host "  GitHub CLI:  $(Get-ToolVersion 'gh')" -ForegroundColor White
$obsidianExe = @(
    "$env:LOCALAPPDATA\Obsidian\Obsidian.exe",
    "$env:LOCALAPPDATA\Programs\Obsidian\Obsidian.exe",
    "$env:APPDATA\Obsidian\Obsidian.exe",
    "$env:ProgramFiles\Obsidian\Obsidian.exe",
    "${env:ProgramFiles(x86)}\Obsidian\Obsidian.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($obsidianExe) {
    Write-Host "  Obsidian:    $(Get-AppInstalled $obsidianExe 'Obsidian')" -ForegroundColor White
} else {
    $wingetHas = winget list --id Obsidian.Obsidian --exact 2>$null | Select-String "Obsidian.Obsidian"
    if ($wingetHas) {
        Write-Host "  Obsidian:    installed (winget)" -ForegroundColor White
    } else {
        Write-Host "  Obsidian:    not found" -ForegroundColor White
    }
}
Write-Host ""
Write-Host "  Note: if anything shows 'not found' above, open a new PowerShell/VS Code window and re-check." -ForegroundColor Gray
Write-Host ""

if ($FailedSteps.Count -gt 0) {
    Write-Host "-------------------------------------------" -ForegroundColor Yellow
    Write-Host "  ⚠  $($FailedSteps.Count) step(s) failed:" -ForegroundColor Yellow
    foreach ($step in $FailedSteps) {
        Write-Host "     - $step" -ForegroundColor Yellow
    }
    Write-Host "  Re-run this script to retry, or install the failed items manually." -ForegroundColor Yellow
    Write-Host "-------------------------------------------" -ForegroundColor Yellow
    Write-Host ""
}

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

# Exit 0 even if some steps failed — summary above tells the user what to fix.
exit 0
