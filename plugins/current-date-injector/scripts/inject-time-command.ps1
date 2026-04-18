# inject-time-command.ps1 — SessionStart hook for the current-date-injector plugin.
# Runs on Windows. Injects context describing the command to get the current time
# in 24-hr format with timezone information.
@{ hookSpecificOutput = @{ additionalContext = "To get the current time in 24-hr format with timezone, run: (Get-Date).ToString('HH:mm:ss zzz')" } } | ConvertTo-Json -Compress
