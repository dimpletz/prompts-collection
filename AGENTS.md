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
- plugins/technical-writer/scripts/inject-env-variables.ps1 — Windows hook script; reads DOC_REVIEWER_DIR and DOC_PROPOSAL_DIR env vars
- plugins/technical-writer/scripts/inject-env-variables.sh — Linux/macOS hook script; reads DOC_REVIEWER_DIR and DOC_PROPOSAL_DIR env vars
- plugins/instructor/ — agent for creating complete learning modules covering theory, practical applications, and a single end-to-end project
- plugins/instructor/.claude-plugin/plugin.json — hook-based plugin manifest for instructor
- plugins/instructor/agents/ModuleMaker.agent.md — creates a complete teaching module from theory through examples to a finish-to-finish project; hands off automatically to Narration Script Writer
- plugins/instructor/agents/NarrationScriptWriter.agent.md — generates a speaker-ready video narration script from a completed module file; invoked by Module Maker or independently
- plugins/instructor/hooks/hooks.json — SessionStart hook that injects MODULE_DIR into agent context as INSTRUCTOR_MODULE_DIR
- plugins/instructor/scripts/inject-module-dir.ps1 — Windows hook script; reads MODULE_DIR env var
- plugins/instructor/scripts/inject-module-dir.sh — Linux/macOS hook script; reads MODULE_DIR env var
- plugins/poetry-user/ — detects poetry.lock and injects Poetry usage context; auto-installs Poetry via pip
- plugins/ai-engineer/.claude-plugin/plugin.json — hook-based plugin manifest for ai-engineer
- plugins/ai-engineer/hooks/hooks.json — SessionStart/SubagentStart hooks that inject temporary-script guidance for large-file handling
- plugins/ai-engineer/scripts/inject-temporary-script-guidance.sh — Linux/macOS hook script for temporary-script guidance
- plugins/ai-engineer/scripts/inject-temporary-script-guidance.ps1 — Windows hook script for temporary-script guidance
- plugins/code-reviewer/agents/LanguageRulesAuditor.agent.md — sub-agent that applies review rules to diff chunks; dispatched by Code Reviewer orchestrator
- plugins/code-reviewer/skills/review-rules-provider/ — skill that loads and concatenates cross-cutting + language-specific review rules
- plugins/code-reviewer/skills/code-review-report-appender/ — skill that appends findings markdown to the shared report file
- plugins/okf-manager/ — skills for managing OKF v0.2 bundle concept documents (create, update, search, delete)
- plugins/okf-manager/.claude-plugin/plugin.json — hook-based plugin manifest for okf-manager
- plugins/okf-manager/hooks/hooks.json — SessionStart/SubagentStart hook that injects OKF_DEFAULT_BUNDLE_DIR into agent context
- plugins/okf-manager/scripts/inject-okf-bundle-dir.ps1 — Windows hook script; reads OKF_DEFAULT_BUNDLE_DIR env var
- plugins/okf-manager/scripts/inject-okf-bundle-dir.sh — Linux/macOS hook script; reads OKF_DEFAULT_BUNDLE_DIR env var
- plugins/okf-manager/skills/create-okf/ — creates a new OKF v0.2 concept document in a bundle directory
- plugins/okf-manager/skills/update-okf/ — updates frontmatter and/or body of an existing OKF concept document
- plugins/okf-manager/skills/search-okf/ — searches an OKF bundle for concept documents matching filters or a free-text query
- plugins/okf-manager/skills/delete-okf/ — deprecates or removes an OKF concept document from a bundle
- plugins/okf-manager/skills/attach-okf/ — hooks an OKF bundle into a project directory by injecting a bundle-use rule into the project's instruction file
- plugins/agent-command-inspector/ — hook that intercepts run_in_terminal calls and requires confirmation when a destructive command pattern is detected
- plugins/agent-command-inspector/.claude-plugin/plugin.json — hook-based plugin manifest for agent-command-inspector
- plugins/agent-command-inspector/hooks/hooks.json — PreToolUse hook that triggers the command inspector script
- plugins/agent-command-inspector/scripts/inspect-command.py — reads PreToolUse stdin, checks patterns, returns permissionDecision:"ask" on match
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
- When adding a new agent or skill to a plugin, update the `keywords` array in that plugin's plugin.json to include relevant terms for the new agent or skill
- When adding a new agent, update both the Plugins table (Agents column) AND the dedicated Agents catalog section in README.md
- When adding a new skill, update both the Plugins table (Skills column) AND the dedicated Skills catalog section in README.md
- Never update CHANGELOG.md unless the marketplace version in .github/plugin/marketplace.json was explicitly changed by the user
- Always ensure the version in a plugin's plugin.json matches its entry in .github/plugin/marketplace.json
- When a plugin's version in plugin.json is updated, update the matching plugin entry in .github/plugin/marketplace.json to the same version
- When a plugin's version in plugin.json is updated, update the corresponding plugin version in README.md to the same version
- When a plugin's version in plugin.json is updated, update the version in the plugin's own README.md title (e.g. `# Plugin Name \`vX.Y.Z\``) to the same version
- The marketplace version (from .github/plugin/marketplace.json metadata.version) belongs on the ## Marketplace heading in README.md, not on the # title; the version must not be enclosed in backticks or quotes (e.g. `## Marketplace v1.23.0`, not `## Marketplace \`v1.23.0\``)
- When the marketplace version in .github/plugin/marketplace.json is updated, update the version on the ## Marketplace heading in README.md to match
- Never update the marketplace version in .github/plugin/marketplace.json unless the user explicitly instructs you to do so
- When a new plugin is created, add a corresponding entry in .github/plugin/marketplace.json
- When adding a hook-based plugin, also add a row to the Hooks section table in README.md — not just the Plugins table
- The Plugins table must include a Requires column (after Description) listing other plugins whose agents or skills are used; use — if there are no cross-plugin dependencies
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
- Skill companion scripts must live under each skill directory (`skills/<skill-name>/scripts/`) rather than plugin-level `scripts/` (learned 2026-05-14)
- README.md has no dedicated Hooks section table; the `Hooks` column in the Plugins table is the hooks catalog — skip the "Hooks section table" rule until that section is added (learned 2026-08-16)
