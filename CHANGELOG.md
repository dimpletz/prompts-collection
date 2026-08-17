# Changelog for Marketplace

## 1.30.1 - 2026-08-17

### Changed
- okf-manager plugin updated to v1.1.1 — `create-okf` skill subdirectory bullets in `index.md` now link to `<directory-name>/index.md` instead of the bare `<directory-name>/` directory path, enabling direct file navigation
- okf-manager plugin updated to v1.1.1 — `create-okf` and `update-okf` skills add a "Full detail, no summarizing" priority: concept body content must be written as completely and thoroughly as possible; shortening, abbreviating, or summarizing content is forbidden
- okf-manager plugin updated to v1.1.1 — `create-okf` and `update-okf` skills add an "Exhaust all concepts from a source" priority and Step 1D: when a file, document, or list is provided as input, every identified concept must be extracted and processed without stopping early or deferring any item
- okf-manager plugin updated to v1.1.1 — `create-okf` and `update-okf` skills enforce `index.md` description quality: every bullet entry must contain a clear, complete, human-readable sentence; empty descriptions and placeholder text are forbidden
- okf-manager plugin updated to v1.1.1 — `create-okf` and `update-okf` skills add Step 8 (Completion Verification): after all concepts are written or updated, a final integrity check confirms the concept roster is complete, all bundle-relative cross-references resolve to existing files, and every `index.md` lists all concepts and subdirectories with meaningful descriptions

## 1.30.0 - 2026-08-17

### Changed
- okf-manager plugin updated to v1.1.0 — `create-okf` skill adds mandatory extraction rules: procedural content (steps, runbooks, how-tos) must be extracted into a separate `Playbook` concept and inline computations must be extracted into a separate `Attested Computation` concept before writing; non-procedural asset concepts (Metric, BigQuery Table, API Endpoint, etc.) must not contain a procedure body
- okf-manager plugin updated to v1.1.0 — `create-okf` skill adds Linking Rules section: body cross-links must use bundle-relative or relative paths (never inline external URLs); external sources belong in `sources` frontmatter entries cited via footnotes; adds Reference concept materialization workflow for substantive external documents fetched during a session; adds Priority 9 for bundle cross-linking (scan for related concepts and add back-links after creation)
- okf-manager plugin updated to v1.1.0 — `update-okf` skill adds decomposition check: prompts extraction of procedural or computation content when updating a concept that mixes concerns; adds the same Linking Rules section as `create-okf` to enforce consistent cross-linking behaviour on update
- okf-manager plugin updated to v1.1.0 — `attach-okf` skill now accepts multiple bundle directories (input renamed from `bundle_directory` to `bundle_directories`); section header in target files renamed from `## OKF Bundle` to `## Primary Knowledge Source`; idempotency is now evaluated per bundle so already-attached bundles are skipped while new ones are added
- ai-engineer plugin — OKF reference concept renamed from `vscode-agent-customization-hooks.md` to `vscode-agent-hooks.md`; hook-maker skill updated to reference the new path

### Fixed
- README corrected code-reviewer hooks column: removed erroneous `SubagentStop` entry; the plugin only registers a `SessionStart` hook

### Removed
- `agent-command-inspector` plugin removed from marketplace and documentation; plugin was listed but its files were never created

## 1.29.0 - 2026-08-16

### Added
- okf-manager plugin v1.0.0 — adds `create-okf` skill that creates a new OKF v0.2 concept document (with YAML frontmatter) inside a bundle directory and optionally updates `index.md` and appends a creation entry to `log.md`
- okf-manager plugin v1.0.0 — adds `update-okf` skill that updates frontmatter fields and/or body content of an existing OKF concept document in place
- okf-manager plugin v1.0.0 — adds `search-okf` skill that searches an OKF bundle for concept documents matching type, tag, or free-text filters and returns a summary table
- okf-manager plugin v1.0.0 — adds `delete-okf` skill that deprecates (default) or permanently removes an OKF concept document from a bundle
- okf-manager plugin v1.0.0 — adds `attach-okf` skill that hooks an OKF bundle into a project directory, agent file, or skill file by injecting a bundle-use rule into the applicable instruction file
- okf-manager plugin v1.0.0 — adds `SessionStart`/`SubagentStart` hook that injects `OKF_DEFAULT_BUNDLE_DIR` into agent context; includes PowerShell and shell script variants
- ai-engineer plugin updated to v1.5.0 — adds OKF bundle at `okf/` containing a VS Code agent customization hooks reference document covering lifecycle events, configuration format, input/output schema, and usage scenarios

