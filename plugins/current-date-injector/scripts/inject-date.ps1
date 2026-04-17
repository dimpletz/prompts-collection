# inject-date.ps1 — SessionStart/SubagentStart hook for the current-date-injector plugin.
# Runs on Windows. Outputs today's date (YYYY-MM-DD) and time (HH:mm:ss) as additionalContext JSON.
$now = Get-Date
$today = $now.ToString("yyyy-MM-dd")
$time = $now.ToString("HH:mm:ss")
@{ hookSpecificOutput = @{ additionalContext = "The current date and time is $today $time (YYYY-MM-DD HH:mm:ss)." } } | ConvertTo-Json -Compress
