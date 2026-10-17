---
type: Reference
title: GitHub Copilot Hooks Exit Codes and Failure Behavior
description: How Copilot interprets command hook exit codes and timeouts, including the fail-closed preToolUse exception, exit code 2 semantics per event, and fail-open timeouts.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, exit-codes, error-handling, security]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Exit codes apply to [Command Hooks](./github-copilot-hooks-command-hooks.md). Part of the [GitHub Copilot Hooks Reference](./github-copilot-hooks-reference.md).

| Exit code | Meaning |
|---|---|
| `0` | Success; stdout is parsed as the hook output JSON if present |
| `2` | Warning by default: stderr is surfaced to the user but the run continues. For `permissionRequest` and `preToolUse`, exit `2` is treated as a deny: any stdout JSON is merged with the deny decision and the tool call is denied even if that JSON reports `permissionDecision: "allow"`. For `postToolUseFailure`, exit `2` is treated as `additionalContext` and stdout is appended to the failure shown to the agent |
| Other non-zero | Logged as a hook failure and the run continues (fail-open). **Exception:** `preToolUse` is fail-closed — a non-zero exit (other than exit `2`, which also denies) denies the tool call with `"Denied by preToolUse hook (hook errored)"` |
| Timeout | Killed after `timeoutSec`; error logged and execution continues. The logged message includes the command that timed out, for example `Hook command timed out after 30 seconds: my-validation-script.sh` (the bash/PowerShell script text, or `program arg1 arg2 …` for exec hooks), truncated to 80 characters |

# Fail Behavior Summary

- For most events, non-zero exits and timeouts are logged and skipped — agent execution continues.
- For `preToolUse` command hooks, exit `2`, a crash, and any other non-zero exit all fail closed and deny the tool call. Exit `2` always denies, even if stdout JSON reports `permissionDecision: "allow"`.
- **Timeouts always fail open**, for every event, including `preToolUse` and admin-deployed policy hooks: a warning is surfaced and processing proceeds as if the hook had not run. For `preToolUse`, the tool call proceeds through the normal permission flow rather than being denied. A crashed or explicitly denying hook still fails closed; only timeouts are exempt. The rationale is that a slow or unreachable hook must not silently block tool calls or work, even when deployed by an administrator as policy.
- HTTP `preToolUse` hooks are **fail-open**: a network error, timeout, or non-2xx response falls through to the default permission flow (see [HTTP Hooks](./github-copilot-hooks-http-hooks.md)). Choose the variant that matches your security requirements.

# Related

- [Tool Decision Control](./github-copilot-hooks-tool-decision-control.md) — the decision fields that exit codes interact with.
- [Locations and Scoping](./github-copilot-hooks-locations.md) — policy hooks and their load order.
