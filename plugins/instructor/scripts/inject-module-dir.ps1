# inject-module-dir.ps1 — SessionStart hook for the instructor plugin.
# Runs on Windows. Reads MODULE_DIR environment variable and outputs it as additionalContext JSON.
# Falls back to empty string if MODULE_DIR is not set (agent uses workspace root /modules/ default).

$moduleDir = if ($env:MODULE_DIR) { $env:MODULE_DIR } else { "" }
$quotedDir = '"' + $moduleDir + '"'
@{ hookSpecificOutput = @{ additionalContext = "INSTRUCTOR_MODULE_DIR=$quotedDir" } } | ConvertTo-Json -Compress
