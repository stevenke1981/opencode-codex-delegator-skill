param([Parameter(Mandatory=$true)][string]$ProjectDir)
$ErrorActionPreference = "Stop"
$required = @("AGENTS.md", "spec.md", "plan.md", "todos.md")
foreach ($file in $required) {
  if (-not (Test-Path (Join-Path $ProjectDir $file))) {
    throw "缺少必要檔案: $file"
  }
}
Push-Location $ProjectDir
try {
  git diff --check
  if ($LASTEXITCODE -ne 0) { throw "git diff --check 失敗" }
  git status --short
} finally { Pop-Location }
