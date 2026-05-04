# inject-doc-dir.ps1 — SessionStart hook for the technical-writer plugin.
# Runs on Windows. Reads DOC_REVIEWER_DIR environment variable and outputs it
# as additionalContext JSON. Silent (no output) if DOC_REVIEWER_DIR is not set;
# the agent falls back to <workspace root>/doc-reviews/ in that case.

if ($env:DOC_REVIEWER_DIR) {
    $quotedDir = '"' + $env:DOC_REVIEWER_DIR + '"'
    @{ hookSpecificOutput = @{ additionalContext = "DOC_REVIEWER_DIR=$quotedDir" } } | ConvertTo-Json -Compress
}
