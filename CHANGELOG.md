# Changelog for Marketplace


## 1.13.0 - 2026-04-19

### Added
- python-user plugin (v1.0.0) with a `SessionStart` hook that injects `DEFAULT_PYTHON_VERSION` into the agent context (falling back to `3.14.4`) and a second `SessionStart` hook that detects whether Python is installed — if missing, injects a permission-request prompt instructing the agent to offer installation via the python-installer skill; includes the `python-installer` skill with cross-platform install scripts (`install-python.ps1` / `install-python.sh`) that download and install a specific Python version from the official FTP server
- poetry-user plugin (v1.0.0) with two `SessionStart` hooks: `inject-poetry-context` checks for a `poetry.lock` file and, if found, injects context instructing the agent to always prefer `poetry` commands (`poetry run`, `poetry add`, `poetry install`, `poetry update`, `poetry remove`); `check-poetry` also fires only when `poetry.lock` is detected — if Python is unavailable it injects "poetry requires python", if Poetry is not installed it attempts `pip install poetry` and injects either a success message (with a reminder to restart the terminal) or the pip error output
- poetry-user plugin — adds `vscode-poetry-configurator` skill that checks for an active Poetry virtual environment (running `poetry install` if none exists), then configures `.vscode/settings.json` with `python.defaultInterpreterPath` pointing to the venv's Python executable and `python.terminal.activateEnvironment: true` so all integrated PowerShell terminals automatically activate the environment

### Changed
- current-date-injector plugin updated to v1.2.0 — inject-date scripts now inject only the current date (YYYY-MM-DD), removing the time component
- current-date-injector plugin updated to v1.2.0 — adds `inject-time-command` hook (runs on both `SessionStart` and `SubagentStart`) that injects context describing the command to determine the current time in 24-hr format with timezone information (`(Get-Date).ToString('HH:mm:ss zzz')` on Windows / `date +"%H:%M:%S %Z"` on Linux/macOS)
- python-developer plugin updated to v1.3.0 — removed `SessionStart` hooks (`inject-python-version`, `check-python`) and `python-installer` skill; these have been moved to the new `python-user` plugin; the plugin now exclusively enforces code quality via the `PostToolUse` hook
- meeting-note-taker plugin updated to v1.1.2 — Workflow Step 1 now scans the user's initial prompt for any of the five setup values (subdirectory, filename prefix, meeting title, facilitators, attendees); pre-filled fields are shown with their inferred values for confirmation instead of asking the question from scratch

## 1.12.0 - 2026-04-18

### Added
- python-developer plugin updated to v1.2.0 — adds `python-installer` skill with cross-platform install scripts (`install-python.ps1` / `install-python.sh`) that download and install a specific Python version from the official FTP server
- python-developer plugin updated to v1.2.0 — adds `inject-python-version` SessionStart hook that reads the `DEFAULT_PYTHON_VERSION` environment variable (falling back to `3.14.4`) and injects it into the agent context
- python-developer plugin updated to v1.2.0 — adds `check-python` SessionStart hook that detects whether Python is installed and, if not, injects a permission-request prompt instructing the agent to offer installation via the python-installer skill

### Changed
- markdown-viewer plugin updated to v1.1.1 — install scripts now inject a concise "Python is required for markdown-viewer-app." message when Python is not detected on PATH, instead of the previous verbose install-instructions message
- current-date-injector plugin updated to v1.1.0 — hook scripts now inject both date (YYYY-MM-DD) and time (HH:mm:ss) as `additionalContext` so agents always know the current date and time
- meeting-note-taker plugin updated to v1.1.1 — inject-meeting-dir hook scripts now output `MEETING_DIR="<path>"` format instead of the previous `Meeting notes directory (MEETING_DIR): <path>` format

## 1.11.0 - 2026-04-16

### Changed
- meeting-note-taker plugin updated to v1.1.0 — Meeting Note Taker agent now collects facilitators and attendees during setup (two additional questions); adds optional `## Facilitators` and `## Attendees` sections to the output document; includes a `[TOC]` in the generated file; timestamps the date field with `YYYY-MM-DD HH:mm` format; renames the "Questions and Answers" section to "Q & A"; promotes all document body sections from H1 to H2; fixes a step-numbering bug in the capture workflow
- inject-meeting-dir.ps1 hook now wraps the resolved meeting directory path in quotes in the injected context output

## 1.10.0 - 2026-04-16

