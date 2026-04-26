# ============================================================
# Claude Code Setup - Windows
# ============================================================
# Installs a complete Claude Code development environment:
# Claude Code CLI, Elnora CLI, Node.js, Git, Python, VS Code,
# GitHub CLI, and Obsidian.
#
# Run from PowerShell:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\setup-windows.ps1
#
# Error handling: the script CONTINUES on failure. Each step is
# isolated - if one install fails (network, winget glitch, broken
# manifest, etc.), remaining steps still run. On any failure you
# get a structured FAILURE box with the exit code, last 10 lines
# of captured output, and a remediation hint. At the end of the
# run a recap block prints remediation for each failed step.
# ============================================================

# Non-terminating errors don't stop the script (this is the PS default,
# but being explicit for clarity).
$ErrorActionPreference = "Continue"

# Default-on logging. Start-Transcript captures all Write-Host, Write-Error,
# AND native command output (winget, git, etc.) in PS 5.1+. Overwrites on each
# run - re-runs are idempotent, so keeping old logs around isn't useful.
$LogFile = Join-Path $env:USERPROFILE "claude-starter-install.log"
try { Start-Transcript -Path $LogFile -Force | Out-Null } catch { }

$FailedSteps = New-Object System.Collections.ArrayList

function Update-SessionPath {
    # Reload PATH from the registry so this session sees binaries added by a
    # just-run installer. Without this, `winget install Git.Git` succeeds but
    # `Get-Command git` still fails until the user restarts PowerShell -
    # which would make the git-config block (and the verify summary) wrong.
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user    = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $parts   = @()
    if ($machine) { $parts += $machine }
    if ($user)    { $parts += $user }
    # Claude Code installer writes to %USERPROFILE%\.local\bin - ensure it's present.
    $claudeBin = Join-Path $env:USERPROFILE ".local\bin"
    if ((Test-Path $claudeBin) -and ($parts -notcontains $claudeBin)) {
        $parts += $claudeBin
    }
    # Elnora CLI installer writes to %USERPROFILE%\.elnora\bin - ensure it's present.
    $elnoraBin = Join-Path $env:USERPROFILE ".elnora\bin"
    if ((Test-Path $elnoraBin) -and ($parts -notcontains $elnoraBin)) {
        $parts += $elnoraBin
    }
    $env:Path = ($parts -join ";")
}

