#!/usr/bin/env bash
# inject-developer.sh — SessionStart/SubagentStart hook for the developer plugin.
# Runs on Linux/macOS. Reads DEVELOPER_NAME, DEVELOPER_EMAIL, and DEVELOPER_COUNTRY
# environment variables and outputs them as additionalContext JSON.

rows=""
if [ -n "$DEVELOPER_NAME" ]; then
    rows="${rows:+$rows\n}| Name | $DEVELOPER_NAME | Use this as the author name or whenever a developer/programmer name is needed. |"
fi
if [ -n "$DEVELOPER_EMAIL" ]; then
    rows="${rows:+$rows\n}| Email | $DEVELOPER_EMAIL | Use this email whenever the developer email is needed. |"
fi
if [ -n "$DEVELOPER_COUNTRY" ]; then
    rows="${rows:+$rows\n}| Country | $DEVELOPER_COUNTRY | Use this for any developer country specific context. |"
fi

if [ -n "$rows" ]; then
    context="Developer Information:\n|--------|---------|--------|\n$rows"
    printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$context"
fi
