# inject-temporary-script-guidance.ps1 — SessionStart/SubagentStart hook for the ai-engineer plugin (Windows).
# Injects guidance for handling large files with temporary shell/PowerShell scripts.

$msg = "Use direct commands for simple tasks. For large or complex file handling, consider temporary scripts (shell or PowerShell) to process or transform content safely. Save temporary scripts in the system temporary directory (for example, /tmp on Linux/macOS or the user temp folder on Windows) and always delete the temporary scripts after use."
@{ hookSpecificOutput = @{ additionalContext = $msg } } | ConvertTo-Json -Compress
