[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$ProjectDir,
  [Parameter(Mandatory=$true)][string]$Title,
  [Parameter(Mandatory=$true)][string]$Problem,
  [Parameter(Mandatory=$true)][string]$RootCause,
  [Parameter(Mandatory=$true)][string]$Solution,
  [Parameter(Mandatory=$true)][string]$Evidence,
  [ValidateSet('confirmed','probable','rejected','obsolete')][string]$Status = 'confirmed',
  [string]$Tags = '',
  [string]$Environment = ''
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path $ProjectDir).Path
$memoryDir = Join-Path $root '.codex-memory'
New-Item -ItemType Directory -Force -Path $memoryDir | Out-Null
$memoryFile = Join-Path $memoryDir 'memory.jsonl'
$lessonsFile = Join-Path $memoryDir 'lessons.md'

$normalized = ($Title + '|' + $Problem + '|' + $RootCause).ToLowerInvariant() -replace '\s+', ' '
$sha = [System.Security.Cryptography.SHA256]::Create()
$fingerprint = ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($normalized)))).Replace('-', '').ToLowerInvariant().Substring(0,16)

$existing = @()
if (Test-Path $memoryFile) {
  $existing = Get-Content -Encoding UTF8 $memoryFile | Where-Object { $_.Trim() } | ForEach-Object { $_ | ConvertFrom-Json }
}

$entry = [ordered]@{
  id = $fingerprint
  title = $Title
  problem = $Problem
  root_cause = $RootCause
  solution = $Solution
  evidence = $Evidence
  status = $Status
  tags = @($Tags -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
  environment = $Environment
  updated_at = (Get-Date).ToUniversalTime().ToString('o')
}

$updated = $false
$output = foreach ($item in $existing) {
  if ($item.id -eq $fingerprint) {
    $updated = $true
    [pscustomobject]$entry
  } else { $item }
}
if (-not $updated) { $output += [pscustomobject]$entry }

$output | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 8 } | Set-Content -Encoding UTF8 $memoryFile

if (-not (Test-Path $lessonsFile)) { '# Project Lessons' | Set-Content -Encoding UTF8 $lessonsFile }
$block = @"

## $Title

- ID: `$fingerprint`
- Status: `$Status`
- Environment: $Environment
- Tags: $Tags
- Problem: $Problem
- Root cause: $RootCause
- Solution: $Solution
- Evidence: $Evidence
- Updated: $((Get-Date).ToUniversalTime().ToString('o'))
"@
Add-Content -Encoding UTF8 $lessonsFile $block

Write-Output (@{ id=$fingerprint; updated=$updated; memory_file=$memoryFile } | ConvertTo-Json)
