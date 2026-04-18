---
name: vscode-poetry-configurator
description: >
  Configures VS Code to use a Poetry virtual environment as its Python interpreter and ensures
  all integrated PowerShell terminals automatically activate that virtual environment.
  Use this skill whenever a Poetry-managed project needs its VS Code workspace wired up to
  the correct Poetry venv. Do NOT use this skill if the IDE is not VS Code, for creating
  pyproject.toml, managing dependencies, or installing packages — those are separate Poetry concerns.
---

# VS Code Poetry Configurator

Ensures the active workspace's VS Code settings point to the Poetry virtual environment's Python
interpreter and that every new integrated PowerShell terminal automatically activates that
environment. Works on Windows (PowerShell), macOS, and Linux.

## Inputs

- **workspace_root** (derived automatically): Absolute path to the workspace root folder. Derived
  from the VS Code workspace context. Never ask the user for this.
- **venv_path** (derived automatically): Resolved by running `poetry env info --path` in the
  terminal. If the command fails, the skill triggers `poetry install` first, then re-runs the
  command. Never ask the user for this.

## Task Priorities

1. **Priority 1 – Idempotency**: Every step must check whether the configuration already matches
   the desired state before writing anything. Never overwrite a setting that already has the
   correct value.

2. **Priority 2 – Correctness**: The python interpreter path written to VS Code settings must
   point to the actual executable inside the Poetry venv (not the system Python or a different
   venv). Verify the path exists after resolving it.

3. **Priority 3 – Minimal footprint**: Only the two settings that are strictly required
   (`python.defaultInterpreterPath` and `python.terminal.activateEnvironment`) must be written.
   Do not add, remove, or reformat any other settings in `.vscode/settings.json`.

## Workflow

### Step 0 – Verify the IDE is VS Code

Check whether the current IDE is VS Code by looking for a `.vscode/` directory in the workspace
root **or** by confirming that the `VSCODE_PID` or `VSCODE_IPC_HOOK_CLI` environment variable is
set in the current shell.

If neither indicator is present, stop immediately and notify the user:

> This skill is only supported in Visual Studio Code. No changes were made.

Do not proceed further.

### Step 1 – Verify poetry is available

Run:

```powershell
poetry --version
```

If the command is not found, stop immediately and notify the user:

> `poetry` is not available. Ensure Poetry is installed and available on PATH. You can install
> it with `pip install poetry`. You may need to restart the terminal after installation.

Do not proceed further until `poetry` is confirmed available.

### Step 2 – Resolve the Poetry virtual environment path

Run:

```powershell
poetry env info --path
```

**If the command succeeds** (exit code 0) and prints a non-empty path, capture that path as
`VENV_PATH`. Proceed to Step 3.

**If the command fails** or prints nothing (no virtual environment exists yet), run:

```powershell
poetry install
```

Wait for `poetry install` to complete. If it fails, stop and report the error output to the user;
do not continue.

After a successful `poetry install`, re-run:

```powershell
poetry env info --path
```

Capture the printed path as `VENV_PATH`. If the path is still empty or the command still fails,
stop and notify the user that the virtual environment could not be located after installation.

### Step 3 – Derive the Python interpreter path

Construct the Python executable path from `VENV_PATH`:

- **Windows**: `<VENV_PATH>\Scripts\python.exe`
- **macOS / Linux**: `<VENV_PATH>/bin/python`

Verify that the file exists at the derived path. If it does not exist, stop and notify the user:

> The Poetry virtual environment was found at `<VENV_PATH>`, but the Python executable was not
> found at `<derived_path>`. The environment may be corrupted. Try running `poetry env remove --all`
> followed by `poetry install` and then re-run this skill.

Capture the verified path as `PYTHON_PATH`.

### Step 4 – Ensure `.vscode/settings.json` exists

Check whether `.vscode/settings.json` exists in the workspace root.

- If the file does not exist, create it with an empty JSON object: `{}`
- If it exists, read it as-is.

### Step 5 – Configure `python.defaultInterpreterPath`

Read the current value of `python.defaultInterpreterPath` in `.vscode/settings.json`.

- **If it already equals `PYTHON_PATH`** (accounting for forward/back-slash variants on Windows):
  skip this step silently — no change is needed.
- **Otherwise**: update the setting to `PYTHON_PATH`. Use forward slashes for the path value
  (VS Code accepts forward slashes on all platforms, including Windows).

### Step 6 – Configure `python.terminal.activateEnvironment`

Read the current value of `python.terminal.activateEnvironment` in `.vscode/settings.json`.

- **If it is already `true`**: skip this step silently — no change is needed.
- **Otherwise**: set `python.terminal.activateEnvironment` to `true`.

When this setting is `true`, VS Code automatically runs the environment's activation script in
every new integrated terminal (PowerShell, bash, zsh, etc.) so the Poetry venv is active without
any manual step.

### Step 7 – Save and report

Write the updated `.vscode/settings.json` back to disk, preserving all existing keys and
formatting as closely as possible (do not re-order unrelated keys).

Report the outcome to the user with a concise summary:

```
VS Code Poetry configuration complete.

  Virtual environment : <VENV_PATH>
  Python interpreter  : <PYTHON_PATH>
  Settings updated    : .vscode/settings.json

  python.defaultInterpreterPath     → <PYTHON_PATH>
  python.terminal.activateEnvironment → true

All new integrated terminals (PowerShell and others) will automatically
activate this virtual environment. Open a new terminal to verify.
```

If any setting was already correct and no change was needed, note it in the report:

```
  python.terminal.activateEnvironment → already set to true (no change)
```

## Assumptions and Limitations

- Only supported in Visual Studio Code. The skill checks for VS Code indicators (`VSCODE_PID`, `VSCODE_IPC_HOOK_CLI`, or the presence of a `.vscode/` directory) and stops if none are found.
- Assumes `poetry` is on the system PATH and the workspace contains a valid `pyproject.toml`.
- Assumes the workspace root is writable (`.vscode/` directory can be created if missing).
- `python.terminal.activateEnvironment: true` activates the environment in VS Code's **integrated**
  terminals only. External terminals (e.g. Windows Terminal launched outside VS Code) are not
  affected.
- On Windows, PowerShell execution policy must permit running activation scripts (usually
  `RemoteSigned` or `Unrestricted`). If activation fails in the terminal, the user may need to
  run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`.
- Does not handle multi-root workspaces; targets the first/primary workspace root only.

## Validation

1. After the skill completes, open a new integrated PowerShell terminal in VS Code and run
   `python --version` — it should report the Python version from the Poetry venv, not the
   system Python.
2. Run `where.exe python` (Windows) or `which python` (macOS/Linux) in the new terminal — the
   path should be inside the Poetry venv's `Scripts` or `bin` directory.
3. Open the VS Code Command Palette and run **Python: Select Interpreter** — the Poetry venv
   interpreter should appear as the currently selected option.
