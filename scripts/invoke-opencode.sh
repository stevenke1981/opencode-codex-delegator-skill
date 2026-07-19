#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  invoke-opencode.sh --project-dir DIR (--task TEXT | --task-file FILE) [options]

Options:
  --agent NAME
  --model NAME
  --session ID
  --continue
  --fork
  --json
  --attach HOST:PORT
  --file PATH          May be repeated.
  --title TEXT         Default: Codex delegated task
  -h, --help
EOF
}

PROJECT_DIR=""
TASK=""
TASK_FILE=""
AGENT=""
MODEL=""
SESSION=""
ATTACH=""
TITLE="Codex delegated task"
CONTINUE_FLAG=0
FORK_FLAG=0
JSON_FLAG=0
FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir) PROJECT_DIR="${2:?Missing value for --project-dir}"; shift 2 ;;
    --task) TASK="${2:?Missing value for --task}"; shift 2 ;;
    --task-file) TASK_FILE="${2:?Missing value for --task-file}"; shift 2 ;;
    --agent) AGENT="${2:?Missing value for --agent}"; shift 2 ;;
    --model) MODEL="${2:?Missing value for --model}"; shift 2 ;;
    --session) SESSION="${2:?Missing value for --session}"; shift 2 ;;
    --continue) CONTINUE_FLAG=1; shift ;;
    --fork) FORK_FLAG=1; shift ;;
    --json) JSON_FLAG=1; shift ;;
    --attach) ATTACH="${2:?Missing value for --attach}"; shift 2 ;;
    --file) FILES+=("${2:?Missing value for --file}"); shift 2 ;;
    --title) TITLE="${2:?Missing value for --title}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

command -v opencode >/dev/null 2>&1 || {
  echo "找不到 opencode。請先安裝並確認它位於 PATH。" >&2
  exit 127
}

[[ -n "$PROJECT_DIR" ]] || { echo "缺少 --project-dir。" >&2; usage >&2; exit 2; }
[[ -d "$PROJECT_DIR" ]] || { echo "專案目錄不存在: $PROJECT_DIR" >&2; exit 2; }
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd -P)"

if [[ -n "$TASK_FILE" ]]; then
  [[ -f "$TASK_FILE" ]] || { echo "任務檔案不存在: $TASK_FILE" >&2; exit 2; }
  TASK="$(cat "$TASK_FILE")"
fi

[[ -n "${TASK//[[:space:]]/}" ]] || {
  echo "請提供 --task 或 --task-file。" >&2
  exit 2
}

ARGS=(run --dir "$PROJECT_DIR" --title "$TITLE")
[[ -n "$AGENT" ]] && ARGS+=(--agent "$AGENT")
[[ -n "$MODEL" ]] && ARGS+=(--model "$MODEL")
[[ -n "$SESSION" ]] && ARGS+=(--session "$SESSION")
(( CONTINUE_FLAG )) && ARGS+=(--continue)
(( FORK_FLAG )) && ARGS+=(--fork)
(( JSON_FLAG )) && ARGS+=(--format json)
[[ -n "$ATTACH" ]] && ARGS+=(--attach "$ATTACH")

for file in "${FILES[@]}"; do
  [[ -f "$file" ]] || { echo "附加檔案不存在: $file" >&2; exit 2; }
  resolved_file="$(cd "$(dirname "$file")" && pwd -P)/$(basename "$file")"
  ARGS+=(--file "$resolved_file")
done

ARGS+=("$TASK")

printf 'Project: %s\n' "$PROJECT_DIR"
printf 'Agent:   %s\n' "$AGENT"
printf 'Model:   %s\n' "$MODEL"
echo "Starting OpenCode..."

exec opencode "${ARGS[@]}"
