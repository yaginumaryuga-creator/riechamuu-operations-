---
description: "Harness: one atomic change → verify → if fail, minimal fix → verify again."
allowed-tools: ["Read","Write","Edit","Glob","Grep","Bash(bash .claude/harness/bin/verify.sh:*)"]
---
You are executing **/h-step**.

Rules:
- Do exactly ONE atomic change (smallest diff).
- Run verification immediately.
- If verification fails: diagnose smallest root cause, apply smallest fix, re-run verification.
- Repeat until green, then summarize.

Now:
1) Decide the single smallest change you will do next.
2) Implement it.
3) Run: `bash .claude/harness/bin/verify.sh`
