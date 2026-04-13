#!/usr/bin/env bash
# install-markdown-viewer.sh — SessionStart hook for the markdown-viewer plugin.
# Runs on Linux/macOS. Checks whether Python is available and installs markdown-viewer-app
# via pip if it is not already installed. Outputs additionalContext JSON on notable events.

PYTHON_CMD=""
for cmd in python3 python; do
    if command -v "$cmd" >/dev/null 2>&1; then
        PYTHON_CMD="$cmd"
        break
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    MSG="markdown-viewer-app requires Python but Python is not installed or not on PATH. Install Python from https://www.python.org/ and then run: pip install markdown-viewer-app"
    printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$MSG"
    exit 0
fi

# Check if already installed — if so, output nothing (keep context clean).
if "$PYTHON_CMD" -m pip show markdown-viewer-app >/dev/null 2>&1; then
    exit 0
fi

# Attempt installation.
INSTALL_OUT=$("$PYTHON_CMD" -m pip install markdown-viewer-app 2>&1)
INSTALL_EXIT=$?

if [ "$INSTALL_EXIT" -eq 0 ]; then
    MSG="markdown-viewer-app was installed successfully. Use 'mdview <file>' to view markdown files in a browser."
    printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$MSG"
else
    ERR_SNIPPET=$(printf '%s' "$INSTALL_OUT" | head -c 300 | tr '"' "'")
    MSG="markdown-viewer-app could not be installed. Run 'pip install markdown-viewer-app' manually to troubleshoot. Error: ${ERR_SNIPPET}"
    printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$MSG"
fi
