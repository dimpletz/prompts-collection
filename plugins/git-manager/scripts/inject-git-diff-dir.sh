#!/usr/bin/env bash
# inject-git-diff-dir.sh — SessionStart/SubagentStart hook for the git-manager plugin.
# Runs on Linux/macOS. Reads the GIT_DIFF_DIR environment variable and, if set,
# outputs it as additionalContext JSON so agents know where to save diff files.

if [ -n "$GIT_DIFF_DIR" ]; then
    printf '{"hookSpecificOutput":{"additionalContext":"GIT_DIFF_DIR=\"%s\""}}\n' "$GIT_DIFF_DIR"
fi
