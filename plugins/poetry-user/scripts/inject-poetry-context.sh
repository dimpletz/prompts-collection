#!/usr/bin/env bash
# inject-poetry-context.sh — SessionStart hook for the poetry-user plugin.
# Runs on Linux/macOS. Checks whether a poetry.lock file exists in the current workspace.
# If found, injects context instructing the agent to prefer poetry commands.

if [ -f "poetry.lock" ]; then
    printf '{"hookSpecificOutput":{"additionalContext":"This project uses Poetry. Always use poetry commands as much as possible (e.g., `poetry run <cmd>`, `poetry add <package>`, `poetry install`, `poetry update`, `poetry remove <package>`)."}}\n'
fi
