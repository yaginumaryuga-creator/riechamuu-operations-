#!/usr/bin/env bash
# cc-harness generated: verify.sh v4
set -euo pipefail

# Find real Python (Windows MS Store python3 may be a redirect)
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
LOG_DIR=".claude/harness/logs"
mkdir -p "$LOG_DIR"
ts="$(date +%Y%m%d_%H%M%S)"
LOG="$LOG_DIR/verify.$ts.log"

if [[ ! -f "$CFG" ]]; then
  echo "[verify] missing $CFG" | tee "$LOG"
  exit 2
fi

$PY_CMD - <<'PY' "$CFG" "$LOG"
import json,sys,subprocess,os
cfg_path, log_path = sys.argv[1], sys.argv[2]
cfg = json.load(open(cfg_path,"r",encoding="utf-8"))
steps = cfg.get("verify",{}).get("steps",[])
if not steps:
  open(log_path,"a",encoding="utf-8").write("[verify] no steps configured in project.json\\n")
  sys.exit(2)

def run_step(step):
  name = step.get("name","(unnamed)")
  cmd = step["cmd"]
  cwd = step.get("cwd",".")
  env = os.environ.copy()
  env.update(step.get("env",{}))
  with open(log_path,"a",encoding="utf-8") as f:
    f.write(f"\\n==> {name}\\n$ (cd {cwd} && {cmd})\\n")
    f.flush()
    p = subprocess.Popen(cmd, shell=True, cwd=cwd, env=env, stdout=f, stderr=subprocess.STDOUT)
    return p.wait()

rc=0
for s in steps:
  rc = run_step(s)
  if rc!=0:
    break
sys.exit(rc)
PY
