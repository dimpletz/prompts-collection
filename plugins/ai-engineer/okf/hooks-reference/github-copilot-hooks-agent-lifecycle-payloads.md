---
type: Reference
title: GitHub Copilot Hooks Agent Lifecycle Event Payloads
description: Input and output payload shapes for the agentStop, subagentStart, and subagentStop hook events, including additionalContext accumulation and agent-name matching.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, payloads, subagents]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Payloads for events tied to the main agent finishing a turn and to subagents starting and completing. Decisions for the stop events are in [Agent Stop Decision Control](./github-copilot-hooks-agent-stop-decision-control.md). Other payload groups: [Session and Prompt Payloads](./github-copilot-hooks-session-and-prompt-payloads.md), [Tool Event Payloads](./github-copilot-hooks-tool-payloads.md), and [Error and Compaction Payloads](./github-copilot-hooks-error-and-compaction-payloads.md). Hooks that fire inside a subagent also receive extra `agentId`, `agentType`, and `parentAgentId` fields (see the [hub](./github-copilot-hooks-reference.md#hook-event-input-payloads)).

## agentStop / Stop

```typescript
// camelCase
{ sessionId: string; timestamp: number; cwd: string; transcriptPath: string; stopReason: "end_turn";
  stop_hook_active: boolean; /* true when this turn was already forced to continue by a prior "block" from this hook */ }

// VS Code compatible
{ hook_event_name: "Stop"; session_id: string; timestamp: string; cwd: string; transcript_path: string;
  stop_reason: "end_turn"; stop_hook_active: boolean; }
```

## subagentStart

The built-in `general-purpose` agent does not emit `subagentStart` or `subagentStop` events. All other built-in YAML-based agents — including `explore`, `task`, `code-review`, `rubber-duck`, `research`, and `security-review` — and user-defined custom agents emit these events.

```typescript
// Input
{ sessionId: string; timestamp: number; cwd: string; transcriptPath: string;
  agentName: string; agentDisplayName?: string; agentDescription?: string; }

// Output
{ additionalContext?: string; }
```

If `additionalContext` is returned, it is prepended to the subagent's first user message, giving hooks a way to inject project-specific context, policies, or instructions into every subagent invocation. The hook cannot block subagent creation.

When multiple `subagentStart` hooks run, they accumulate the same way as `sessionStart`: successful hooks with a non-empty string `additionalContext` contribute in execution order joined by `"\n\n"`, empty or whitespace-only strings don't erase already-accumulated context, and the combined string is bounded by the 10 MiB hook-output limit (an over-limit contribution is dropped, the prior context is kept, and a size-only warning is logged and raised in the session).

**Matcher:** supports an optional `matcher` field that filters by agent name. The value is a regular expression wrapped as `^(?:matcher)$` and tested against `agentName`. The pattern must match the **entire** agent name, not just a substring. If the pattern is not a valid regular expression, the hook is skipped entirely (it will not fire for any agent). See [Matchers and Tool Names](./github-copilot-hooks-matchers-and-tool-names.md).

## subagentStop / SubagentStop

Fires when a subagent completes normally, before returning results to the parent. `stopReason` is currently always `"end_turn"`. This hook fires before large-response spill handling, so `response` (or `last_assistant_message` in the VS Code compatible format) carries the full final subagent response text.

```typescript
// camelCase
{ sessionId: string; timestamp: number; cwd: string; transcriptPath: string;
  agentId: string; agentType: string; agentName: string; agentDisplayName?: string;
  response: string;       // full final subagent response text
  stopReason: "end_turn"; }

// VS Code compatible
{ hook_event_name: "SubagentStop"; session_id: string; timestamp: string; cwd: string; transcript_path: string;
  agent_id: string; agent_type: string; agent_name: string; agent_display_name?: string;
  last_assistant_message: string; // the `response` text
  stop_reason: "end_turn"; }
```
