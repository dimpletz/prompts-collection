---
name: chrome-browser-path-provider
description: >
  Returns the absolute path of the Google Chrome browser executable on the current machine. Use this skill whenever an agent or workflow needs to know the exact Chrome executable path before launching, configuring, or referencing Chrome. Do NOT use this skill for installing Chrome or for general browser automation setup.
---

# Chrome Browser Path

> Scripts live in `scripts/` inside this skill directory: `find-chrome.ps1` (Windows) and `find-chrome.sh` (macOS/Linux).

Locates the Google Chrome browser installation on the current machine and returns the absolute path to its executable. If Chrome is not found in any known location, reports its absence to the user.

## Inputs

- **os_hint** (optional): The target operating system — `windows`, `macos`, or `linux`. If not provided, detect the OS automatically from the environment (e.g. by checking `$env:OS` on Windows, `uname` on Unix).

## Task Priorities

1. **Priority 1 – Accuracy**: Only return a path that has been verified to exist. Never fabricate or assume a path without confirming it.
2. **Priority 2 – Coverage**: Check all well-known installation locations before reporting Chrome as absent. A single miss means the consumer cannot launch Chrome.
3. **Priority 3 – Clear feedback**: Whether Chrome is found or not, report clearly and actionably so the user or calling agent knows what to do next.

## Workflow

### Step 1 – Detect the Operating System

If **os_hint** was not supplied, determine the OS:

- **Windows**: Check if `$env:OS` contains `Windows` or if `$env:WINDIR` is set.
- **macOS**: Run `uname -s`; if the output is `Darwin`, the OS is macOS.
- **Linux**: Run `uname -s`; if the output is `Linux`, the OS is Linux.

### Step 2 – Search Known Chrome Locations

Run the appropriate script from `scripts/`. The script checks all well-known installation locations and exits with code `0` if Chrome is found, or `1` if not.

**Windows:**
```powershell
.\scripts\find-chrome.ps1
```

**macOS / Linux:**
```bash
bash scripts/find-chrome.sh
```

### Step 3 – Report the Result

**If a path was found:**

Return the absolute path to the user or calling agent. Example response:

> Chrome is installed at: `/usr/bin/google-chrome-stable`

**If no path was found:**

Notify the user clearly. Do not guess or fabricate a path. Example response:

> Google Chrome does not appear to be installed on this machine. None of the standard installation locations contain a Chrome executable.
> To install Chrome, visit: https://www.google.com/chrome/

## Output Format

Return one of the following, with no additional prose:

**Found:**
```
Chrome executable path: <absolute-path>
```

**Not found:**
```
Google Chrome is not installed. None of the standard locations contain a Chrome executable.
Download Chrome at: https://www.google.com/chrome/
```

## Assumptions and Known Limits

- Assumes the agent has permission to execute the scripts and read the file system.
- Does not handle portable Chrome installations placed in non-standard directories — only well-known system and user paths are checked.
- On Linux, Chromium is included as a fallback since it shares the same binary interface as Chrome for most automation purposes. If the caller requires Google Chrome specifically (not Chromium), they should check the returned path name.
- Does not install or update Chrome.
- Does not validate the Chrome version — only checks that the executable file exists.
