#!/usr/bin/env bash
# cc-harness generated: fingerprint.sh v4
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
OUT_DIR=".claude/harness/artifacts"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/fingerprint.$(date +%Y%m%d_%H%M%S).json"

$PY_CMD - <<'PY' "$OUT"
import json,subprocess,sys,platform
out_path=sys.argv[1]
def sh(cmd):
  try:
    return subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, text=True)[:8000]
  except Exception as e:
    return f"<error: {e}>"

data={
  "platform": platform.platform(),
  "python": sh("python --version"),
  "pip_freeze": sh("python -m pip freeze"),
  "node": sh("node --version"),
  "npm": sh("npm --version"),
  "git_commit": sh("git rev-parse HEAD"),
  "git_status": sh("git status --porcelain"),
}
json.dump(data, open(out_path,"w",encoding="utf-8"), indent=2, ensure_ascii=False)
print(out_path)
PY
