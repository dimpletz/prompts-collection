---
type: Reference
title: GitHub Copilot Hooks Error and Compaction Event Payloads
description: Input payload shapes for the errorOccurred and preCompact hook events in camelCase and VS Code compatible formats.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, payloads, errors, compaction]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Both events are notification-only: their output is not processed. Other payload groups: [Session and Prompt Payloads](./github-copilot-hooks-session-and-prompt-payloads.md), [Tool Event Payloads](./github-copilot-hooks-tool-payloads.md), and [Agent Lifecycle Payloads](./github-copilot-hooks-agent-lifecycle-payloads.md). See the [hub](./github-copilot-hooks-reference.md#hook-event-input-payloads) for the format explanation.

## errorOccurred / ErrorOccurred

Fires when an error occurs during execution. Fires under cloud agent as well.

```typescript
// camelCase
{ sessionId: string; timestamp: number; cwd: string;
  error: { message: string; name: string; stack?: string };
  errorContext: "model_call" | "tool_execution" | "system" | "user_input";
  recoverable: boolean; }

// VS Code compatible
{ hook_event_name: "ErrorOccurred"; session_id: string; timestamp: string; cwd: string;
  error: { message: string; name: string; stack?: string };
  error_context: "model_call" | "tool_execution" | "system" | "user_input";
  recoverable: boolean; }
```

## preCompact / PreCompact

Fires when context compaction is about to begin (manual or automatic). It supports a `matcher` regex on `trigger` (`"manual"` or `"auto"`; see [Matchers and Tool Names](./github-copilot-hooks-matchers-and-tool-names.md)). Under cloud agent it fires only with `trigger: "auto"`, because there is no user to request manual compaction.

```typescript
// camelCase
{ sessionId: string; timestamp: number; cwd: string; transcriptPath: string;
  trigger: "manual" | "auto"; customInstructions: string; }

// VS Code compatible
{ hook_event_name: "PreCompact"; session_id: string; timestamp: string; cwd: string; transcript_path: string;
  trigger: "manual" | "auto"; custom_instructions: string; }
```
