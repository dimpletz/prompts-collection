---
name: brave-browser-path-provider
description: >
  Returns the absolute path of the Brave browser executable on the current machine. Use this skill whenever an agent or workflow needs to know the exact Brave executable path before launching, configuring, or referencing Brave. Do NOT use this skill for installing Brave or for general browser automation setup.
---

# Brave Browser Path

> Scripts live in `scripts/` inside this skill directory: `find-brave.ps1` (Windows) and `find-brave.sh` (macOS/Linux).

Locates the Brave browser installation on the current machine and returns the absolute path to its executable. If Brave is not found in any known location, reports its absence to the user.

## Inputs

- **os_hint** (optional): The target operating system — `windows`, `macos`, or `linux`. If not provided, detect the OS automatically from the environment (e.g. by checking `$env:OS` on Windows, `uname` on Unix).

## Task Priorities

1. **Priority 1 – Accuracy**: Only return a path that has been verified to exist. Never fabricate or assume a path without confirming it.
2. **Priority 2 – Coverage**: Check all well-known installation locations before reporting Brave as absent. A single miss means the consumer cannot launch Brave.
3. **Priority 3 – Clear feedback**: Whether Brave is found or not, report clearly and actionably so the user or calling agent knows what to do next.

## Workflow

### Step 1 – Detect the Operating System

If **os_hint** was not supplied, determine the OS:

- **Windows**: Check if `$env:OS` contains `Windows` or if `$env:WINDIR` is set.
- **macOS**: Run `uname -s`; if the output is `Darwin`, the OS is macOS.
- **Linux**: Run `uname -s`; if the output is `Linux`, the OS is Linux.

### Step 2 – Search Known Brave Locations

Run the appropriate script from `scripts/`. The script checks all well-known installation locations and exits with code `0` if Brave is found, or `1` if not.

**Windows:**
```powershell
.\scripts\find-brave.ps1
```

**macOS / Linux:**
```bash
bash scripts/find-brave.sh
```

### Step 3 – Report the Result

**If a path was found:**

Return the absolute path to the user or calling agent. Example response:

> Brave is installed at: `/usr/bin/brave-browser`

**If no path was found:**

Notify the user clearly. Do not guess or fabricate a path. Example response:

> Brave does not appear to be installed on this machine. None of the standard installation locations contain a Brave executable.
> To install Brave, visit: https://brave.com/download

## Output Format

Return one of the following, with no additional prose:

**Found:**
```
Brave executable path: <absolute-path>
```

**Not found:**
```
Brave is not installed. None of the standard locations contain a Brave executable.
Download Brave at: https://brave.com/download
```

## Assumptions and Known Limits

- Assumes the agent has permission to execute the scripts and read the file system.
- Does not handle portable Brave installations placed in non-standard directories — only well-known system and user paths are checked.
- On Windows, Brave installs per-user under `%LocalAppData%` by default; the script checks both system-wide and per-user locations.
- Does not install or update Brave.
- Does not validate the Brave version — only checks that the executable file exists.
