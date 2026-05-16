#!/usr/bin/env bash
# cc-harness generated: harness_stop_verify.sh v4
set -euo pipefail

find_py() {
  for c in python3 python "/c/Users/oneoc/AppData/Local/Programs/Python/Python310/python.exe"; do
    if "$c" -c "import sys; sys.exit(0)" 2>/dev/null; then echo "$c"; return; fi
  done
  echo "python"
}
PY_CMD="$(find_py)"

json="$(cat || true)"
stop_active="$($PY_CMD - <<'PY' "$json"
import json,sys
raw=sys.argv[1] if len(sys.argv)>1 else ""
if not raw.strip():
  print("false"); raise SystemExit(0)
try:
  d=json.loads(raw)
  print("true" if d.get("stop_hook_active") else "false")
except Exception:
  print("false")
PY
)"

if [[ "$stop_active" == "true" ]]; then
  exit 0
fi

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [[ -z "$(git status --porcelain)" ]]; then
    exit 0
  fi
fi

mkdir -p .claude/harness/logs
OUT=".claude/harness/logs/stop_verify.$(date +%Y%m%d_%H%M%S).log"

if bash .claude/harness/bin/verify.sh >"$OUT" 2>&1; then
  exit 0
fi

echo "Verification failed (Stop hook blocked). Fix and run /h-verify." >&2
echo "Log: $OUT" >&2
tail -n 80 "$OUT" >&2 || true
exit 2
