---
name: hook-maker
description: >
  A skill for creating VS Code Copilot agent hook configurations (hooks.json and companion scripts). Use it whenever the user asks to create a new hook, automate an action at a specific agent lifecycle event, or add hook support to a plugin. Do not use it for creating agents (.agent.md), skills (SKILL.md), or plugin manifests — use the appropriate maker skill for those.
---

# Hook Maker

This **skill** is for developers who need to add automated lifecycle hooks to a VS Code Copilot agent plugin. Hooks run shell scripts or commands at specific points in the agent lifecycle and can inject context, enforce security policies, run quality checks, install dependencies, or perform any side-effect needed before or after agent activity.

## Primary Knowledge Source
- Knowledge source: `plugins/ai-engineer/okf` (entry point: `plugins/ai-engineer/okf/index.md`)
- Always start searches from `plugins/ai-engineer/okf/index.md` before consulting any other source.
- Only read or search from this knowledge source; never write to or modify it.
- Navigate the knowledge source only through `plugins/ai-engineer/okf/index.md`: read it, follow its links to the relevant concept groups and their own `index.md` files, and open only the concepts they point to. Do not assume or hardcode concept file names or paths.
- Look up by topic: **lifecycle events** (which events exist and when they fire), **event payloads and output/decision fields**, **exit codes and failure behavior**, and **hook configuration** (command fields, locations, matchers, platform limits).
- The knowledge source documents GitHub Copilot hooks (Copilot CLI and cloud agent). PascalCase event names (for example `PreToolUse`) select the VS Code compatible payload format, which is what this skill generates.

## Inputs

- **hook_intent** (required): A description of what the hook should do and when it should fire (e.g. "inject the current git branch into context at session start" or "run eslint after every JavaScript file modification").
- **plugin_name** (optional): The name of the plugin this hook belongs to. If omitted, the hook is created at **workspace level** using the Claude format (`.claude/settings.json`) instead of inside a plugin directory. Do not infer or ask — default to workspace level when not provided.
- **hook_event** (optional): Which lifecycle event should trigger the hook. Valid values: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, `Stop`. If omitted, infer from the intent or ask.
- **platform_support** (optional): Whether the hook needs a Windows variant in addition to the default Linux/macOS command. Defaults to `true` — always produce both unless told otherwise.

## Task Priorities

1. **Priority 1 – Correct lifecycle placement**
   The hook must fire on exactly the right event for its purpose. Misplacing a hook is a behavioral defect. Consult the lifecycle events information in the Primary Knowledge Source to choose correctly.

2. **Priority 2 – Reliable output contract**
   For context injection, output a flat `{"additionalContext": "..."}` object (no `hookSpecificOutput` wrapper). Consult the Primary Knowledge Source for other per-event output and decision fields. Exit `0` with JSON to influence agent behavior. Exit code semantics are event-specific — consult the exit code and failure behavior information in the Primary Knowledge Source: exit `2` denies on `preToolUse` and `permissionRequest` but is only a warning on most other events; other non-zero exits are non-blocking warnings except on `preToolUse`, which fails closed; timeouts always fail open.

3. **Priority 3 – Cross-platform correctness**
   Every hook command must have a `windows` variant using PowerShell unless the hook is explicitly Linux/macOS-only. Scripts must be tested for the target OS.

## Workflow

### Step 1 – Understand the Request

- Read the **hook_intent** carefully and identify:
  - **What** the hook does (inject context, block operations, run tool, audit, clean up).
  - **When** it fires — consult the lifecycle events information in the Primary Knowledge Source.
  - **What output** it produces — consult the per-event payload and decision-control information in the Primary Knowledge Source for the schema.

- If the event is ambiguous, apply these defaults:
  - Context injection at session level → `SessionStart` (add `SubagentStart` if subagents also need it).
  - Context injection per prompt → `UserPromptSubmit`.
  - Block or approve a tool call → `PreToolUse`.
  - Quality enforcement after file changes → `PostToolUse`.
  - Save state before context truncation → `PreCompact`.
  - Clean up or report at session end → `Stop`.
- Ask the user if the event still cannot be determined after inference.

### Step 1b – Determine Scope

Before writing any files, decide which scope applies:

| Condition | Scope | Config file | Script location |
|---|---|---|---|
| `plugin_name` provided | **Plugin** | `plugins/<plugin-name>/com.github.copilot/hooks/hooks.json` | `plugins/<plugin-name>/scripts/` |
| `plugin_name` omitted | **Workspace** | `.claude/settings.json` | `.claude/scripts/` |

