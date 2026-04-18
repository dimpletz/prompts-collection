#!/usr/bin/env bash
# check-poetry.sh — SessionStart hook for the poetry-user plugin.
# Runs on Linux/macOS. Only runs when a poetry.lock exists in the current workspace.
# 1. If no poetry.lock — silent exit.
# 2. If Python is not available — injects a context message.
# 3. If poetry is already installed — silent exit.
# 4. Installs poetry via pip; injects success or failure message.

[ -f "poetry.lock" ] || exit 0

# Locate Python
PYTHON_CMD=""
for cmd in python3 python; do
    if command -v "$cmd" >/dev/null 2>&1; then
        if "$cmd" --version 2>&1 | grep -q 'Python [0-9]'; then
            PYTHON_CMD="$cmd"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    printf '{"hookSpecificOutput":{"additionalContext":"poetry requires python. Python is not available on this system."}}\n'
    exit 0
fi

# Check if poetry is already installed
if command -v poetry >/dev/null 2>&1; then
    exit 0
fi

# Attempt to install poetry via pip
INSTALL_OUT=$("$PYTHON_CMD" -m pip install poetry 2>&1)
INSTALL_EXIT=$?

if [ "$INSTALL_EXIT" -eq 0 ]; then
    printf '{"hookSpecificOutput":{"additionalContext":"Poetry was not installed and has been installed successfully via pip. You may need to restart the terminal for the '\''poetry'\'' command to be available in PATH."}}\n'
else
    ERR_SNIPPET=$(printf '%s' "$INSTALL_OUT" | head -c 300 | tr '"' "'")
    printf '{"hookSpecificOutput":{"additionalContext":"Poetry is not installed and could not be installed via pip. Error: %s"}}\n' "$ERR_SNIPPET"
fi
