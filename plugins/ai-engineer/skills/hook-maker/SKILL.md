---
name: hook-maker
description: >
  A skill for creating VS Code Copilot agent hook configurations (hooks.json and companion scripts). Use it whenever the user asks to create a new hook, automate an action at a specific agent lifecycle event, or add hook support to a plugin. Do not use it for creating agents (.agent.md), skills (SKILL.md), or plugin manifests — use the appropriate maker skill for those.
---

# Hook Maker

This **skill** is for developers who need to add automated lifecycle hooks to a VS Code Copilot agent plugin. Hooks run shell scripts or commands at specific points in the agent lifecycle and can inject context, enforce security policies, run quality checks, install dependencies, or perform any side-effect needed before or after agent activity.

VS Code supports eight hook lifecycle events: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, and `Stop`.

## Inputs

- **hook_intent** (required): A description of what the hook should do and when it should fire (e.g. "inject the current git branch into context at session start" or "run eslint after every JavaScript file modification").
- **plugin_name** (optional): The name of the plugin this hook belongs to. If omitted, the hook is created at **workspace level** using the Claude format (`.claude/settings.json`) instead of inside a plugin directory. Do not infer or ask — default to workspace level when not provided.
- **hook_event** (optional): Which lifecycle event should trigger the hook. Valid values: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, `Stop`. If omitted, infer from the intent or ask.
- **platform_support** (optional): Whether the hook needs a Windows variant in addition to the default Linux/macOS command. Defaults to `true` — always produce both unless told otherwise.

## Task Priorities

1. **Priority 1 – Correct lifecycle placement**
   The hook must fire on exactly the right event for its purpose. Misplacing a hook is a behavioral defect. Use the event reference table in Step 1 to choose correctly.

2. **Priority 2 – Reliable output contract**
   Each hook event has its own `hookSpecificOutput` schema — use the correct fields for the event. Exit code `2` is a hard blocking error; any other non-zero exit is a non-blocking warning. Exit `0` with JSON to influence agent behavior.

3. **Priority 3 – Cross-platform correctness**
   Every hook command must have a `windows` variant using PowerShell unless the hook is explicitly Linux/macOS-only. Scripts must be tested for the target OS.

## Workflow

### Step 1 – Understand the Request

- Read the **hook_intent** carefully and identify:
  - **What** the hook does (inject context, block operations, run tool, audit, clean up).
  - **When** it fires — use the table below to select the correct event.
  - **What output** it produces (see Step 2 for the per-event output schema).

| Event | Fires when | Typical use |
|---|---|---|
| `SessionStart` | User submits the first prompt of a new session | Inject context, validate state, initialize resources |
| `UserPromptSubmit` | User submits any prompt | Audit requests, inject system context |
| `PreToolUse` | Before agent invokes a tool | Block dangerous operations, require approval, modify tool input |
| `PostToolUse` | After a tool completes successfully | Run formatters, log results, trigger follow-up actions |
| `PreCompact` | Before conversation context is compacted | Export context, save state before truncation |
| `SubagentStart` | A subagent is spawned | Track nested agent usage, initialize subagent resources |
| `SubagentStop` | A subagent completes | Aggregate results, clean up subagent resources |
| `Stop` | Agent session ends | Generate reports, clean up, send notifications |

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
| `plugin_name` provided | **Plugin** | `plugins/<plugin-name>/hooks/hooks.json` | `plugins/<plugin-name>/scripts/` |
| `plugin_name` omitted | **Workspace** | `.claude/settings.json` | `.claude/scripts/` |

- **Plugin scope**: follows Steps 3–7 as written. Use `${CLAUDE_PLUGIN_ROOT}` to reference scripts.
- **Workspace scope**: write the hook into `.claude/settings.json` using paths relative to the workspace root. No `plugin.json` is needed. Scripts go in `.claude/scripts/`. Use `.claude/settings.local.json` instead if the user requests a local-only hook (not committed to version control).
- **Important distinction**: Hook scripts belong to plugin-level/workspace-level hook script paths above. If a request also includes **skill companion scripts**, those must be created under the skill directory: `plugins/<plugin-name>/skills/<skill-name>/scripts/` (or `.agents/skills/<skill-name>/scripts/` for workspace scope).

### Step 2 – Choose Output Mode

Hooks communicate via **exit code** and **stdout JSON**. The exit code determines how VS Code handles the result:

| Exit code | Meaning |
|---|---|
| `0` | Success — stdout is parsed as JSON |
| `2` | Blocking error — stop processing and show stderr to the model |
| Other non-zero | Non-blocking warning — show warning to user, continue processing |

All hooks support these **common JSON output fields** (stdout, exit 0):

```json
{"continue": false, "stopReason": "Reason shown to user", "systemMessage": "Warning shown in chat"}
```

Set `continue: false` to stop the entire agent session. Use `stopReason` to explain why. `systemMessage` displays a warning regardless of other decisions.

In addition, each event supports **event-specific `hookSpecificOutput`** fields:

#### `SessionStart` — inject context into the session
```json
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"<text>"}}
```

#### `UserPromptSubmit` — common output only (no hookSpecificOutput)
Exit 0 with no output, or use `continue`/`systemMessage` from the common fields.

