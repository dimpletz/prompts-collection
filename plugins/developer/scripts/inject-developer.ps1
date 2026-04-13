# inject-developer.ps1 — SessionStart/SubagentStart hook for the developer plugin.
# Runs on Windows. Reads DEVELOPER_NAME, DEVELOPER_EMAIL, and DEVELOPER_COUNTRY
# environment variables and outputs them as additionalContext JSON.

$rows = [System.Collections.Generic.List[string]]::new()
if ($env:DEVELOPER_NAME) {
    $rows.Add("| Name | $($env:DEVELOPER_NAME) | Use this as the author name or whenever a developer/programmer name is needed. |")
}
if ($env:DEVELOPER_EMAIL) {
    $rows.Add("| Email | $($env:DEVELOPER_EMAIL) | Use this email whenever the developer email is needed. |")
}
if ($env:DEVELOPER_COUNTRY) {
    $rows.Add("| Country | $($env:DEVELOPER_COUNTRY) | Use this for any developer country specific context. |")
}

if ($rows.Count -gt 0) {
    $lines = @("Developer Information:", "|--------|---------|--------|")
    $lines += $rows
    $context = $lines -join "`n"
    @{ hookSpecificOutput = @{ additionalContext = $context } } | ConvertTo-Json -Compress
}
