#!/usr/bin/env bash
# inject-configs.sh — SessionStart hook for the code-reviewer plugin.
# Always injects CODE_REVIEW_DIFF_CHUNK_MAX_LINES.
# Only injects CODE_REVIEW_IGNORE_FILE if the environment variable is set.
# Only injects CODE_REVIEW_REPORT_DIR if the environment variable is set.

MAX_LINES="${CODE_REVIEW_DIFF_CHUNK_MAX_LINES:-500}"

context="CODE_REVIEW_DIFF_CHUNK_MAX_LINES=${MAX_LINES}"

if [ -n "${CODE_REVIEW_IGNORE_FILE+x}" ]; then
    context="${context}\nCODE_REVIEW_IGNORE_FILE=${CODE_REVIEW_IGNORE_FILE}"
fi

if [ -n "${CODE_REVIEW_REPORT_DIR+x}" ]; then
    context="${context}\nCODE_REVIEW_REPORT_DIR=${CODE_REVIEW_REPORT_DIR}"
fi

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$context"
