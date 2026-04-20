# inject-date.ps1 — SessionStart/SubagentStart hook for the current-date-injector plugin.
# Runs on Windows. Outputs instructions for obtaining the current date and time as additionalContext JSON.
$context = "To get the current date, run: (Get-Date).ToString('MMMM d, yyyy'). If the current date does not match the output of this command, use the command output as the current date.`nTo get the current time in 24-hr format with timezone, run: (Get-Date).ToString('HH:mm:ss zzz')"
@{ hookSpecificOutput = @{ additionalContext = $context } } | ConvertTo-Json -Compress
