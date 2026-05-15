#!/usr/bin/env bash
# inject-temporary-script-guidance.sh — SessionStart/SubagentStart hook for the ai-engineer plugin.
# Injects guidance for using direct shell/PowerShell commands for large, simple
# file handling and temporary scripts for large, complex handling.

context='For large, simple file handling, consider using direct shell or PowerShell commands (for example, searching text). For large, complex file handling, consider temporary scripts (shell or PowerShell) to process or transform content safely. Save temporary scripts in the system temporary directory (for example, /tmp on Linux/macOS or the user temp folder on Windows) and always delete the temporary scripts after use.'
printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$context"
