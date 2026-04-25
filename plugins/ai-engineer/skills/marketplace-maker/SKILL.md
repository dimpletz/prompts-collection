---
name: marketplace-maker
description: >
  A skill for registering and exposing the current project's plugins in the VS Code Chat Plugin Marketplace. Use it whenever the user wants to publish a new plugin, update the marketplace listing, or synchronize the marketplace.json and README.md with the current set of plugins. Do not use it for creating plugin manifests, skills, agents, or hooks — use the dedicated maker skills for those.
---

# Marketplace Maker

This **skill** is for developers who need to expose one or more plugins from the current repository to the VS Code Chat Plugin Marketplace. It ensures that `.github/plugin/marketplace.json` is correct, complete, and consistent with all `plugin.json` manifests in the `plugins/` directory, and that the global `README.md` accurately reflects every plugin, agent, skill, and hook in the marketplace.

## Inputs

- **action** (required): What to do — one of:
  - `add` — register one or more new plugins in the marketplace.
  - `sync` — synchronize the entire marketplace.json and README.md with the actual contents of the `plugins/` directory.
  - `update` — update an existing plugin entry (version, description, or metadata).
  - `remove` — remove a plugin entry from marketplace.json (does not delete plugin files).
- **plugin_names** (optional): Comma-separated list of plugin names to act on (for `add`, `update`, `remove`). If omitted with `sync`, all plugins are inspected.
- **marketplace_version** (optional): A new semver version for the overall marketplace (`metadata.version` in `marketplace.json`). Only update this when explicitly instructed by the user — never auto-increment it.

## Task Priorities

1. **Priority 1 – Consistency between plugin.json and marketplace.json**
   Every plugin entry in `marketplace.json` must have a `version` and `description` that exactly matches the corresponding `plugin.json` or `.claude-plugin/plugin.json`. Mismatches cause stale or broken marketplace listings.

2. **Priority 2 – Complete README.md catalog**
   The global `README.md` must accurately list every plugin (Plugins table), every agent (Agents section), every skill (Skills section), and every hook (Hooks section). Missing entries reduce discoverability.

3. **Priority 3 – No unauthorized version changes**
   Never change the marketplace `metadata.version` unless the user explicitly provides a new value. Never change a plugin's `version` in `plugin.json` unless the user explicitly requests a version bump.

## Workflow

### Step 1 – Understand the Request

- Read **action** and **plugin_names** carefully.
- For `sync`: scan every folder under `plugins/` and compare against `marketplace.json`.
- For `add` / `update` / `remove`: operate only on the named plugins.
- Identify the current marketplace version from `metadata.version` in `.github/plugin/marketplace.json` — do not change it unless **marketplace_version** was explicitly provided.

### Step 2 – Discover Plugin Metadata

For each plugin being processed:

1. **Locate the manifest**: check for `.claude-plugin/plugin.json` first, then `plugin/plugin.json`.
2. **Read required fields**: `name`, `description`, `version`.
3. **Inventory capabilities**:
   - **Skills**: list directories under `plugins/<name>/skills/` that contain a `SKILL.md`.
   - **Agents**: list `.agent.md` files under `plugins/<name>/agents/`.
   - **Hooks**: read `plugins/<name>/hooks/hooks.json` to identify hook events (`SessionStart`, `SubagentStart`, `PostToolUse`).
4. If a manifest is missing required fields, report the gap and ask the user before proceeding.

### Step 3 – Update marketplace.json

File location: `.github/plugin/marketplace.json`

Structure:

```json
{
  "name": "<repo-name>",
  "metadata": {
    "description": "<repo description>",
    "version": "<marketplace-semver>",
    "pluginRoot": "./plugins"
  },
  "owner": {
    "name": "<owner>"
  },
  "plugins": [
    {
      "name": "<plugin-name>",
      "source": "<plugin-folder-name>",
      "description": "<One sentence from plugin.json description.>",
      "version": "<version from plugin.json>"
    }
  ]
}
```

Rules:
- For `add`: append a new entry to `"plugins"`. The `"source"` must match the folder name under `plugins/`.
- For `update`: find the entry by `"name"` and update only `"description"` and/or `"version"` as needed.
- For `remove`: remove the entry from `"plugins"`. Do not delete any plugin files.
- For `sync`: ensure every plugin folder has a matching entry; add missing ones, update stale ones, report orphan entries (entries with no matching folder) for user review.
- Never change `metadata.version` unless the user provided **marketplace_version**.
- Preserve the existing ordering of entries unless explicitly asked to reorder.