### Changed
- ai-engineer plugin updated to v1.5.0 — `hook-maker` skill removes all inline hook reference documentation (lifecycle events table, per-event output schemas, hook command properties table) and replaces them with references to the OKF bundle at `../../okf`

## 1.28.0 - 2026-07-04

### Changed
- meeting-note-taker plugin updated to v1.2.0 — `Meeting Note Taker` agent no longer includes the verbatim `## Original Notes` section in the generated document; attendees are now listed immediately after facilitators in the output
- technical-writer plugin updated to v1.2.1 — `Architectural Designer` agent removes the `Source References` subsection from the Context section; all source references (PRDs, business cases, RFCs, ADRs, diagrams, and external resources) are now consolidated into the `## References` section at the end of the document

## 1.27.0 - 2026-06-13

### Added
- instructor plugin v1.0.0 — adds `Module Maker` agent that creates a complete, self-contained learning module covering theory, practical applications with examples, and a single end-to-end project for any topic; automatically hands off to `Narration Script Writer` after saving the module
- instructor plugin v1.0.0 — adds `Narration Script Writer` agent that generates a speaker-ready video narration script from a completed learning module file; can be invoked by Module Maker or independently
- instructor plugin v1.0.0 — adds `SessionStart` hook that injects `MODULE_DIR` as `INSTRUCTOR_MODULE_DIR` into agent context; includes PowerShell and shell script variants

## 1.26.0 - 2026-06-13

### Changed
- poetry-user plugin updated to v1.1.0 — `vscode-poetry-configurator` skill now also configures `python-envs.defaultEnvManager` and `python-envs.defaultPackageManager` to `ms-python.python:poetry` in `.vscode/settings.json`

## 1.25.1 - 2026-06-07

### Changed
- code-reviewer plugin updated to v1.0.2 — patch version bump; no functional changes

## 1.25.0 - 2026-05-23

### Added
- technical-writer plugin updated to v1.2.0 — adds `Architectural Designer` agent that synthesizes one or more sources (URLs, files, pasted text, images) into a comprehensive architectural design document covering overview, context, goals, architecture overview, design tradeoffs, component breakdown, impact analysis, security, scalability, quality attributes, low-level design, testing, and deployment; uses Mermaid diagrams; saves to `DOC_ARCHITECTURE_DIR` or `<workspace root>/doc-architecture/`
- technical-writer plugin updated to v1.2.0 — adds `Proposal Writer` agent that synthesizes one or more sources into a professional Markdown proposal covering title page, executive summary, background, scope, approach, timeline, roles, deliverables, budget, risks, qualifications, terms, benefits, and acceptance; saves to `DOC_PROPOSAL_DIR` or `<workspace root>/doc-proposals/`

### Changed
- technical-writer plugin updated to v1.2.0 — replaces `inject-doc-dir` hook script with `inject-env-variables` script that injects both `DOC_REVIEWER_DIR` and `DOC_PROPOSAL_DIR` environment variables into agent context; includes PowerShell and shell script variants

## 1.24.0 - 2026-05-22

### Added
- git-manager plugin updated to v1.4.0 — adds `git-encoding-normalizer` skill that detects whether a tracked text file changed only because of line-ending churn or mixed encodings, then restores the file to the encoding and newline style used in Git history; supports optional reference commit and auto-restaging of previously staged files

### Changed
- git-manager plugin updated to v1.4.0 — `git-diff-generator` skill now supports additional source types: commit ranges, single commits, and staged files; uses `^!` syntax for single-commit diffs and `--cached` for staged file diffs in addition to existing branch and PR sources

