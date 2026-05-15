#!/usr/bin/env bash
# inject-temporary-script-guidance.sh — SessionStart/SubagentStart hook for the ai-engineer plugin.
# Injects guidance for using direct commands for simple handling (including large files)
# and temporary shell/PowerShell scripts for large, complex handling.

context='Use direct commands for simple file handling, including large files when handling is simple. For large, complex file handling, consider temporary scripts (shell or PowerShell) to process or transform content safely. Save temporary scripts in the system temporary directory (for example, /tmp on Linux/macOS or the user temp folder on Windows) and always delete the temporary scripts after use.'
printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$context"