# ------------------------------------------------------------
# Get-RemediationHint -Label "<step label>"
# ------------------------------------------------------------
# Returns a multi-line, step-specific remediation message. Used by
# Write-StepFailure (immediate failure context) AND by the end-of-run
# recap (so the user gets a full punch list of what to do next).
# Matched via -like wildcards so "Python 3.12 (PATH/alias issue)" still
# hits the Python branch.
function Get-RemediationHint {
    param([string]$Label)
    if ($Label -like "winget*") {
        return @'
winget ships with the "App Installer" package on Windows 10 (build 1809+)
and Windows 11. If it's missing:
  1. Open Microsoft Store
  2. Search for "App Installer" OR go to:
       https://apps.microsoft.com/detail/9nblggh4nns1
  3. Click Install
  4. Reopen PowerShell and re-run this script
If the Store is blocked by your org's policy:
  - Download the .msixbundle directly from
      https://github.com/microsoft/winget-cli/releases
    and install via: Add-AppxPackage <path-to-bundle>
  - Or use Chocolatey (https://chocolatey.org) / Scoop (https://scoop.sh)
    to install these tools instead.
'@
    }
    elseif ($Label -like "Node.js*") {
        return @'
Try manually:
  winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
Or download the installer:
  https://nodejs.org/en/download
Verify in a NEW PowerShell window:
  node --version    # should print vXX.X.X
  npm --version
If `node` still isn't found after a new terminal, your PATH didn't update -
check: Get-Command node  and:  $env:Path -split ';' | Select-String node
'@
    }
    elseif ($Label -like "Git*" -and $Label -notlike "Git config*") {
        return @'
Try manually:
  winget install Git.Git --accept-package-agreements --accept-source-agreements
Or download the installer:
  https://git-scm.com/download/win
Verify in a NEW PowerShell window:
  git --version
'@
    }
    elseif ($Label -like "Git config*") {
        return @'
Set the values manually:
  git config --global user.name  "Your Full Name"
  git config --global user.email "you@example.com"
  git config --global init.defaultBranch main
Verify all three at once:
  git config --global --list | Select-String -Pattern 'user\.|init\.'
'@
    }
    elseif ($Label -like "Python*") {
        return @'
Try manually:
  winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements
Or download the installer:
  https://www.python.org/downloads/windows/
If the Microsoft Store keeps intercepting `python`:
  1. Settings -> Apps -> Advanced app settings -> App execution aliases
  2. Turn OFF BOTH `python.exe` and `python3.exe`
  3. Reopen PowerShell and run:  python --version
Verify:
  python --version   # should print "Python 3.x.x" - NOT open the Store
If `python` still opens the Store but real Python is installed, use the
`py` launcher instead (lives at C:\Windows\py.exe, always available):
  py --version
  py -m pip install <pkg>
'@
    }
    elseif ($Label -like "VS Code*") {
        return @'
Try manually:
  winget install Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
Or download the installer:
  https://code.visualstudio.com/download
Verify by reopening PowerShell and running:
  code --version
If `code` command isn't found but VS Code is installed: add its bin dir
to PATH manually (usually $env:LOCALAPPDATA\Programs\Microsoft VS Code\bin).
'@
    }
    elseif ($Label -like "Claude Code*") {
        return @'
Try manually:
  irm https://claude.ai/install.ps1 | iex
Or install via npm (requires Node.js):
  npm install -g @anthropic-ai/claude-code
If PowerShell blocks the install script with an execution policy error:
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  irm https://claude.ai/install.ps1 | iex
If your PATH keeps reverting (corporate laptop / Group Policy), copy
the exe into WindowsApps which is always in default user PATH:
  Copy-Item "$env:USERPROFILE\.local\bin\claude.exe" `
            "$env:LOCALAPPDATA\Microsoft\WindowsApps\claude.exe" -Force
Docs: https://docs.claude.com/en/docs/claude-code/overview
Verify in a NEW PowerShell window:
  claude --version
'@
    }
    elseif ($Label -like "Elnora CLI*") {
        return @'
Try manually:
  irm https://cli.elnora.ai/install.ps1 | iex
npm fallback (requires Node.js, installed later in this script):
  npm install -g @elnora-ai/cli
If PowerShell blocks the install script with an execution policy error:
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  irm https://cli.elnora.ai/install.ps1 | iex
The installer writes elnora.exe to %USERPROFILE%\.elnora\bin and updates
User PATH. If PATH reverted (corporate Group Policy), copy the exe into
WindowsApps (always on default user PATH):
  Copy-Item "$env:USERPROFILE\.elnora\bin\elnora.exe" `
            "$env:LOCALAPPDATA\Microsoft\WindowsApps\elnora.exe" -Force
Docs: https://cli.elnora.ai
Verify in a NEW PowerShell window:
  elnora --version
'@
    }
    elseif ($Label -like "GitHub CLI*") {
        return @'
Try manually:
  winget install --id GitHub.cli --accept-package-agreements --accept-source-agreements
Or download the installer:
  https://cli.github.com/
Verify in a NEW PowerShell window:
  gh --version
Then authenticate:
  gh auth login        # choose GitHub.com, HTTPS, then browser login
If PATH didn't persist, copy gh.exe to WindowsApps:
  Copy-Item "$env:ProgramFiles\GitHub CLI\gh.exe" `
            "$env:LOCALAPPDATA\Microsoft\WindowsApps\gh.exe" -Force
'@
    }
    elseif ($Label -like "Obsidian*") {
        return @'
Try manually:
  winget install Obsidian.Obsidian --accept-package-agreements --accept-source-agreements
Or download the installer:
  https://obsidian.md/download
This step is OPTIONAL - you can skip it if you don't plan to use a
knowledge base. Nothing else in this setup depends on Obsidian.
'@
    }
    elseif ($Label -like "Projects folder*") {
        return @'
Try manually:
  New-Item -ItemType Directory "$env:USERPROFILE\Documents\Projects"
If that fails, check your Documents folder exists and is writable:
  Get-Item "$env:USERPROFILE\Documents"
  (Get-Acl "$env:USERPROFILE\Documents").Access | Where-Object { $_.IdentityReference -like "*$env:USERNAME*" }
Common causes: OneDrive "Known Folder Move" has relocated Documents to
a synced folder that's temporarily offline, or a corporate policy has
made Documents read-only. In that case, pick a different parent folder:
  New-Item -ItemType Directory "$env:USERPROFILE\Projects"
'@
    }
    else {
        return "No specific remediation available - scroll up to see the captured output."
    }
}

# ------------------------------------------------------------
# Write-StepFailure -Label "..." -ExitCode N [-Command "..."] [-ErrorOutput "..."]
# ------------------------------------------------------------
# Prints a structured FAILURE box with the exit code, the command,
# the last 10 lines of captured output, and a step-specific remediation hint.
function Write-StepFailure {
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][int]$ExitCode,
        [string]$Command = "",
        [string]$ErrorOutput = ""
    )
    Write-Host ""
    Write-Host "  +-- FAILURE: $Label" -ForegroundColor Red
    Write-Host "  |   Exit code: $ExitCode" -ForegroundColor Red
    if ($Command) {
        Write-Host "  |   Command:   $Command" -ForegroundColor Red
    }
    if ($ErrorOutput) {
        $lines = ($ErrorOutput -split "`r?`n") | Where-Object { $_.Trim() } | Select-Object -Last 10
        if ($lines) {
            Write-Host "  |" -ForegroundColor Red
            Write-Host "  |   Captured output (last 10 lines):" -ForegroundColor Red
            foreach ($line in $lines) {
                Write-Host "  |     $line" -ForegroundColor DarkGray
            }
        }
    }
    Write-Host "  |" -ForegroundColor Red
    Write-Host "  |   What to do:" -ForegroundColor Yellow
    $hint = Get-RemediationHint -Label $Label
    foreach ($line in ($hint -split "`r?`n")) {
        Write-Host "  |     $line" -ForegroundColor Yellow
    }
    Write-Host "  +-----------------------------------------------------------" -ForegroundColor Red
    Write-Host ""
}

function Invoke-Step {
    # Runs a scriptblock. On failure (exception or non-zero $LASTEXITCODE)
    # prints a structured FAILURE box and records the step for the end-of-run
    # recap.
    #
    # Captures stdout+stderr (via 2>&1) into a buffer while still echoing each
    # line live, so the FAILURE box can quote the last 10 lines of output.
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][scriptblock]$Action
    )
    $commandText = ($Action.ToString().Trim() -replace '\s+', ' ')
    $buffer = New-Object System.Text.StringBuilder
    try {
        & $Action 2>&1 | ForEach-Object {
            $line = $_.ToString()
            [void]$buffer.AppendLine($line)
            Write-Host $line
        }
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
            Write-StepFailure -Label $Label -ExitCode $LASTEXITCODE `
                -Command $commandText -ErrorOutput $buffer.ToString()
            [void]$FailedSteps.Add("$Label (exit $LASTEXITCODE)")
            $global:LASTEXITCODE = 0
        }
    } catch {
        [void]$buffer.AppendLine($_.Exception.Message)
        Write-StepFailure -Label $Label -ExitCode -1 `
            -Command $commandText -ErrorOutput $buffer.ToString()
        [void]$FailedSteps.Add("$Label ($($_.Exception.Message))")
    }
}

function Test-RealPython {
    # Windows ships with a Microsoft Store "app execution alias" for `python` -
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
    # PATH lookup. We only delete if the file is actually a 0-byte stub - never
    # touch a real python.exe.
    $stub = "$env:LOCALAPPDATA\Microsoft\WindowsApps\python.exe"
    if (-not (Test-Path $stub)) { return $false }
    $stubItem = Get-Item $stub -ErrorAction SilentlyContinue
    if (-not $stubItem -or $stubItem.Length -ne 0) { return $false }
    try {
        Remove-Item $stub -Force -ErrorAction Stop
        Write-Host "  Removed Python Store alias stub at $stub" -ForegroundColor Yellow
        return $true
    } catch {
        Write-Host "  [!] Could not remove Python Store alias stub at $stub" -ForegroundColor Red
        Write-Host "      Reason: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "      Disable it manually instead: Settings -> Apps -> Advanced app settings" -ForegroundColor Red
        Write-Host "      -> App execution aliases -> turn OFF 'python.exe' and 'python3.exe'." -ForegroundColor Red
        return $false
    }
}

function Copy-StandaloneExeToWindowsApps {
    # Copies a self-contained .exe into %LOCALAPPDATA%\Microsoft\WindowsApps -
    # always in the default user PATH on Win10/11 and immune to Group Policy
    # PATH reverts. Only safe for single-binary tools (Go binaries like gh.exe,
    # bundled binaries like claude.exe). Do NOT use for Python - python.exe
    # depends on neighbouring DLLs that won't travel with the copy.
    param(
        [Parameter(Mandatory)][string]$ExePath,
        [Parameter(Mandatory)][string]$ToolName
    )
    if (-not (Test-Path $ExePath)) {
        Write-Host "  [!] Source exe not found at $ExePath - cannot copy." -ForegroundColor Red
        return $false
    }
    $windowsApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    if (-not (Test-Path $windowsApps)) {
        Write-Host "  [!] WindowsApps folder not found at $windowsApps - unusual for Win10/11." -ForegroundColor Red
        Write-Host "      You can add $((Split-Path $ExePath -Parent)) to your User PATH manually:" -ForegroundColor Red
        Write-Host "        [Environment]::SetEnvironmentVariable('Path', `"`$env:Path;$((Split-Path $ExePath -Parent))`", 'User')" -ForegroundColor Red
        return $false
    }
    try {
        Copy-Item $ExePath (Join-Path $windowsApps "$ToolName.exe") -Force -ErrorAction Stop
        Write-Host "  Copied $ToolName.exe to WindowsApps (GP-immune PATH fallback)." -ForegroundColor Green
        Write-Host "  Note: this copy will not auto-update - re-run the script after upstream releases." -ForegroundColor Gray
        return $true
    } catch {
        Write-Host "  [!] Fallback copy for $ToolName failed:" -ForegroundColor Red
        Write-Host "      Source:      $ExePath" -ForegroundColor Red
        Write-Host "      Destination: $(Join-Path $windowsApps "$ToolName.exe")" -ForegroundColor Red
        Write-Host "      Reason:      $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "      This usually means antivirus is blocking the copy, or WindowsApps" -ForegroundColor Red
        Write-Host "      is locked down by Group Policy. Try running PowerShell as Administrator" -ForegroundColor Red
        Write-Host "      and re-run, or add $(Split-Path $ExePath -Parent) to PATH manually." -ForegroundColor Red
        return $false
    }
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Claude Code Setup for Windows" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Log: $LogFile" -ForegroundColor Gray
Write-Host ""

