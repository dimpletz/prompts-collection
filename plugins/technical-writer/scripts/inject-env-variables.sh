#!/usr/bin/env bash
# inject-env-variables.sh — SessionStart hook for the technical-writer plugin.
# Runs on Linux/macOS. Reads DOC_REVIEWER_DIR, DOC_PROPOSAL_DIR, DOC_ARCHITECTURE_DIR, DOC_HOWTO_DIR,
# DOC_QUICKREF_DIR, and DOC_USERGUIDE_DIR environment variables and outputs them as additionalContext JSON.
# Silent (no output) if none of the variables are set.

context=""

for name in DOC_REVIEWER_DIR DOC_PROPOSAL_DIR DOC_ARCHITECTURE_DIR DOC_HOWTO_DIR DOC_QUICKREF_DIR DOC_USERGUIDE_DIR; do
    value="${!name}"
    if [ -n "$value" ]; then
        escaped=${value//\\/\\\\}
        escaped=${escaped//\"/\\\"}
        line="$name=\\\"$escaped\\\""
        if [ -n "$context" ]; then
            context="$context\\n$line"
        else
            context="$line"
        fi
    fi
done

if [ -n "$context" ]; then
    printf '{"additionalContext":"%s"}\n' "$context"
fi
