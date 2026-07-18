[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectDir,

    [string]$Task,
    [string]$TaskFile,
    [string]$Agent,
    [string]$Model,
    [string]$Session,
    [switch]$Continue,
    [switch]$Fork,
    [switch]$JsonOutput,
    [string]$Attach,
    [string[]]$Files,
    [string]$Title = "Codex delegated task"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
    throw "找不到 opencode。請先安裝並確認它位於 PATH。"
}

$resolvedProject = (Resolve-Path $ProjectDir).Path

if ($TaskFile) {
    $resolvedTaskFile = (Resolve-Path $TaskFile).Path
    $Task = Get-Content -Raw -Encoding UTF8 $resolvedTaskFile
}

if ([string]::IsNullOrWhiteSpace($Task)) {
    throw "請提供 -Task 或 -TaskFile。"
}

$argsList = @("run", "--dir", $resolvedProject, "--title", $Title)

if ($Agent) { $argsList += @("--agent", $Agent) }
if ($Model) { $argsList += @("--model", $Model) }
if ($Session) { $argsList += @("--session", $Session) }
if ($Continue) { $argsList += "--continue" }
if ($Fork) { $argsList += "--fork" }
if ($JsonOutput) { $argsList += @("--format", "json") }
if ($Attach) { $argsList += @("--attach", $Attach) }

foreach ($file in $Files) {
    $resolvedFile = (Resolve-Path $file).Path
    $argsList += @("--file", $resolvedFile)
}

$argsList += $Task

Write-Host "Project: $resolvedProject"
Write-Host "Agent:   $Agent"
Write-Host "Model:   $Model"
Write-Host "Starting OpenCode..."

& opencode @argsList
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    throw "OpenCode 執行失敗，exit code: $exitCode"
}
