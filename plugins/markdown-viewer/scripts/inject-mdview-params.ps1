# inject-mdview-params.ps1 — SessionStart hook for the markdown-viewer plugin.
# Runs on Windows. Reads the MDVIEW_BROWSER and MDVIEW_PORT environment variables and,
# if set, outputs additionalContext with a table of preferred mdview parameters.

$rows = [System.Collections.Generic.List[string]]::new()

if ($env:MDVIEW_BROWSER) {
    $rows.Add("| browser | $($env:MDVIEW_BROWSER) |")
}
if ($env:MDVIEW_PORT) {
    $rows.Add("| port | $($env:MDVIEW_PORT) |")
}

if ($rows.Count -gt 0) {
    $lines = @(
        "mdview command prefered parameters:",
        "| Parameter | Prefered |",
        "|------------|--------------|"
    )
    $lines += $rows
    $context = $lines -join "`n"
    @{ hookSpecificOutput = @{ additionalContext = $context } } | ConvertTo-Json -Compress
}
