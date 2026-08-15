# inject-okf-bundle-dir.ps1 — SessionStart/SubagentStart hook for the okf-manager plugin.
# Runs on Windows. Reads OKF_DEFAULT_BUNDLE_DIR and, if set, injects it as additionalContext.

if ($env:OKF_DEFAULT_BUNDLE_DIR) {
    $context = "OKF_DEFAULT_BUNDLE_DIR=`"$($env:OKF_DEFAULT_BUNDLE_DIR)`""
    @{ hookSpecificOutput = @{ additionalContext = $context } } | ConvertTo-Json -Compress
}
