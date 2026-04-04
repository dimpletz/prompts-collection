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
- plugins/*/agents/ — agent definition files (.agent.md)
- plugins/*/skills/ — skill definition files (SKILL.md)
- plugins/*/plugin/ — plugin.json manifest for each plugin
- plugins/*/hooks/ — hook configuration files (hooks.json)
- plugins/*/scripts/ — hook scripts referenced by hooks.json
- plugins/python-developer/plugin/plugin.json — python-developer manifest
- plugins/python-developer/hooks/hooks.json — PostToolUse hook config
- plugins/python-developer/scripts/python-quality.py — black + pylint hook script
- custom-instructions/ — global custom instruction files
- CHANGELOG.md — marketplace changelog
- README.md — repo overview, plugin table, agent/skill catalog, usage guide

## Rules

- Before creating a new agent, read an existing agent in the same plugin for structure and conventions
- Before creating a new skill, read plugins/ai-engineer/skills/skill-maker/SKILL.md for the canonical format
- Before modifying README.md, read plugins/developer/skills/readme-maintainer/SKILL.md
- Before modifying CHANGELOG.md, read plugins/developer/skills/changelog-maintainer/SKILL.md
- Every plugin must have a plugin/plugin.json manifest — never create a plugin without one
- Every agent file uses the .agent.md extension; every skill entry point is SKILL.md
- Keep plugin folders named in kebab-case matching the domain (e.g. git-manager, technical-writer)
- When adding a new plugin, agent, or skill, update the tables in README.md to reflect the addition
- When adding a new plugin, add a CHANGELOG.md entry under the current version
- Always ensure the version in a plugin's plugin.json matches its entry in .github/plugin/marketplace.json
- When a plugin's version in plugin.json is updated, update the matching plugin entry in .github/plugin/marketplace.json to the same version
- When a plugin's version in plugin.json is updated, update the corresponding plugin version in README.md to the same version
- The marketplace version (from .github/plugin/marketplace.json metadata.version) belongs on the ## Plugins heading in README.md, not on the # title
- When the marketplace version in .github/plugin/marketplace.json is updated, update the version on the ## Plugins heading in README.md to match
- When a new plugin is created, add a corresponding entry in .github/plugin/marketplace.json
- When you create or discover new files, update the Tree above
- All Markdown content must be clean — no unnecessary code fences wrapping entire documents

## Note-taking

- After each task, log any correction, preference, or pattern learned.
- Write to the matching docs file's "Session learnings" section;
  if none fits, add to Rules above. One dated line, plain language.
  e.g. "Plugin manifests require 'version' field in plugin.json (learned 3/29)"
- 3+ related notes → create a new docs/ file. Move notes there.
  Update the Tree. Keep this file under 100 lines.
