# inject-evaluator-dir.ps1 — SessionStart hook for the evaluator plugin.
# Runs on Windows. Reads the EVALUATOR_DIR environment variable and outputs it as additionalContext JSON.
# Silent (no output) if the variable is not set.

if ($env:EVALUATOR_DIR) {
    @{ additionalContext = 'EVALUATOR_DIR="' + $env:EVALUATOR_DIR + '"' } | ConvertTo-Json -Compress
}
