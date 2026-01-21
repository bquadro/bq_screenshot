#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path "$ScriptDir/.."
Set-Location $ProjectRoot/app

$nodeVersion = (node -v).Trim()
if ($nodeVersion -notmatch '^v25\.') {
    Write-Error "Node.js 25.x is required for this build (found $nodeVersion)."
    exit 1
}

Write-Host "Installing dependencies..."
npm install

Write-Host "Building Windows distributables..."
npm run make -- --platform=win32 --arch=x64

Write-Host "Packaging complete. Check out/out for the generated installers."
