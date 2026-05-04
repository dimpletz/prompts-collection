# inject-configs.ps1 — SessionStart hook for the code-reviewer plugin (Windows).
# Always injects CODE_REVIEW_DIFF_CHUNK_MAX_LINES.
# Only injects CODE_REVIEW_IGNORE_FILE if the environment variable is set.
# Only injects CODE_REVIEW_REPORT_DIR if the environment variable is set.

$maxLines = if ($env:CODE_REVIEW_DIFF_CHUNK_MAX_LINES) { $env:CODE_REVIEW_DIFF_CHUNK_MAX_LINES } else { "500" }

$context = "CODE_REVIEW_DIFF_CHUNK_MAX_LINES=${maxLines}"

$ignoreFileEnv = [System.Environment]::GetEnvironmentVariable('CODE_REVIEW_IGNORE_FILE')
if ($null -ne $ignoreFileEnv) {
    $context += "`nCODE_REVIEW_IGNORE_FILE=${ignoreFileEnv}"
}

$reportDirEnv = [System.Environment]::GetEnvironmentVariable('CODE_REVIEW_REPORT_DIR')
if ($null -ne $reportDirEnv) {
    $context += "`nCODE_REVIEW_REPORT_DIR=${reportDirEnv}"
}

@{ hookSpecificOutput = @{ hookEventName = "SessionStart"; additionalContext = $context } } | ConvertTo-Json -Compress