# --- Check for winget ---
$hasWinget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $hasWinget) {
    Write-Host ""
    Write-Host "  +-- PREREQUISITE: winget not found" -ForegroundColor Yellow
    Write-Host "  |" -ForegroundColor Yellow
    Write-Host "  |   winget is the Windows package manager used by this script to" -ForegroundColor Yellow
    Write-Host "  |   install Node.js, Python, VS Code, GitHub CLI, and Obsidian." -ForegroundColor Yellow
    Write-Host "  |" -ForegroundColor Yellow
    Write-Host "  |   What to do:" -ForegroundColor Yellow
    foreach ($line in ((Get-RemediationHint -Label "winget") -split "`r?`n")) {
        Write-Host "  |     $line" -ForegroundColor Yellow
    }
    Write-Host "  +-----------------------------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter AFTER installing winget (script will retry), or Ctrl+C to exit"
    # Re-check; if still missing, most steps will fail but we let them run so
    # the user sees the full picture and can take action on any that use direct
    # installers (Claude Code uses irm|iex, not winget).
    $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $hasWinget) {
        Write-Host "  [!] winget still not found - winget-based steps will fail below." -ForegroundColor Red
        [void]$FailedSteps.Add("winget (prerequisite missing)")
    }
}

# --- [1/9] Claude Code CLI (installed FIRST - zero dependencies) ---
# Using Anthropic's native installer so Claude Code is the very first thing on
# the machine. Works even when winget is missing (unlike the rest of the tools
# below). Writes a self-contained binary to %USERPROFILE%\.local\bin\claude.exe.
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "[1/9] Installing Claude Code..." -ForegroundColor Green
    Write-Host "  Using Anthropic's native installer (no prerequisites required)." -ForegroundColor Gray
    # Run the installer in a child powershell.exe. `iex` evaluates its input in
    # caller scope, so an `exit N` inside the fetched installer would terminate
    # setup-windows.ps1 itself - skipping every later step and the end-of-run
    # recap. The sub-process contains `exit`, propagates the exit code back via
    # $LASTEXITCODE for Invoke-Step to detect, and isolates any
    # $ErrorActionPreference changes made by the installer.
    #
    # The leading SecurityProtocol assignment forces TLS 1.2. powershell.exe =
    # Windows PowerShell 5.1, which on older/unpatched Windows 10 builds
    # defaults to SSL3/TLS 1.0. Modern CDNs (claude.ai, cli.elnora.ai) reject
    # that handshake and `irm` fails with an opaque "underlying connection was
    # closed" error the FAILURE box can't explain.
    Invoke-Step "Claude Code" { powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm https://claude.ai/install.ps1 | iex" }
    Update-SessionPath

    # The Anthropic installer writes claude.exe to %USERPROFILE%\.local\bin and
    # updates User PATH via setx. Corporate Group Policy can silently revert
    # User PATH - user opens a new terminal, claude is gone. Detect and fall
    # back to WindowsApps (default user PATH, GP-immune).
    $claudeBinDir = Join-Path $env:USERPROFILE ".local\bin"
    $claudeExe    = Join-Path $claudeBinDir "claude.exe"
    if (-not (Test-Path $claudeExe)) {
        # Installer reported success but the binary isn't on disk. If Invoke-Step
        # already logged a non-zero exit, skip to avoid duplicate entries in the
        # recap - the existing failure already routes to the right remediation.
        $alreadyLogged = @($FailedSteps | Where-Object { $_ -like "Claude Code*" }).Count -gt 0
        if (-not $alreadyLogged) {
            Write-Host "  [!] Installer completed but claude.exe is missing at $claudeExe." -ForegroundColor Red
            [void]$FailedSteps.Add("Claude Code (binary not found after install)")
        }
    } else {
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$claudeBinDir*") {
            Write-Host "  [!] User PATH did not persist '.local\bin' - Group Policy may be reverting." -ForegroundColor Yellow
            Write-Host "      Attempting fallback: copy claude.exe to WindowsApps (always on default user PATH)." -ForegroundColor Yellow
            if (-not (Copy-StandaloneExeToWindowsApps -ExePath $claudeExe -ToolName "claude")) {
                [void]$FailedSteps.Add("Claude Code PATH")
            }
        }
    }
} else {
    Write-Host "[1/9] Claude Code already installed: $(claude --version). Skipping." -ForegroundColor Gray
}

