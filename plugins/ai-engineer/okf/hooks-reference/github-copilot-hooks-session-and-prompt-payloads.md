---
type: Reference
title: GitHub Copilot Hooks Session and Prompt Event Payloads
description: Input and output payload shapes for the sessionStart, sessionEnd, userPromptSubmitted, and userPromptTransformed hook events in both camelCase and VS Code compatible formats.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, payloads, session, prompts]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Payload formats are selected by the event name used in configuration: camelCase names (for example `sessionStart`) deliver camelCase fields, while PascalCase names (for example `SessionStart`) deliver the VS Code compatible snake_case format. See the [hub](./github-copilot-hooks-reference.md#hook-event-input-payloads) for the format explanation and the extra subagent fields. Other payload groups: [Tool Event Payloads](./github-copilot-hooks-tool-payloads.md), [Agent Lifecycle Payloads](./github-copilot-hooks-agent-lifecycle-payloads.md), and [Error and Compaction Payloads](./github-copilot-hooks-error-and-compaction-payloads.md).

## sessionStart / SessionStart

```typescript
// camelCase
{ sessionId: string; timestamp: number /* Unix ms */; cwd: string;
  source: "startup" | "resume" | "new"; initialPrompt?: string; }

// VS Code compatible
{ hook_event_name: "SessionStart"; session_id: string; timestamp: string /* ISO 8601 */; cwd: string;
  source: "startup" | "resume" | "new"; initial_prompt?: string; }

// Output
{ additionalContext?: string; }
```

Only `additionalContext` is consumed (command and HTTP variants); return `{}` or empty for no action. When multiple `sessionStart` hooks run, successful hooks returning a non-empty string `additionalContext` contribute in execution order, separated by exactly `"\n\n"`. An empty or whitespace-only string does not erase already-accumulated context; if every hook returns only empty/whitespace strings, the last one is kept. The combined string is bounded by the 10 MiB hook-output limit — an over-limit contribution is dropped, the previously accumulated context is kept, and a size-only warning is logged and raised in the session.

## sessionEnd / SessionEnd

```typescript
// camelCase
{ sessionId: string; timestamp: number; cwd: string;
  reason: "complete" | "error" | "abort" | "timeout" | "user_exit"; }

// VS Code compatible
{ hook_event_name: "SessionEnd"; session_id: string; timestamp: string; cwd: string;
  reason: "complete" | "error" | "abort" | "timeout" | "user_exit"; }
```

CLI only: `/clear` in interactive mode closes the old session and fires its `sessionEnd` hooks with `reason: "user_exit"` while the CLI keeps running. The replacement session has its own independent lifecycle. Because the CLI itself isn't exiting, these hooks dispatch detached — they run in the background with their full `timeoutSec` while `/clear` returns immediately, so a hook doing real work is neither cut short nor able to stall the prompt. A detached hook still running when you later quit the CLI is terminated along with the process.

## userPromptSubmitted / UserPromptSubmit

```typescript
// camelCase
{ sessionId: string; timestamp: number; cwd: string; prompt: string; }

// VS Code compatible
{ hook_event_name: "UserPromptSubmit"; session_id: string; timestamp: string; cwd: string; prompt: string; }

// Output
{ modifiedPrompt?: string; } // replaces the prompt for the rest of the turn (SDK programmatic hooks only)
```

Return `{}` or empty to leave the prompt unchanged.

- `modifiedPrompt` is only honored by SDK programmatic hooks. Command and HTTP config-file `userPromptSubmitted` hooks have their output dropped, including `modifiedPrompt`. The lighter hooks-processing runtime used by hosted or steering cloud agent sessions also ignores it. This is the same runtime split as `preToolUse`.
- A non-string `modifiedPrompt`, `modifiedTransformedPrompt`, or a handled `responseContent` value is ignored rather than corrupting the session — a type warning naming the field is logged and emitted as a `session.warning` event. An empty-string override is rejected instead of blanking the model-facing content. A `null` `additionalContext` value is treated as absent instead of being injected as the literal text `null`. Hook output (stdout for command hooks, the response body for HTTP hooks) is bounded at 10 MiB per invocation — a larger response is truncated rather than exhausting memory.

## userPromptTransformed

Fires after the runtime transforms a submitted prompt into its model-facing content, just before that content is emitted and persisted to session history. Runs for the primary message and for every preceding message in a batched submission. Mutation-only — it can rewrite the content the model receives, but not block or handle the turn. System notifications never trigger it.

```typescript
// Input
{ sessionId: string; timestamp: number /* epoch ms */; cwd: string;
  prompt: string;            // user prompt after userPromptSubmitted hooks have run
  transformedPrompt: string; // runtime-transformed content the model will receive
}

// Output
{ modifiedTransformedPrompt?: string; } // replaces the model-facing content
```

Return `{}` or empty to leave the transformed content unchanged. `modifiedTransformedPrompt` replaces only the content sent to the model and stored in session history — the prompt displayed in the timeline is unaffected — and the replacement is replayed unchanged if the session is resumed.

# Related

- [Prompt Hooks](./github-copilot-hooks-prompt-hooks.md) — hook type that auto-submits a prompt on `sessionStart`.
