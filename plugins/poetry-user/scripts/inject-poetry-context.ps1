# inject-poetry-context.ps1 — SessionStart hook for the poetry-user plugin.
# Runs on Windows. Checks whether a poetry.lock file exists in the current workspace.
# If found, injects context instructing the agent to prefer poetry commands.

if (Test-Path "poetry.lock") {
    $msg = "This project uses Poetry. Always use poetry commands as much as possible (e.g., ``poetry run <cmd>``, ``poetry add <package>``, ``poetry install``, ``poetry update``, ``poetry remove <package>``)."
    @{ hookSpecificOutput = @{ additionalContext = $msg } } | ConvertTo-Json -Compress
}
