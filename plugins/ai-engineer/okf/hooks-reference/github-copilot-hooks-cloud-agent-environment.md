---
type: Reference
title: GitHub Copilot Cloud Agent Hooks Execution Environment
description: Constraints of the ephemeral Linux sandbox that Copilot cloud agent uses to run hooks, including honored fields, filesystem, network, environment variables, and interactivity.
tags: [github-copilot, cloud-agent, hooks, sandbox, environment]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

This applies to Copilot cloud agent only and affects how hook scripts and hook entries must be written for cloud agent jobs. Part of the [GitHub Copilot Hooks Reference](./github-copilot-hooks-reference.md).

| Property | Value |
|---|---|
| Operating system | Linux. Only the `bash` field on command hooks is honored; `powershell` entries are ignored; the cross-platform `command` field is honored as a fallback |
| Working directory | `/workspace` when a repository is cloned, otherwise `/root`; use this path when setting `cwd` on a hook entry or referencing files from a script |
| Filesystem | Ephemeral; files written by hooks (logs, CSVs, transcripts) are discarded when the job ends — send output through an `http` hook entry to retain it |
| Outbound network | Restricted by the cloud agent firewall; by default only GitHub and Copilot hostnames are reachable, and any other host (for example `https://hooks.example.com`) requires an admin-configured firewall allow rule |
| Environment variables | `GITHUB_COPILOT_API_TOKEN` and `GITHUB_COPILOT_GIT_TOKEN` are set; `COPILOT_AGENT_PROMPT` holds the prompt the job was invoked with; `HOME` is `/root`, so `~/...` paths write into the ephemeral sandbox; `GITHUB_TOKEN` is **not** set |
| Interactivity | Fully non-interactive; the agent runs with all tool permissions pre-granted, so no permission dialogs are shown and no notifications are surfaced to a user |
| Configuration discovery | Only `.github/hooks/*.json` inside the cloned repository exists by default; the sandbox ships no user-level hook files, `settings.json`, `config.json`, or installed plugins |

# Implications

- Use `bash` or `command` entries; `powershell` entries never run. See [Command Hooks](./github-copilot-hooks-command-hooks.md).
- HTTP hook `url` values must target an allow-listed host. See [HTTP Hooks](./github-copilot-hooks-http-hooks.md).
- `prompt` entries may not fire because jobs are non-interactive. See [Prompt Hooks](./github-copilot-hooks-prompt-hooks.md).
- `permissionRequest` and `notification` do not apply; use `preToolUse` for permission decisions and treat `"ask"` as `"deny"`. See [Tool Decision Control](./github-copilot-hooks-tool-decision-control.md) and [Notification Hook](./github-copilot-hooks-notification-hook.md).
- Per-event cloud agent behavior is listed in the Hook Events table of the [hub](./github-copilot-hooks-reference.md#hook-events).
- Where hook configuration is discovered is covered in [Locations and Scoping](./github-copilot-hooks-locations.md).
