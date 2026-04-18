# check-poetry.ps1 — SessionStart hook for the poetry-user plugin.
# Runs on Windows. Only runs when a poetry.lock exists in the current workspace.
# 1. If no poetry.lock — silent exit.
# 2. If Python is not available — injects a context message.
# 3. If poetry is already installed — silent exit.
# 4. Installs poetry via pip; injects success or failure message.

if (-not (Test-Path "poetry.lock")) { exit 0 }

# Locate Python
$pythonCmd = $null
foreach ($cmd in @('python', 'python3', 'py')) {
    try {
        $out = & $cmd --version 2>&1
        if ($LASTEXITCODE -eq 0 -and "$out" -match 'Python \d') {
            $pythonCmd = $cmd
            break
        }
    } catch { }
}

if (-not $pythonCmd) {
    @{ hookSpecificOutput = @{ additionalContext = "poetry requires python. Python is not available on this system." } } | ConvertTo-Json -Compress
    exit 0
}

# Check if poetry is already installed
try {
    $null = & poetry --version 2>&1
    if ($LASTEXITCODE -eq 0) { exit 0 }
} catch { }

# Attempt to install poetry via pip
$installOut = & $pythonCmd -m pip install poetry 2>&1
if ($LASTEXITCODE -eq 0) {
    $msg = "Poetry was not installed and has been installed successfully via pip. You may need to restart the terminal for the 'poetry' command to be available in PATH."
    @{ hookSpecificOutput = @{ additionalContext = $msg } } | ConvertTo-Json -Compress
} else {
    $errSnippet = ($installOut | Out-String).Trim() -replace '"', "'"
    if ($errSnippet.Length -gt 300) { $errSnippet = $errSnippet.Substring(0, 300) + '...' }
    $msg = "Poetry is not installed and could not be installed via pip. Error: $errSnippet"
    @{ hookSpecificOutput = @{ additionalContext = $msg } } | ConvertTo-Json -Compress
}
