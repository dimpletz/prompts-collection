---
name: python-installer
description: >
  Downloads and installs a specific Python version from the official python.org FTP server.
  Use this skill whenever you need to download or install a Python release on Windows, macOS, or Linux.
  Do NOT use this skill for managing virtual environments, pip packages, or any other Python tooling.
---

# Python Installer

Downloads and installs the official Python release for the current platform using the bundled install scripts.

## Inputs

- **python_version** (optional): The Python version to install (e.g. `3.14.4`). Defaults to the
  value of `DEFAULT_PYTHON_VERSION` injected into the agent context at session start. If neither
  is available, ask the user before proceeding.

## Workflow

1. Resolve `python_version` from the input or `DEFAULT_PYTHON_VERSION` in context. If neither is available, ask the user.

2. Run the appropriate script for the current platform, passing the version as the only argument:
   **Windows**

   ```powershell
   powershell -ExecutionPolicy Bypass -File plugins/python-user/skills/python-installer/scripts/install-python.ps1 -PythonVersion <python_version>
   ```

   **macOS / Linux**

    ```bash
    bash plugins/python-user/skills/python-installer/scripts/install-python.sh <python_version>
    ```

3. Report the script's output to the user.
- Does not handle proxy settings, offline installation, or non-amd64 Windows architectures.
- `DEFAULT_PYTHON_VERSION` is injected by the python-user plugin `SessionStart` hook; if the hook is not active, the version must be supplied manually.
