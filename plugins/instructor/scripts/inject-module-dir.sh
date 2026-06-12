#!/usr/bin/env bash
# inject-module-dir.sh — SessionStart hook for the instructor plugin.
# Runs on Linux/macOS. Reads MODULE_DIR environment variable and outputs it as additionalContext JSON.
# Falls back to empty string if MODULE_DIR is not set (agent uses workspace root /modules/ default).

MODULE_DIR="${MODULE_DIR:-}"
printf '{"hookSpecificOutput":{"additionalContext":"INSTRUCTOR_MODULE_DIR=\"%s\""}}\n' "$MODULE_DIR"
