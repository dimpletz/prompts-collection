---
name: marketplace-maker
description: >
  A skill for registering and exposing the current project's plugins in the VS Code Chat Plugin Marketplace. Use it whenever the user wants to publish a new plugin, update the marketplace listing, or synchronize the marketplace.json and README.md with the current set of plugins. Do not use it for creating plugin manifests, skills, agents, MCP, or hooks — use the dedicated maker skills for those if available.
---

# Marketplace Maker

This **skill** is for developers who need to expose one or more plugins from the current repository to the VS Code Chat Plugin Marketplace. It ensures that `.github/plugin/marketplace.json` is correct, complete, and consistent with all `.claude-plugin/plugin.json` manifests in the `plugins/` directory — creating the file from scratch when it does not yet exist — and that the global `README.md` Plugins table accurately reflects every plugin in the marketplace.

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
   Every plugin entry in `marketplace.json` must have a `version` and `description` that exactly matches the corresponding `.claude-plugin/plugin.json`. Mismatches cause stale or broken marketplace listings.

2. **Priority 2 – Complete README.md Plugins table**
   The global `README.md` Plugins table must accurately list every plugin. Missing entries reduce discoverability.

3. **Priority 3 – No unauthorized version changes**
   Never change the marketplace `metadata.version` unless the user explicitly provides a new value. Never change a plugin's `version` in `plugin.json` unless the user explicitly requests a version bump.

## Workflow

### Step 1 – Understand the Request

- Read **action** and **plugin_names** carefully.
- For `sync`: scan every folder under `plugins/` and compare against `marketplace.json`.
- For `add` / `update` / `remove`: operate only on the named plugins.
- Check whether `.github/plugin/marketplace.json` exists. If it does not exist and plugins are available, it will be created in Step 3 using the discovered plugin metadata.
- If the file exists, identify the current marketplace version from `metadata.version` — do not change it unless **marketplace_version** was explicitly provided.

### Step 2 – Discover Plugin Metadata

For each plugin being processed:

1. **Locate the manifest**: always use `.claude-plugin/plugin.json`. This is the only supported manifest path — `plugin/plugin.json` is not used.
2. **Read required fields**: `name`, `description`, `version`.
3. **Inventory capabilities**:
   - **Skills**: list directories under `plugins/<name>/skills/` that contain a `SKILL.md`.
   - **Agents**: list `.agent.md` files under `plugins/<name>/agents/`.
   - **Hooks**: read `plugins/<name>/hooks/hooks.json` to identify hook events (`SessionStart`, `SubagentStart`, `PostToolUse`).
   - **MCP**: check for a `.mcp.json` file at `plugins/<name>/` (Claude-format plugins), or check the `mcpServers` field in `.claude-plugin/plugin.json` for inline or file-path MCP server definitions. The top-level key in `.mcp.json` is `mcpServers`.
4. If a manifest is missing required fields, report the gap and ask the user before proceeding.

### Step 3 – Create or Update marketplace.json

File location: `.github/plugin/marketplace.json`

If this file does not yet exist, create it from scratch using the structure below, populated with the discovered plugin metadata. Use the repository name as `"name"`, a brief repo description as `metadata.description`, `"1.0.0"` as the initial `metadata.version` (unless **marketplace_version** was provided), `"./plugins"` as `metadata.pluginRoot`, and the repository owner as `owner.name`.

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
- If the file does not exist: create it with all discovered plugins already included.
- For `add`: append a new entry to `"plugins"`. The `"source"` must match the folder name under `plugins/`.
- For `update`: find the entry by `"name"` and update only `"description"` and/or `"version"` as needed.
- For `remove`: remove the entry from `"plugins"`. Do not delete any plugin files.
- For `sync`: ensure every plugin folder with a `.claude-plugin/plugin.json` has a matching entry; add missing ones, update stale ones, report orphan entries (entries with no matching folder) for user review.
- Never change `metadata.version` unless the user provided **marketplace_version**.
- Preserve the existing ordering of entries unless explicitly asked to reorder.

### Step 4 – Update README.md

Only the Plugins table in the global `README.md` is maintained by this skill. No other sections (Agents, Skills, Hooks, MCP) are added or modified.

#### Plugins Table

Located under `## Plugins`. Each row:

```markdown
| [<plugin-name>](plugins/<plugin-name>/) `v<version>` | <description> | <agent links or —> | <skill links or —> | <hook events or —> | <mcp server names or —> |
```

- List agents as comma-separated Markdown links to their `.agent.md` files.
- List skills as comma-separated Markdown links to their `SKILL.md` files.
- List hook events as backtick-formatted event names (e.g. `` `SessionStart` ``).
- List MCP server names (the keys from `mcpServers` in `.mcp.json` or inline in `plugin.json`) as backtick-formatted names (e.g. `` `plugin-database` ``).
- Use `—` for columns with no entries.

Rules:
- Only add or update rows in the Plugins table. Do not create or modify any other README sections.
- Do not remove entries for plugins that still exist.
- When `sync`, update stale descriptions and versions in the table.

### Step 5 – Validate

Before saving:

1. **marketplace.json** — Every plugin in `plugins/` with a `.claude-plugin/plugin.json` has an entry. Every entry's `version` matches its `.claude-plugin/plugin.json`. No duplicate `"name"` values. If the file was newly created, confirm it is well-formed JSON.
2. **Plugins table** — Every `marketplace.json` plugin appears in the Plugins table. Version badge matches `.claude-plugin/plugin.json`. Agent, skill, hook, and MCP columns within that table are accurate. No other README sections were created or modified.
3. **No unauthorized version changes** — `metadata.version` unchanged unless user provided a new value.
4. **Manifest path** — No plugin entry references `plugin/plugin.json`; all manifests are sourced exclusively from `.claude-plugin/plugin.json`.

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
- All plugin manifests are exclusively at `.claude-plugin/plugin.json`. The `plugin/plugin.json` path is not supported by this skill.
- If `.github/plugin/marketplace.json` does not exist, it is created automatically when at least one plugin with a valid `.claude-plugin/plugin.json` is found.
- The marketplace version (`metadata.version`) is never changed automatically — it requires an explicit user instruction. When creating the file fresh, the initial version defaults to `"1.0.0"` unless **marketplace_version** was provided.
- Plugins that expose MCP server definitions declare them in `.mcp.json` at the plugin root, referenced via the `mcpServers` field in `.claude-plugin/plugin.json`. The `${CLAUDE_PLUGIN_ROOT}` token is used in MCP server `command`, `args`, `cwd`, `env`, `envFile`, `url`, and `headers` fields to reference files within the plugin directory. This skill inventories but does not create MCP definitions.
- Does not create or modify any plugin files, skill files, agent files, hook scripts, or MCP definitions — use the dedicated maker skills for those if available.
- Removing a plugin from `marketplace.json` does not delete its files from `plugins/` — the user must do that manually if desired.
- Only the Plugins table in README.md is managed by this skill. Agents, Skills, and Hooks catalog sections are out of scope.
- Skill and agent `description` fields used in the Plugins table are taken from their YAML frontmatter; if a file has no description, a placeholder is used and flagged for the user to fill in.
