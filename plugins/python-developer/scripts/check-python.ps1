# check-python.ps1 — SessionStart hook for the python-developer plugin.
# Runs on Windows. Detects whether Python is actually available (not just a Windows Store stub).
# If Python is not found, injects a permission-request to install it using the python-installer skill.

$pythonFound = $false
try {
    $output = & python --version 2>&1
    if ($LASTEXITCODE -eq 0 -and "$output" -match 'Python \d') {
        $pythonFound = $true
    }
} catch { }

if (-not $pythonFound) {
    @{ hookSpecificOutput = @{ additionalContext = "Python is not installed on this system. Ask the user for permission to install Python using the python-installer skill. Do not proceed with the installation until the user explicitly grants permission. Once installation is complete, you MUST ask the user to restart the IDE or CLI for the changes to take effect. IMPORTANT: Never skip or forget the restart step - Python will not be recognized until the IDE or CLI is restarted." } } | ConvertTo-Json -Compress
}
