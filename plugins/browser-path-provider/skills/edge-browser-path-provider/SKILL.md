---
name: edge-browser-path-provider
description: >
  Returns the absolute path of the Microsoft Edge browser executable on the current machine. Use this skill whenever an agent or workflow needs to know the exact Edge executable path before launching, configuring, or referencing Edge. Do NOT use this skill for installing Edge or for general browser automation setup.
---

# Edge Browser Path

> Scripts live in `scripts/` inside this skill directory: `find-edge.ps1` (Windows) and `find-edge.sh` (macOS/Linux).

Locates the Microsoft Edge browser installation on the current machine and returns the absolute path to its executable. If Edge is not found in any known location, reports its absence to the user.

## Inputs

- **os_hint** (optional): The target operating system — `windows`, `macos`, or `linux`. If not provided, detect the OS automatically from the environment (e.g. by checking `$env:OS` on Windows, `uname` on Unix).

## Task Priorities

1. **Priority 1 – Accuracy**: Only return a path that has been verified to exist. Never fabricate or assume a path without confirming it.
2. **Priority 2 – Coverage**: Check all well-known installation locations before reporting Edge as absent. A single miss means the consumer cannot launch Edge.
3. **Priority 3 – Clear feedback**: Whether Edge is found or not, report clearly and actionably so the user or calling agent knows what to do next.

## Workflow

### Step 1 – Detect the Operating System

If **os_hint** was not supplied, determine the OS:

- **Windows**: Check if `$env:OS` contains `Windows` or if `$env:WINDIR` is set.
- **macOS**: Run `uname -s`; if the output is `Darwin`, the OS is macOS.
- **Linux**: Run `uname -s`; if the output is `Linux`, the OS is Linux.

### Step 2 – Search Known Edge Locations

Run the appropriate script from `scripts/`. The script checks all well-known installation locations and exits with code `0` if Edge is found, or `1` if not.

**Windows:**
```powershell
.\scripts\find-edge.ps1
```

**macOS / Linux:**
```bash
bash scripts/find-edge.sh
```

### Step 3 – Report the Result

**If a path was found:**

Return the absolute path to the user or calling agent. Example response:

> Microsoft Edge is installed at: `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe`

**If no path was found:**

Notify the user clearly. Do not guess or fabricate a path. Example response:

> Microsoft Edge does not appear to be installed on this machine. None of the standard installation locations contain an Edge executable.
> To install Edge, visit: https://www.microsoft.com/edge

## Output Format

Return one of the following, with no additional prose:

**Found:**
```
Edge executable path: <absolute-path>
```

**Not found:**
```
Microsoft Edge is not installed. None of the standard locations contain an Edge executable.
Download Edge at: https://www.microsoft.com/edge
```

## Assumptions and Known Limits

- Assumes the agent has permission to execute the scripts and read the file system.
- Does not handle portable Edge installations placed in non-standard directories — only well-known system and user paths are checked.
- Microsoft Edge comes pre-installed on Windows 10/11; if it is absent, it may have been uninstalled or the system is running an older Windows version.
- Does not install or update Edge.
- Does not validate the Edge version — only checks that the executable file exists.
