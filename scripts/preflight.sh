#!/usr/bin/env bash
set -euo pipefail
command -v opencode >/dev/null 2>&1 || { echo "找不到 opencode" >&2; exit 127; }

echo "== Version =="
opencode --version
echo
echo "== Authentication =="
opencode auth list
echo
echo "== Agents =="
opencode agent list
echo
echo "== Models =="
opencode models
