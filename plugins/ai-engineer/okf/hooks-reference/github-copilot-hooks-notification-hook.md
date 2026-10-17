---
type: Reference
title: GitHub Copilot Notification Hook
description: Reference for the CLI-only notification hook event, including its input payload, notification types, additionalContext injection, and matcher on notification_type.
tags: [github-copilot, copilot-cli, hooks, notification, payloads]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

The `notification` hook is **Copilot CLI only** and does not fire under cloud agent, which surfaces no notifications to a user (see [Cloud Agent Execution Environment](./github-copilot-hooks-cloud-agent-environment.md)). It fires asynchronously when the CLI emits a system notification (shell completion, agent completion or idle, permission prompts, elicitation dialogs). These hooks are fire-and-forget: they never block the session, and any errors are logged and skipped. Part of the [GitHub Copilot Hooks Reference](./github-copilot-hooks-reference.md).

# Input

```typescript
{ sessionId: string; timestamp: number; cwd: string; hook_event_name: "Notification";
  message: string;           // human-readable notification text
  title?: string;            // short title, e.g. "Permission needed", "Shell completed"
  notification_type: string; // one of the types below
}
```

# Notification Types

| Type | When it fires |
|---|---|
| `shell_completed` | A background (async) shell command finishes |
| `shell_detached_completed` | A detached shell session completes |
| `agent_completed` | A background subagent finishes (completed or failed) |
| `agent_idle` | A background agent finishes a turn and enters idle state (waiting for `write_agent`) |
| `permission_prompt` | The agent requests permission to execute a tool |
| `elicitation_dialog` | The agent requests additional information from the user |

# Output

```typescript
{ additionalContext?: string; } // injected into the session as a user message
```

If `additionalContext` is returned, the text is injected into the session as a prepended user message, which can trigger further agent processing if the session is idle. Return `{}` or empty output to take no action.

# Matcher

Optional regex on `notification_type`, anchored as `^(?:PATTERN)$`. Omit `matcher` to receive all notification types. See [Matchers and Tool Names](./github-copilot-hooks-matchers-and-tool-names.md).
