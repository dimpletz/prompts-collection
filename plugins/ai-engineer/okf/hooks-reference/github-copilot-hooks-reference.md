---
type: Reference
title: GitHub Copilot Hooks Reference (Copilot CLI and Cloud Agent)
description: Hub for the official GitHub Docs hooks reference covering Copilot CLI and Copilot cloud agent — surface differences, the full hook event catalog, payload format conventions, and links to focused concepts for each topic.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, automation]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Hooks are external commands (or HTTP calls) that execute at specific lifecycle points during a Copilot session, enabling custom automation, security controls, and integrations. They are supported on two Copilot surfaces: **Copilot CLI** and **Copilot cloud agent**. Configuration format and event payloads are mostly identical, but the execution environment and the set of events that fire differ. Behavior that differs is called out as "CLI only" or "Cloud agent only" in the focused concepts; anything unmarked applies to both.

This concept is the entry point. The detail lives in the focused concepts listed under [Concept Map](#concept-map).

## Surfaces at a Glance

| | Copilot CLI | Copilot cloud agent |
|---|---|---|
| Where hooks run | Developer's local machine, same shell as the CLI | Ephemeral, non-interactive Linux sandbox per job |
| Events supported | All events | A subset (see the Cloud agent column below) |
| Command fields honored | `bash`, `powershell`, `command`, plus `exec`/`args` | `bash` (and `command` as fallback) only |
| Configuration sources | Policy, repository, user, inline settings, plugins | `.github/hooks/*.json` in the cloned repository only |

# Hook Events

| Event | Fires when | Output processed | Cloud agent |
|---|---|---|---|
| `sessionStart` | A new or resumed session begins | Optional — can inject `additionalContext` | Fires once per job, as a new session |
| `sessionEnd` | The session terminates | No | Fires once per job; `reason` is typically `complete`, `error`, or `timeout` |
| `userPromptSubmitted` | The user submits a prompt | Optional — `modifiedPrompt` honored only by SDK programmatic hooks | Fires at most once, for the job's prompt |
| `userPromptTransformed` | After the runtime transforms a submitted prompt into model-facing content, just before it is emitted and persisted; runs for the primary and every preceding message in a batched submission; mutation-only; system notifications never trigger it | Yes — can rewrite the model-facing content | Fires |
| `preToolUse` | Before each tool executes | Yes — can allow, deny, or modify | Fires; `"ask"` is treated as `"deny"` |
| `postToolUse` | After each tool completes successfully | Yes — can modify the result or inject context | Fires |
| `postToolUseFailure` | After a tool completes with a failure | Yes — can provide recovery guidance via `additionalContext` (exit code `2` for command hooks) | Fires |
| `permissionRequest` | Before the permission service runs; `allow`/`deny` short-circuits the normal flow (except sandbox-bypass requests, where only `deny` propagates); supports a `toolName` matcher | Yes — can allow or deny programmatically | Tool calls are pre-approved, so it does not fire or has no effect; use `preToolUse` |
| `agentStop` | The main agent finishes a turn | Yes — can block and force continuation | Fires; a `block` forces another turn that still counts against the job timeout |
| `subagentStart` | A subagent is spawned, before it runs; supports an agent-name matcher | Optional — cannot block creation, but `additionalContext` is prepended to the subagent's prompt | Fires |
| `subagentStop` | A subagent completes | Yes — can block and force continuation | Fires |
| `preCompact` | Context compaction is about to begin (manual or automatic); supports a trigger matcher | No — notification only | Fires only with `trigger: "auto"` |
| `errorOccurred` | An error occurs during execution | No | Fires |
| `notification` | The CLI emits a system notification; asynchronous, fire-and-forget; supports a `notification_type` matcher | Optional — can inject `additionalContext` | Does not fire |

# Hook Event Input Payloads

Each hook event delivers a JSON payload to the hook handler. Two payload formats are supported, selected by the event name used in the hook configuration:

- **camelCase format** — configure the event name in camelCase (for example `sessionStart`); fields use camelCase.
- **VS Code compatible format** — configure the event name in PascalCase (for example `SessionStart`); fields use snake_case to match the VS Code Copilot extension format.

Hooks that fire inside a subagent include extra fields in their input. Root-agent hook inputs are unchanged.

| camelCase | VS Code compatible | Description |
|---|---|---|
| `agentId` | `agent_id` | Identifier of the subagent firing the hook |
| `agentType` | `agent_type` | Subagent type, when known |
| `parentAgentId` | `parent_agent_id` | Identifier of the parent agent, when known |

# Concept Map

**Configuration and environment**

- [Locations and Scoping](./github-copilot-hooks-locations.md) — CLI and cloud agent load locations, policy hooks, agent-scoped hooks.
- [Cloud Agent Execution Environment](./github-copilot-hooks-cloud-agent-environment.md) — sandbox constraints for cloud agent jobs.
- [Disable All Hooks](./github-copilot-hooks-disable-all-hooks.md) — the `disableAllHooks` flag and its scope.

**Hook types**

- [Command Hooks](./github-copilot-hooks-command-hooks.md) — fields, exec form, progress messages, stdout parsing, sandboxed sessions.
- [HTTP Hooks](./github-copilot-hooks-http-hooks.md) — JSON POST hooks, TLS rules, header env expansion.
- [Prompt Hooks](./github-copilot-hooks-prompt-hooks.md) — auto-submitted prompts on `sessionStart`.

**Event payloads**

- [Session and Prompt Payloads](./github-copilot-hooks-session-and-prompt-payloads.md) — `sessionStart`, `sessionEnd`, `userPromptSubmitted`, `userPromptTransformed`.
- [Tool Event Payloads](./github-copilot-hooks-tool-payloads.md) — `preToolUse`, `postToolUse`, `postToolUseFailure`.
- [Agent Lifecycle Payloads](./github-copilot-hooks-agent-lifecycle-payloads.md) — `agentStop`, `subagentStart`, `subagentStop`.
- [Error and Compaction Payloads](./github-copilot-hooks-error-and-compaction-payloads.md) — `errorOccurred`, `preCompact`.
- [Notification Hook](./github-copilot-hooks-notification-hook.md) — the CLI-only `notification` event.

**Behavior and control**

- [Tool Decision Control](./github-copilot-hooks-tool-decision-control.md) — `preToolUse`, `postToolUse`, and `permissionRequest` outputs.
- [Agent Stop Decision Control](./github-copilot-hooks-agent-stop-decision-control.md) — `agentStop` and `subagentStop` block decisions.
- [Matchers and Tool Names](./github-copilot-hooks-matchers-and-tool-names.md) — `matcher` semantics, Claude-format matchers, tool names.
- [Exit Codes and Failure Behavior](./github-copilot-hooks-exit-codes-and-failure-behavior.md) — exit codes, fail-open and fail-closed rules.