# --- [2/9] Elnora CLI (installed SECOND - also zero dependencies) ---
# Elnora's installer downloads a pre-built binary to %USERPROFILE%\.elnora\bin
# and updates User PATH. No winget/Node required. "AI surfaces first,
# toolchain second" mirrors the macOS script.
# We always install the LATEST release so users get current bug fixes and
# features. To keep the upgrade path tight, we re-run the installer even
# when `elnora` is already on PATH - Elnora's installer is idempotent and a
# no-op when the existing binary already matches the latest release.
#
# Escape hatch: set $env:ELNORA_CLI_VERSION (e.g. "v1.5.0") to pin to a
# specific release. Useful behind a corporate NAT where many machines share
# an IP and can exhaust GitHub's 60/hr unauthenticated rate limit on
# api.github.com/repos/.../releases/latest. Workshop hosts on shared wifi
# may want to set this in the environment before kicking off the install.
if ($env:ELNORA_CLI_VERSION) {
    $elnoraCliVersion = $env:ELNORA_CLI_VERSION
    $elnoraInstallLabel = "$elnoraCliVersion (pinned via ELNORA_CLI_VERSION)"
} else {
    $elnoraCliVersion = ""
    $elnoraInstallLabel = "latest"
}

# Build the installer invocation. Passing an empty -Version arg lets the
# installer fall through to its default (latest GitHub release).
$elnoraInstallerCommand = if ($elnoraCliVersion) {
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; & ([scriptblock]::Create((Invoke-RestMethod 'https://cli.elnora.ai/install.ps1'))) -Version '$elnoraCliVersion'"
} else {
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; & ([scriptblock]::Create((Invoke-RestMethod 'https://cli.elnora.ai/install.ps1')))"
}

