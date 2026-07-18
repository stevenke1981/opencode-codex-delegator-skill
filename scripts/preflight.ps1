$ErrorActionPreference = "Stop"

if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
    throw "找不到 opencode。"
}

Write-Host "== Version =="
opencode --version

Write-Host "`n== Authentication =="
opencode auth list

Write-Host "`n== Agents =="
opencode agent list

Write-Host "`n== Models =="
opencode models
