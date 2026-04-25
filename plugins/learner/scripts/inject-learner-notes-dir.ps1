# inject-learner-notes-dir.ps1 — SessionStart hook for the learner plugin.
# Runs on Windows. Reads LEARNER_NOTES_DIR environment variable and outputs it as additionalContext JSON.
# Falls back to %USERPROFILE%\Documents\LearnerNotes if LEARNER_NOTES_DIR is not set.

$learnerNotesDir = if ($env:LEARNER_NOTES_DIR) { $env:LEARNER_NOTES_DIR } else { Join-Path $env:USERPROFILE "Documents\LearnerNotes" }
$quotedDir = '"' + $learnerNotesDir + '"'
@{ hookSpecificOutput = @{ additionalContext = "LEARNER_NOTES_DIR=$quotedDir" } } | ConvertTo-Json -Compress
