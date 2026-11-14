# inject-env-variables.ps1 — SessionStart hook for the technical-writer plugin.
# Runs on Windows. Reads DOC_REVIEWER_DIR, DOC_PROPOSAL_DIR, DOC_ARCHITECTURE_DIR, DOC_HOWTO_DIR,
# DOC_QUICKREF_DIR, and DOC_USERGUIDE_DIR environment variables and outputs them as additionalContext JSON.
# Silent (no output) if none of the variables are set.

$lines = @()

foreach ($name in 'DOC_REVIEWER_DIR', 'DOC_PROPOSAL_DIR', 'DOC_ARCHITECTURE_DIR', 'DOC_HOWTO_DIR', 'DOC_QUICKREF_DIR', 'DOC_USERGUIDE_DIR') {
    $value = [Environment]::GetEnvironmentVariable($name)
    if ($value) {
        $lines += $name + '="' + $value + '"'
    }
}

if ($lines.Count -gt 0) {
    @{ additionalContext = ($lines -join "`n") } | ConvertTo-Json -Compress
}
