---
name: firefox-browser-path-provider
description: >
  Returns the absolute path of the Mozilla Firefox browser executable on the current machine. Use this skill whenever an agent or workflow needs to know the exact Firefox executable path before launching, configuring, or referencing Firefox. Do NOT use this skill for installing Firefox or for general browser automation setup.
---

# Firefox Browser Path

> Scripts live in `scripts/` inside this skill directory: `find-firefox.ps1` (Windows) and `find-firefox.sh` (macOS/Linux).

Locates the Mozilla Firefox browser installation on the current machine and returns the absolute path to its executable. If Firefox is not found in any known location, reports its absence to the user.

## Inputs

- **os_hint** (optional): The target operating system — `windows`, `macos`, or `linux`. If not provided, detect the OS automatically from the environment (e.g. by checking `$env:OS` on Windows, `uname` on Unix).

## Task Priorities

1. **Priority 1 – Accuracy**: Only return a path that has been verified to exist. Never fabricate or assume a path without confirming it.
2. **Priority 2 – Coverage**: Check all well-known installation locations before reporting Firefox as absent. A single miss means the consumer cannot launch Firefox.
3. **Priority 3 – Clear feedback**: Whether Firefox is found or not, report clearly and actionably so the user or calling agent knows what to do next.

## Workflow

### Step 1 – Detect the Operating System

If **os_hint** was not supplied, determine the OS:

- **Windows**: Check if `$env:OS` contains `Windows` or if `$env:WINDIR` is set.
- **macOS**: Run `uname -s`; if the output is `Darwin`, the OS is macOS.
- **Linux**: Run `uname -s`; if the output is `Linux`, the OS is Linux.

### Step 2 – Search Known Firefox Locations

Run the appropriate script from `scripts/`. The script checks all well-known installation locations and exits with code `0` if Firefox is found, or `1` if not.

**Windows:**
```powershell
.\scripts\find-firefox.ps1
```

**macOS / Linux:**
```bash
bash scripts/find-firefox.sh
```

### Step 3 – Report the Result

**If a path was found:**

Return the absolute path to the user or calling agent. Example response:

> Mozilla Firefox is installed at: `/usr/bin/firefox`

**If no path was found:**

Notify the user clearly. Do not guess or fabricate a path. Example response:

> Mozilla Firefox does not appear to be installed on this machine. None of the standard installation locations contain a Firefox executable.
> To install Firefox, visit: https://www.mozilla.org/firefox

## Output Format

Return one of the following, with no additional prose:

**Found:**
```
Firefox executable path: <absolute-path>
```

**Not found:**
```
Mozilla Firefox is not installed. None of the standard locations contain a Firefox executable.
Download Firefox at: https://www.mozilla.org/firefox
```

## Assumptions and Known Limits

- Assumes the agent has permission to execute the scripts and read the file system.
- Does not handle portable Firefox installations placed in non-standard directories — only well-known system and user paths are checked.
- On Linux, Firefox ESR is included as a fallback since distributions often package it as a separate binary.
- Does not install or update Firefox.
- Does not validate the Firefox version — only checks that the executable file exists.