#### `PreToolUse` — allow, deny, or prompt for a tool call
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Reason shown to user",
    "updatedInput": {},
    "additionalContext": "Extra context for the model"
  }
}
```
`permissionDecision` values: `"allow"` (auto-approve), `"deny"` (block), `"ask"` (require user confirmation). When multiple hooks run, the most restrictive decision wins (`deny` > `ask` > `allow`).

#### `PostToolUse` — block further processing or inject context
```json
{
  "decision": "block",
  "reason": "Validation failed",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Lint errors found in the edited file"
  }
}
```

#### `PreCompact` — common output only (no hookSpecificOutput)
Use `continue`/`systemMessage` from the common fields to influence compaction.

#### `SubagentStart` — inject context into a subagent's conversation
```json
{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"<text>"}}
```

#### `SubagentStop` — prevent a subagent from stopping
```json
{"decision":"block","reason":"Verify results before the subagent completes"}
```
Always check `stop_hook_active` in the stdin input to prevent infinite loops.

#### `Stop` — prevent the agent session from ending
```json
{"hookSpecificOutput":{"hookEventName":"Stop","decision":"block","reason":"Run tests before finishing"}}
```
Always check `stop_hook_active` in the stdin input to prevent the agent from running indefinitely (each extra turn consumes premium requests).

**Exit-code-only mode**: For side-effect hooks (format, lint, test) that do not need to communicate with the agent, exit 0 for success and exit 2 to surface an error to the model via stderr.

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

### Step 4 – Write the Hook Configuration

The configuration file and its structure differ by scope.

#### Plugin scope — `plugins/<plugin-name>/hooks/hooks.json`

```json
{
  "hooks": {
    "<HookEvent>": [
      {
        "type": "command",
        "command": "bash \"${CLAUDE_PLUGIN_ROOT}/scripts/<hook-name>.sh\"",
        "windows": "powershell -ExecutionPolicy Bypass -File \"${CLAUDE_PLUGIN_ROOT}/scripts/<hook-name>.ps1\"",
        "timeout": 30
      }
    ]
  }
}
```

Use `${CLAUDE_PLUGIN_ROOT}` to reference scripts — do not hardcode paths.

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

#### Supported hook command properties (both scopes)

| Property | Type | Description |
|---|---|---|
| `type` | string | Must be `"command"` |
| `command` | string | Default command (cross-platform fallback) |
| `windows` | string | Windows-specific command override |
| `linux` | string | Linux-specific command override |
| `osx` | string | macOS-specific command override |
| `cwd` | string | Working directory (relative to repository root) |
| `env` | object | Additional environment variables |
| `timeout` | number | Timeout in seconds (default: 30) |

Rules (both scopes):
- `<HookEvent>` must be one of: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, `Stop`.
- The runtime selects the OS-specific command (`windows`, `linux`, `osx`) when present, falling back to `command`.
- Multiple hooks on the same event are listed as additional objects in the array.
- Omit OS-specific keys only when the hook is explicitly single-platform.

### Step 5 – Update plugin.json

Hook-based plugins must use `.claude-plugin/plugin.json` (not `plugin/plugin.json`). If the plugin manifest does not yet exist or uses `plugin/plugin.json`, create or convert it:

```json
{
  "name": "<plugin-name>",
  "description": "<plugin description>",
  "version": "<semver>",
  "author": { "name": "<author>" },
  "repository": "<repo-url>",
  "keywords": ["<plugin-name>", "hook", "<relevant-keywords>"]
}
```

The hooks directory does not need to be referenced in `plugin.json` — the runtime discovers `hooks/hooks.json` automatically when `.claude-plugin/plugin.json` is present.

### Step 6 – Validate

Before delivering, verify:

1. **Hook config file** — Event name is one of `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, `Stop`. `type` is `"command"`. `command` and/or OS-specific keys are present as needed.
2. **Scope routing** — Plugin scope uses `plugins/<plugin-name>/hooks/hooks.json` with `${CLAUDE_PLUGIN_ROOT}` paths. Workspace scope uses `.claude/settings.json` with workspace-relative paths. These must not be mixed.
3. **Merge safety** — For workspace scope, confirm that the `.claude/settings.json` file was merged (not overwritten) if it already existed.
4. **Output contract** — The JSON output matches the event-specific schema from Step 2. `hookSpecificOutput.hookEventName` matches the event. `stop_hook_active` is checked for `Stop` and `SubagentStop` hooks.
5. **Shell script** — Starts with `#!/usr/bin/env bash`. JSON output uses `printf`. Environment variable reads are guarded. Script exits 0 when nothing to output, exits 2 to hard-block with an error.
6. **PowerShell script** — Uses `$env:VAR` syntax. Uses `Write-Output` for JSON output. Escaping is correct (backtick-escaped quotes inside double-quoted strings). Exits 2 to hard-block.
7. **plugin.json** (plugin scope only) — Located at `.claude-plugin/plugin.json`. Contains `name`, `description`, `version`, `author`.

### Step 7 – Save the Files

**Plugin scope** — save all files to the plugin directory:

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
- Assumes the VS Code Copilot runtime supports `hooks.json` discovery when `.claude-plugin/plugin.json` is present.
- Valid hook events are: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, `Stop` — any other event name is invalid.
- OS-specific command selection (`windows`, `linux`, `osx`) is based on the extension host platform, which may differ from the local OS in remote development scenarios (SSH, Containers, WSL).
- `${CLAUDE_PLUGIN_ROOT}` is the only supported runtime variable for referencing plugin files inside hook commands.
- `Stop` and `SubagentStop` hooks that return `decision: "block"` cause the agent to run additional turns, each consuming premium requests. Always guard with `stop_hook_active`.
- Matchers (Claude Code-style `tool_name` filters) are parsed by VS Code but currently ignored — all hooks run on every matching event regardless of tool name.
- Does not generate MCP server configurations, agent files, or skill files — use the dedicated maker skills for those.
- Scripts that produce JSON output must emit well-formed JSON on a single line; multi-line printf is safe only if newlines are escaped within the JSON string value.
