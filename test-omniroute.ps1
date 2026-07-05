#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Test script for OmniRoute API endpoints
.DESCRIPTION
    Tests all available OmniRoute endpoints with the configured API key
.NOTES
    Requires: OMNIROUTER_API_KEY in .env file
    Run from the repository root (uses $PSScriptRoot)
#>

param(
    [string]$ApiKey = "",
    [string]$BaseUrl = "http://localhost:20128",
    [switch]$Verbose
)

# Load API key from .env if not provided
if (-not $ApiKey) {
    $envFile = Join-Path $PSScriptRoot ".env"
    if (Test-Path $envFile) {
        $content = Get-Content $envFile -Raw
        if ($content -match 'OMNIROUTER_API_KEY=([^\s]+)') {
            $ApiKey = $matches[1]
            Write-Host "Loaded API key from .env: $($ApiKey.Substring(0,12))..." -ForegroundColor Green
        }
    }
}

if (-not $ApiKey) {
    Write-Error "No API key provided. Set OMNIROUTER_API_KEY in .env or pass -ApiKey parameter"
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type"  = "application/json"
}

$vscodeBase = "$BaseUrl/api/v1/vscode/$ApiKey"

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Method = "GET",
        [string]$Body = $null,
        [hashtable]$CustomHeaders = $null
    )
    
    $h = if ($CustomHeaders) { $CustomHeaders + $headers } else { $headers }
    
    try {
        $start = Get-Date
        $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $h -Body $Body -ErrorAction Stop
        $elapsed = (Get-Date) - $start
        
        if ($Verbose) {
            Write-Host "✅ $Name - $($elapsed.TotalMilliseconds)ms" -ForegroundColor Green
            $response | ConvertTo-Json -Depth 3 | Write-Host
        } else {
            Write-Host "✅ $Name - $($elapsed.TotalMilliseconds)ms" -ForegroundColor Green
        }
        return $response
    }
    catch {
        Write-Host "❌ $Name - $($_.Exception.Message)" -ForegroundColor Red
        if ($Verbose) { $_.ErrorDetails.Message | Write-Host }
        return $null
    }
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           OmniRoute API Test Suite v3.8.43                   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow
Write-Host "API Key:  $($ApiKey.Substring(0,12))...`n" -ForegroundColor Yellow

# ==========================================
# CORE ENDPOINTS (Standard /v1/)
# ==========================================
Write-Host "━━━ CORE ENDPOINTS (/v1/) ━━━" -ForegroundColor Magenta

Test-Endpoint "List Models" "$BaseUrl/v1/models"
Test-Endpoint "Chat Completions" "$BaseUrl/v1/chat/completions" "POST" '{"model":"auto","messages":[{"role":"user","content":"Hello! Quick test."}],"max_tokens":50}'
Test-Endpoint "Responses API" "$BaseUrl/v1/responses" "POST" '{"model":"auto","input":"Hello! Quick test.","max_output_tokens":50}'
Test-Endpoint "Completions (Legacy)" "$BaseUrl/v1/completions" "POST" '{"model":"auto","prompt":"Hello! Quick test.","max_tokens":50}'

# ==========================================
# MEDIA & MULTI-MODAL
# ==========================================
Write-Host "`n━━━ MEDIA & MULTI-MODAL ━━━" -ForegroundColor Magenta

Test-Endpoint "Video Generation" "$BaseUrl/v1/videos/generations" "POST" '{"model":"auto","prompt":"A beautiful sunset","duration":5}'

# ==========================================
# SEARCH & DISCOVERY
# ==========================================
Write-Host "`n━━━ SEARCH & DISCOVERY ━━━" -ForegroundColor Magenta

Test-Endpoint "Web Search" "$BaseUrl/v1/search" "POST" '{"query":"latest AI news","max_results":3}'

# ==========================================
# VSCODE COMPATIBILITY ENDPOINTS
# ==========================================
Write-Host "`n━━━ VSCODE COMPATIBILITY (/api/v1/vscode/KEY/) ━━━" -ForegroundColor Magenta

Test-Endpoint "VSCode Models" "$vscodeBase/models"
Test-Endpoint "VSCode Chat" "$vscodeBase/chat/completions" "POST" '{"model":"auto","messages":[{"role":"user","content":"Hello from VSCode endpoint!"}],"max_tokens":50}'

# ==========================================
# OTHER COMPATIBILITY ALIASES
# ==========================================
Write-Host "`n━━━ OTHER COMPATIBILITY ALIASES ━━━" -ForegroundColor Magenta

Test-Endpoint "OpenAI Catalog" "$BaseUrl/vscode/$ApiKey/"
Test-Endpoint "OpenAI Models" "$BaseUrl/vscode/$ApiKey/models"
Test-Endpoint "OpenAI Chat" "$BaseUrl/vscode/$ApiKey/chat/completions" "POST" '{"model":"auto","messages":[{"role":"user","content":"Hello from OpenAI alias!"}],"max_tokens":50}'
Test-Endpoint "Ollama Chat" "$BaseUrl/vscode/$ApiKey/api/chat" "POST" '{"model":"auto","messages":[{"role":"user","content":"Hello from Ollama alias!"}],"stream":false}'
Test-Endpoint "Ollama Tags" "$BaseUrl/vscode/$ApiKey/api/tags"

# ==========================================
# SUMMARY
# ==========================================
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                        TEST COMPLETE                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📋 Available Models: Run with -Verbose to see full model list" -ForegroundColor Yellow
Write-Host "🔧 Configure clients with:" -ForegroundColor Yellow
Write-Host "   Standard:    $BaseUrl/v1" -ForegroundColor Gray
Write-Host "   VSCode:      $vscodeBase" -ForegroundColor Gray
Write-Host "   OpenAI:      $BaseUrl/vscode/$ApiKey" -ForegroundColor Gray
Write-Host "   Ollama:      $BaseUrl/vscode/$ApiKey/api" -ForegroundColor Gray