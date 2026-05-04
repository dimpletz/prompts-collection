#!/usr/bin/env bash
# inject-doc-dir.sh — SessionStart hook for the technical-writer plugin.
# Runs on Linux/macOS. Reads DOC_REVIEWER_DIR environment variable and outputs it
# as additionalContext JSON. Silent (no output) if DOC_REVIEWER_DIR is not set;
# the agent falls back to <workspace root>/doc-reviews/ in that case.

if [ -n "$DOC_REVIEWER_DIR" ]; then
    printf '{"hookSpecificOutput":{"additionalContext":"DOC_REVIEWER_DIR=\"%s\""}}\n' "$DOC_REVIEWER_DIR"
fi
