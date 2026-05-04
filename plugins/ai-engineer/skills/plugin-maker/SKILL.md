---
name: plugin-maker
description: >
  A skill for creating VS Code Copilot agent plugin manifests and scaffolding the complete plugin directory structure. Use it whenever the user asks to create a new plugin, register a collection of agents, skills, hooks, or MCP servers as an installable unit, or add a plugin.json manifest to an existing folder. Do not use it for creating individual agents (.agent.md), skills (SKILL.md), or hook scripts — use the dedicated maker skills for those.
---

# Plugin Maker

This **skill** is for developers who need to package VS Code Copilot agents, skills, hooks, and MCP servers into a named, versioned, installable plugin. A plugin is the unit of distribution in the Chat Plugin Marketplace: it groups related capabilities under a single `plugin.json` manifest and can be installed, updated, or removed as one unit.

## Inputs

- **plugin_intent** (required): A description of what the plugin should provide (e.g. "a plugin that groups all Java development skills and a code quality agent" or "a hook-only plugin that injects environment variables at session start").
- **plugin_name** (optional): The kebab-case name for the plugin (e.g. `java-developer`, `env-injector`). If omitted, derive from the intent.
- **plugin_version** (optional): The initial semver version. Defaults to `1.0.0` if omitted.
- **repository** (optional): The Git repository URL for the plugin (e.g. `https://github.com/myorg/my-repo`). If omitted, ask the user.
- **skills** (optional): List of skill folder names to include (e.g. `["java-unit-test-maker", "java-style-checker"]`). Each must already exist under `plugins/<plugin-name>/skills/`.
- **agents** (optional): Whether the plugin includes an `agents/` directory. Defaults to `false`.
- **hooks** (optional): Whether the plugin includes hooks (`hooks/hooks.json` + scripts). Defaults to `false`.
- **mcp** (optional): Whether the plugin includes an MCP server (`.mcp.json`). Defaults to `false`.
- **license** (optional): The SPDX license identifier (e.g. `MIT`, `Apache-2.0`). If omitted, the `"license"` field is excluded from `plugin.json`.
- **author** (optional): The author name to include in the manifest. If omitted, check the author name from the context. If nothing was found, ask the user.

> **Component requirement**: Components are optional. If no component is specified, scaffold the plugin directory structure only — no `skills`, `agents`, `hooks`, or `mcpServers` fields will be added to `plugin.json`.

## Task Priorities

1. **Priority 1 – Always use `.claude-plugin/plugin.json`**
   All plugins MUST use `.claude-plugin/plugin.json` as the manifest location. This is required for cross-tool compatibility and hook/MCP discovery by the VS Code Copilot runtime.

2. **Priority 2 – Complete and valid manifest**
   The `plugin.json` must contain all required fields (`name`). Recommended fields (`description`, `version`, `author`, `repository`) should be included when available. Skill and agent paths must be relative to the plugin root and must match the actual directory structure.

3. **Priority 3 – Consistent directory layout**
   The plugin folder structure must follow the established conventions so that the marketplace and runtime can discover all capabilities without additional configuration.

## Workflow

### Step 0 – Identify Components (Optional)

Check whether the request includes any of:
- A **skill** (with a `SKILL.md`)
- An **agent** (with a `.agent.md` file)
- A **hook** (with `hooks/hooks.json` and at least one script)
- An **MCP server** (with a `.mcp.json`)

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
  .claude-plugin/
    plugin.json
  skills/              (if skills are included)
    <skill-name>/
      SKILL.md
  agents/              (if agents are included)
  hooks/               (if hooks are included)
    hooks.json
  scripts/             (if hooks are included)
    <hook-name>.sh
    <hook-name>.ps1
  .mcp.json            (if MCP is included)
  README.md
```

Create any directories that do not already exist. Never overwrite existing files.

### Step 3 – Write plugin.json

All plugins use `.claude-plugin/plugin.json`. Fields are relative to the **plugin root** (the parent of `.claude-plugin/`).

```json
{
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
  ],
  "skills": "./skills/<skill-name>",
  "agents": "./agents",
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

