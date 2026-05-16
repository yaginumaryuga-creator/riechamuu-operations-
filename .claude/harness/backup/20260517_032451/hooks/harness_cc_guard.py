#!/usr/bin/env python
# cc-harness generated: harness_cc_guard.py v4
import json,sys,re,os

data=json.load(sys.stdin)
tool=data.get("tool_name","")
inp=data.get("tool_input") or {}
cmd=inp.get("command","") if isinstance(inp,dict) else ""

if tool != "Bash":
    sys.exit(0)

BLOCK_PATTERNS = [
    (re.compile(r"\brm\s+-rf\s+/\b"), "Refusing: rm -rf /"),
    (re.compile(r"\brm\s+-rf\s+\.\.\b"), "Refusing: rm -rf .."),
    (re.compile(r"\bgit\s+push\b.*--force\b"), "Refusing: git push --force (set CC_ALLOW_FORCE=1 to override)"),
    (re.compile(r"--no-dry-run"), "Refusing: --no-dry-run (dangerous)."),
]

if os.environ.get("CC_ALLOW_FORCE","") == "1":
    BLOCK_PATTERNS = [p for p in BLOCK_PATTERNS if "push --force" not in p[1]]

for pat,msg in BLOCK_PATTERNS:
    if pat.search(cmd):
        sys.stderr.write(msg+"\n")
        sys.exit(2)

sys.exit(0)
