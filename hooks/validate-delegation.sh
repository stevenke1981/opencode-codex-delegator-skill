#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="${1:?Usage: validate-delegation.sh PROJECT_DIR}"
for file in AGENTS.md spec.md plan.md todos.md; do
  [[ -f "$PROJECT_DIR/$file" ]] || { echo "缺少必要檔案: $file" >&2; exit 2; }
done
cd "$PROJECT_DIR"
git diff --check
git status --short
