# inject-okf-bundle-dir.ps1 — SessionStart/SubagentStart hook for the okf-manager plugin.
# Runs on Windows. Reads OKF_DEFAULT_DIR and OKF_DEFAULT_BUNDLE_DIR; injects whichever are set.

$parts = @()
if ($env:OKF_DEFAULT_DIR) { $parts += "OKF_DEFAULT_DIR=`"$($env:OKF_DEFAULT_DIR)`"" }
if ($env:OKF_DEFAULT_BUNDLE_DIR) { $parts += "OKF_DEFAULT_BUNDLE_DIR=`"$($env:OKF_DEFAULT_BUNDLE_DIR)`"" }

if ($parts.Count -gt 0) {
    $context = $parts -join ' '
    @{ hookSpecificOutput = @{ additionalContext = $context } } | ConvertTo-Json -Compress
}
