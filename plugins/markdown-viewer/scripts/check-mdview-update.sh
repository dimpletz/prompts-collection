#!/usr/bin/env bash
# check-mdview-update.sh — SessionStart hook for the markdown-viewer plugin.
# Runs on Linux/macOS. Checks whether a newer version of markdown-viewer-app is
# available via pip. If one is found, injects context instructing the agent to
# notify the user before executing the mdview command and offer to upgrade.

PYTHON_CMD=""
for cmd in python3 python; do
    if command -v "$cmd" >/dev/null 2>&1; then
        PYTHON_CMD="$cmd"
        break
    fi
done

[ -z "$PYTHON_CMD" ] && exit 0

# Only run if markdown-viewer-app is installed.
INSTALLED_LINE=$("$PYTHON_CMD" -m pip show markdown-viewer-app 2>/dev/null | grep '^Version:')
[ -z "$INSTALLED_LINE" ] && exit 0

INSTALLED_VER=$(printf '%s' "$INSTALLED_LINE" | awk '{print $2}' | tr '"\\' "''")

# Check for an outdated package.
OUTDATED=$("$PYTHON_CMD" -m pip list --outdated 2>/dev/null | grep '^markdown-viewer-app ')
[ -z "$OUTDATED" ] && exit 0

LATEST_VER=$(printf '%s' "$OUTDATED" | awk '{print $3}' | tr '"\\' "''")

MSG="A new version of markdown-viewer-app is available (installed: ${INSTALLED_VER}, latest: ${LATEST_VER}). Before executing the mdview command, notify the user that a new version is available. Offer to upgrade it and use the following pip command to upgrade: pip install --upgrade markdown-viewer-app"
printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$MSG"
