---
type: Reference
title: GitHub Copilot Hooks Locations and Scoping
description: Where Copilot CLI and Copilot cloud agent load hook configuration from, including load order, policy hooks, and agent-scoped hooks declared in custom agent frontmatter.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, configuration, policy-hooks]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

The locations where hooks run, and where hook configuration files can be stored, depend on the Copilot surface. Part of the [GitHub Copilot Hooks Reference](./github-copilot-hooks-reference.md).

## Copilot CLI

Hooks run on the developer's local machine in the same shell as the CLI. All hook events are supported. Sources are loaded in this order — policy, user, project, plugins — and combined. When the same event appears in multiple sources, all hook entries from all sources run.

| Source | Location |
|---|---|
| Policy-level hook files | JSON files in the platform policy directory, loaded alphabetically; machine-wide, loaded before all other hooks, not disabled by `disableAllHooks`, available regardless of folder trust |
| Repository-level hook files | `.github/hooks/*.json` in the repository root |
| User-level hook files | `*.json` in `~/.copilot/hooks/` (macOS/Linux) or `%USERPROFILE%\.copilot\hooks\` (Windows); `$COPILOT_HOME/hooks/` when `COPILOT_HOME` is set |
| Inline repository settings | Top-level `hooks` field in `.github/copilot/settings.json` (committed) or `.github/copilot/settings.local.json` (typically gitignored); cross-tool `.claude/settings.json` and `.claude/settings.local.json` are also read |
| Inline user config | Top-level `hooks` field in `~/.copilot/settings.json` (the CLI no longer reads `~/.copilot/config.json` for hooks) |
| Plugins | Each installed plugin's own `hooks.json` (or `hooks/hooks.json`) in its installation directory |

## Copilot cloud agent

Hooks run inside the ephemeral Linux sandbox provisioned for each job. The sandbox is non-interactive, has a constrained network, and is destroyed when the job ends. Only a subset of events fires, and only `bash` (or `command`) entries are honored. Hook configuration is loaded from `.github/hooks/*.json` in the cloned repository. See [Cloud Agent Execution Environment](./github-copilot-hooks-cloud-agent-environment.md) for the sandbox constraints.

## Policy Hooks (CLI only)

Policy hooks are machine-wide hooks installed by administrators. They load before all other hooks and cannot be disabled by `disableAllHooks`. They are not supported under cloud agent.

- **Filesystem**: JSON files loaded alphabetically from `/etc/github-copilot/policy.d/*.json` (Linux/macOS) or `C:\ProgramData\GitHub\Copilot\policy.d\*.json` (Windows).
- **Windows Registry**: values under `HKLM\Software\Policies\GitHub\Copilot`, where each subkey holds a `Policy` `REG_SZ` value containing a JSON policy document.
- Policy files use the same format as user and project hooks (`{ "version": 1, "hooks": { ... } }`).
- On POSIX systems, policy files must be owned by root and must not be group- or world-writable.
- They require elevated privileges to install, cannot be modified by end users, and always run on the host even when the session sandbox is enabled (see [Command Hooks](./github-copilot-hooks-command-hooks.md#sandboxed-sessions-cli-only)).

## Agent-Scoped Hooks (CLI only)

A custom agent can declare a `hooks` event map in its frontmatter so the hooks run only while that agent is selected. They run in addition to session, user, repository, plugin, and policy hooks.

```yaml
---
name: formatter
description: Formats changed files
hooks:
  PostToolUse:
    - type: command
      command: ./scripts/format-changed-files.sh
      windows: ./scripts/format-changed-files.ps1
---
Format the files you change.
```

| Behavior | Details |
|---|---|
| Event names | Runtime names such as `postToolUse` and aliases such as `PostToolUse` are accepted |
| Commands | `command` is the fallback; `windows`, `linux`, and `osx` override it per platform; paths resolve from the repository root |
| Subagent `Stop` | A subagent's scoped `Stop` (`agentStop`) hooks run at `SubagentStop`; after eight consecutive scoped blocks, further blocks are ignored |
| Trust | Repository and inherited-agent hooks require workspace admission; hook-disable settings, enterprise restrictions, and timeouts still apply |
| Unsupported | Remote or organization-hosted agent definitions do not run scoped hooks |

# Related

- [GitHub Copilot Hooks Reference](./github-copilot-hooks-reference.md) — hub and concept map.
- [Disable All Hooks](./github-copilot-hooks-disable-all-hooks.md) — how `disableAllHooks` interacts with these sources.