### Step 4 – Update README.md

The global `README.md` contains four catalog sections that must stay in sync with the marketplace.

#### A. Plugins Table

Located under `## Plugins`. Each row:

```markdown
| [<plugin-name>](plugins/<plugin-name>/) `v<version>` | <description> | <agent links or —> | <skill links or —> | <hook events or —> |
```

- List agents as comma-separated Markdown links to their `.agent.md` files.
- List skills as comma-separated Markdown links to their `SKILL.md` files.
- List hook events as backtick-formatted event names (e.g. `` `SessionStart` ``).
- Use `—` for columns with no entries.

#### B. Agents Section

Located under `## Agents`. Agents are grouped by functional category. For each agent:

```markdown
| [<Agent Display Name>](plugins/<plugin>/<path>.agent.md) | <plugin-name> | <One-sentence description from the agent's `description` frontmatter field.> |
```

Add the agent to the most relevant existing category, or create a new category heading if none fits.

#### C. Skills Section

Located under `## Skills`. For each skill:

```markdown
| [<Skill Display Name>](plugins/<plugin>/skills/<skill-name>/SKILL.md) | <plugin-name> | <One-sentence description from the skill's `description` frontmatter field.> |
```

#### D. Hooks Section

Located under `## Hooks`. For each hook-enabled plugin:

```markdown
| [<plugin-name>](plugins/<plugin-name>/) | `<HookEvent>`, `<HookEvent>` | <What the hook does — one sentence.> |
```

Rules:
- Add to the Plugins table, Agents section, Skills section, and Hooks section as appropriate.
- Do not remove entries for plugins that still exist.
- When `sync`, update stale descriptions and versions in the table.

### Step 5 – Validate

Before saving:

1. **marketplace.json** — Every plugin in `plugins/` with a valid manifest has an entry. Every entry's `version` matches its `plugin.json`. No duplicate `"name"` values.
2. **Plugins table** — Every `marketplace.json` plugin appears in the table. Version badge matches `plugin.json`. Agent, skill, and hook columns are accurate.
3. **Agents section** — Every `.agent.md` file in every plugin appears in the catalog. No duplicates.
4. **Skills section** — Every `SKILL.md` file in every plugin appears in the catalog. No duplicates.
5. **Hooks section** — Every plugin with a `hooks.json` appears in the Hooks table.
6. **No unauthorized version changes** — `metadata.version` unchanged unless user provided a new value.

### Step 6 – Save the Files

Write updated files:
- `.github/plugin/marketplace.json`
- `README.md`

Do not wrap file content in code fences when writing to disk.

## Output Format

After completing the marketplace update, respond with:

```markdown
## Summary
- Action performed (add / sync / update / remove).
- Number of plugins added, updated, or removed.
- Whether README.md was updated and which sections changed.

## Changes Made
- `.github/plugin/marketplace.json`: list plugins added, updated, or removed.
- `README.md`: describe which rows/sections were added or changed.

## Warnings
- Any orphan marketplace entries (entries with no matching plugin folder).
- Any plugin folders missing a valid manifest (no plugin.json found).
- Any agents or skills referenced in the README that no longer exist on disk.

## Next Steps
- Suggest bumping the marketplace version (metadata.version) if significant plugins were added.
- Note any plugins that have skills or agents not yet created (manifest references non-existent paths).
```

## Assumptions and Limitations

- Assumes all plugins live under the `plugins/` directory at the repository root, as configured by `"pluginRoot": "./plugins"` in `marketplace.json`.
- The marketplace version (`metadata.version`) is never changed automatically — it requires an explicit user instruction.
- Agent categories in the `## Agents` section of README.md are determined by best-fit judgment; the user should review groupings after a `sync`.
- Does not create or modify any plugin files, skill files, agent files, or hook scripts — use the dedicated maker skills for those.
- Removing a plugin from `marketplace.json` does not delete its files from `plugins/` — the user must do that manually if desired.
- Skill and agent `description` fields used in README.md are taken from their YAML frontmatter; if a file has no description, a placeholder is used and flagged for the user to fill in.
