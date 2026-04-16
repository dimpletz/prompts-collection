# inject-meeting-dir.ps1 — SessionStart/SubagentStart hook for the meeting-note-taker plugin.
# Runs on Windows. Reads MEETING_DIR environment variable and outputs it as additionalContext JSON.
# Falls back to %USERPROFILE%\Documents\MeetingNotes if MEETING_DIR is not set.

$meetingDir = if ($env:MEETING_DIR) { $env:MEETING_DIR } else { Join-Path $env:USERPROFILE "Documents\MeetingNotes" }
@{ hookSpecificOutput = @{ additionalContext = "Meeting notes directory (MEETING_DIR): $meetingDir" } } | ConvertTo-Json -Compress
