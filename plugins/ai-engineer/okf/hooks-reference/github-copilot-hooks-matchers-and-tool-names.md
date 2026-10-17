---
type: Reference
title: GitHub Copilot Hooks Matchers and Tool Names
description: How the matcher regex field filters hook invocations per event, the Claude-format matcher semantics for PascalCase events, and the runtime and Claude tool names used for matching.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, matchers, tool-names]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Several events accept an optional `matcher` regex on each hook entry that filters which invocations the hook fires for. It is compiled as `^(?:PATTERN)$` and must match the full value. Invalid regexes cause the hook entry to be skipped. Part of the [GitHub Copilot Hooks Reference](./github-copilot-hooks-reference.md).

# Matcher Filtering

| Event | `matcher` is matched against |
|---|---|
| `notification` | `notification_type` |
| `permissionRequest` | `toolName` |
| `postToolUse` | `toolName` |
| `preCompact` | `trigger` (`"manual"` or `"auto"`) |
| `preToolUse` | `toolName` |
| `subagentStart` | `agentName` |

Details per event: [Notification Hook](./github-copilot-hooks-notification-hook.md), [Tool Decision Control](./github-copilot-hooks-tool-decision-control.md), [Error and Compaction Payloads](./github-copilot-hooks-error-and-compaction-payloads.md), and [Agent Lifecycle Payloads](./github-copilot-hooks-agent-lifecycle-payloads.md).

# Claude-Format Matchers (PascalCase PreToolUse)

Hooks configured with the PascalCase event name `PreToolUse` — as used in Claude Code plugins and the Open Plugins format — apply Claude's matcher semantics instead of the native regex rule. `PermissionRequest` in PascalCase uses the same rules.

- `*`, `**`, or an empty `matcher` value fires for every tool.
- A literal name or `|`-separated alternation (for example `Bash` or `Edit|Write`) fires when any token equals the runtime tool name or its Claude tool name from the table below.
- Any other value is treated as a case-sensitive regex anchored as `^(?:PATTERN)$` tested against the Claude tool name (or the runtime name for tools with no Claude equivalent).
- Payloads for PascalCase `PreToolUse` report `tool_name` as the Claude tool name (for example `Bash`, not `bash`).

| Runtime tool | Claude tool name |
|---|---|
| `bash`, `powershell` | `Bash` |
| `view` | `Read` |
| `create` | `Write` |
| `edit`, `str_replace_editor`, `apply_patch` | `Edit` |
| `grep`, `rg` | `Grep` |
| `glob` | `Glob` |
| `web_fetch` | `WebFetch` |
| `web_search` | `WebSearch` |
| `ask_user` | `AskUserQuestion` |
| `update_todo` | `TodoWrite` |
| `task` | `Agent` (the literal `Task` is also accepted) |

Tools with no Claude equivalent keep their runtime names.

# Tool Names for Hook Matching

| Tool name | Description |
|---|---|
| `ask_user` | Ask the user a clarifying question; under cloud agent there is no user, so it produces no useful result |
| `bash` | Execute shell commands (Unix) |
| `create` | Create new files |
| `edit` | Modify file contents |
| `glob` | Find files by pattern |
| `grep` | Search file contents |
| `powershell` | Execute shell commands (Windows); does not appear under cloud agent (Linux sandbox) |
| `task` | Run subagent tasks |
| `view` | Read file contents |
| `web_fetch` | Fetch web pages |

If multiple hooks of the same type are configured, they execute in order. For `preToolUse`, if any hook returns `"deny"`, the tool is blocked.