## 1.23.0 - 2026-05-22

### Changed
- markdown-viewer plugin updated to v1.2.0 — adds `check-mdview-update` SessionStart hook that checks whether a newer version of `markdown-viewer-app` is available via pip and, if one is found, injects context instructing the agent to notify the user before executing the `mdview` command and offer to upgrade; includes PowerShell and shell script variants

## 1.22.0 - 2026-05-15

### Changed
- ai-engineer plugin updated to v1.4.0 — refines lifecycle hook guidance so large, simple file handling uses direct shell/PowerShell commands and large, complex file handling uses temporary scripts in the system temp directory with cleanup after use
- ai-engineer plugin updated to v1.4.0 — updates `hook-maker` guidance to clearly separate lifecycle hook script paths from skill companion script paths
- ai-engineer plugin updated to v1.4.0 — updates `skill-maker` to support explicit `skill_scripts` input and enforce companion script placement under each skill’s `scripts/` directory

## 1.21.0 - 2026-05-04

### Added
- technical-writer plugin updated to v1.1.0 — adds `Document Reviewer` agent that reviews documents from URLs or attachments and produces a structured multi-section Markdown report (summary, observations, clarity, structure, concerns, recommendations, overall 1–5 rating); report saved to `DOC_REVIEWER_DIR` or `<workspace root>/doc-reviews/`
- technical-writer plugin updated to v1.1.0 — adds `SessionStart` hook (`inject-doc-dir`) that reads the `DOC_REVIEWER_DIR` environment variable and injects it into agent context; includes PowerShell and shell script variants

### Changed
- technical-writer plugin updated to v1.1.0 — migrated from agent-only manifest (`plugin/plugin.json`) to hook-based manifest (`.claude-plugin/plugin.json`) to support the new `SessionStart` hook

## 1.20.1 - 2026-05-04

### Changed
- code-reviewer plugin updated to v1.0.1 — patch version bump; no functional changes

## 1.20.0 - 2026-05-04