Field rules:
- **`name`** (required): kebab-case, lowercase letters/numbers/hyphens only, max 64 characters.
- **`description`**, **`version`**, **`author`**, **`repository`**: include when provided; omit if not available.
- **`license`**: include only if the **license** input was provided (e.g. `"license": "MIT"`); omit the field entirely otherwise.
- **`skills`**: use `"./skills/<name>"` for a single skill or an array for multiple. Omit if no skills.
- **`agents`**: use `"./agents"`. Omit if no agents.
- **`hooks`**: use `"./hooks/hooks.json"`. Omit if no hooks.
- **`mcpServers`**: use `"./.mcp.json"`. Omit if no MCP server.

#### MCP server configuration (`.mcp.json`)

When MCP is included, create `.mcp.json` at the plugin root with the top-level `mcpServers` key. Use `${CLAUDE_PLUGIN_ROOT}` to reference files inside the plugin directory:

```json
{
  "mcpServers": {
    "<server-name>": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/<executable>",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": {
        "PLUGIN_PATH": "${CLAUDE_PLUGIN_ROOT}"
      }
    }
  }
}
```

#### Hook configuration (`hooks/hooks.json`)

When hooks are included, create `hooks/hooks.json`. Use `${CLAUDE_PLUGIN_ROOT}` in command paths:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/<hook-name>.sh"
      }
    ]
  }
}
```

Supported hook events: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, `Stop`.

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

1. **Manifest location** — Every plugin uses `.claude-plugin/plugin.json`. No other manifest location is used.
2. **Required field** — `name` is present, kebab-case, and max 64 characters with no slashes, colons, or namespace prefixes.
3. **Component presence** — If no components were specified, `plugin.json` omits `skills`, `agents`, `hooks`, and `mcpServers` fields — this is valid.
4. **Skill paths** — Each path in `"skills"` resolves to a directory containing a `SKILL.md` file.
5. **Agent paths** — Each path in `"agents"` resolves to a directory containing `.agent.md` files.
6. **MCP config** — If `mcpServers` is set, `.mcp.json` exists at the plugin root with a top-level `mcpServers` object.
7. **Hook config** — If `hooks` is set, `hooks/hooks.json` exists and references scripts using `${CLAUDE_PLUGIN_ROOT}`.
8. **README.md** — Present at `plugins/<plugin-name>/README.md`. Title includes plugin name and version.
9. **marketplace.json** — Registered only if the file exists; version matches `plugin.json`.
10. **No duplicate names** — The plugin name does not already exist in `marketplace.json`.

### Step 7 – Save the Files

Write all files to disk. Do not wrap any file content in code fences when writing.

## Output Format

After scaffolding the plugin, respond with:

```markdown
## Summary
- Plugin name, version, and what it provides (1–2 sentences).
- Manifest location (.claude-plugin/plugin.json).
- Components registered: list of skills, agents, hooks, and/or MCP servers included.

## Files Created
- List every file created with its relative path.

## Next Steps
- How to install the plugin in VS Code (point to marketplace or manual install).
- Which additional skills, agents, hooks, or MCP servers still need to be created (if any were referenced but not yet built).
- Suggest running the relevant maker skills to create any missing components.

## Limitations
- Any assumptions made about existing file structure.
- Skills, agents, or MCP servers referenced in the manifest that were not yet created.
- Whether marketplace.json registration was skipped (and why).
```

## Assumptions and Limitations

- All plugins use `.claude-plugin/plugin.json` — this is the only supported manifest location in this skill.
- MCP servers are defined in `.mcp.json` at the plugin root, referenced via `"mcpServers": "./.mcp.json"` in `plugin.json`.
- Does not create the content of individual SKILL.md, `.agent.md`, or MCP server executables — use the dedicated maker skills for those.
- Does not create hook scripts — use hook-maker for that.
- The `"repository"` field is sourced from user input and is not hardcoded.
- The `"license"` field is omitted from `plugin.json` unless explicitly provided.
- Marketplace registration is skipped when `.github/plugin/marketplace.json` does not exist.
- Plugin names must be unique within `marketplace.json` — creating a plugin with a duplicate name will cause a conflict.
