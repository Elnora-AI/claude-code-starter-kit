# ============================================================
# Handoff E2E — post-state assertions (Windows)
# ============================================================
# Run AFTER the headless handoff completes. Verifies on disk
# that Claude actually did the Phase 2 work — independent of
# what the transcript says.
#
# Usage:
#   .\tests\handoff\assert.ps1 <repo-dir> <transcript-path>
#
# Exits 0 if all assertions pass, 1 if any fail.
# ============================================================

param(
    [string]$RepoDir = $PWD,
    [string]$Transcript = (Join-Path $env:USERPROFILE "handoff-transcript.jsonl")
)

$ErrorActionPreference = "Continue"

$Pass = 0
$Fail = 0
$FailMsgs = New-Object System.Collections.ArrayList

function Assert-Ok {
    param([string]$Msg)
    Write-Host "  [OK] $Msg" -ForegroundColor Green
    $script:Pass++
}
function Assert-Fail {
    param([string]$Msg)
    Write-Host "  [FAIL] $Msg" -ForegroundColor Red
    $script:Fail++
    [void]$script:FailMsgs.Add($Msg)
}

Set-Location $RepoDir

Write-Host "==========================================="
Write-Host "  Handoff E2E assertions"
Write-Host "==========================================="
Write-Host "  Repo:       $RepoDir"
Write-Host "  Transcript: $Transcript"
Write-Host ""

# --- .env file ---
Write-Host "[.env]"
if (Test-Path .env) {
    Assert-Ok ".env exists"
    # On Windows we don't enforce mode 600 — INSTALL_FOR_AGENTS.md tells
    # Claude to skip chmod on Windows since .gitignore protects it.
    $envContent = Get-Content .env -Raw
    if ($envContent -match '(?m)^ELNORA_API_KEY=elnora_live_') {
        Assert-Ok ".env contains ELNORA_API_KEY=elnora_live_*"
    } else {
        Assert-Fail ".env missing ELNORA_API_KEY=elnora_live_* line"
    }
} else {
    Assert-Fail ".env was not created"
}

# --- git repo ---
Write-Host ""
Write-Host "[git]"
if (Test-Path .git) {
    Assert-Ok ".git directory exists"
    $upstream = git remote get-url elnora-upstream 2>$null
    if ($LASTEXITCODE -eq 0 -and $upstream) {
        Assert-Ok "elnora-upstream remote is set ($upstream)"
    } else {
        Assert-Fail "elnora-upstream remote was not configured"
    }
    $global:LASTEXITCODE = 0
} else {
    Assert-Fail ".git directory was not created"
}

# --- Knowledge base config ---
Write-Host ""
Write-Host "[knowledge base]"
$kbPath = ".claude/knowledge-base.local.md"
if (Test-Path $kbPath) {
    Assert-Ok "$kbPath exists"
    $kbContent = Get-Content $kbPath -Raw
    if ($kbContent -match '<ABSOLUTE_PATH_TO_YOUR_VAULT>') {
        Assert-Fail "$kbPath still contains <ABSOLUTE_PATH_TO_YOUR_VAULT> placeholder"
    } else {
        Assert-Ok "$kbPath placeholder was replaced"
    }
} else {
    Assert-Fail "$kbPath was not created"
}

# --- CLAUDE.md self-cleanup ---
Write-Host ""
Write-Host "[CLAUDE.md self-cleanup]"
$claudeMd = Get-Content CLAUDE.md -Raw
if ($claudeMd -match '### First-run setup') {
    Assert-Fail "CLAUDE.md still contains '### First-run setup' block (should have self-deleted)"
} else {
    Assert-Ok "CLAUDE.md '### First-run setup' block was removed"
}

# --- HANDOFF_COMPLETE marker in transcript ---
Write-Host ""
Write-Host "[transcript]"
if (Test-Path $Transcript) {
    $lineCount = (Get-Content $Transcript | Measure-Object -Line).Lines
    Assert-Ok "transcript file exists ($lineCount lines)"
    $transcriptText = Get-Content $Transcript -Raw
    if ($transcriptText -match 'HANDOFF_COMPLETE') {
        Assert-Ok "transcript contains HANDOFF_COMPLETE marker"
    } else {
        Assert-Fail "transcript does not contain HANDOFF_COMPLETE marker"
    }
    if ($transcriptText -match 'elnora\s+(auth\s+whoami|protocol|--version)') {
        Assert-Ok "transcript shows Claude invoked the elnora CLI"
    } else {
        Assert-Fail "transcript shows no elnora CLI invocation"
    }
} else {
    Assert-Fail "transcript file not found at $Transcript"
}

# --- Summary ---
Write-Host ""
Write-Host "==========================================="
Write-Host "  Result: $Pass passed, $Fail failed"
Write-Host "==========================================="
if ($Fail -gt 0) {
    Write-Host ""
    Write-Host "Failures:"
    foreach ($m in $FailMsgs) {
        Write-Host "  - $m"
    }
    exit 1
}
exit 0
