# check-mdview-update.ps1 — SessionStart hook for the markdown-viewer plugin.
# Runs on Windows. Checks whether a newer version of markdown-viewer-app is
# available via pip. If one is found, injects context instructing the agent to
# notify the user before executing the mdview command and offer to upgrade.

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

if (-not $pythonCmd) { exit 0 }

# Only run if markdown-viewer-app is installed.
$showOut = & $pythonCmd -m pip show markdown-viewer-app 2>&1
if ($LASTEXITCODE -ne 0) { exit 0 }

$installedLine = $showOut | Where-Object { $_ -match '^Version:' } | Select-Object -First 1
if (-not $installedLine) { exit 0 }

$installedVer = ($installedLine -replace '^Version:\s*', '').Trim()

# Check for an outdated package.
$outdatedOut = & $pythonCmd -m pip list --outdated 2>&1
$outdatedLine = $outdatedOut | Where-Object { $_ -match '^markdown-viewer-app\s' } | Select-Object -First 1
if (-not $outdatedLine) { exit 0 }

$parts = $outdatedLine -split '\s+'
$latestVer = $parts[2]

$msg = "A new version of markdown-viewer-app is available (installed: $installedVer, latest: $latestVer). Before executing the mdview command, notify the user that a new version is available. Offer to upgrade it and use the following pip command to upgrade: pip install --upgrade markdown-viewer-app"
@{ hookSpecificOutput = @{ additionalContext = $msg } } | ConvertTo-Json -Compress
