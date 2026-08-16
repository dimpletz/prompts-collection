---
type: Reference
title: Agent Hooks in Visual Studio Code
description: Official VS Code documentation covering how to configure and use agent hooks — custom shell commands that execute at agent session lifecycle points.
tags: [vscode, hooks, agent-customization, automation]
resource: https://code.visualstudio.com/docs/agent-customization/hooks
generated: { by: agent:create-okf, at: 2026-08-16T22:19:52+12:00 }
---

# Overview

Agent hooks execute custom shell commands at specific lifecycle points during a VS Code agent session. Unlike instructions or prompts, hooks provide deterministic, code-driven automation with guaranteed outcomes.

## Why Use Hooks

- **Enforce security policies**: Block dangerous commands before they execute.
- **Automate code quality**: Run formatters, linters, or tests after file modifications.
- **Create audit trails**: Log every tool invocation or file change.
- **Inject context**: Add project-specific information or environment details.
- **Control approvals**: Automatically approve safe operations or require confirmation for sensitive ones.

## Hook Lifecycle Events

VS Code supports eight hook events:

| Event | Fires when |
|---|---|
| `SessionStart` | User submits the first prompt of a new session |
| `UserPromptSubmit` | User submits a prompt |
| `PreToolUse` | Before the agent invokes any tool |
| `PostToolUse` | After a tool completes successfully |
| `PreCompact` | Before conversation context is compacted |
| `SubagentStart` | A subagent is spawned |
| `SubagentStop` | A subagent completes |
| `Stop` | The agent session ends |

## Configuration Format

Hook configuration files are JSON with a `hooks` object mapping event names to arrays of command objects:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "type": "command",
        "command": "./scripts/validate-tool.sh",
        "timeout": 15
      }
    ],
    "PostToolUse": [
      {
        "type": "command",
        "command": "npx prettier --write ."
      }
    ]
  }
}
```

Each entry requires `type: "command"` and a `command` string. Optional properties include `cwd`, `env`, `timeout`, and OS-specific overrides (`windows`, `linux`, `osx`).

## Hook File Locations

VS Code searches for hooks in:

| Scope | Location |
|---|---|
| Workspace | `.github/hooks/*.json` |
| Workspace (Claude format) | `.claude/settings.json`, `.claude/settings.local.json` |
| User | `~/.copilot/hooks`, `~/.claude/settings.json` |
| Custom agent | `hooks` field in `.agent.md` frontmatter |
| Plugin | `hooks.json` or `hooks/hooks.json` |

Workspace hooks take precedence over user hooks for the same event type. Use the `chat.hookFilesLocations` setting to add or disable locations.

## Agent-Scoped Hooks

Hooks can be defined directly in a custom agent's `.agent.md` YAML frontmatter under a `hooks` key. These run only when that agent is active and require `chat.useCustomAgentHooks: true`.

## Hook Input and Output

Every hook receives JSON on stdin with fields including `timestamp`, `hook_event_name`, `cwd`, `session_id`, and `transcript_path`. Hooks can write JSON to stdout to influence agent behavior:

| Field | Effect |
|---|---|
| `continue: false` | Stops the entire agent session |
| `stopReason` | Message shown to the user when stopping |
| `systemMessage` | Warning displayed in chat |

Exit codes: `0` = success (parse stdout), `2` = blocking error (stop and show to model), any other = non-blocking warning.

The `PreToolUse` event additionally supports `hookSpecificOutput.permissionDecision` to allow, deny, or prompt for a single tool call without stopping the session.

## Security Considerations

Hooks execute with the same permissions as VS Code. Best practices:

- Review all hook scripts before enabling, especially in shared repositories.
- Apply the principle of least privilege.
- Validate and sanitize all hook input to prevent injection attacks.
- Never hardcode secrets in hook scripts — use environment variables or secure credential storage.
- Use `chat.tools.edits.autoApprove` to prevent the agent from modifying its own hook scripts.

## Troubleshooting

- **Hook not executing**: Verify the file is in `.github/hooks/` with a `.json` extension and `type: "command"` set.
- **Permission denied**: Ensure hook scripts have execute permissions (`chmod +x script.sh`).
- **Timeout errors**: Increase the `timeout` value (default: 30 seconds).
- **JSON parse errors**: Verify that stdout outputs valid JSON.

View loaded hooks and errors via **Output → GitHub Copilot Chat Hooks**, or run **Developer: Show Agent Debug Logs**.