### Added
- code-reviewer plugin (v1.0.0) — adds `Code Reviewer` orchestrator agent that drives a full diff-based code review: splits the diff with the `diff-chunker` skill, dispatches the `Language Rules Auditor` sub-agent for each chunk, and produces a structured Markdown report saved to `CODE_REVIEW_DIFF_DIR` or `<workspace>/code-reviews/`
- code-reviewer plugin (v1.0.0) — adds `Language Rules Auditor` sub-agent that reviews all files in a diff chunk against cross-cutting and language-specific rule sets (C#, Java, JavaScript, Magento, PHP, Python), falling back to built-in expertise for unmatched file types, and appends findings to the shared report via the `code-review-report-appender` skill
- code-reviewer plugin (v1.0.0) — adds `review-rules-provider` skill that loads and concatenates cross-cutting and language-specific review rules from `config/rules/` for a given set of languages
- code-reviewer plugin (v1.0.0) — adds `diff-chunker` skill that splits an oversized diff file into smaller chunk files
- code-reviewer plugin (v1.0.0) — adds `code-review-report-appender` skill that appends findings Markdown to the shared review report file
- code-reviewer plugin (v1.0.0) — adds `SessionStart` hook (`inject-configs`) that injects `CODE_REVIEW_DIFF_CHUNK_MAX_LINES` and related config into the agent context; includes PowerShell and shell script variants

## 1.19.0 - 2026-05-01

### Changed
- ai-engineer plugin updated to v1.3.0 — `plugin-maker` skill now treats all plugin components (agents, skills, hooks, MCP) as optional, allowing minimal plugins to be scaffolded without requiring every component type

## 1.18.0 - 2026-04-30

### Changed
- learner plugin updated to v1.1.0 — `Topic Scriber` agent now asks the learner for an optional sub-directory at the start of each session; the sub-directory is created under the resolved notes directory and can be any number of levels deep (e.g. `work/docker` or `school/math/calculus`); all topic files for the session are saved in the effective save directory; if no sub-directory is provided, notes are saved directly in the root notes folder

## 1.17.0 - 2026-04-26

### Added
- ai-engineer plugin updated to v1.2.0 — adds `hook-maker` skill for creating VS Code Copilot agent hook configurations (`hooks.json` and companion shell/PowerShell scripts) for any lifecycle event (`SessionStart`, `SubagentStart`, `PostToolUse`)
- ai-engineer plugin updated to v1.2.0 — adds `plugin-maker` skill that scaffolds a complete VS Code Copilot agent plugin with the correct manifest (`.claude-plugin/plugin.json` for hook-based plugins, `plugin/plugin.json` for skill/agent-only plugins), directory structure, README, and marketplace registration
- ai-engineer plugin updated to v1.2.0 — adds `marketplace-maker` skill that registers, synchronizes, and updates the project's plugins in the VS Code Chat Plugin Marketplace by keeping `marketplace.json` and the global `README.md` in sync with the actual plugin contents

### Changed
- ai-engineer plugin updated to v1.2.0 — plugin description updated to reflect the expanded scope (hooks, plugins, and marketplace management in addition to agents, skills, and custom instructions)

## 1.16.1 - 2026-04-26

### Changed
- learner plugin updated to v1.0.1 — `Topic Scriber` agent now auto-generates Mermaid diagrams immediately after a section is completed when the content would benefit from one, removing the previous confirmation prompt

## 1.16.0 - 2026-04-26

### Added
- learner plugin (v1.0.0) — adds `Topic Scriber` agent that guides learners through creating and updating personal study notes organised by topic; captures typed text, pasted content, and images then writes structured Markdown files with named sections, Mermaid diagrams, and a table of contents; one Markdown file per topic stored in a configurable notes directory
- learner plugin (v1.0.0) — adds `SessionStart` hook (`inject-learner-notes-dir`) that reads the `LEARNER_NOTES_DIR` environment variable and injects its value into the agent context so the Topic Scriber agent knows where to store notes without prompting

## 1.15.0 - 2026-04-21

### Added
- git-manager plugin updated to v1.3.0 — `git-diff-generator` skill adds `first_commit` source input that diffs the repository's very first (root) commit against Git's empty tree (`4b825dc642cb6eb9a060e54bf8d69288fbee4904`), producing a self-contained diff of everything introduced by the initial commit; no target branch is required for this source type

### Changed
- git-manager plugin updated to v1.3.0 — `git-diff-generator` skill makes `target_branch` optional when source is `first_commit` (not needed since the diff targets Git's empty tree)
- git-manager plugin updated to v1.3.0 — `git-diff-generator` skill now always generates a fresh diff file on every invocation and never reads or loads an existing diff file from the output directory unless the user explicitly requests it
- git-manager plugin updated to v1.3.0 — `git-diff-generator` skill uses `git rev-list --reverse HEAD | head -1` (or `Select-Object -First 1` on PowerShell) to reliably resolve the chronologically earliest ancestor reachable from `HEAD`

## 1.14.0 - 2026-04-21

### Added
- git-manager plugin updated to v1.2.0 — adds `git-diff-generator` skill that generates a `.diff` file comparing a source (pull request ID, currently checked-out branch, or remote branch) against a target branch using three-dot diff semantics; saves diff files to `GIT_DIFF_DIR` when set, otherwise to the current workspace root
- git-manager plugin updated to v1.2.0 — adds `SessionStart` and `SubagentStart` hooks (`inject-git-diff-dir`) that read the `GIT_DIFF_DIR` environment variable and inject its value into agent context

### Changed
- git-manager plugin updated to v1.2.0 — renames `pr-cloner` skill to `git-pr-cloner` for naming consistency; plugin manifest converted from `plugin/plugin.json` to hook-based `.claude-plugin/plugin.json`
- current-date-injector plugin updated to v1.3.0 — consolidates `inject-date` and `inject-time-command` into a single `inject-date` script that outputs both the date command hint and the time command hint as `additionalContext`

### Removed
- current-date-injector plugin updated to v1.3.0 — removes redundant `inject-time-command.ps1` and `inject-time-command.sh` scripts and their corresponding hook entries from `hooks.json`

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
