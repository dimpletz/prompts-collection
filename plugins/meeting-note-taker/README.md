# meeting-note-taker `v1.0.0`

> Guides you through structured meeting note capture and produces a formatted summary saved to your meeting notes directory.

## Overview

The **meeting-note-taker** plugin provides a conversational agent that walks you through the full meeting note lifecycle:

1. Choose a subdirectory and filename (with smart defaults)
2. Set the meeting title
3. Enter your raw notes at your own pace
4. Let the agent analyze and structure the notes into a clean document
5. Auto-save to the configured meeting notes directory

The generated document always includes a header table, a prose summary (with Mermaid diagrams for any technical flows or topic maps), and the verbatim original notes. A Questions & Answers table and Actions checklist are added only when the notes actually contain that content.

## Prerequisites

No additional installation is required. The plugin works with the VS Code Chat Plugin Marketplace out of the box.

To customize the meeting notes directory, set the `MEETING_DIR` environment variable before starting VS Code:

```sh
# Linux / macOS
export MEETING_DIR="$HOME/work/meeting-notes"

# Windows (PowerShell)
$env:MEETING_DIR = "C:\work\meeting-notes"
```

If `MEETING_DIR` is not set, the hook falls back to:

| Platform | Default path |
|----------|-------------|
| Windows | `%USERPROFILE%\Documents\MeetingNotes` |
| Linux / macOS | `$HOME/Documents/MeetingNotes` |

## Hooks

| Event | Script | What it does |
|-------|--------|--------------|
| `SessionStart` | `inject-meeting-dir.ps1` / `.sh` | Reads `MEETING_DIR` (or uses the platform default) and injects the resolved path into the agent context as `additionalContext`. |
| `SubagentStart` | `inject-meeting-dir.ps1` / `.sh` | Same as above — ensures subagents also receive the meeting directory path. |

## Agents

| Agent | File | Description |
|-------|------|-------------|
| [Meeting Note Taker](agents/MeetingNoteTaker.agent.md) | `MeetingNoteTaker.agent.md` | Interactive agent that captures meeting notes, analyzes them, and saves a structured Markdown document to the meeting notes directory. |

## Output Document Structure

The agent saves a `.md` file with this structure (conditional sections shown with ▸):

```
# Meeting Notes
| Date | Title | Noted By |

# Summary
<prose summary>
▸ Mermaid diagrams (sequence, flowchart, mindmap — when applicable)

▸ # Questions and Answers   (omitted if no questions found)
  | # | Question | Answer |

▸ # Actions                 (omitted if no actions found)
  - [ ] pending action
  - [x] completed during meeting

# Original Notes
<verbatim notes>
```

## File Naming

All note files follow the pattern:

```
<prefix>-YYYY-MM-DD-HH-mm.md
```

Example: `meeting-2026-04-16-14-30.md`

The prefix defaults to `meeting` and the subdirectory defaults to `general` — both are configurable per session.

## Configuration Reference

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `MEETING_DIR` | `%USERPROFILE%\Documents\MeetingNotes` (Windows) / `$HOME/Documents/MeetingNotes` (Linux/macOS) | Root directory where all meeting note subdirectories and files are stored. |

## Author

[Dimpletz](https://github.com/dimpletz)
