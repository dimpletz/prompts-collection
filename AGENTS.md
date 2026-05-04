## Purpose

This repo is a curated collection of specialized AI prompts for VS Code,
organized as a plugin marketplace. It provides agents (.agent.md), skills
(SKILL.md), and custom instructions (.instructions.md / copilot-instructions.md)
across domains: code quality, unit testing, technical writing, requirements
analysis, git management, software evaluation, and more. Content is pure
Markdown — no build step. Install plugins via VS Code's Chat Plugin Marketplace
using the `dimpletz/prompts-collection` marketplace source.

## Tree

- plugins/ — all plugins, grouped by domain
- plugins/*/README.md — per-plugin documentation
- plugins/*/agents/ — agent definition files (.agent.md)
- plugins/*/skills/ — skill definition files (SKILL.md)
- plugins/*/plugin/ — plugin.json manifest for skill/agent-only plugins
- plugins/*/.claude-plugin/ — plugin.json manifest for plugins that include hooks
- plugins/*/hooks/ — hook configuration files (hooks.json)
- plugins/*/scripts/ — hook scripts referenced by hooks.json
- plugins/technical-writer/ — agents for creating how-to guides, quick reference guides, user guides, and document reviews
- plugins/technical-writer/.claude-plugin/plugin.json — hook-based plugin manifest
- plugins/technical-writer/agents/DocumentReviewer.agent.md — reviews documents from URLs or attachments and produces a multi-section structured Markdown report
- plugins/technical-writer/hooks/hooks.json — SessionStart hook that injects DOC_REVIEWER_DIR into agent context
- plugins/technical-writer/scripts/inject-doc-dir.ps1 — Windows hook script; reads DOC_REVIEWER_DIR env var
- plugins/technical-writer/scripts/inject-doc-dir.sh — Linux/macOS hook script; reads DOC_REVIEWER_DIR env var
- plugins/poetry-user/ — detects poetry.lock and injects Poetry usage context; auto-installs Poetry via pip
- plugins/code-reviewer/agents/LanguageRulesAuditor.agent.md — sub-agent that applies review rules to diff chunks; dispatched by Code Reviewer orchestrator
- plugins/code-reviewer/skills/review-rules-provider/ — skill that loads and concatenates cross-cutting + language-specific review rules
- plugins/code-reviewer/skills/code-review-report-appender/ — skill that appends findings markdown to the shared report file
- custom-instructions/ — global custom instruction files
- CHANGELOG.md — marketplace changelog
- README.md — repo overview, plugin table, agent/skill catalog, usage guide

## Rules

- Before creating a new agent, read an existing agent in the same plugin for structure and conventions
- Before creating a new skill, read plugins/ai-engineer/skills/skill-maker/SKILL.md for the canonical format
- Before modifying README.md, read plugins/developer/skills/readme-maintainer/SKILL.md
- Before modifying CHANGELOG.md, read plugins/developer/skills/changelog-maintainer/SKILL.md
- Every plugin must have a plugin.json manifest — plugins with hooks use `.claude-plugin/plugin.json`; skill/agent-only plugins use `plugin/plugin.json`; never create a plugin without one
- Every agent file uses the .agent.md extension; every skill entry point is SKILL.md
- Keep plugin folders named in kebab-case matching the domain (e.g. git-manager, technical-writer)
- When adding a new plugin, agent, or skill, update the tables in README.md to reflect the addition
- When adding a new agent, update both the Plugins table (Agents column) AND the dedicated Agents catalog section in README.md
- When adding a new skill, update both the Plugins table (Skills column) AND the dedicated Skills catalog section in README.md
- Never update CHANGELOG.md unless the marketplace version in .github/plugin/marketplace.json was explicitly changed by the user
- Always ensure the version in a plugin's plugin.json matches its entry in .github/plugin/marketplace.json
- When a plugin's version in plugin.json is updated, update the matching plugin entry in .github/plugin/marketplace.json to the same version
- When a plugin's version in plugin.json is updated, update the corresponding plugin version in README.md to the same version
- When a plugin's version in plugin.json is updated, update the version in the plugin's own README.md title (e.g. `# Plugin Name \`vX.Y.Z\``) to the same version
- The marketplace version (from .github/plugin/marketplace.json metadata.version) belongs on the ## Plugins heading in README.md, not on the # title
- When the marketplace version in .github/plugin/marketplace.json is updated, update the version on the ## Plugins heading in README.md to match
- Never update the marketplace version in .github/plugin/marketplace.json unless the user explicitly instructs you to do so
- When a new plugin is created, add a corresponding entry in .github/plugin/marketplace.json
- When adding a hook-based plugin, also add a row to the Hooks section table in README.md — not just the Plugins table
- When you create or discover new files, update the Tree above
- Every plugin must have a README.md — never create a plugin without one
- All Markdown content must be clean — no unnecessary code fences wrapping entire documents

## Note-taking

- After each task, log any correction, preference, or pattern learned.
- Write to the matching docs file's "Session learnings" section;
  if none fits, add to Rules above. One dated line, plain language.
  e.g. "Plugin manifests require 'version' field in plugin.json (learned 3/29)"
- 3+ related notes → create a new docs/ file. Move notes there.
  Update the Tree. Keep this file under 100 lines.

## Session learnings

- Hook-based plugins require a row in both the Plugins table AND the Hooks section table in README.md; omitting the Hooks row was caught on review (learned 2026-04-19)
- Agents and Skills sections in README.md are standalone catalogs that must be kept in sync with the Plugins table; sub-agents and new skills were missing from their catalog sections (learned 2026-04-19)
