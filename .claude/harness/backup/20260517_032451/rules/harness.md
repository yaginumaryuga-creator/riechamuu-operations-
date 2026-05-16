# Harness rules (Pareto: safety / automation / review / failure-avoidance / audit)

- Prefer deterministic changes and keep diffs small.
- After any change, run verification (`/h-verify`) before declaring success.
- Avoid silent fallback; log reasons and expose effective config.
- Protect secrets: never read `.env` / keys / tokens unless explicitly approved.

