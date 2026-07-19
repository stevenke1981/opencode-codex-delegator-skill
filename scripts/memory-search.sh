#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR=""
QUERY=""
MAX_RESULTS=10
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --query) QUERY="$2"; shift 2 ;;
    --max-results) MAX_RESULTS="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done
[[ -d "$PROJECT_DIR" ]] || { echo "Project not found" >&2; exit 2; }
[[ -n "$QUERY" ]] || { echo "Query required" >&2; exit 2; }
FILES=(
  "$PROJECT_DIR/.codex-memory/memory.jsonl"
  "$PROJECT_DIR/.codex-memory/lessons.md"
  "$PROJECT_DIR/lessons.md"
  "$PROJECT_DIR/final.md"
  "$PROJECT_DIR/test.md"
)
EXISTING=()
for file in "${FILES[@]}"; do [[ -f "$file" ]] && EXISTING+=("$file"); done
[[ ${#EXISTING[@]} -gt 0 ]] || { echo "NO_MEMORY_FOUND"; exit 0; }
python3 - "$QUERY" "$MAX_RESULTS" "${EXISTING[@]}" <<'PY'
import json,re,sys
query=sys.argv[1].lower(); limit=int(sys.argv[2]); files=sys.argv[3:]
tokens={t for t in re.split(r'[^\w.-]+',query) if len(t)>=2}
rows=[]
for path in files:
    with open(path,encoding='utf-8-sig') as f:
        for n,line in enumerate(f,1):
            low=line.lower(); score=sum(t in low for t in tokens)
            if score: rows.append({'score':score,'file':path,'line':n,'text':line.rstrip()})
rows.sort(key=lambda x:(-x['score'],x['file'],x['line']))
print(json.dumps(rows[:limit],ensure_ascii=False,indent=2))
PY
