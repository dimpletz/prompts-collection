#!/usr/bin/env bash
# inject-date.sh — SessionStart/SubagentStart hook for the current-date-injector plugin.
# Runs on Linux/macOS. Outputs today's date (YYYY-MM-DD) and time (HH:mm:ss) as additionalContext JSON.
NOW=$(date +"%Y-%m-%d %H:%M:%S")
printf '{"hookSpecificOutput":{"additionalContext":"The current date and time is %s (YYYY-MM-DD HH:mm:ss)."}}
' "$NOW"