- **Plugin scope**: follows Steps 3–7 as written. Use `${PLUGIN_ROOT}` to reference scripts.
- **Workspace scope**: write the hook into `.claude/settings.json` using paths relative to the workspace root. No `plugin.json` is needed. Scripts go in `.claude/scripts/`. Use `.claude/settings.local.json` instead if the user requests a local-only hook (not committed to version control).
- **Important distinction**: Hook scripts belong to plugin-level/workspace-level hook script paths above. If a request also includes **skill companion scripts**, those must be created under the skill directory: `plugins/<plugin-name>/skills/<skill-name>/scripts/` (or `.agents/skills/<skill-name>/scripts/` for workspace scope).

### Step 2 – Choose Output Mode

Consult the Primary Knowledge Source for the exit-code contract, common output fields, and per-event output schemas. Context injection uses a flat `additionalContext` field without `hookSpecificOutput`.

### Step 3 – Write the Scripts

**Plugin scope**: create script files under `plugins/<plugin-name>/scripts/`.
**Workspace scope**: create script files under `.claude/scripts/`.
Do not place hook scripts under `skills/<skill-name>/scripts/` unless the request is specifically for a skill companion script rather than a lifecycle hook script.

#### Linux/macOS script (`<hook-name>.sh`)

```bash
#!/usr/bin/env bash
# <hook-name>.sh — <hook_event> hook for <plugin-name>.
# <Brief description of what the script does.>

# Script logic here.
# For context injection, end with:
# printf '{"additionalContext":"%s"}\n' "$context"
```

Rules:
- Must start with `#!/usr/bin/env bash`.
- Use `[ -n "$VAR" ]` guards before reading environment variables.
- Use `printf` (not `echo`) for JSON output to avoid newline issues.
- Exit non-zero with a descriptive message on any unrecoverable error.

#### Windows script (`<hook-name>.ps1`)

```powershell
# <hook-name>.ps1 — <hook_event> hook for <plugin-name> (Windows).
# <Brief description of what the script does.>

# Script logic here.
# For context injection, end with:
# @{ additionalContext = $context } | ConvertTo-Json -Compress
```

Rules:
- Do not include a shebang line.
- Use `$env:VAR` syntax for environment variables.
- Use `Write-Output` for JSON output.
- Use `exit 1` with `Write-Error` for unrecoverable errors.

### Step 4 – Write the Hook Configuration

The configuration file and its structure differ by scope.

#### Plugin scope — `plugins/<plugin-name>/com.github.copilot/hooks/hooks.json`

```json
{
  "version": 1,
  "hooks": {
    "<HookEvent>": [
      {
        "type": "command",
        "bash": "bash \"${PLUGIN_ROOT}/scripts/<hook-name>.sh\"",
        "powershell": "powershell -NoProfile -ExecutionPolicy Bypass -File \"${PLUGIN_ROOT}/scripts/<hook-name>.ps1\"",
        "timeout": 30
      }
    ]
  }
}
```

Use `${PLUGIN_ROOT}` to reference scripts — do not hardcode paths.

#### Workspace scope — `.claude/settings.json`

```json
{
  "hooks": {
    "<HookEvent>": [
      {
        "type": "command",
        "command": "bash \".claude/scripts/<hook-name>.sh\"",
        "windows": "powershell -ExecutionPolicy Bypass -File \".claude/scripts/<hook-name>.ps1\"",
        "timeout": 30
      }
    ]
  }
}
```

Paths are relative to the workspace root. If `.claude/settings.json` already exists, **merge** the new hook entry into the existing `hooks` object — do not overwrite the file.

For the full list of supported hook command properties (`type`, `command`, `bash`, `powershell`, `windows`, `linux`, `osx`, `cwd`, `env`, `timeout`/`timeoutSec`, and `matcher`) and their valid values, consult the hook configuration information in the Primary Knowledge Source.

### Step 5 – Update plugin.json

Plugin manifests live at the plugin root (`plugins/<plugin-name>/plugin.json`), not in `.claude-plugin/` or `plugin/`. If the plugin manifest does not yet exist or lives in an old location, create or move it:

```json
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",
  "name": "<plugin-name>",
  "description": "<plugin description>",
  "version": "<semver>",
  "author": { "name": "<author>" },
  "repository": "<repo-url>",
  "keywords": ["<plugin-name>", "hook", "<relevant-keywords>"]
}
```

