---
description: "Harness: run UI/E2E smoke (mock by default; live requires explicit env guard)."
allowed-tools: ["Bash(bash .claude/harness/bin/ui_smoke.sh:*)"]
---
!bash .claude/harness/bin/ui_smoke.sh
