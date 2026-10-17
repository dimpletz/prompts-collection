---
type: Reference
title: GitHub Copilot Prompt Hooks
description: Configuration and behavior of Copilot prompt hooks, which auto-submit text or a slash command on sessionStart, including CLI and cloud agent limitations.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, prompt-hooks, configuration]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Prompt hooks auto-submit text as if the user typed it. The text can be a natural language prompt or a slash command. They are supported only on `sessionStart`. Part of the [GitHub Copilot Hooks Reference](./github-copilot-hooks-reference.md); the other hook types are [Command Hooks](./github-copilot-hooks-command-hooks.md) and [HTTP Hooks](./github-copilot-hooks-http-hooks.md).

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "type": "prompt",
        "prompt": "YOUR_PROMPT_TEXT_OR_SLASH_COMMAND"
      }
    ]
  }
}
```

# Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `type` | `"prompt"` | Yes | Must be `"prompt"` |
| `prompt` | string | Yes | Text to submit — can be a natural language message or a slash command |

# Surface Behavior

- **Copilot CLI only:** prompt hooks fire only for **new interactive sessions**. They do not fire on resume, and they do not fire in non-interactive prompt mode (`-p`).
- **Cloud agent:** jobs run non-interactively (similar to `-p`), so `prompt` entries may not fire. Confirm the behavior in your environment before relying on them (see [Cloud Agent Execution Environment](./github-copilot-hooks-cloud-agent-environment.md)).

# Related

- [Session and Prompt Event Payloads](./github-copilot-hooks-session-and-prompt-payloads.md) — the `sessionStart` event the prompt hook attaches to.
