# Changelog for Marketplace

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