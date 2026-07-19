#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR=""; TITLE=""; PROBLEM=""; ROOT_CAUSE=""; SOLUTION=""; EVIDENCE=""; STATUS="confirmed"; TAGS=""; ENVIRONMENT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --problem) PROBLEM="$2"; shift 2 ;;
    --root-cause) ROOT_CAUSE="$2"; shift 2 ;;
    --solution) SOLUTION="$2"; shift 2 ;;
    --evidence) EVIDENCE="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --environment) ENVIRONMENT="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done
[[ -d "$PROJECT_DIR" ]] || { echo "Project not found" >&2; exit 2; }
case "$STATUS" in confirmed|probable|rejected|obsolete) ;; *) echo "Invalid status" >&2; exit 2;; esac
python3 - "$PROJECT_DIR" "$TITLE" "$PROBLEM" "$ROOT_CAUSE" "$SOLUTION" "$EVIDENCE" "$STATUS" "$TAGS" "$ENVIRONMENT" <<'PY'
import datetime,hashlib,json,pathlib,re,sys
project,title,problem,root_cause,solution,evidence,status,tags,environment=sys.argv[1:]
if not all([title,problem,root_cause,solution,evidence]): raise SystemExit('Missing required field')
memdir=pathlib.Path(project)/'.codex-memory'; memdir.mkdir(exist_ok=True)
memfile=memdir/'memory.jsonl'; lessons=memdir/'lessons.md'
normalized=re.sub(r'\s+',' ',f'{title}|{problem}|{root_cause}'.lower()).strip()
fingerprint=hashlib.sha256(normalized.encode()).hexdigest()[:16]
entries=[]
if memfile.exists():
    for line in memfile.read_text(encoding='utf-8-sig').splitlines():
        if line.strip(): entries.append(json.loads(line))
entry={'id':fingerprint,'title':title,'problem':problem,'root_cause':root_cause,'solution':solution,'evidence':evidence,'status':status,'tags':[x.strip() for x in tags.split(',') if x.strip()],'environment':environment,'updated_at':datetime.datetime.now(datetime.timezone.utc).isoformat()}
updated=False
for i,item in enumerate(entries):
    if item.get('id')==fingerprint: entries[i]=entry; updated=True
if not updated: entries.append(entry)
memfile.write_text('\n'.join(json.dumps(x,ensure_ascii=False,separators=(',',':')) for x in entries)+'\n',encoding='utf-8')
if not lessons.exists(): lessons.write_text('# Project Lessons\n',encoding='utf-8')
with lessons.open('a',encoding='utf-8') as f:
    f.write(f'\n## {title}\n\n- ID: `{fingerprint}`\n- Status: `{status}`\n- Environment: {environment}\n- Tags: {tags}\n- Problem: {problem}\n- Root cause: {root_cause}\n- Solution: {solution}\n- Evidence: {evidence}\n- Updated: {entry["updated_at"]}\n')
print(json.dumps({'id':fingerprint,'updated':updated,'memory_file':str(memfile)},ensure_ascii=False))
PY
