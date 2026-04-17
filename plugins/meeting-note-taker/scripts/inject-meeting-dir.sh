#!/usr/bin/env bash
# inject-meeting-dir.sh — SessionStart/SubagentStart hook for the meeting-note-taker plugin.
# Runs on Linux/macOS. Reads MEETING_DIR environment variable and outputs it as additionalContext JSON.
# Falls back to $HOME/Documents/MeetingNotes if MEETING_DIR is not set.

MEETING_DIR="${MEETING_DIR:-$HOME/Documents/MeetingNotes}"
printf '{"hookSpecificOutput":{"additionalContext":"MEETING_DIR=\"%s\""}}\n' "$MEETING_DIR"
