#!/usr/bin/env bash
# inject-temporary-script-guidance.sh — SessionStart/SubagentStart hook for the ai-engineer plugin.
# Injects guidance for handling large files with temporary shell/PowerShell scripts.

context="When handling large files, always consider using temporary scripts (shell or PowerShell) to process or transform content safely. Save temporary scripts in a temporary location (for example, /tmp) and always delete the temporary scripts after use."
printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$context"
