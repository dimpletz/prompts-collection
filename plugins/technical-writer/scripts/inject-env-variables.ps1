# inject-env-variables.ps1 — SessionStart hook for the technical-writer plugin.
# Runs on Windows. Reads DOC_REVIEWER_DIR, DOC_PROPOSAL_DIR, and DOC_ARCHITECTURE_DIR environment variables
# and outputs them as additionalContext JSON. Silent (no output) if neither variable is set.

$lines = @()

if ($env:DOC_REVIEWER_DIR) {
    $lines += 'DOC_REVIEWER_DIR="' + $env:DOC_REVIEWER_DIR + '"'
}

if ($env:DOC_PROPOSAL_DIR) {
    $lines += 'DOC_PROPOSAL_DIR="' + $env:DOC_PROPOSAL_DIR + '"'
}

if ($env:DOC_ARCHITECTURE_DIR) {
    $lines += 'DOC_ARCHITECTURE_DIR="' + $env:DOC_ARCHITECTURE_DIR + '"'
}

if ($lines.Count -gt 0) {
    @{ hookSpecificOutput = @{ additionalContext = ($lines -join "`n") } } | ConvertTo-Json -Compress
}
