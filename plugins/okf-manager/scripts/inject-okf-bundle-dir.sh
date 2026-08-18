#!/usr/bin/env bash
# inject-okf-bundle-dir.sh — SessionStart/SubagentStart hook for the okf-manager plugin.
# Runs on Linux/macOS. Reads OKF_DEFAULT_DIR and OKF_DEFAULT_BUNDLE_DIR; injects whichever are set.

parts=()
[ -n "$OKF_DEFAULT_DIR" ] && parts+=("OKF_DEFAULT_DIR=\"$OKF_DEFAULT_DIR\"")
[ -n "$OKF_DEFAULT_BUNDLE_DIR" ] && parts+=("OKF_DEFAULT_BUNDLE_DIR=\"$OKF_DEFAULT_BUNDLE_DIR\"")

if [ ${#parts[@]} -gt 0 ]; then
    context="${parts[*]}"
    printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$context"
fi
