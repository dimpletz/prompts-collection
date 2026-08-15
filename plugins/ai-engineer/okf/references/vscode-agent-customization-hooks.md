---
type: Reference
title: VS Code Agent Customization Hooks
description: Official VS Code documentation for agent hook lifecycle events, configuration format, input/output schema, and usage scenarios for automating workflows during agent sessions.
resource: https://code.visualstudio.com/docs/agent-customization/hooks
tags: [vscode, agent, hooks, customization, automation]
generated: { by: github-copilot/claude-sonnet-4.6, at: 2026-08-15T14:59:35Z }
---

# Overview

Hooks execute custom shell commands at specific lifecycle points during agent sessions. They are
deterministic and code-driven — unlike instructions, they run at guaranteed moments with
guaranteed outcomes.

## Lifecycle Events

| Event | Fires When | Common Uses |
|---|---|---|
| `SessionStart` | First prompt of a new session | Initialize resources, validate project state |
| `UserPromptSubmit` | User submits a prompt | Audit requests, inject system context |
| `PreToolUse` | Before any tool is invoked | Block dangerous ops, require approval |
| `PostToolUse` | After tool completes | Run formatters, trigger follow-up actions |
| `PreCompact` | Before context compaction | Export state, save important context |
| `SubagentStart` | Subagent spawned | Track nested agent usage |
| `SubagentStop` | Subagent completes | Aggregate results, cleanup |
| `Stop` | Agent session ends | Generate reports, cleanup resources |

## Configuration

Hooks are defined in JSON files. Default search locations:

| Scope | Path |
|---|---|
| Workspace | `.github/hooks/*.json` |
| Workspace (Claude) | `.claude/settings.json`, `.claude/settings.local.json` |
| User | `~/.copilot/hooks`, `~/.claude/settings.json` |
| Custom agent | `hooks` field in `.agent.md` frontmatter |
| Plugin | `hooks.json` or `hooks/hooks.json` |

Minimal hook (formats files after every tool use):

```json
{
  "hooks": {
    "PostToolUse": [
      { "type": "command", "command": "npx prettier --write ." }
    ]
  }
}
```

Customize loaded locations via `chat.hookFilesLocations` setting. Use `windows`, `linux`, `osx`
properties on a hook entry for OS-specific commands.

**Agent-scoped hooks** (Preview): add a `hooks` block to `.agent.md` frontmatter. Enable with
`chat.useCustomAgentHooks: true`. Runs only when that agent is active, in addition to
workspace/user hooks.

## Input / Output

Hooks receive a JSON object on stdin and may write JSON to stdout.

**Common stdin fields**: `timestamp`, `cwd`, `session_id`, `hook_event_name`, `transcript_path`.

**Common stdout fields**:

| Field | Type | Meaning |
|---|---|---|
| `continue` | boolean | `false` stops the entire session (default: `true`) |
| `stopReason` | string | Shown to user when `continue` is `false` |
| `systemMessage` | string | Warning displayed in chat |

**Exit codes**: `0` = success (parse stdout as JSON), `2` = blocking error (shown to model),
other = non-blocking warning.

Use `PreToolUse` + `hookSpecificOutput.permissionDecision` to allow/deny a single tool call
without stopping the session.

## Security

- Hooks run with VS Code's permissions — review all scripts before enabling.
- Validate and sanitize stdin input to prevent injection attacks.
- Never hardcode secrets; use environment variables or credential stores.
- Use `chat.tools.edits.autoApprove` to prevent the agent from modifying its own hook scripts.

## Troubleshooting

- **Hook not executing**: ensure the file is in `.github/hooks/` with a `.json` extension and
  `type: "command"` is set.
- **View diagnostics**: Output panel → *GitHub Copilot Chat Hooks* channel.
- **Debug logs**: run `Developer: Show Agent Debug Logs` command.

## Claude Code / Copilot CLI Compatibility

VS Code reads `.claude/settings.json` but ignores matcher values (all hooks fire on every
matching event). Tool input properties use camelCase in VS Code vs snake_case in Claude Code.
Copilot CLI `bash`/`powershell` command properties map to `linux`/`osx` and `windows`.

## Related

- [Hooks reference](https://code.visualstudio.com/docs/agents/reference/hooks-reference) — full per-event input/output schema
- [Custom agents](https://code.visualstudio.com/docs/agent-customization/custom-agents) — agent-scoped hooks
- [Customization concepts](https://code.visualstudio.com/docs/agents/concepts/customization)
