#!/usr/bin/env bash
# inject-okf-bundle-dir.sh — SessionStart/SubagentStart hook for the okf-manager plugin.
# Runs on Linux/macOS. Reads OKF_DEFAULT_BUNDLE_DIR and, if set, injects it as additionalContext.

if [ -n "$OKF_DEFAULT_BUNDLE_DIR" ]; then
    printf '{"hookSpecificOutput":{"additionalContext":"OKF_DEFAULT_BUNDLE_DIR=\"%s\""}}\n' "$OKF_DEFAULT_BUNDLE_DIR"
fi
