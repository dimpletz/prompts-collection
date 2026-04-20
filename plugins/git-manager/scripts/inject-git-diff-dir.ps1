# inject-git-diff-dir.ps1 — SessionStart/SubagentStart hook for the git-manager plugin.
# Runs on Windows. Reads the GIT_DIFF_DIR environment variable and, if set,
# outputs it as additionalContext JSON so agents know where to save diff files.

if ($env:GIT_DIFF_DIR) {
    $context = "GIT_DIFF_DIR=`"$($env:GIT_DIFF_DIR)`""
    @{ hookSpecificOutput = @{ additionalContext = $context } } | ConvertTo-Json -Compress
}
