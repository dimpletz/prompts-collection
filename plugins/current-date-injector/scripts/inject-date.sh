#!/usr/bin/env bash
# inject-date.sh — SessionStart/SubagentStart hook for the current-date-injector plugin.
# Runs on Linux/macOS. Outputs instructions for obtaining the current date and time as additionalContext JSON.
printf '{"hookSpecificOutput":{"additionalContext":"To get the current date, run: date +\"%%B %%-d, %%Y\". If the current date does not match the output of this command, use the command output as the current date.\nTo get the current time in 24-hr format with timezone, run: date +\"%%H:%%M:%%S %%Z\""}}\n'