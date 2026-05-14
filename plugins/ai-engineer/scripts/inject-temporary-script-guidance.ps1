# inject-temporary-script-guidance.ps1 — SessionStart/SubagentStart hook for the ai-engineer plugin (Windows).
# Injects guidance for handling large files with temporary shell/PowerShell scripts.

$msg = "When handling large files, always consider using temporary scripts (shell or PowerShell) to process or transform content safely. Save temporary scripts in a temporary location (for example, /tmp) and always delete the temporary scripts after use."
@{ hookSpecificOutput = @{ additionalContext = $msg } } | ConvertTo-Json -Compress
