# Changelog for Marketplace

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