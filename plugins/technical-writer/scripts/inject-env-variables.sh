#!/usr/bin/env bash
# inject-env-variables.sh — SessionStart hook for the technical-writer plugin.
# Runs on Linux/macOS. Reads DOC_REVIEWER_DIR, DOC_PROPOSAL_DIR, and DOC_ARCHITECTURE_DIR environment variables
# and outputs them as additionalContext JSON. Silent (no output) if neither variable is set.

context=""

if [ -n "$DOC_REVIEWER_DIR" ]; then
    context="DOC_REVIEWER_DIR=\"$DOC_REVIEWER_DIR\""
fi

if [ -n "$DOC_PROPOSAL_DIR" ]; then
    if [ -n "$context" ]; then
        context="$context\nDOC_PROPOSAL_DIR=\"$DOC_PROPOSAL_DIR\""
    else
        context="DOC_PROPOSAL_DIR=\"$DOC_PROPOSAL_DIR\""
    fi
fi

if [ -n "$DOC_ARCHITECTURE_DIR" ]; then
    if [ -n "$context" ]; then
        context="$context\nDOC_ARCHITECTURE_DIR=\"$DOC_ARCHITECTURE_DIR\""
    else
        context="DOC_ARCHITECTURE_DIR=\"$DOC_ARCHITECTURE_DIR\""
    fi
fi

if [ -n "$context" ]; then
    printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$context"
fi
