#!/usr/bin/env bash
# inject-evaluator-dir.sh — SessionStart hook for the evaluator plugin.
# Runs on Linux/macOS. Reads the EVALUATOR_DIR environment variable and outputs it as additionalContext JSON.
# Silent (no output) if the variable is not set.

if [ -n "$EVALUATOR_DIR" ]; then
    escaped=${EVALUATOR_DIR//\\/\\\\}
    escaped=${escaped//\"/\\\"}
    printf '{"additionalContext":"EVALUATOR_DIR=\\"%s\\""}\n' "$escaped"
fi
