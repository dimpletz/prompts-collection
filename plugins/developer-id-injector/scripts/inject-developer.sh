#!/usr/bin/env bash
# inject-developer.sh — SessionStart/SubagentStart hook for the developer-id-injector plugin.
# Runs on Linux/macOS. Reads the DEVELOPER_NAME environment variable and outputs it as additionalContext JSON.
if [ -n "$DEVELOPER_NAME" ]; then
    printf '{"hookSpecificOutput":{"additionalContext":"The developer name is '\''%s'\''. Use this as the author name or whenever a developer/programmer name is needed."}}\n' "$DEVELOPER_NAME"
fi
