---
type: Reference
title: GitHub Copilot HTTP Hooks
description: Configuration and field reference for Copilot HTTP hooks that POST the hook input payload as JSON to a URL, including TLS rules, header env expansion, and cloud agent firewall limits.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, http-hooks, configuration]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

HTTP hooks send the hook input payload as a JSON `POST` to a URL. Part of the [GitHub Copilot Hooks Reference](./github-copilot-hooks-reference.md); the other hook types are [Command Hooks](./github-copilot-hooks-command-hooks.md) and [Prompt Hooks](./github-copilot-hooks-prompt-hooks.md).

- By default only `https://` URLs are allowed. Non-TLS `http://` requests are rejected, except for `http://localhost`, `http://127.*`, and `http://[::1]` when `COPILOT_HOOK_ALLOW_LOCALHOST=1` is set.
- Cloud agent only: outbound network from the sandbox is restricted by the cloud agent firewall, so `url` must target an allow-listed host (see [Cloud Agent Execution Environment](./github-copilot-hooks-cloud-agent-environment.md)).

```json
{
  "version": 1,
  "hooks": {
    "postToolUse": [
      {
        "type": "http",
        "url": "https://hooks.example.com/copilot",
        "headers": { "X-Source": "copilot-cli" },
        "allowedEnvVars": ["GITHUB_TOKEN"],
        "timeoutSec": 30
      }
    ]
  }
}
```

# Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `type` | `"http"` | Yes | Must be `"http"` |
| `url` | string | Yes | Target URL, `http:` or `https:`; for `preToolUse` and `permissionRequest` it must be `https://` because the response can grant tool permissions |
| `headers` | object | No | Request headers to include |
| `allowedEnvVars` | string[] | No | Environment variable names that may be expanded inside `headers` values; when set, `url` must use `https://` |
| `timeoutSec` | number | No | Timeout in seconds; default `30` |
| `timeout` | number | No | Alias for `timeoutSec`, in seconds; used only when `timeoutSec` is absent |

# Failure Behavior

HTTP `preToolUse` hooks are **fail-open**: a network error, timeout, or non-2xx response falls through to the default permission flow. See [Exit Codes and Failure Behavior](./github-copilot-hooks-exit-codes-and-failure-behavior.md) for the contrast with command hooks.

# Related

- [Tool Decision Control](./github-copilot-hooks-tool-decision-control.md) — the response body of an HTTP hook is interpreted using the same decision fields as command-hook stdout.