$elnoraIsInstalled = [bool](Get-Command elnora -ErrorAction SilentlyContinue)
if (-not $elnoraIsInstalled) {
    Write-Host "[2/9] Installing Elnora CLI ($elnoraInstallLabel)..." -ForegroundColor Green
    Write-Host "  Using Elnora's native installer (no prerequisites required)." -ForegroundColor Gray
    # Sub-process isolation: see matching comment in the Claude Code block above.
    # The Elnora installer has 8 `exit 1` paths (GitHub API failure, 404 on
    # ARM64 Windows since no win-arm64 asset is published, AV-blocked copy,
    # etc.) - without the sub-process, any one of them would kill
    # setup-windows.ps1 mid-run.
    # Leading SecurityProtocol assignment forces TLS 1.2 on PS 5.1 - see the
    # Claude Code block above for the full reasoning.
    # The scriptblock-create dance is needed to pass -Version to the installer.
    # iex evaluates a string in caller scope and ignores trailing -Version
    # because iex itself has no such param; converting to a scriptblock first
    # honors the installer's `param([string]$Version)` declaration.
    #
    # Use Invoke-RestMethod (not Invoke-WebRequest). IRM auto-decodes text
    # responses to a string. IWR returns a `Response.Content` that is a byte[]
    # for some content types (including what cli.elnora.ai serves install.ps1
    # as), and `[scriptblock]::Create($byteArray)` then chokes trying to parse
    # decimal byte values like "35 32 69 108..." as PowerShell syntax.
    Invoke-Step "Elnora CLI" { powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $elnoraInstallerCommand }
    Update-SessionPath

    # Same Group Policy fallback as Claude Code - copy the exe into WindowsApps
    # if User PATH didn't pick up .elnora\bin.
    $elnoraBinDir = Join-Path $env:USERPROFILE ".elnora\bin"
    $elnoraExe    = Join-Path $elnoraBinDir "elnora.exe"
    if (-not (Test-Path $elnoraExe)) {
        $alreadyLogged = @($FailedSteps | Where-Object { $_ -like "Elnora CLI*" }).Count -gt 0
        if (-not $alreadyLogged) {
            Write-Host "  [!] Installer completed but elnora.exe is missing at $elnoraExe." -ForegroundColor Red
            [void]$FailedSteps.Add("Elnora CLI (binary not found after install)")
        }
    } else {
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$elnoraBinDir*") {
            Write-Host "  [!] User PATH did not persist '.elnora\bin' - Group Policy may be reverting." -ForegroundColor Yellow
            Write-Host "      Attempting fallback: copy elnora.exe to WindowsApps (always on default user PATH)." -ForegroundColor Yellow
            if (-not (Copy-StandaloneExeToWindowsApps -ExePath $elnoraExe -ToolName "elnora")) {
                [void]$FailedSteps.Add("Elnora CLI PATH")
            }
        }
    }
    Write-Host "  Next: run 'elnora auth login' after setup to authenticate (browser OAuth)." -ForegroundColor Gray
} else {
    $currentElnoraVersion = (& elnora --version 2>$null)
    if (-not $currentElnoraVersion) { $currentElnoraVersion = "unknown" }
    Write-Host "[2/9] Elnora CLI already installed ($currentElnoraVersion) - refreshing to $elnoraInstallLabel..." -ForegroundColor Green
    Invoke-Step "Elnora CLI upgrade" { powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $elnoraInstallerCommand }
    Update-SessionPath
}

# --- [3/9] Node.js ---
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[3/9] Installing Node.js..." -ForegroundColor Green
    Invoke-Step "Node.js" { winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements }
    Update-SessionPath
} else {
    Write-Host "[3/9] Node.js already installed: $(node --version). Skipping." -ForegroundColor Gray
}

