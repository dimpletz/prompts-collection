#!/usr/bin/env bash
# check-python.sh — SessionStart hook for the python-user plugin.
# Runs on Linux/macOS. Detects whether Python is actually installed and executable.
# If Python is not found, injects a permission-request to install it using the python-installer skill.

python_found=false
for cmd in python3 python; do
    if command -v "$cmd" &>/dev/null; then
        if "$cmd" --version 2>&1 | grep -q 'Python [0-9]'; then
            python_found=true
            break
        fi
    fi
done

if [ "$python_found" = false ]; then
    printf '{"hookSpecificOutput":{"additionalContext":"Python is not installed on this system. Ask the user for permission to install Python using the python-installer skill. Do not proceed with the installation until the user explicitly grants permission. Once installation is complete, you MUST ask the user to restart the IDE or CLI for the changes to take effect. IMPORTANT: Never skip or forget the restart step — Python will not be recognized until the IDE or CLI is restarted."}}\n'
fi
