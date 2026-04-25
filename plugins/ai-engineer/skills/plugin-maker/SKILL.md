---
name: plugin-maker
description: >
  A skill for creating VS Code Copilot agent plugin manifests and scaffolding the complete plugin directory structure. Use it whenever the user asks to create a new plugin, register a collection of agents or skills as an installable unit, or add a plugin.json manifest to an existing folder. Always uses .claude-plugin/plugin.json as the plugin descriptor. Do not use it for creating individual agents (.agent.md), skills (SKILL.md), or hook scripts — use the dedicated maker skills for those.
---

# Plugin Maker

This **skill** is for developers who need to package VS Code Copilot agents, skills, and hooks into a named, versioned, installable plugin. A plugin is the unit of distribution in the Chat Plugin Marketplace: it groups related capabilities under a single `plugin.json` manifest and can be installed, updated, or removed as one unit.

## Inputs

- **plugin_intent** (required): A description of what the plugin should provide (e.g. "a plugin that groups all Java development skills and a code quality agent" or "a hook-only plugin that injects environment variables at session start").
- **plugin_name** (optional): The kebab-case name for the plugin (e.g. `java-developer`, `env-injector`). If omitted, derive from the intent.
- **plugin_version** (optional): The initial semver version. Defaults to `1.0.0` if omitted.
- **skills** (optional): List of skill folder names to include (e.g. `["java-unit-test-maker", "java-style-checker"]`). Each must already exist under `plugins/<plugin-name>/skills/`.
- **agents** (optional): Whether the plugin includes an `agents/` directory. Defaults to `false`.
- **hooks** (optional): Whether the plugin includes hooks (hooks.json + scripts). If `true`, the manifest must be placed at `.claude-plugin/plugin.json`. Defaults to `false`.
- **author** (optional): The author name to include in the manifest. If omitted, use `"Dimpletz"` as the default.

## Task Priorities

1. **Priority 1 – Correct manifest location**
   Plugins that include hooks MUST use `.claude-plugin/plugin.json`. Plugins with only skills and/or agents use `plugin/plugin.json`. Using the wrong location will prevent the runtime from discovering hooks.

2. **Priority 2 – Complete and valid manifest**
   The `plugin.json` must contain all required fields (`name`, `description`, `version`, `author`). Skill and agent paths must be relative to the manifest location and must match the actual directory structure.

3. **Priority 3 – Consistent directory layout**
   The plugin folder structure must follow the established conventions so that the marketplace and runtime can discover all capabilities without additional configuration.

## Workflow

### Step 1 – Understand the Request

- Read **plugin_intent** and identify what the plugin contains:
  - **Skills only** → use `plugin/plugin.json`.
  - **Agents only** → use `plugin/plugin.json`.
  - **Skills + agents** → use `plugin/plugin.json`.
  - **Hooks (with or without skills/agents)** → use `.claude-plugin/plugin.json`.
- Derive a kebab-case plugin name from the intent if not provided.
- Determine initial version (default: `1.0.0`).
- If skills or agents are listed, verify that their directories will exist before referencing them in the manifest.

### Step 2 – Scaffold the Plugin Directory

Create the following structure under `plugins/<plugin-name>/`:

#### For skills/agents-only plugins

```
plugins/<plugin-name>/
  plugin/
    plugin.json
  skills/
    <skill-name>/
      SKILL.md
  agents/              (if agents are included)
  README.md
```

#### For hook-based plugins

```
plugins/<plugin-name>/
  .claude-plugin/
    plugin.json
  hooks/
    hooks.json
  scripts/
    <hook-name>.sh
    <hook-name>.ps1
  skills/              (if skills are included)
    <skill-name>/
      SKILL.md
  agents/              (if agents are included)
  README.md
```

Create any directories that do not already exist. Never overwrite existing files.

### Step 3 – Write plugin.json

#### Skills/agents-only manifest (`plugin/plugin.json`)

```json
{
  "name": "<plugin-name>",
  "description": "<One sentence describing what the plugin provides.>",
  "version": "<semver>",
  "author": {
    "name": "<author>"
  },
  "repository": "https://github.com/dimpletz/prompts-collection",
  "license": "MIT",
  "keywords": [
    "<plugin-name>",
    "<domain-keyword-1>",
    "<domain-keyword-2>"
  ],
  "skills": [
    "./skills/<skill-name-1>",
    "./skills/<skill-name-2>"
  ]
}
```

