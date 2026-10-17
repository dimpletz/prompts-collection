---
type: Reference
title: GitHub Copilot Hooks Agent Stop Decision Control
description: Output fields for agentStop and subagentStop hooks that block and force another turn or rewrite a subagent response, including merge rules and the eight-block runaway guard.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, decision-control, subagents]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

`agentStop` and `subagentStop` hooks can force the agent or subagent to continue by returning a `block` decision. Input payloads are in [Agent Lifecycle Payloads](./github-copilot-hooks-agent-lifecycle-payloads.md). Tool-call decisions are covered separately in [Tool Decision Control](./github-copilot-hooks-tool-decision-control.md).

| Field | Values | Description |
|---|---|---|
| `decision` | `"block"`, `"allow"` | `"block"` forces another agent turn using `reason` as the prompt |
| `reason` | string | Prompt for the next turn when `decision` is `"block"` |
| `modifiedResponse` | string | `subagentStop` only. Replaces the response returned to the parent when the subagent is allowed to complete — useful for redacting or reformatting subagent output. Not applicable to `agentStop` |

`decision` and `reason` behave the same for both events. Under cloud agent, `decision: "block"` forces another turn that still counts against the job's timeout.

# modifiedResponse Rules

- A valid `block` decision wins over `modifiedResponse`: if a hook returns both, the subagent continues and the rewrite is discarded.
- Rewrites do not compose across multiple matching hooks. Every hook receives the same original `response`, and the last hook to return `modifiedResponse` wins — chaining a redactor and a formatter does not feed the redacted text into the formatter.
- The output field names (`decision`, `reason`, `modifiedResponse`) are the same for both the camelCase and VS Code compatible configs.

# Validation

- Command and HTTP hooks keep the permissive behavior of other hook events: unsupported verdict fields and non-object JSON outputs are ignored, and `reason` only takes effect alongside a `block` decision with a nonempty string.
- SDK callback outputs are validated before merging: an invalid `decision`, a `reason` without `block`, a `block` without a nonempty `reason`, or a non-object output fails the subagent hook. An explicit `null` in an optional field is treated as absent.

# Runaway Guard

After 8 consecutive `block` continuations, the CLI overrides the hook and ends the turn anyway, to prevent an unbounded loop. Use the `stop_hook_active` input field on `agentStop` to detect that this turn was already forced to continue, and self-limit before hitting the cap. Scoped `Stop` hooks declared in a custom agent's frontmatter run at `SubagentStop` for subagents and have the same eight-block limit (see [Locations and Scoping](./github-copilot-hooks-locations.md)).
