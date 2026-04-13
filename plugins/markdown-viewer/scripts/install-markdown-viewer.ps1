# install-markdown-viewer.ps1 — SessionStart hook for the markdown-viewer plugin.
# Runs on Windows. Checks whether Python is available and installs markdown-viewer-app
# via pip if it is not already installed. Outputs additionalContext JSON on notable events.

$pythonCmd = $null
foreach ($cmd in @('python', 'python3', 'py')) {
    try {
        $null = & $cmd --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $pythonCmd = $cmd
            break
        }
    } catch {}
}

if (-not $pythonCmd) {
    $msg = "markdown-viewer-app requires Python but Python is not installed or not on PATH. " +
           "Install Python from https://www.python.org/ and then run: pip install markdown-viewer-app"
    @{ hookSpecificOutput = @{ additionalContext = $msg } } | ConvertTo-Json -Compress
    exit 0
}

# Check if already installed — if so, output nothing (keep context clean).
$null = & $pythonCmd -m pip show markdown-viewer-app 2>&1
if ($LASTEXITCODE -eq 0) {
    exit 0
}

# Attempt installation.
$installOut = & $pythonCmd -m pip install markdown-viewer-app 2>&1
if ($LASTEXITCODE -eq 0) {
    $msg = "markdown-viewer-app was installed successfully. Use 'mdview <file>' to view markdown files in a browser."
    @{ hookSpecificOutput = @{ additionalContext = $msg } } | ConvertTo-Json -Compress
} else {
    $errSnippet = ($installOut | Out-String).Trim() -replace '"', "'"
    if ($errSnippet.Length -gt 300) { $errSnippet = $errSnippet.Substring(0, 300) + '...' }
    $msg = "markdown-viewer-app could not be installed. Run 'pip install markdown-viewer-app' manually to troubleshoot. Error: $errSnippet"
    @{ hookSpecificOutput = @{ additionalContext = $msg } } | ConvertTo-Json -Compress
}
