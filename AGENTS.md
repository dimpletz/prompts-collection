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
- plugins/analyst/ — requirements specifications and solution design agents
- plugins/developer/ — code quality reviewers, unit test generators, release notes, changelog/README skills
- plugins/dotnet-developer/ — .NET/C# unit test generation agent
- plugins/git-manager/ — git merge conflict resolver, worktree manager, PR cloner skills
- plugins/leader/ — presentation creator agent
- plugins/makers/ — agent-maker, agent-optimizer, skill-maker, custom-instruction-maker skills
- plugins/php-developer/ — PHP/Magento unit test generation agent
- plugins/software-evaluator/ — cloud-native and procurement evaluation agents
- plugins/technical-writer/ — how-to, quick reference, and user guide generators
- plugins/tester/ — test case generation agent
- plugins/*/agents/ — agent definition files (.agent.md)
- plugins/*/skills/ — skill definition files (SKILL.md)
- plugins/*/plugin/ — plugin.json manifest for each plugin
- custom-instructions/ — global custom instruction files
- custom-instructions/copilot-instructions.md — universal coding standards (all languages)
- custom-instructions/PHP-Magento.instructions.md — PHP & Magento 2 standards
- .github/plugin/marketplace.json — marketplace manifest listing all plugins and their versions
- .github/skills/ — internal skills used by this repo's own workflows
- CHANGELOG.md — marketplace changelog
- README.md — repo overview, plugin table, agent/skill catalog, usage guide

## Rules

- Before creating a new agent, read an existing agent in the same plugin for structure and conventions
- Before creating a new skill, read plugins/makers/skills/skill-maker/SKILL.md for the canonical format
- Before modifying README.md, read plugins/developer/skills/readme-maintainer/SKILL.md
- Before modifying CHANGELOG.md, read plugins/developer/skills/changelog-maintainer/SKILL.md
- Every plugin must have a plugin/plugin.json manifest — never create a plugin without one
- Every agent file uses the .agent.md extension; every skill entry point is SKILL.md
- Keep plugin folders named in kebab-case matching the domain (e.g. git-manager, technical-writer)
- When adding a new plugin, agent, or skill, update the tables in README.md to reflect the addition
- When adding a new plugin, add a CHANGELOG.md entry under the current version
- Always ensure the version in a plugin's plugin.json matches its entry in .github/plugin/marketplace.json
- When a plugin's version in plugin.json is updated, update the matching plugin entry in .github/plugin/marketplace.json to the same version
- When a new plugin is created, add a corresponding entry in .github/plugin/marketplace.json
- Any update to .github/plugin/marketplace.json must increment the minor version in its metadata.version field
- When you create or discover new files, update the Tree above
- All Markdown content must be clean — no unnecessary code fences wrapping entire documents

## Note-taking

- After each task, log any correction, preference, or pattern learned.
- Write to the matching docs file's "Session learnings" section;
  if none fits, add to Rules above. One dated line, plain language.
  e.g. "Plugin manifests require 'version' field in plugin.json (learned 3/29)"
- 3+ related notes → create a new docs/ file. Move notes there.
  Update the Tree. Keep this file under 100 lines.
