#!/usr/bin/env bash
# inject-learner-notes-dir.sh — SessionStart hook for the learner plugin.
# Runs on Linux/macOS. Reads LEARNER_NOTES_DIR environment variable and outputs it as additionalContext JSON.
# Falls back to $HOME/Documents/LearnerNotes if LEARNER_NOTES_DIR is not set.

LEARNER_NOTES_DIR="${LEARNER_NOTES_DIR:-$HOME/Documents/LearnerNotes}"
printf '{"hookSpecificOutput":{"additionalContext":"LEARNER_NOTES_DIR=\"%s\""}}\n' "$LEARNER_NOTES_DIR"
