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

# --- Elnora CLI auth ---
# The CLI persists credentials to ~/.elnora/profiles.toml via
# `elnora auth login --api-key …`. Verify Claude actually authenticated
# the CLI (not just wrote a useless .env file — the CLI doesn't read .env).
Write-Host "[elnora auth]"
$profilesPath = Join-Path $env:USERPROFILE ".elnora\profiles.toml"
if (Test-Path $profilesPath) {
    Assert-Ok "$profilesPath exists"
    $profilesContent = Get-Content $profilesPath -Raw
    if ($profilesContent -match '(?m)^api_key = "elnora_live_') {
        Assert-Ok "profiles.toml contains api_key = elnora_live_*"
    } else {
        Assert-Fail "profiles.toml missing api_key = `"elnora_live_*`" line"
    }
} else {
    Assert-Fail "$profilesPath was not created (Claude did not run 'elnora auth login --api-key …')"
}
elnora auth status > $null 2>&1
if ($LASTEXITCODE -eq 0) {
    Assert-Ok "elnora auth status returns success"
} else {
    Assert-Fail "elnora auth status failed (CLI is not authenticated)"
}
$global:LASTEXITCODE = 0

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
    # Match the auth/verification commands from INSTALL_FOR_AGENTS.md (steps 4-7).
    # `elnora --version` alone is not enough — it doesn't prove auth works.
    if ($transcriptText -match 'elnora\s+(whoami|doctor|auth\s+(login|status))') {
        Assert-Ok "transcript shows Claude invoked an elnora auth/verification command"
    } else {
        Assert-Fail "transcript shows no elnora auth/verification command (whoami|doctor|auth login|auth status)"
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