# --- [4/9] Git + user config ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[4/9] Installing Git..." -ForegroundColor Green
    Invoke-Step "Git" { winget install Git.Git --accept-package-agreements --accept-source-agreements }
    Update-SessionPath
} else {
    Write-Host "[4/9] Git already installed: $(git --version). Skipping." -ForegroundColor Gray
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    try {
        $gitName  = git config --global user.name
        $gitEmail = git config --global user.email
        # `git config --global <key>` exits 1 when the key is unset. Reset
        # $LASTEXITCODE so the stale 1 doesn't bleed into Invoke-Step's
        # success check for a subsequent scriptblock that doesn't itself
        # set $LASTEXITCODE (pure PS cmdlets don't update it).
        $global:LASTEXITCODE = 0
        if (-not $gitName) {
            $gitName = Read-Host "  Enter your full name for git commits"
            if ($gitName) {
                git config --global user.name "$gitName"
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "  [!] 'git config --global user.name' failed (exit $LASTEXITCODE)." -ForegroundColor Red
                    Write-Host "      Run manually: git config --global user.name `"$gitName`"" -ForegroundColor Red
                    [void]$FailedSteps.Add("Git config (user.name)")
                    $global:LASTEXITCODE = 0
                }
            }
        }
        if (-not $gitEmail) {
            $gitEmail = Read-Host "  Enter your email for git commits"
            if ($gitEmail) {
                git config --global user.email "$gitEmail"
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "  [!] 'git config --global user.email' failed (exit $LASTEXITCODE)." -ForegroundColor Red
                    Write-Host "      Run manually: git config --global user.email `"$gitEmail`"" -ForegroundColor Red
                    [void]$FailedSteps.Add("Git config (user.email)")
                    $global:LASTEXITCODE = 0
                }
            }
        }
        Write-Host "  git user: $(git config --global user.name) <$(git config --global user.email)>" -ForegroundColor Gray
        $defBranch = git config --global init.defaultBranch
        if (-not $defBranch) { git config --global init.defaultBranch main; Write-Host "  git init.defaultBranch: main" -ForegroundColor Gray }
    } catch {
        Write-StepFailure -Label "Git config" -ExitCode -1 `
            -Command "git config --global ..." -ErrorOutput $_.Exception.Message
        [void]$FailedSteps.Add("Git config ($($_.Exception.Message))")
    }
} else {
    Write-Host "  [!] git not available - skipping git config." -ForegroundColor Red
    Write-Host "      See the Git remediation in the recap at the end of this run." -ForegroundColor Red
}

# --- [5/9] Python 3.12 ---
# Test-RealPython rejects the Microsoft Store stub alias - Get-Command alone
# would return a false positive on a fresh Windows laptop.
if (-not (Test-RealPython)) {
    Write-Host "[5/9] Installing Python 3.12..." -ForegroundColor Green
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
            # Python isn't a single binary - it depends on neighbouring DLLs -
            # so we can't use the WindowsApps copy trick. Tell the user how to
            # fix PATH manually, and point them at the py launcher as a fallback
            # (py.exe lives in C:\Windows and is always on Machine PATH).
            Write-Host ""
            Write-Host "  +-- FAILURE: Python 3.12 (PATH/alias issue)" -ForegroundColor Red
            Write-Host "  |   winget reported success, but 'python' still doesn't resolve" -ForegroundColor Red
            Write-Host "  |   to real Python in this shell." -ForegroundColor Red
            $pyCandidate = "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe"
            if (Test-Path $pyCandidate) {
                Write-Host "  |" -ForegroundColor Red
                Write-Host "  |   Real Python is at:  $pyCandidate" -ForegroundColor Red
            }
            $pyLauncher = "C:\Windows\py.exe"
            if (Test-Path $pyLauncher) {
                Write-Host "  |   Py launcher is at:  $pyLauncher  (always on PATH)" -ForegroundColor Red
            }
            Write-Host "  |" -ForegroundColor Red
            Write-Host "  |   What to do:" -ForegroundColor Yellow
            foreach ($line in ((Get-RemediationHint -Label "Python 3.12") -split "`r?`n")) {
                Write-Host "  |     $line" -ForegroundColor Yellow
            }
            Write-Host "  +-----------------------------------------------------------" -ForegroundColor Red
            Write-Host ""
            [void]$FailedSteps.Add("Python 3.12 (PATH/alias issue)")
        }
    }
} else {
    Write-Host "[5/9] Python already installed: $(python --version). Skipping." -ForegroundColor Gray
}

# --- [6/9] VS Code ---
$codePaths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
    "$env:ProgramFiles\Microsoft VS Code\Code.exe",
    "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
)
$codeInstalled = (Get-Command code -ErrorAction SilentlyContinue) -or ($codePaths | Where-Object { Test-Path $_ } | Select-Object -First 1)
if ($env:ELNORA_SKIP_OPTIONAL_INSTALLS -eq "1") {
    # CI/test escape hatch: skip optional editor on environments where winget
    # isn't available (windows-2022/2025 GitHub Actions runners). Used by
    # .github/workflows/install-smoke-test.yml so the smoke test validates
    # the core path (Claude Code + Elnora CLI + Group Policy fallback)
    # without false-positive FAILUREs for components that need winget on a
    # Server SKU. Real Win10/11 attendees never set this variable.
    Write-Host "[6/9] VS Code: ELNORA_SKIP_OPTIONAL_INSTALLS=1 - skipping for non-interactive run." -ForegroundColor Gray
} elseif (-not $codeInstalled) {
    Write-Host "[6/9] Installing VS Code..." -ForegroundColor Green
    Invoke-Step "VS Code" { winget install Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements }
    Update-SessionPath
} else {
    Write-Host "[6/9] VS Code already installed. Skipping." -ForegroundColor Gray
}

# --- [7/9] GitHub CLI ---
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[7/9] Installing GitHub CLI..." -ForegroundColor Green
    Invoke-Step "GitHub CLI" { winget install --id GitHub.cli --accept-package-agreements --accept-source-agreements }
    Update-SessionPath

    # gh is a standalone Go binary - safe to copy to WindowsApps as a PATH
    # fallback if the User/Machine PATH update didn't stick (GP, or new session
    # env not refreshed in time).
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        $ghCandidates = @(
            "$env:ProgramFiles\GitHub CLI\gh.exe",
            "${env:ProgramFiles(x86)}\GitHub CLI\gh.exe",
            "$env:LOCALAPPDATA\Programs\GitHub CLI\gh.exe"
        )
        $ghExe = $ghCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
        if ($ghExe) {
            Write-Host "  [!] gh installed to $ghExe but not on PATH - applying WindowsApps fallback." -ForegroundColor Yellow
            if (-not (Copy-StandaloneExeToWindowsApps -ExePath $ghExe -ToolName "gh")) {
                [void]$FailedSteps.Add("GitHub CLI PATH")
            }
        } else {
            Write-Host "  [!] gh reported installed by winget but not found in the usual locations." -ForegroundColor Red
            Write-Host "      Check with: winget list --id GitHub.cli --exact" -ForegroundColor Red
            Write-Host "      Or reinstall: winget install --id GitHub.cli" -ForegroundColor Red
            [void]$FailedSteps.Add("GitHub CLI (binary not found after install)")
        }
    }
} else {
    Write-Host "[7/9] GitHub CLI already installed: $(gh --version | Select-Object -First 1). Skipping." -ForegroundColor Gray
}

# --- [8/9] Obsidian (optional - knowledge base) ---
$obsidianPaths = @(
    "$env:LOCALAPPDATA\Obsidian\Obsidian.exe",
    "$env:LOCALAPPDATA\Programs\Obsidian\Obsidian.exe",
    "$env:APPDATA\Obsidian\Obsidian.exe",
    "$env:ProgramFiles\Obsidian\Obsidian.exe",
    "${env:ProgramFiles(x86)}\Obsidian\Obsidian.exe"
)
$obsidianInstalled = [bool]($obsidianPaths | Where-Object { Test-Path $_ } | Select-Object -First 1)
if (-not $obsidianInstalled -and $hasWinget) {
    # Fall back to winget - catches installs in non-standard locations. Gated
    # on $hasWinget so that on machines without winget (some Win10 builds, the
    # GitHub Actions windows-2022 runner), this doesn't surface a raw "term not
    # recognized" error to stderr and confuse the user.
    $wingetHas = winget list --id Obsidian.Obsidian --exact 2>$null | Select-String "Obsidian.Obsidian"
    if ($wingetHas) { $obsidianInstalled = $true }
}
if ($env:ELNORA_SKIP_OPTIONAL_INSTALLS -eq "1") {
    # See matching comment on the VS Code step above.
    Write-Host "[8/9] Obsidian: ELNORA_SKIP_OPTIONAL_INSTALLS=1 - skipping for non-interactive run." -ForegroundColor Gray
} elseif (-not $obsidianInstalled) {
    Write-Host "[8/9] Installing Obsidian (optional)..." -ForegroundColor Green
    Invoke-Step "Obsidian" { winget install Obsidian.Obsidian --accept-package-agreements --accept-source-agreements }
    Update-SessionPath
} else {
    Write-Host "[8/9] Obsidian already installed. Skipping." -ForegroundColor Gray
}

# --- [9/9] Projects folder ---
$projectsDir = "$env:USERPROFILE\Documents\Projects"
if (-not (Test-Path $projectsDir)) {
    Write-Host "[9/9] Creating Projects folder at $projectsDir..." -ForegroundColor Green
    try {
        New-Item -ItemType Directory -Path $projectsDir -ErrorAction Stop | Out-Null
        Write-Host "  Done." -ForegroundColor Yellow
    } catch {
        Write-StepFailure -Label "Projects folder" -ExitCode -1 `
            -Command "New-Item -ItemType Directory -Path $projectsDir" `
            -ErrorOutput $_.Exception.Message
        [void]$FailedSteps.Add("Projects folder")
    }
} else {
    Write-Host "[9/9] Projects folder already exists. Skipping." -ForegroundColor Gray
}

Write-Host ""
Write-Host "==========================================="
Write-Host "  Install summary"
Write-Host "==========================================="
Write-Host ""
Update-SessionPath

# Force UTF-8 output so the unicode check / cross marks render. PS 5.1 defaults
# to OEM codepage which mangles them - without this, ✓ shows as garbled bytes
# in the very summary row that's supposed to scream "all good".
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

function Get-ToolVersion {
    param([string]$Name, [string]$VersionArg = "--version")
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) { return "" }
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
        return ""
    }
}

# Write-Status "<label>" "<version-or-empty>"
# Empty / "not found" version => red [X] NOT INSTALLED
# Anything else                => green [OK] <version>
function Write-Status {
    param([string]$Label, [string]$Version)
    $padded = ($Label + ":").PadRight(13)
    if (-not $Version -or $Version -eq "not found") {
        Write-Host "  " -NoNewline
        Write-Host ([char]0x2717) -ForegroundColor Red -NoNewline   # ✗
        Write-Host " $padded " -NoNewline
        Write-Host "NOT INSTALLED" -ForegroundColor Red
    } else {
        Write-Host "  " -NoNewline
        Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline  # ✓
        Write-Host " $padded " -NoNewline
        Write-Host $Version -ForegroundColor Green
    }
}

# Compute every tool's version up-front so the summary AND the headline use the
# same data. Storing in an ordered dict keeps output order stable.
$results = [ordered]@{}
$results["Node.js"]     = Get-ToolVersion 'node'
$results["Git"]         = Get-ToolVersion 'git'
$results["Python"]      = Get-ToolVersion 'python'

$vscodeExe = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
    "$env:ProgramFiles\Microsoft VS Code\Code.exe",
    "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($vscodeExe) {
    $results["VS Code"] = Get-AppInstalled $vscodeExe 'VS Code'
} else {
    $results["VS Code"] = Get-ToolVersion 'code'
}

$results["Claude Code"] = Get-ToolVersion 'claude'
$results["Elnora CLI"]  = Get-ToolVersion 'elnora'
$results["GitHub CLI"]  = Get-ToolVersion 'gh'

$obsidianExe = @(
    "$env:LOCALAPPDATA\Obsidian\Obsidian.exe",
    "$env:LOCALAPPDATA\Programs\Obsidian\Obsidian.exe",
    "$env:APPDATA\Obsidian\Obsidian.exe",
    "$env:ProgramFiles\Obsidian\Obsidian.exe",
    "${env:ProgramFiles(x86)}\Obsidian\Obsidian.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($obsidianExe) {
    $results["Obsidian"] = Get-AppInstalled $obsidianExe 'Obsidian'
} else {
    $wingetHas = $null
    if ($hasWinget) {
        $wingetHas = winget list --id Obsidian.Obsidian --exact 2>$null | Select-String "Obsidian.Obsidian"
    }
    if ($wingetHas) {
        $results["Obsidian"] = "installed (winget)"
    } else {
        $results["Obsidian"] = ""
    }
}

foreach ($key in $results.Keys) {
    Write-Status $key $results[$key]
}

$missing = @($results.GetEnumerator() | Where-Object { -not $_.Value -or $_.Value -eq "not found" }).Count
$total   = $results.Count
Write-Host ""
if ($missing -eq 0) {
    Write-Host "  All $total components installed." -ForegroundColor Green
} else {
    Write-Host "  $missing component(s) NOT installed - see red X rows above and remediation below." -ForegroundColor Red
    Write-Host "  If something says NOT INSTALLED but you think it is, open a new PowerShell/VS Code window and re-check."
}
Write-Host ""
Write-Host "-------------------------------------------"
Write-Host "  IMPORTANT - to see the new PATH in VS Code:"
Write-Host "  Quit VS Code FULLY (File -> Exit), then reopen it."
Write-Host "  Closing just the terminal panel is not enough -"
Write-Host "  VS Code caches its PATH at app launch time."
Write-Host "-------------------------------------------"
Write-Host ""

if ($FailedSteps.Count -gt 0) {
    Write-Host "==========================================="
    Write-Host "  $($FailedSteps.Count) step(s) failed - remediation below"
    Write-Host "==========================================="
    foreach ($stepEntry in $FailedSteps) {
        # Strip trailing "(exit N)" / "(message)" to recover the bare label for lookup.
        $stepLabel = ($stepEntry -replace '\s*\([^)]*\)\s*$', '').Trim()
        if (-not $stepLabel) { $stepLabel = $stepEntry }
        Write-Host ""
        Write-Host "-- $stepEntry --"
        $hint = Get-RemediationHint -Label $stepLabel
        foreach ($line in ($hint -split "`r?`n")) {
            Write-Host "  $line"
        }
    }
    Write-Host ""
    Write-Host "Once you've fixed the issue(s), re-run:  .\setup-windows.ps1"
    Write-Host "The script is idempotent - already-installed steps are skipped."
    Write-Host "==========================================="
    Write-Host ""
}

Write-Host "==========================================="
Write-Host "  Phase 1 complete - handing off to Claude"
Write-Host "==========================================="
Write-Host ""

# CI integration: propagate the script's accumulated PATH to $env:GITHUB_PATH
# so subsequent workflow steps (handoff-e2e assertions, install-smoke-test
# verifications, bootstrap-e2e checks) see every binary Phase 1 installed.
# Without this, a fresh pwsh in the next step inherits the runner's job-
# start PATH snapshot, which doesn't include %USERPROFILE%\.local\bin
# (Claude), %USERPROFILE%\.elnora\bin, or anything winget added after job
# start. Update-SessionPath fixed this for the current process; this fixes
# it for downstream steps. No-op outside GH Actions (variable unset).
if ($env:GITHUB_PATH) {
    foreach ($dir in ($env:Path -split ';')) {
        if ($dir) { Add-Content -Path $env:GITHUB_PATH -Value $dir }
    }
    Write-Host "  (CI: propagated PATH to `$GITHUB_PATH for downstream steps)"
}

