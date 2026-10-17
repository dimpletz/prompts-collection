---
type: Reference
title: GitHub Copilot Hooks Tool Event Payloads
description: Input payload shapes for the preToolUse, postToolUse, and postToolUseFailure hook events in camelCase and VS Code compatible formats, including Claude-format tool name handling for PascalCase PreToolUse.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, payloads, tools]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Payloads for the three tool-related events. Outputs and decisions for these events are described in [Tool Decision Control](./github-copilot-hooks-tool-decision-control.md). Other payload groups: [Session and Prompt Payloads](./github-copilot-hooks-session-and-prompt-payloads.md), [Agent Lifecycle Payloads](./github-copilot-hooks-agent-lifecycle-payloads.md), and [Error and Compaction Payloads](./github-copilot-hooks-error-and-compaction-payloads.md). See the [hub](./github-copilot-hooks-reference.md#hook-event-input-payloads) for the camelCase vs VS Code compatible format explanation.

## preToolUse / PreToolUse

```typescript
// camelCase
{ sessionId: string; timestamp: number; cwd: string; toolName: string; toolArgs: unknown; }

// VS Code compatible (PascalCase event name; snake_case fields)
{ hook_event_name: "PreToolUse"; session_id: string; timestamp: string /* ISO 8601 */; cwd: string;
  tool_name: string; tool_input: unknown; /* tool arguments, parsed from JSON string when possible */ }
```

When configured with PascalCase `PreToolUse`, hooks use Claude matcher semantics and the payload reports `tool_name` as the Claude tool name (for example `Bash`, not `bash`). The matcher rules and the runtime-to-Claude tool name table live in [Matchers and Tool Names](./github-copilot-hooks-matchers-and-tool-names.md#claude-format-matchers-pascalcase-pretooluse).

Failure behavior differs by hook type: command `preToolUse` hooks are fail-closed on crashes and non-zero exits, while HTTP `preToolUse` hooks and all timeouts are fail-open. See [Exit Codes and Failure Behavior](./github-copilot-hooks-exit-codes-and-failure-behavior.md).

## postToolUse / PostToolUse

```typescript
// camelCase
{ sessionId: string; timestamp: number; cwd: string; toolName: string; toolArgs: unknown;
  toolResult: { resultType: "success"; textResultForLlm: string; } }

// VS Code compatible
{ hook_event_name: "PostToolUse"; session_id: string; timestamp: string; cwd: string;
  tool_name: string; tool_input: unknown;
  tool_result: { result_type: "success"; text_result_for_llm: string; } }
```

## postToolUseFailure / PostToolUseFailure

```typescript
// camelCase
{ sessionId: string; timestamp: number; cwd: string; toolName: string; toolArgs: unknown; error: string; }

// VS Code compatible
{ hook_event_name: "PostToolUseFailure"; session_id: string; timestamp: string; cwd: string;
  tool_name: string; tool_input: unknown; error: string; }
```

For command hooks, exit code `2` on `postToolUseFailure` is treated as `additionalContext`: stdout is appended to the failure shown to the agent (see [Exit Codes and Failure Behavior](./github-copilot-hooks-exit-codes-and-failure-behavior.md)).