### Added
- meeting-note-taker plugin (v1.0.0) with a Meeting Note Taker agent that guides the user through structured meeting note capture; SessionStart hook that reads the `MEETING_DIR` environment variable (falling back to `%USERPROFILE%\Documents\MeetingNotes` on Windows or `$HOME/Documents/MeetingNotes` on Linux/macOS) and injects the resolved path into the agent context; the agent collects notes interactively, analyzes them to produce a summary with optional Mermaid diagrams, an optional Q&A table (questions not answered are marked **UNANSWERED**), an optional actions checklist, and the verbatim original notes, then saves the document to a timestamped file under the configured directory

## 1.10.0 - 2026-04-16

### Added
- meeting-note-taker plugin (v1.0.0) with a Meeting Note Taker agent that guides the user through structured meeting note capture; SessionStart and SubagentStart hooks that read the `MEETING_DIR` environment variable (falling back to `%USERPROFILE%\Documents\MeetingNotes` on Windows or `$HOME/Documents/MeetingNotes` on Linux/macOS) and inject the resolved path into the agent context; the agent collects notes interactively, analyzes them to produce a summary with optional Mermaid diagrams, an optional Q&A table (questions not answered are marked **UNANSWERED**), an optional actions checklist, and the verbatim original notes, then saves the document to a timestamped file under the configured directory

## 1.9.0 - 2026-04-13

### Add
- markdown-viewer plugin updated to v1.1.0 — adds `inject-mdview-params` SessionStart hook that reads `MDVIEW_BROWSER` and `MDVIEW_PORT` environment variables and injects preferred mdview parameters into the agent context; outputs nothing if neither variable is set

## 1.8.0 - 2026-04-13

### Added
- markdown-viewer plugin (v1.0.0) with a SessionStart hook that installs `markdown-viewer-app` via pip when Python is available, and a Markdown Viewer skill that runs `mdview <file>` to open any markdown file in a browser with optional `--browser` and `-p` (port) parameters; notifies the user if Python is absent or installation fails; also handles stopping the background server on request

### Changed
- Merged developer-id-injector plugin into developer plugin (v1.1.0) — SessionStart and SubagentStart hooks that inject the developer name from the `DEVELOPER_NAME` environment variable are now part of the developer plugin
- developer plugin updated to v1.2.0 — developer name injector hook now supports `DEVELOPER_EMAIL` and `DEVELOPER_COUNTRY` environment variables in addition to `DEVELOPER_NAME`; any combination of the three variables can be set and only those that are present are injected into the agent context

### Removed
- developer-id-injector plugin — functionality consolidated into the developer plugin

## 1.7.0 - 2026-04-13

### Added
- current-date-injector plugin (v1.0.0) with SessionStart and SubagentStart hooks that inject the current date (YYYY-MM-DD) into the agent context automatically — once when a session begins and once per subagent spawned
- developer-id-injector plugin (v1.0.0) with SessionStart and SubagentStart hooks that inject the developer name from the `DEVELOPER_NAME` environment variable into the agent context automatically — once when a session begins and once per subagent spawned; outputs nothing if the variable is not set

## 1.6.0 - 2026-04-05

### Added
- python-developer plugin (v1.0.0) with a PostToolUse hook that runs `black` on all Python files and `pylint` on all non-test Python files after every Python file modification; missing `black` or `pylint` produces a blocking error with installation instructions

## 1.5.2 - 2026-04-04

### Changed
- Custom Instruction Maker skill updated to restrict the Tree section to main folders and important files only — individual source files are no longer enumerated
- ai-engineer plugin updated to v1.0.1

## 1.5.1 - 2026-04-02

### Changed
- Git Merge Auditor skill updated to audit binary file changes (*.jar, *.exe, etc.) — confirms add/replace/remove operations are mirrored in the target branch
- Changelog Maintainer skill updated to support a fourth `Removed` section, skip lock files during diff analysis, handle binary files with high-level add/replace/remove entries, and fix the "entirely removed file" heuristic to classify under `Removed` instead of `Changed`
- git-manager plugin updated to v1.1.1
- developer plugin updated to v1.0.2

## 1.5.0 - 2026-04-01

### Added
- Git Merge Auditor skill in the git-manager plugin for verifying that a target branch contains all commits and changes from a source branch

### Changed
- Enhance Comprehensive Code Quality Reviewer agent with executive summary, production readiness assessment, Confluence-ready Markdown report output, and improved finding structure with file-path links and descriptive titles
- Enhance Changelog Maintainer skill to detect staged index changes in addition to committed git history
- Renamed makers plugin to ai-engineer
- git-manager plugin updated to v1.1.0
- developer plugin updated to v1.0.1

## 1.4.0 - 2026-03-29

### Added
- Custom Instruction Maker skill in the makers plugin for creating AGENTS.md, copilot-instructions.md, CLAUDE.md, and similar AI instruction files

### Changed
- Makers plugin updated to v1.1.0

## 1.3.0 - 2026-03-29

### Changed
- Reorganize to add plugin in support.