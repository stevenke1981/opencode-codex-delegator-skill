[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$ProjectDir,
  [Parameter(Mandatory=$true)][string]$Query,
  [int]$MaxResults = 10
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path $ProjectDir).Path
$targets = @(
  (Join-Path $root ".codex-memory\memory.jsonl"),
  (Join-Path $root ".codex-memory\lessons.md"),
  (Join-Path $root "lessons.md"),
  (Join-Path $root "final.md"),
  (Join-Path $root "test.md")
) | Where-Object { Test-Path $_ }

if ($targets.Count -eq 0) {
  Write-Output "NO_MEMORY_FOUND"
  exit 0
}

$tokens = $Query.ToLowerInvariant() -split '[^\p{L}\p{N}_\-\.]+' | Where-Object { $_.Length -ge 2 } | Select-Object -Unique
$results = @()

foreach ($target in $targets) {
  $lineNumber = 0
  Get-Content -Encoding UTF8 $target | ForEach-Object {
    $lineNumber++
    $line = $_
    $lower = $line.ToLowerInvariant()
    $score = 0
    foreach ($token in $tokens) {
      if ($lower.Contains($token)) { $score++ }
    }
    if ($score -gt 0) {
      $results += [pscustomobject]@{
        Score = $score
        File = $target
        Line = $lineNumber
        Text = $line
      }
    }
  }
}

$results |
  Sort-Object Score -Descending |
  Select-Object -First $MaxResults |
  ConvertTo-Json -Depth 4