- Omit the `"skills"` key entirely if there are no skills.
- Omit the `"agents"` key entirely if there are no agents. When present, use `"agents": ["./agents"]`.
- Skill paths are relative to the `plugin/` directory — use `"./skills/<name>"`.

#### Hook-based manifest (`.claude-plugin/plugin.json`)

```json
{
  "name": "<plugin-name>",
  "description": "<One sentence describing what the plugin provides.>",
  "version": "<semver>",
  "author": {
    "name": "<author>"
  },
  "repository": "https://github.com/dimpletz/prompts-collection",
  "license": "MIT",
  "keywords": [
    "<plugin-name>",
    "hook",
    "<domain-keyword>"
  ]
}
```

- Do **not** reference the hooks directory in `plugin.json` — the runtime auto-discovers `hooks/hooks.json`.
- Skills and agents, if present, are referenced with paths relative to the plugin root: `"./skills/<name>"`, `"./agents"`.

### Step 4 – Write the Plugin README.md

Every plugin must have a `README.md`. Create `plugins/<plugin-name>/README.md` with:

```markdown
# <Plugin Display Name> `v<version>`

> <One-sentence summary of what this plugin provides.>

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) extension installed and active.

## Installation

Install via the VS Code Chat Plugin Marketplace using the `dimpletz/prompts-collection` marketplace source and enable the **<plugin-name>** plugin.

## Usage

<Describe how to use the plugin — skills to invoke, agents to start, hooks that run automatically.>

| Skill/Agent | Invoke when… |
|-------------|--------------|
| **<SkillName>** | <When to use this skill.> |

## Components

<Describe what each skill, agent, or hook does.>

## Author

[<author>](https://github.com/<author-handle>)
```

Omit sections (Skills table, Agents table, Hooks section) that are not applicable to this plugin.

### Step 5 – Register in marketplace.json

Add a new entry to `.github/plugin/marketplace.json` under the `"plugins"` array:

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

### Step 6 – Validate

Before delivering, verify:

1. **Manifest location** — Hook plugins use `.claude-plugin/plugin.json`; others use `plugin/plugin.json`. Never create both.
2. **Required fields** — `name`, `description`, `version`, `author` are present and non-empty.
3. **Skill paths** — Each path in `"skills"` resolves to a directory containing a `SKILL.md` file.
4. **Agent paths** — Each path in `"agents"` resolves to a directory containing `.agent.md` files.
5. **README.md** — Present at `plugins/<plugin-name>/README.md`. Title includes plugin name and version.
6. **marketplace.json** — New plugin entry added with matching name, source, description, and version.
7. **No duplicate names** — The plugin name does not already exist in `marketplace.json`.

### Step 7 – Save the Files

Write all files to disk. Do not wrap any file content in code fences when writing.

## Output Format

After scaffolding the plugin, respond with:

```markdown
## Summary
- Plugin name, version, and what it provides (1–2 sentences).
- Manifest location (plugin/ or .claude-plugin/).
- Components registered: list of skills, agents, and/or hooks included.

## Files Created
- List every file created with its relative path.

## Next Steps
- How to install the plugin in VS Code (point to marketplace or manual install).
- Which additional skills, agents, or hooks still need to be created (if any were referenced but not yet built).
- Suggest running the relevant maker skills to create any missing components.

## Limitations
- Any assumptions made about existing file structure.
- Skills or agents referenced in the manifest that were not yet created.
```

## Assumptions and Limitations

- Assumes the repository follows the `plugins/<plugin-name>/` layout with either `plugin/plugin.json` or `.claude-plugin/plugin.json`.
- Always uses `.claude-plugin/plugin.json` as the plugin descriptor when hooks are involved, as required by the VS Code Copilot runtime.
- Does not create the content of individual skill SKILL.md or agent .agent.md files — use skill-maker or agent-maker for those.
- Does not create hook scripts — use hook-maker for that.
- The `"repository"` field is hardcoded to `https://github.com/dimpletz/prompts-collection`; update manually for other repos.
- Plugin names must be unique within `marketplace.json` — creating a plugin with a duplicate name will cause a conflict.
