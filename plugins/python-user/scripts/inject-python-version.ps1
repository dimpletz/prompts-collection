# inject-python-version.ps1 — SessionStart hook for the python-user plugin.
# Runs on Windows. Reads DEFAULT_PYTHON_VERSION environment variable and outputs it as additionalContext JSON.
# Falls back to '3.14.8' if DEFAULT_PYTHON_VERSION is not set.

$pythonVersion = if ($env:DEFAULT_PYTHON_VERSION) { $env:DEFAULT_PYTHON_VERSION } else { "3.14.8" }
$context = "DEFAULT_PYTHON_VERSION=`"$pythonVersion`""
@{
    additionalContext  = $context
} | ConvertTo-Json -Compress
