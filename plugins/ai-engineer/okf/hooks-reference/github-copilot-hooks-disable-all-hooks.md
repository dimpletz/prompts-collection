---
type: Reference
title: GitHub Copilot Hooks Disable All Hooks
description: How the disableAllHooks flag skips hook configuration without deleting it, and how its scope differs between a single hooks file and repository settings.json.
tags: [github-copilot, copilot-cli, cloud-agent, hooks, configuration, disable]
resource: https://docs.github.com/en/copilot/reference/hooks-reference
generated: { by: agent:update-okf, at: 2026-10-18T02:13:11+13:00 }
---

# Overview

Use `disableAllHooks` to keep hook configuration on disk but stop it from running — for example when debugging to confirm a hook is the cause, pausing automation during a sensitive task (a code review, a release branch, working with secrets), letting contributors opt out of a hooks file shipped in source control, or silencing slow or noisy hooks during an interactive session. The last three uses are CLI only. Part of the [GitHub Copilot Hooks Reference](./github-copilot-hooks-reference.md).

Set `disableAllHooks` to `true` at the top level of a configuration file:

```json
{
  "version": 1,
  "disableAllHooks": false,
  "hooks": {
    "preToolUse": [ /* hook entries */ ]
  }
}
```

# Scope

- **Inside a single `.github/hooks/*.json` file** — only the hooks declared in that file are skipped. Honored by both Copilot CLI and cloud agent.
- **At the top level of repository `settings.json`** — **CLI only.** Every hook from every source (repository files, user files, plugins, and inline hook blocks) is skipped for sessions in that repository. Policy hooks are not affected and continue to run. Cloud agent does not load `settings.json`.

See [Locations and Scoping](./github-copilot-hooks-locations.md) for the sources involved and why policy hooks cannot be disabled.
