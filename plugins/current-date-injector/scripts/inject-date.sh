#!/usr/bin/env bash
# inject-date.sh — SessionStart/SubagentStart hook for the current-date-injector plugin.
# Runs on Linux/macOS. Outputs today's date (YYYY-MM-DD) as additionalContext JSON.
TODAY=$(date +%Y-%m-%d)
printf '{"hookSpecificOutput":{"additionalContext":"Today'\''s date is %s (YYYY-MM-DD)."}}\n' "$TODAY"