The hooks directory does not need to be referenced in `plugin.json` — the runtime discovers `com.github.copilot/hooks/hooks.json` automatically.

### Step 6 – Validate

Before delivering, verify:

1. **Hook config file** — Event name is a valid lifecycle event according to the Primary Knowledge Source. `type` is `"command"`. `bash` and/or `powershell` keys are present for plugin scope (`command` and OS-specific keys for workspace scope), and plugin scope sets `"version": 1`.
2. **Scope routing** — Plugin scope uses `plugins/<plugin-name>/com.github.copilot/hooks/hooks.json` with `${PLUGIN_ROOT}` paths. Workspace scope uses `.claude/settings.json` with workspace-relative paths. These must not be mixed.
3. **Merge safety** — For workspace scope, confirm that the `.claude/settings.json` file was merged (not overwritten) if it already existed.
4. **Output contract** — The JSON output matches the event-specific schema from Step 2. Context injection uses a flat `additionalContext` field with no `hookSpecificOutput` wrapper. `stop_hook_active` is checked for `Stop` and `SubagentStop` hooks.
5. **Shell script** — Starts with `#!/usr/bin/env bash`. JSON output uses `printf`. Environment variable reads are guarded. Script exits 0 when nothing to output; exits 2 only where the event treats it as a block or deny (for example `preToolUse`), per the exit code information in the Primary Knowledge Source.
6. **PowerShell script** — Uses `$env:VAR` syntax. Uses `Write-Output` for JSON output. Escaping is correct (backtick-escaped quotes inside double-quoted strings). Exits 2 only where the event treats it as a block or deny.
7. **plugin.json** (plugin scope only) — Located at the plugin root (`plugin.json`). Contains `name`, `description`, `version`, `author`.

### Step 7 – Save the Files

**Plugin scope** — save all files to the plugin directory:

```
plugins/<plugin-name>/
  plugin.json
  com.github.copilot/
    hooks/
      hooks.json
  scripts/
    <hook-name>.sh
    <hook-name>.ps1
```

**Workspace scope** — save files at the workspace root:

```
.claude/
  settings.json          ← merge hook entry here
  scripts/
    <hook-name>.sh
    <hook-name>.ps1
```

Do not wrap any file content in code fences when writing to disk.

## Output Format

After creating all hook files, respond with:

```markdown
## Summary
- Hook event and what it does (1–2 sentences).
- Files created and their paths.
- Output mode: additionalContext injection or exit-code enforcement.

## Files Created
- List every file created with its relative path.

## How to Test
- How to trigger the hook manually (e.g. start a new agent session, modify a file).
- What to observe to confirm the hook is working (context injected, tool blocked on failure).

## Limitations
- Any platform-specific assumptions or limitations.
- Conditions under which the hook will silently skip (e.g. env var not set).
```

## Assumptions and Limitations

- When `plugin_name` is not provided, hooks are written to `.claude/settings.json` at the workspace root (Claude format). Use `.claude/settings.local.json` only when the user explicitly requests a local-only, non-committed hook.
- Assumes the VS Code Copilot runtime discovers `com.github.copilot/hooks/hooks.json` at the plugin root.
- Valid hook events are documented in the Primary Knowledge Source — any event name not listed there is invalid. Some events (for example `notification`, `permissionRequest`, and policy hooks) are Copilot CLI only, and cloud agent fires only a subset; check the per-surface behavior documented there before targeting it.
- OS-specific command selection (`windows`, `linux`, `osx`) is based on the extension host platform, which may differ from the local OS in remote development scenarios (SSH, Containers, WSL).
- `${PLUGIN_ROOT}` is the only supported runtime variable for referencing plugin files inside hook commands.
- `Stop` and `SubagentStop` hooks that return `decision: "block"` cause the agent to run additional turns, each consuming premium requests. Always guard with `stop_hook_active`.
- Matchers (`matcher` regex on `preToolUse`, `postToolUse`, `permissionRequest`, `subagentStart`, `preCompact`, `notification`) are honored by Copilot CLI per the Primary Knowledge Source, but Claude Code-style `tool_name` matchers are currently ignored by VS Code — there, all hooks run on every matching event regardless of tool name.
- Does not generate MCP server configurations, agent files, or skill files — use the dedicated maker skills for those.
- Scripts that produce JSON output must emit well-formed JSON on a single line; multi-line printf is safe only if newlines are escaped within the JSON string value.
