#!/usr/bin/env bash
# inject-python-version.sh — SessionStart hook for the python-developer plugin.
# Runs on Linux/macOS. Reads DEFAULT_PYTHON_VERSION environment variable and outputs it as additionalContext JSON.
# Falls back to '3.14.4' if DEFAULT_PYTHON_VERSION is not set.

PYTHON_VERSION="${DEFAULT_PYTHON_VERSION:-3.14.4}"
printf '{"hookSpecificOutput":{"additionalContext":"DEFAULT_PYTHON_VERSION=\"%s\""}}\n' "$PYTHON_VERSION"
