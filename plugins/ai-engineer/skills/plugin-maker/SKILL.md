---
name: plugin-maker
description: >
  A skill for creating VS Code Copilot agent plugin manifests and scaffolding the complete plugin directory structure. Use it whenever the user asks to create a new plugin, register a collection of agents, skills, hooks, automation templates, or MCP servers as an installable unit, or add a plugin.json manifest to an existing folder. Do not use it for creating individual agents (.agent.md), skills (SKILL.md), or hook scripts — use the dedicated maker skills for those.
---

# Plugin Maker

This **skill** is for developers who need to package VS Code Copilot agents, skills, hooks, and MCP servers into a named, versioned, installable plugin. A plugin is the unit of distribution in the Chat Plugin Marketplace: it groups related capabilities under a single `plugin.json` manifest and can be installed, updated, or removed as one unit.

## Inputs

- **plugin_intent** (required): A description of what the plugin should provide (e.g. "a plugin that groups all Java development skills and a code quality agent" or "a hook-only plugin that injects environment variables at session start").
- **plugin_name** (optional): The kebab-case name for the plugin (e.g. `java-developer`, `env-injector`). If omitted, derive from the intent.
- **plugin_version** (optional): The initial semver version. Defaults to `1.0.0` if omitted.
- **repository** (optional): The Git repository URL for the plugin (e.g. `https://github.com/myorg/my-repo`). If omitted, ask the user.
- **skills** (optional): List of skill folder names to include (e.g. `["java-unit-test-maker", "java-style-checker"]`). Each must already exist under `plugins/<plugin-name>/skills/`.
- **agents** (optional): Whether the plugin includes custom agents (`com.github.copilot/agents/`). Defaults to `false`.
- **hooks** (optional): Whether the plugin includes hooks (`com.github.copilot/hooks/hooks.json` + scripts). Defaults to `false`.
- **mcp** (optional): Whether the plugin includes an MCP server (`mcp.json`). Defaults to `false`.
- **automations** (optional): Whether the plugin includes automation templates (`automations/*.automation.md`). Defaults to `false`.
- **commands** / **rules** (optional): Whether the plugin includes Copilot slash commands (`com.github.copilot/commands/`) or rules (`com.github.copilot/rules/`). Both default to `false`.
- **license** (optional): The SPDX license identifier (e.g. `MIT`, `Apache-2.0`). If omitted, the `"license"` field is excluded from `plugin.json`.
- **author** (optional): The author name to include in the manifest. If omitted, check the author name from the context. If nothing was found, ask the user.

> **Component requirement**: Components are optional. If no component is specified, scaffold the plugin directory structure only — no component directories or files are created. `plugin.json` never lists components — skills, agents, hooks, automation templates, and MCP servers are discovered from fixed locations.

## Task Priorities

1. **Priority 1 – Always use the plugin-root `plugin.json`**
   All plugins MUST place `plugin.json` at the plugin root (`plugins/<plugin-name>/plugin.json`). Do not use `.claude-plugin/` or `plugin/` directories.

2. **Priority 2 – Complete and valid manifest**
   The `plugin.json` must contain all required fields (`name`). Recommended fields (`description`, `version`, `author`, `repository`) should be included when available. `plugin.json` must conform to the Agent Plugins 1.0.0 schema (a closed schema: only `$schema`, `name`, `version`, `description`, `author`, `homepage`, `repository`, `license`, `keywords`, and `extensions` are permitted; `author` accepts only `name`, `email`, and `url`).

3. **Priority 3 – Consistent directory layout**
   The plugin folder structure must follow the established conventions so that the marketplace and runtime can discover all capabilities without additional configuration.

## Workflow

### Step 0 – Identify Components (Optional)

Check whether the request includes any of:
- A **skill** (with a `SKILL.md`)
- An **agent** (with a `.agent.md` file)
- A **hook** (with `com.github.copilot/hooks/hooks.json` and at least one script)
- An **MCP server** (with a `mcp.json`)
- An **automation template** (with an `automations/<id>.automation.md` file)
- A Copilot **slash command** or **rule** (under `com.github.copilot/`)

Skills and MCP servers are the portable Agent Plugins 1.0 components. Agents, hooks, automation templates, commands, and rules are VS Code/Copilot-specific.

If none is specified, proceed with scaffolding the plugin directory structure only. Do not ask the user for a component.

### Step 1 – Understand the Request

- Read **plugin_intent** and identify what the plugin contains.
- Derive a kebab-case plugin name from the intent if not provided.
- Determine initial version (default: `1.0.0`).
- If skills or agents are listed, verify that their directories will exist before referencing them in the manifest.
- Collect `repository` from the user if not provided.

### Step 2 – Scaffold the Plugin Directory

Always create the following structure under `plugins/<plugin-name>/`:

```
plugins/<plugin-name>/
  plugin.json
  skills/              (if skills are included)
    <skill-name>/
      SKILL.md
  com.github.copilot/  (if agents, hooks, commands, or rules are included)
    agents/            (if agents are included)
    commands/          (if slash commands are included)
    rules/             (if rules are included)
    hooks/             (if hooks are included)
      hooks.json
  scripts/             (if hooks are included)
    <hook-name>.sh
    <hook-name>.ps1
  automations/         (if automation templates are included)
    <id>.automation.md
  mcp.json             (if MCP is included)
  README.md
```

Create any directories that do not already exist. Never overwrite existing files.

### Step 3 – Write plugin.json

All plugins use `plugin.json` at the plugin root. Fields are relative to the **plugin root**.

```json
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",
  "name": "<plugin-name>",
  "description": "<One sentence describing what the plugin provides.>",
  "version": "<semver>",
  "author": {
    "name": "<author>"
  },
  "repository": "<repository-url>",
  "keywords": [
    "<plugin-name>",
    "<domain-keyword-1>",
    "<domain-keyword-2>"
  ]
}
```

Field rules:
- **`name`** (required): kebab-case, lowercase letters/numbers/hyphens, max 64 characters. The schema also permits periods, but this repository uses hyphens only. No slashes or colons.
- **`description`**, **`version`**, **`author`**, **`repository`**: include when provided; omit if not available.
- **`license`**: include only if the **license** input was provided (e.g. `"license": "MIT"`); omit the field entirely otherwise.
- **`$schema`** (required): always `https://agent-plugins.org/schemas/1.0.0/plugin.schema.json`.
- **Components**: never add `skills`, `agents`, `hooks`, or `mcpServers` fields — the schema rejects them. Skills are discovered from `skills/`, MCP servers from `mcp.json`, and agents and hooks from `com.github.copilot/agents/` and `com.github.copilot/hooks/hooks.json`.
- **`extensions`**: optional client-specific data keyed by reverse-domain namespace (e.g. `com.github.copilot`). Omit unless needed. Use it only for Copilot-specific manifest data such as extra automation template folders (see below).

#### MCP server configuration (`mcp.json`)

When MCP is included, create `mcp.json` at the plugin root with the required `$schema` and `mcpServers` top-level fields. Each server needs a `type`. Use `${PLUGIN_ROOT}` in `args`, `env`, and `cwd` (not in `command`; use a bare executable name or a `./`-relative path):

```json
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/mcp.schema.json",
  "mcpServers": {
    "<server-name>": {
      "type": "stdio",
      "command": "./servers/<executable>",
      "args": ["--config", "${PLUGIN_ROOT}/config.json"],
      "env": {
        "PLUGIN_PATH": "${PLUGIN_ROOT}"
      }
    }
  }
}
```

#### Hook configuration (`com.github.copilot/hooks/hooks.json`)

When hooks are included, create `com.github.copilot/hooks/hooks.json`. Use `${PLUGIN_ROOT}` in command paths:

```json
{
  "version": 1,
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "bash": "bash \"${PLUGIN_ROOT}/scripts/<hook-name>.sh\"",
        "powershell": "powershell -NoProfile -ExecutionPolicy Bypass -File \"${PLUGIN_ROOT}/scripts/<hook-name>.ps1\""
      }
    ]
  }
}
```

Supported hook events: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, `Stop`.

Plugin hooks run alongside workspace and user hooks for the same event. In the Local harness, `matcher` values are ignored, so scripts must filter on the event input themselves. Plugin hooks and MCP servers run code on the user's machine, so describe them in the README.

#### Automation templates (`automations/<id>.automation.md`)

When automation templates are included, create each file in the root `automations/` folder with the `.automation.md` suffix. A template is Markdown with YAML frontmatter; the body is the prompt. It never creates or enables an automation on install:

```markdown
---
version: 1
id: weekly-review
name: Weekly review
description: Review the workspace for regressions.
schedule:
  kind: cron
  expression: "30 10 * * 5"
  timeZone: local
---
Review the workspace changes from the past week.
Identify regressions and suggest follow-up actions.
```

- **`version`** (required): `1`.
- **`id`** (required): unique within the plugin; lowercase letters, numbers, periods, or hyphens; max 64 characters.
- **`name`** (required) and **`description`** (optional).
- **`schedule`** (required): `kind: manual`, `kind: hourly`, or `kind: cron` with a five-field local-time expression (`timeZone: local`) that is daily (`"0 9 * * *"`) or weekly (`"30 10 * * 5"`). Invalid templates are ignored.
- Do not specify workspace, provider, model, permissions, or enabled state.
- To load templates from other folders, add `extensions.com.github.copilot.automations.paths` (relative to `com.github.copilot/`) to `plugin.json`; add `"exclusive": true` to skip the default `automations/` folder.

### Step 4 – Write the Plugin README.md

Every plugin must have a `README.md`. Create `plugins/<plugin-name>/README.md` with:

```markdown
# <Plugin Display Name> `v<version>`

> <One-sentence summary of what this plugin provides.>

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) extension installed and active.

## Installation

Install via the VS Code Chat Plugin Marketplace using the `<marketplace-source>` marketplace source and enable the **<plugin-name>** plugin.

## Usage

<Describe how to use the plugin — skills to invoke, agents to start, hooks that run automatically, MCP tools available.>

| Component | Type | Invoke when… |
|-----------|------|--------------|
| **<Name>** | Skill / Agent / Hook / MCP | <When to use this component.> |

## Components

<Describe what each skill, agent, hook, or MCP server does.>

## Author

[<author>](https://github.com/<author-handle>)
```

Omit sections that are not applicable to this plugin.

### Step 5 – Register in marketplace.json (Conditional)

**Only perform this step if `.github/plugin/marketplace.json` exists in the repository.**

If the file exists, add a new entry under the `"plugins"` array:

```json
{
  "name": "<plugin-name>",
  "source": "<plugin-name>",
  "description": "<One sentence describing what the plugin provides.>",
  "version": "<semver>"
}
```

- The `"source"` field is the folder name under `plugins/` — it must match `<plugin-name>` exactly.
- The `"version"` must match the version in `plugin.json`.
- If `.github/plugin/marketplace.json` does not exist, skip this step entirely and note it in the output.

### Step 6 – Validate

Before delivering, verify:

1. **Manifest location** — Every plugin uses `plugin.json` at the plugin root. No other manifest location is used.
2. **Required field** — `name` is present, kebab-case, and max 64 characters with no slashes, colons, or namespace prefixes.
3. **Component presence** — If no components were specified, `plugin.json` contains only schema-permitted fields — this is valid.
4. **Schema** — `plugin.json` has `$schema` set to the Agent Plugins 1.0.0 URL and no unlisted top-level fields (`skills`, `agents`, `hooks`, and `mcpServers` are invalid).
5. **Skill and agent locations** — Every skill is a `skills/<name>/SKILL.md` whose frontmatter `name` is plain kebab-case (no namespace prefix) and matches its directory name; every agent is a `com.github.copilot/agents/<Name>.agent.md`.
6. **MCP config** — If MCP is included, `mcp.json` exists at the plugin root with `$schema` and a top-level `mcpServers` object.
7. **Hook config** — If hooks are included, `com.github.copilot/hooks/hooks.json` exists and references scripts using `${PLUGIN_ROOT}`.
8. **README.md** — Present at `plugins/<plugin-name>/README.md`. Title includes plugin name and version.
9. **marketplace.json** — Registered only if the file exists; version matches `plugin.json`.
10. **No duplicate names** — The plugin name does not already exist in `marketplace.json`.
11. **Automation templates** — If included, each is `automations/<id>.automation.md` with `version: 1`, a unique valid `id`, `name`, and a manual, hourly, daily, or weekly `schedule`.

### Step 7 – Save the Files

Write all files to disk. Do not wrap any file content in code fences when writing.

## Output Format

After scaffolding the plugin, respond with:

```markdown
## Summary
- Plugin name, version, and what it provides (1–2 sentences).
- Manifest location (plugin root `plugin.json`).
- Components registered: list of skills, agents, hooks, automation templates, and/or MCP servers included.

## Files Created
- List every file created with its relative path.

## Next Steps
- How to install the plugin in VS Code: from the marketplace (`@agentPlugins` in the Extensions view or `/plugin install <plugin>@<marketplace>`), from a Git URL (**Chat: Install Plugin From Source**), or locally via the `chat.pluginLocations` setting (path mapped to `true`). Requires `chat.plugins.enabled`.
- Remind the user to bump `version` in `plugin.json` (and `marketplace.json`) before pushing, otherwise installed copies will not update.
- Which additional skills, agents, hooks, or MCP servers still need to be created (if any were referenced but not yet built).
- Suggest running the relevant maker skills to create any missing components.

## Limitations
- Any assumptions made about existing file structure.
- Skills, agents, or MCP servers referenced in the manifest that were not yet created.
- Whether marketplace.json registration was skipped (and why).
```

## Assumptions and Limitations

- All plugins use the plugin-root `plugin.json` — this is the only supported manifest location in this skill.
- MCP servers are defined in `mcp.json` at the plugin root and discovered automatically; they are never declared in `plugin.json`.
- Automation templates are a VS Code-specific component, not part of the portable Agent Plugins 1.0 standard.
- Other clients ignore the `com.github.copilot/` namespace, so Copilot-specific components do not break portability of skills and MCP servers.
- Does not create the content of individual SKILL.md, `.agent.md`, or MCP server executables — use the dedicated maker skills for those.
- Does not create hook scripts — use hook-maker for that.
- The `"repository"` field is sourced from user input and is not hardcoded.
- The `"license"` field is omitted from `plugin.json` unless explicitly provided.
- Marketplace registration is skipped when `.github/plugin/marketplace.json` does not exist.
- Plugin names must be unique within `marketplace.json` — creating a plugin with a duplicate name will cause a conflict.
