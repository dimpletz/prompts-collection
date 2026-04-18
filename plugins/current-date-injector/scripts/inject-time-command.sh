#!/usr/bin/env bash
# inject-time-command.sh — SessionStart hook for the current-date-injector plugin.
# Runs on Linux/macOS. Injects context describing the command to get the current time
# in 24-hr format with timezone information.
printf '{"hookSpecificOutput":{"additionalContext":"To get the current time in 24-hr format with timezone, run: date +\"%%H:%%M:%%S %%Z\""}}\n'