# Close the transcript before handing off, so the log file is flushed and
# Claude can read it as part of Phase 2.
try { Stop-Transcript | Out-Null } catch { }

# The exact prompt handed to Claude. Defined once so the headless test mode
# below uses byte-for-byte the same string as the production handoff -
# divergence here is the bug headless mode is supposed to catch.
$HandoffPrompt = "Phase 1 of the Elnora Starter Kit install just completed. Please read INSTALL_FOR_AGENTS.md in this directory and finish Phase 2 setup. The Phase 1 install log is at $env:USERPROFILE\claude-starter-install.log."

$claudeAvailable = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeAvailable) {
    if ($env:ELNORA_SKIP_HANDOFF -eq "1") {
        # CI/test escape hatch: print what would happen and exit cleanly. Used
        # by .github/workflows/install-smoke-test.yml so the smoke test doesn't
        # hang on Claude trying to open a browser for first-run auth.
        Write-Host "ELNORA_SKIP_HANDOFF=1 set - would invoke claude with the Phase 2 prompt. Skipping for non-interactive run." -ForegroundColor Gray
        exit 0
    }

    if ($env:ELNORA_HANDOFF_MODE -eq "headless") {
        # Headless E2E test mode. Used by .github/workflows/handoff-e2e.yml so
        # we can verify what Claude actually does after the handoff, not just
        # that the handoff fired. Same prompt, same cwd as production - only
        # the I/O wrapper changes (one-shot print mode + bypassPermissions
        # because nobody's there to approve tool calls).
        #
        # Requires ANTHROPIC_API_KEY in env so claude skips browser OAuth.
        # Pre-staged ELNORA_API_KEY in env lets Claude skip the "ask user
        # for the API key" step in INSTALL_FOR_AGENTS.md (the doc handles
        # that branch explicitly).
        $transcript = if ($env:ELNORA_HANDOFF_TRANSCRIPT) { $env:ELNORA_HANDOFF_TRANSCRIPT } else { Join-Path $env:USERPROFILE "handoff-transcript.jsonl" }
        Write-Host "ELNORA_HANDOFF_MODE=headless - running claude -p (transcript: $transcript)" -ForegroundColor Cyan
        # --verbose is REQUIRED with -p --output-format=stream-json (Claude Code
        # rejects the combo otherwise). --max-turns 50 caps a runaway loop;
        # Phase 2 should fit comfortably under 30 turns.
        & claude -p $HandoffPrompt `
            --permission-mode bypassPermissions `
            --output-format stream-json `
            --verbose `
            --max-turns 50 `
          | Tee-Object -FilePath $transcript
        $rc = $LASTEXITCODE
        Write-Host ""
        Write-Host "claude -p exited with code $rc (transcript saved to $transcript)" -ForegroundColor Cyan
        exit $rc
    }

    Write-Host "Starting Claude - it will read INSTALL_FOR_AGENTS.md and finish setup." -ForegroundColor White
    Write-Host "On first run, your browser will open to log into your Claude Pro/Max account." -ForegroundColor White
    Write-Host ""
    # PowerShell has no `exec` - call claude as a child process and let it own
    # the terminal until it exits. Then the script exits cleanly.
    & claude $HandoffPrompt
    exit 0
}

# Fallback: claude not on PATH (install of Claude Code itself failed) - show
# the manual continuation path so the user can recover after fixing the issue.
Write-Host "  ! 'claude' command not found - Claude Code install may have failed." -ForegroundColor Yellow
Write-Host ""
Write-Host "  See the remediation hints above. Once you've fixed it, re-run:" -ForegroundColor White
Write-Host "      .\setup-windows.ps1"
Write-Host ""
Write-Host "  Or continue manually:" -ForegroundColor White
Write-Host "      cd $(Get-Location)"
Write-Host "      claude"
Write-Host "      Then say: 'Read INSTALL_FOR_AGENTS.md and finish setup.'"
Write-Host ""

# Exit 0 even if some steps failed - the remediation recap above tells the user
# exactly what to do, and a non-zero exit would trip callers (e.g. IDE terminals
# that highlight failures) in ways that can hide the remediation text.
exit 0
