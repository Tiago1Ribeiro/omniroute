#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Start OmniRoute server persistently in background
.DESCRIPTION
    Keeps OmniRoute running. If it crashes, restarts automatically.
    Run this once and leave the window open.
#>

$ErrorActionPreference = "Stop"

# Use script root as working directory (works from any laptop)
$scriptRoot = $PSScriptRoot ? $PSScriptRoot : (Get-Location).Path

# Load .env if present
$envFile = Join-Path $scriptRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^#=]+)=(.+)') {
            Set-Item -Path "Env:$($matches[1])" -Value $matches[2]
        }
    }
    Write-Host "Loaded environment from .env" -ForegroundColor Green
}

Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     OmniRoute - Persistent Server Launcher        ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$port = 20128
$maxRetries = 10
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Starting OmniRoute on port $port..." -ForegroundColor Yellow
    
    try {
        $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "omniroute serve --port $port" -NoNewWindow -PassThru -Wait -WorkingDirectory $scriptRoot
        
        if ($process.ExitCode -eq 0) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] OmniRoute stopped normally." -ForegroundColor Green
            break
        } else {
            $retryCount++
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] OmniRoute crashed (exit code: $($process.ExitCode)). Restarting in 3s... ($retryCount/$maxRetries)" -ForegroundColor Red
            Start-Sleep -Seconds 3
        }
    }
    catch {
        $retryCount++
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Error: $_. Restarting in 3s... ($retryCount/$maxRetries)" -ForegroundColor Red
        Start-Sleep -Seconds 3
    }
}

if ($retryCount -ge $maxRetries) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Too many crashes. Giving up." -ForegroundColor Red
    pause
}