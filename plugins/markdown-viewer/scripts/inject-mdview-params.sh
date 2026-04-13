#!/usr/bin/env bash
# inject-mdview-params.sh — SessionStart hook for the markdown-viewer plugin.
# Runs on Linux/macOS. Reads the MDVIEW_BROWSER and MDVIEW_PORT environment variables and,
# if set, outputs additionalContext with a table of preferred mdview parameters.

ROWS=""
if [ -n "$MDVIEW_BROWSER" ]; then
    ROWS="${ROWS:+$ROWS\n}| browser | ${MDVIEW_BROWSER} |"
fi
if [ -n "$MDVIEW_PORT" ]; then
    ROWS="${ROWS:+$ROWS\n}| port | ${MDVIEW_PORT} |"
fi

if [ -n "$ROWS" ]; then
    CONTEXT="mdview command prefered parameters:\n| Parameter | Prefered |\n|------------|-------------- |\n$ROWS"
    printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$CONTEXT"
fi
