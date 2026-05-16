#!/usr/bin/env bash
# cc-harness generated: ui_smoke.sh v4
set -euo pipefail

find_py() {
  for c in python3 python "/c/Users/oneoc/AppData/Local/Programs/Python/Python310/python.exe"; do
    if "$c" -c "import sys; sys.exit(0)" 2>/dev/null; then echo "$c"; return; fi
  done
  echo "python"
}
PY_CMD="$(find_py)"

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"

CFG=".claude/harness/project.json"
if [[ ! -f "$CFG" ]]; then
  echo "[ui] missing $CFG" >&2
  exit 2
fi

mode="$($PY_CMD - <<'PY' "$CFG"
import json,sys
cfg=json.load(open(sys.argv[1],"r",encoding="utf-8"))
print(cfg.get("ui",{}).get("e2e_mode","mock"))
PY
)"

if [[ "$mode" == "live" ]]; then
  if [[ "${CC_E2E_LIVE_OK:-}" != "1" ]]; then
    echo "[ui] Refusing LIVE E2E without CC_E2E_LIVE_OK=1 (cost guard)." >&2
    exit 2
  fi
  if [[ -z "${CC_E2E_BUDGET_YEN:-}" ]]; then
    echo "[ui] LIVE E2E requires CC_E2E_BUDGET_YEN (cost guard)." >&2
    exit 2
  fi
fi

$PY_CMD - <<'PY' "$CFG"
import json,sys,subprocess,os
cfg=json.load(open(sys.argv[1],"r",encoding="utf-8"))
steps=cfg.get("ui",{}).get("steps",[])
if not steps:
  print("[ui] no ui steps configured; skipping.")
  raise SystemExit(0)

for s in steps:
  cmd=s["cmd"]
  cwd=s.get("cwd",".")
  env=os.environ.copy()
  env.update(s.get("env",{}))
  rc=subprocess.call(cmd, shell=True, cwd=cwd, env=env)
  if rc!=0:
    raise SystemExit(rc)
PY
