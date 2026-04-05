#!/usr/bin/env python3
"""
python-quality.py — PostToolUse hook for the python-developer plugin.

Runs after every agent tool call. When a Python file is modified it:
  1. Checks that `black` is available (blocking error if missing).
  2. Checks that `pylint` is available (blocking error if missing).
  3. Runs `black` on the modified Python files.
  4. Runs `pylint` on the modified non-test Python files and reports findings via
     hookSpecificOutput.additionalContext so the agent can iterate and fix.
"""

import json
import os
import subprocess
import sys
import shutil
from pathlib import Path

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def read_stdin_json() -> dict:
    """Read and parse the JSON payload VS Code sends via stdin."""
    raw = sys.stdin.read()
    if not raw.strip():
        return {}
    return json.loads(raw)


def extract_modified_files(data: dict) -> list[str]:
    """
    Extract the list of files that were modified from the PostToolUse payload.
    VS Code may pass files in different shapes depending on the tool that ran.
    """
    tool_input = data.get("tool_input", {})

    # editFiles / create_file / replace_string_in_file send a list
    files = tool_input.get("files", [])
    if isinstance(files, list) and files:
        return [str(f) for f in files]

    # Some tools send a single camelCase path
    for key in ("filePath", "file_path", "path"):
        value = tool_input.get(key)
        if value:
            return [str(value)]

    return []


def is_python_file(path: str) -> bool:
    return path.endswith(".py")


def is_test_file(path: str) -> bool:
    """Return True when a file is part of the test suite."""
    p = Path(path)
    name = p.name
    if name.startswith("test_") or name.endswith("_test.py"):
        return True
    # Any file inside a 'tests' or 'test' directory
    parts = set(p.parts)
    return bool(parts & {"tests", "test"})


def check_tool_available(tool_name: str) -> bool:
    return shutil.which(tool_name) is not None


def blocking_error(message: str) -> None:
    """Write message to stderr and exit with code 2 (blocking error)."""
    print(message, file=sys.stderr)
    sys.exit(2)


# ---------------------------------------------------------------------------
# Main helpers
# ---------------------------------------------------------------------------


def get_modified_py_files(data: dict) -> tuple[list[str], list[str]]:
    """Return (all_py_files, non_test_py_files) from the hook payload."""
    modified_files = extract_modified_files(data)
    all_py = [f for f in modified_files if is_python_file(f)]
    non_test = [f for f in all_py if not is_test_file(f)]
    return all_py, non_test


def install_tool(tool_name: str) -> bool:
    """Attempt to install *tool_name* via `python -m pip`. Return True on success."""
    result = subprocess.run(
        [sys.executable, "-m", "pip", "install", tool_name],
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode == 0


def check_required_tools() -> None:
    """Ensure black and pylint are available, installing them if needed."""
    for tool in ("black", "pylint"):
        if not check_tool_available(tool):
            if not install_tool(tool):
                blocking_error(
                    f"ERROR: '{tool}' is not available and could not be installed.\n"
                    f"Please install it manually before continuing:\n\n"
                    f"    python -m pip install {tool}\n\n"
                    "Once installed, re-run the agent action."
                )


def run_black(files: list[str], workspace: str) -> subprocess.CompletedProcess:
    """Run black on *files* and return the CompletedProcess result."""
    return subprocess.run(
        ["black"] + files,
        cwd=workspace,
        capture_output=True,
        text=True,
        check=False,
    )


def run_pylint(files: list[str], workspace: str) -> str:
    """Run pylint on *files* and return combined stdout+stderr, or '' if no files."""
    if not files:
        return ""
    result = subprocess.run(
        ["pylint"] + files,
        cwd=workspace,
        capture_output=True,
        text=True,
        check=False,
    )
    return (result.stdout + result.stderr).strip()


def build_context(
    black_result: subprocess.CompletedProcess,
    pylint_output: str,
    non_test_py_files: list[str],
) -> str:
    """Assemble the additionalContext string from black and pylint results."""
    context_parts = []

    black_summary = (black_result.stdout + black_result.stderr).strip()
    context_parts.append(
        f"black output:\n{black_summary}"
        if black_summary
        else "black: all files already well-formatted."
    )

    if pylint_output:
        context_parts.append(f"pylint output:\n{pylint_output}")
    elif non_test_py_files:
        context_parts.append("pylint: no issues found.")

    return "\n\n".join(context_parts) if context_parts else ""


def emit_hook_output(additional_context: str) -> None:
    """Print the JSON hook output payload when there is context to share."""
    if not additional_context:
        return
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": additional_context,
        }
    }
    print(json.dumps(output))


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> None:
    data = read_stdin_json()

    all_py_files, non_test_py_files = get_modified_py_files(data)
    if not all_py_files:
        sys.exit(0)

    workspace = data.get("cwd") or os.getcwd()

    check_required_tools()

    black_result = run_black(all_py_files, workspace)
    pylint_output = run_pylint(non_test_py_files, workspace)

    additional_context = build_context(black_result, pylint_output, non_test_py_files)
    emit_hook_output(additional_context)

    sys.exit(0)


if __name__ == "__main__":
    main()
