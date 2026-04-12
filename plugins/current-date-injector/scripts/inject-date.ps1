# inject-date.ps1 — SessionStart/SubagentStart hook for the current-date-injector plugin.
# Runs on Windows. Outputs today's date (YYYY-MM-DD) as additionalContext JSON.
$today = Get-Date -Format "yyyy-MM-dd"
@{ hookSpecificOutput = @{ additionalContext = "Today's date is $today (YYYY-MM-DD)." } } | ConvertTo-Json -Compress
