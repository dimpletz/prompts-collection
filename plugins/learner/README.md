# learner `v1.0.0`

> Capture and organise personal study notes by topic in structured Markdown files.

## Overview

The **learner** plugin provides a conversational agent that helps you build and maintain a personal knowledge base. For every topic you study, the agent creates or updates a dedicated Markdown file with a consistent header, a table of contents placeholder, and individually titled sections separated by horizontal rules. Sections can include typed text, pasted content, attached images, and auto-generated Mermaid diagrams.

Each session follows a guided flow:

1. Identify the topic (or provide it in your opening message)
2. Choose to update an existing note or start a fresh one
3. Add or continue named sections at your own pace
4. Confirm when each section is done — the agent writes and saves it immediately
5. Optionally enrich sections with Mermaid diagrams (suggested automatically when relevant)

## Prerequisites

No additional installation is required. The plugin works with the VS Code Chat Plugin Marketplace out of the box.

To customise the notes directory, set the `LEARNER_NOTES_DIR` environment variable before starting VS Code:

```sh
# Linux / macOS
export LEARNER_NOTES_DIR="$HOME/work/learner-notes"

# Windows (PowerShell)
$env:LEARNER_NOTES_DIR = "C:\work\learner-notes"
```

If `LEARNER_NOTES_DIR` is not set, the agent falls back to:

| Platform | Default path |
|----------|-------------|
| Windows | `%USERPROFILE%\Documents\LearnerNotes` |
| Linux / macOS | `$HOME/Documents/LearnerNotes` |

## Hooks

| Event | Script | What it does |
|-------|--------|--------------|
| `SessionStart` | `inject-learner-notes-dir.ps1` / `.sh` | Reads `LEARNER_NOTES_DIR` (or uses the platform default) and injects the resolved path into the agent context as `additionalContext`. |

## Agents

| Agent | File | Description |
|-------|------|-------------|
| [Topic Scriber](agents/TopicScriber.agent.md) | `TopicScriber.agent.md` | Interactive agent that guides the learner through creating and updating topic-based study notes, capturing text, images, and Mermaid diagrams in structured Markdown files. |

## Output Document Structure

Each topic note follows this structure:

```
# <Topic>

|Learner|Date|
|--------|------|
|<learner_name>|<current_date>|

-----

[TOC]

-----

## <Section Title>

<Section content>
▸ Mermaid diagram (when applicable)

-----

## <Another Section Title>

<Section content>

-----
```

## File Naming

Topic files are always lowercase, with spaces replaced by hyphens, and stripped of non-alphanumeric/hyphen characters:

| Topic Name | Filename |
|------------|----------|
| `Machine Learning Basics` | `machine-learning-basics.md` |
| `Python Basics!` | `python-basics.md` |
| `Docker Networking` | `docker-networking.md` |

## Configuration Reference

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `LEARNER_NOTES_DIR` | `%USERPROFILE%\Documents\LearnerNotes` (Windows) / `$HOME/Documents/LearnerNotes` (Linux/macOS) | Root directory where all topic note files are stored. |

## Author

[Dimpletz](https://github.com/dimpletz)
