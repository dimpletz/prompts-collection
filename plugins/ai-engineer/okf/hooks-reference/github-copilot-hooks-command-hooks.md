---
type: Reference
title: GitHub Copilot Command Hooks
description: Configuration format and fields for Copilot command hooks (bash, powershell, command, exec/args), plus progress messages, stdout parsing rules, and sandboxed-session behavior.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, command-hooks, configuration]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Hook configuration files use JSON with `"version": 1`. If a file loaded from a directory (for example `.github/hooks/`) contains a malformed hook item, only that item is dropped and logged; valid sibling hooks in the same file still load. Structural errors (invalid JSON, a bad `version`, or a non-array event list) reject the entire file. Hooks defined inline in `settings.json` are strict: any item-level validation error rejects the whole `hooks` field. Other configuration files always load independently.

Command hooks run shell scripts or executables and are supported on all hook types. Cloud agent only honors the `bash` field (with `command` as a fallback); `powershell` entries are ignored (see [Cloud Agent Execution Environment](./github-copilot-hooks-cloud-agent-environment.md)). Part of the [GitHub Copilot Hooks Reference](./github-copilot-hooks-reference.md); the other hook types are [HTTP Hooks](./github-copilot-hooks-http-hooks.md) and [Prompt Hooks](./github-copilot-hooks-prompt-hooks.md).

## Shell Form

```json
{
  "version": 1,
  "hooks": {
    "preToolUse": [
      {
        "type": "command",
        "bash": "YOUR_BASH_COMMAND",
        "powershell": "YOUR_POWERSHELL_COMMAND",
        "cwd": "OPTIONAL/WORKING/DIRECTORY",
        "env": { "VAR": "VALUE" },
        "timeoutSec": 30
      }
    ]
  }
}
```

## Exec Form (CLI only)

In Copilot CLI, `exec` and `args` run an executable directly instead of through a shell. Do not combine `exec` with `bash`, `powershell`, or `command`. Arguments are passed without shell interpretation, so pipes, redirection, and glob expansion are unavailable. Replace `YOUR_EXECUTABLE` with the executable name or path; add more arguments to the `args` array as needed.

```json
{
  "version": 1,
  "hooks": {
    "preToolUse": [
      {
        "type": "command",
        "exec": "YOUR_EXECUTABLE",
        "args": ["YOUR_ARGUMENT"],
        "cwd": "OPTIONAL/WORKING/DIRECTORY",
        "env": { "VAR": "VALUE" },
        "timeoutSec": 30
      }
    ]
  }
}
```

## Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `type` | `"command"` | No | Defaults to `"command"` when omitted |
| `bash` | string | One of `bash`, `powershell`, or `command`, unless `exec` is specified | Shell command for Unix |
| `powershell` | string | Same as above | Shell command for Windows |
| `command` | string | Same as above | Cross-platform fallback; copied to both `bash` and `powershell` when those are absent; explicit `bash`/`powershell` take precedence on their platforms |
| `exec` | string | Instead of `bash`, `powershell`, and `command` | Executable name or path, run without a shell; CLI only |
| `args` | array of strings | No | Arguments passed directly to `exec`; CLI only |
| `cwd` | string | No | Working directory (relative to repository root, or absolute) |
| `env` | object | No | Environment variables to set (supports variable expansion) |
| `timeoutSec` | number | No | Timeout in seconds; default `30` |
| `timeout` | number | No | Alias for `timeoutSec`, in seconds; used only when `timeoutSec` is absent |

## Progress Messages

Command hooks can emit progress status lines to the CLI timeline while executing. Write a single-line `{"type": "progress", "message": "..."}` JSON object to stdout before the final output.

```bash
echo '{"type": "progress", "message": "Checking policy..."}'
# ... perform work ...
echo '{"permissionDecision": "allow"}'
```

Set `"temporary": true` to emit a transient status line. A transient line replaces the previous transient line and is cleared when the assistant responds, instead of accumulating in the timeline.

```bash
echo '{"type": "progress", "message": "Routing...", "temporary": true}'
echo '{"type": "progress", "message": "Thinking...", "temporary": true}'
# ... perform work ...
echo '{"permissionDecision": "allow"}'
```

Progress messages are display-only and do not affect hook output or decision logic.

### How stdout Is Parsed

The CLI scans stdout line by line as the hook runs.

- Any line that, after trimming, is a single complete JSON object with `"type": "progress"` is consumed as a progress event and **removed from the hook's output stream**.
- Every other line (blank lines, plain text, JSON objects that are not progress messages) is preserved verbatim.
- When the hook exits, the preserved lines are concatenated, trimmed, and parsed with a single `JSON.parse`; that result is the hook output JSON referenced elsewhere in the reference.
- Emitting progress lines alongside one final decision object is safe and the intended pattern — progress lines never reach the JSON parser.
- Each progress message must be valid JSON on its own single line. Multi-line or pretty-printed progress objects are not recognized and stay in the output stream, where they will likely make the final `JSON.parse` fail.
- The final decision object may span multiple lines — only progress recognition is line-oriented; what remains after stripping is parsed as one JSON document, not line-delimited JSON.
- If the leftover output is empty or fails to parse, the hook is treated as having produced no output and default behavior applies. Two or more non-progress JSON objects on stdout (for example, two `echo '{"permissionDecision": ...}'` calls) concatenate into invalid JSON and are ignored, so emit exactly one final decision object.

## Sandboxed Sessions (CLI only)

When the session sandbox is enabled, command hooks from the repository, user settings, and plugins run inside it with the same access as the agent's shell commands.

- A hook can read the directory it was loaded from, so a plugin can run the scripts it ships.
- A plugin hook can write to its data directory (`$COPILOT_PLUGIN_DATA`).
- A hook's `cwd` and `env` fields do not widen access: a `cwd` outside the session's grants gives no access there, and variables such as `TMPDIR` or `PATH` set in `env` grant nothing.
- When a hook fails in the sandbox, Copilot shows a warning once per hook and session. To give a hook more access, add the required paths to `sandbox.userPolicy` in settings.
- Policy hooks always run on the host, outside the sandbox, and should not run scripts from the workspace (see [Locations and Scoping](./github-copilot-hooks-locations.md)).

# Related

- [Exit Codes and Failure Behavior](./github-copilot-hooks-exit-codes-and-failure-behavior.md) — how exit codes and timeouts are interpreted.
- [Matchers and Tool Names](./github-copilot-hooks-matchers-and-tool-names.md) — the `matcher` field accepted on hook entries.
