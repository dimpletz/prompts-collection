# inject-developer.ps1 — SessionStart/SubagentStart hook for the developer-id-injector plugin.
# Runs on Windows. Reads the DEVELOPER_NAME environment variable and outputs it as additionalContext JSON.
$developerName = $env:DEVELOPER_NAME
if ($developerName) {
    @{ hookSpecificOutput = @{ additionalContext = "The developer name is '$developerName'. Use this as the author name or whenever a developer/programmer name is needed." } } | ConvertTo-Json -Compress
}
