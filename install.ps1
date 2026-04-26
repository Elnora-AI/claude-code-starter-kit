# ============================================================
# Elnora Starter Kit — One-liner Installer (Windows)
# ============================================================
# Usage (PowerShell):
#   irm https://raw.githubusercontent.com/Elnora-AI/elnora-starter-kit/main/install.ps1 | iex
#
# Downloads the starter kit zip (no git required), extracts it to
# %USERPROFILE%\Documents\elnora-starter-kit, and runs setup-windows.ps1.
# ============================================================

$ErrorActionPreference = "Stop"

# Force TLS 1.2 for the Invoke-WebRequest below. Windows PowerShell 5.1 (the
# default on Win10/11) defaults to SSL3/TLS 1.0 on older unpatched builds;
# GitHub's CDN (codeload.github.com) rejects that handshake and the zip
# download fails with an opaque "underlying connection was closed" error
# before we reach setup-windows.ps1. Mirrors the same fix that setup-windows.ps1
# applies to its installer sub-processes.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepoOwner = "Elnora-AI"
$RepoName  = "elnora-starter-kit"
$Branch    = "main"
$TargetDir = Join-Path $env:USERPROFILE "Documents\$RepoName"

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Elnora Starter Kit - Bootstrap" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will:"
Write-Host "  1. Download the starter kit to $TargetDir"
Write-Host "  2. Run setup-windows.ps1 (installs Claude Code + dev tools)"
Write-Host ""

if (Test-Path $TargetDir) {
    Write-Host "Starter kit already exists at $TargetDir" -ForegroundColor Gray
    Write-Host "Re-running setup from existing copy. Remove the folder to re-download." -ForegroundColor Gray
} else {
    Write-Host "Downloading starter kit zip..." -ForegroundColor Green
    $zipUrl  = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/$Branch.zip"
    $zipPath = Join-Path $env:TEMP "$RepoName-bootstrap.zip"
    $tmpExtractDir = Join-Path $env:TEMP "$RepoName-bootstrap"

    try {
        # Retry up to 3 times on flaky networks (hotel / conference wifi).
        # -TimeoutSec caps the whole request; retries cover transient DNS/TLS
        # hiccups that return immediately instead of hanging.
        $maxAttempts = 3
        for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
            try {
                Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing -TimeoutSec 300
                break
            } catch {
                if ($attempt -eq $maxAttempts) { throw }
                Write-Host "  Download attempt $attempt failed: $($_.Exception.Message). Retrying in 2s..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
        if (Test-Path $tmpExtractDir) { Remove-Item $tmpExtractDir -Recurse -Force }
        Expand-Archive -Path $zipPath -DestinationPath $tmpExtractDir -Force

        $extracted = Join-Path $tmpExtractDir "$RepoName-$Branch"
        if (-not (Test-Path $extracted)) {
            throw "Expected folder not found after extract: $extracted"
        }

        New-Item -ItemType Directory -Path (Split-Path $TargetDir -Parent) -Force -ErrorAction SilentlyContinue | Out-Null
        Move-Item -Path $extracted -Destination $TargetDir -Force
        Write-Host "Extracted to $TargetDir" -ForegroundColor Green
    } catch {
        Write-Host "[!] Failed to download starter kit from $zipUrl" -ForegroundColor Red
        Write-Host "    Reason: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "    Check your internet connection and retry:" -ForegroundColor Red
        Write-Host "      irm https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/install.ps1 | iex" -ForegroundColor Red
        # `throw` instead of `exit 1`: this script is invoked via `irm ... | iex`,
        # which runs in the caller's scope. `exit` would terminate the caller's
        # shell/parent script silently; `throw` surfaces as a catchable error and
        # still halts this installer if uncaught. Same reasoning as Bug 2 in the
        # elnora-cli handoff doc.
        throw "Starter kit bootstrap: failed to download from $zipUrl ($($_.Exception.Message))"
    } finally {
        if (Test-Path $zipPath)       { Remove-Item $zipPath -Force -ErrorAction SilentlyContinue }
        if (Test-Path $tmpExtractDir) { Remove-Item $tmpExtractDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

Set-Location $TargetDir
# Bypass execution policy for this process only so setup-windows.ps1 runs
# without requiring the user to set it manually (as the older flow did).
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Write-Host ""
& .\setup-windows.ps1
