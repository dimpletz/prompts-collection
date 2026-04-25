---
name: hook-maker
description: >
  A skill for creating VS Code Copilot agent hook configurations (hooks.json and companion scripts). Use it whenever the user asks to create a new hook, automate an action at a specific agent lifecycle event, or add hook support to a plugin. Do not use it for creating agents (.agent.md), skills (SKILL.md), or plugin manifests — use the appropriate maker skill for those.
---

# Hook Maker

This **skill** is for developers who need to add automated lifecycle hooks to a VS Code Copilot agent plugin. Hooks run shell scripts or commands at specific points in the agent lifecycle (session start, subagent start, post-tool-use) and can inject context, run quality checks, install dependencies, or perform any side-effect needed before or after agent activity.

## Inputs

- **hook_intent** (required): A description of what the hook should do and when it should fire (e.g. "inject the current git branch into context at session start" or "run eslint after every JavaScript file modification").
- **plugin_name** (optional): The name of the plugin this hook belongs to. If omitted, infer from the workspace folder name or ask.
- **hook_event** (optional): Which lifecycle event should trigger the hook (`SessionStart`, `SubagentStart`, `PostToolUse`). If omitted, infer from the intent or ask.
- **platform_support** (optional): Whether the hook needs a Windows variant in addition to the default Linux/macOS command. Defaults to `true` — always produce both unless told otherwise.

## Task Priorities

1. **Priority 1 – Correct lifecycle placement**
   The hook must fire on exactly the right event for its purpose. SessionStart/SubagentStart hooks inject context; PostToolUse hooks react to file or tool changes. Misplacing a hook is a behavioral defect.

2. **Priority 2 – Reliable output contract**
   Hooks that produce agent context must emit valid JSON: `{"hookSpecificOutput":{"additionalContext":"<text>"}}`. Hooks that only run side-effects (formatting, linting) must exit with a non-zero code on failure to block the agent.

3. **Priority 3 – Cross-platform correctness**
   Every hook command must have a `windows` variant using PowerShell unless the hook is explicitly Linux/macOS-only. Scripts must be tested for the target OS.

## Workflow

### Step 1 – Understand the Request

- Read the **hook_intent** carefully and identify:
  - **What** the hook does (inject context, run tool, check state, install dependency).
  - **When** it fires (`SessionStart`, `SubagentStart`, `PostToolUse`).
  - **What output** it produces (additionalContext JSON, exit code, stdout for blocking errors).
- If the event is ambiguous, apply these defaults:
  - Context injection → `SessionStart` (and optionally `SubagentStart` if subagents also need it).
  - Quality enforcement after file changes → `PostToolUse`.
  - Dependency setup → `SessionStart`.
- Ask the user if the event still cannot be determined after inference.

### Step 2 – Choose Output Mode

Determine how the hook communicates with the agent:

- **additionalContext** — for hooks that inject information into the agent's context window. The script must print a JSON object:
  ```json
  {"hookSpecificOutput":{"additionalContext":"<markdown or plain-text context>"}}
  ```
  Output nothing (exit 0) when there is no relevant context to inject.

- **Exit-code-only** — for hooks that run side-effects (format, lint, test). Exit 0 for success, non-zero to signal failure. The agent treats non-zero exit as a blocking error and surfaces the stdout to the user.

### Step 3 – Write the Scripts

Create two script files under `plugins/<plugin-name>/scripts/`:

#### Linux/macOS script (`<hook-name>.sh`)

```bash
#!/usr/bin/env bash
# <hook-name>.sh — <hook_event> hook for <plugin-name>.
# <Brief description of what the script does.>

# Script logic here.
# For context injection, end with:
# printf '{"hookSpecificOutput":{"additionalContext":"%s"}}\n' "$context"
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
# Write-Output "{`"hookSpecificOutput`":{`"additionalContext`":`"$context`"}}"
```

Rules:
- Do not include a shebang line.
- Use `$env:VAR` syntax for environment variables.
- Use `Write-Output` for JSON output.
- Use `exit 1` with `Write-Error` for unrecoverable errors.

### Step 4 – Write hooks.json

Create `plugins/<plugin-name>/hooks/hooks.json` with the following structure:

```json
{
  "hooks": {
    "<HookEvent>": [
      {
        "type": "command",
        "command": "bash \"${CLAUDE_PLUGIN_ROOT}/scripts/<hook-name>.sh\"",
        "windows": "powershell -ExecutionPolicy Bypass -File \"${CLAUDE_PLUGIN_ROOT}/scripts/<hook-name>.ps1\""
      }
    ]
  }
}
```

Rules:
- Use `${CLAUDE_PLUGIN_ROOT}` (not a hardcoded path) to reference the plugin root.
- `command` is used on Linux/macOS; `windows` is used on Windows.
- Multiple hooks on the same event are listed as additional objects in the array.
- Omit the `windows` key only if the hook is explicitly Linux/macOS-only.

### Step 5 – Update plugin.json

Hook-based plugins must use `.claude-plugin/plugin.json` (not `plugin/plugin.json`). If the plugin manifest does not yet exist or uses `plugin/plugin.json`, create or convert it:

```json
{
  "name": "<plugin-name>",
  "description": "<plugin description>",
  "version": "<semver>",
  "author": { "name": "<author>" },
  "repository": "<repo-url>",
  "license": "MIT",
  "keywords": ["<plugin-name>", "hook", "<relevant-keywords>"]
}
```

The hooks directory does not need to be referenced in `plugin.json` — the runtime discovers `hooks/hooks.json` automatically when `.claude-plugin/plugin.json` is present.

### Step 6 – Validate

Before delivering, verify:

1. **hooks.json** — Event name is one of `SessionStart`, `SubagentStart`, `PostToolUse`. `type` is `"command"`. Both `command` and `windows` keys are present (unless intentionally omitted).
2. **Shell script** — Starts with `#!/usr/bin/env bash`. JSON output uses `printf`. Environment variable reads are guarded. Script exits 0 when nothing to output.
3. **PowerShell script** — Uses `$env:VAR` syntax. Uses `Write-Output` for JSON output. Escaping is correct (backtick-escaped quotes inside double-quoted strings).
4. **plugin.json** — Located at `.claude-plugin/plugin.json`. Contains `name`, `description`, `version`, `author`.
5. **No hardcoded paths** — All script references use `${CLAUDE_PLUGIN_ROOT}`.

### Step 7 – Save the Files

Save all files to the plugin directory:

```
plugins/<plugin-name>/
  .claude-plugin/
    plugin.json
  hooks/
    hooks.json
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

- Assumes the VS Code Copilot runtime supports `hooks.json` discovery when `.claude-plugin/plugin.json` is present.
- Hook events are limited to `SessionStart`, `SubagentStart`, and `PostToolUse` — other event names are invalid.
- `${CLAUDE_PLUGIN_ROOT}` is the only supported runtime variable for referencing plugin files inside hook commands.
- Does not generate MCP server configurations, agent files, or skill files — use the dedicated maker skills for those.
- Scripts that produce `additionalContext` must emit well-formed JSON on a single line; multi-line printf is safe only if newlines are escaped within the JSON string value.
