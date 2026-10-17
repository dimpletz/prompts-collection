---
type: Reference
title: GitHub Copilot Hooks Tool Decision Control
description: Output fields that let preToolUse, postToolUse, and permissionRequest hooks allow, deny, modify, or augment tool calls, including the sandbox-bypass exception for permissionRequest.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, decision-control, permissions, tools]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Hooks control tool execution by writing a single JSON object to stdout (command hooks) or returning it in the response body (HTTP hooks). Input payloads are in [Tool Event Payloads](./github-copilot-hooks-tool-payloads.md). Exit-code behavior is in [Exit Codes and Failure Behavior](./github-copilot-hooks-exit-codes-and-failure-behavior.md). For stop events see [Agent Stop Decision Control](./github-copilot-hooks-agent-stop-decision-control.md).

## preToolUse Decision Control

| Field | Values | Description |
|---|---|---|
| `permissionDecision` | `"allow"`, `"deny"`, `"ask"` | Whether the tool executes; empty output uses default behavior. Under cloud agent, `"ask"` is treated as `"deny"` because no user can answer; in CLI autopilot mode no prompt is shown and `"ask"` is denied, so the agent sees that the CLI was unable to ask the user |
| `permissionDecisionReason` | string | Reason shown to the agent; required when the decision is `"deny"` |
| `modifiedArgs` | object | Substitute tool arguments to use instead of the originals |

When the CLI can show the hook-permission prompt, the user can type optional feedback with a denial. That feedback is appended to the message the agent receives: `Denied by user via preToolUse hook prompt: <permissionDecisionReason>. The user provided the following feedback: <feedback>`.

If multiple `preToolUse` hooks are configured they execute in order, and if any returns `"deny"` the tool is blocked. HTTP `preToolUse` hooks must use `https://` URLs because the response can grant tool permissions (see [HTTP Hooks](./github-copilot-hooks-http-hooks.md)).

## postToolUse Output

The `postToolUse` hook can modify the tool result or inject additional context for the model.

```typescript
{ modifiedResult?: { resultType: "success"; textResultForLlm: string; }; additionalContext?: string; }
```

| Field | Type | Description |
|---|---|---|
| `modifiedResult` | object | Replacement tool result; must have `resultType: "success"`. If returned with `resultType: "failure"`, the failure routes downstream and `postToolUseFailure` fires next |
| `additionalContext` | string | Additional guidance appended to `textResultForLlm` so the model sees it after the tool output on the same turn; when multiple hooks return it, results are joined with a double newline and capped at 10 KB |

Return `{}` or empty output to keep the original successful result. `modifiedResult` is honored by both SDK programmatic hooks and command/HTTP config-file `postToolUse` hooks.

An optional `matcher` regex is tested against `toolName`, compiled as `^(?:PATTERN)$`, and must match the entire tool name. If the pattern is not a valid regular expression the hook is skipped. Omit `matcher` to receive results from all tools.

```json
{
  "type": "command",
  "matcher": "bash|edit",
  "bash": "./scripts/log-tool.sh"
}
```

## permissionRequest Decision Control (CLI only)

The `permissionRequest` hook does not apply under cloud agent, where tool calls are pre-approved; use `preToolUse` there instead.

It fires before the permission service runs — before rule checks, session approvals, auto-allow/auto-deny, and user prompting. If hooks return `behavior: "allow"` or `"deny"`, that decision short-circuits the normal permission flow. Returning nothing falls through to normal permission handling. It is especially useful in CLI pipe mode (`-p`) and other CLI CI usages where no interactive prompt is available.

All configured `permissionRequest` hooks run for each request (except `read` and `hook` permission kinds, which short-circuit before hooks). Hook outputs are merged with later hook outputs overriding earlier ones.

**Sandbox-bypass exception:** for any request that asks to escape the sandbox (`requestSandboxBypass: true` in `toolInput`), a hook `allow` does not pre-approve the request or short-circuit the user prompt — leaving the sandbox is a privilege escalation the user must always confirm interactively. This covers a shell command asking to run outside the sandbox and a `web_fetch` whose URL the sandbox network policy denies. Only `deny` still propagates (so a policy hook can block the escape); an `allow` (or no decision) falls through to the normal prompt.

| Field | Values | Description |
|---|---|---|
| `behavior` | `"allow"`, `"deny"` | Whether to approve or deny the tool call |
| `message` | string | Reason fed back to the LLM when denying |
| `interrupt` | boolean | When `true` combined with `"deny"`, stops the agent entirely |

Return empty output or `{}` to fall through to the normal permission flow. For command hooks, exit code `2` is treated as a deny: stdout JSON (if any) is merged with `{"behavior":"deny"}`, and stderr is ignored. The matcher is an optional regex on `toolName`, anchored as `^(?:PATTERN)$`. The PascalCase `PermissionRequest` event name uses the same Claude matcher semantics as `PreToolUse` (see [Matchers and Tool Names](./github-copilot-hooks-matchers-and-tool-names.md#claude-format-matchers-pascalcase-pretooluse)).
