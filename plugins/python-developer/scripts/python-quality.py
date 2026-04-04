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
# Main
# ---------------------------------------------------------------------------


def main() -> None:
    data = read_stdin_json()

    # Only act when a Python file was modified
    modified_files = extract_modified_files(data)
    if not any(is_python_file(f) for f in modified_files):
        sys.exit(0)

    workspace = data.get("cwd") or os.getcwd()

    # --- Availability checks (blocking) ------------------------------------
    if not check_tool_available("black"):
        blocking_error(
            "ERROR: 'black' is not available on PATH.\n"
            "Please install it before continuing:\n\n"
            "    pip install black\n\n"
            "Or, if you are using a virtual environment:\n"
            "    python -m pip install black\n\n"
            "Once installed, re-run the agent action."
        )

    if not check_tool_available("pylint"):
        blocking_error(
            "ERROR: 'pylint' is not available on PATH.\n"
            "Please install it before continuing:\n\n"
            "    pip install pylint\n\n"
            "Or, if you are using a virtual environment:\n"
            "    python -m pip install pylint\n\n"
            "Once installed, re-run the agent action."
        )

    # Partition modified Python files into test and non-test
    modified_py_files = [f for f in modified_files if is_python_file(f)]
    non_test_py_files = [f for f in modified_py_files if not is_test_file(f)]

    # --- Run black on modified Python files --------------------------------
    black_result = subprocess.run(
        ["black"] + modified_py_files,
        cwd=workspace,
        capture_output=True,
        text=True,
    )

    # --- Run pylint on modified non-test files -----------------------------
    pylint_output = ""
    if non_test_py_files:
        pylint_result = subprocess.run(
            ["pylint"] + non_test_py_files,
            cwd=workspace,
            capture_output=True,
            text=True,
        )
        pylint_output = (pylint_result.stdout + pylint_result.stderr).strip()

    # --- Build context string for the agent --------------------------------
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

    additional_context = "\n\n".join(context_parts) if context_parts else ""

    # --- Emit hook output --------------------------------------------------
    output: dict = {}
    if additional_context:
        output["hookSpecificOutput"] = {
            "hookEventName": "PostToolUse",
            "additionalContext": additional_context,
        }

    if output:
        print(json.dumps(output))

    sys.exit(0)


if __name__ == "__main__":
    main()
