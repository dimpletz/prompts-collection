---
name: markdown-viewer
description: >
  Views a markdown file in a browser using the mdview command from markdown-viewer-app.
  Use this skill whenever a markdown file needs to be rendered and opened in a browser.
  Do NOT use this skill for exporting markdown to PDF or Word — that is a separate concern.
---

# Markdown Viewer

Opens any markdown file in a full browser UI using `mdview`, which starts a local Flask server
on localhost and renders the file with full GitHub Flavored Markdown, Mermaid diagrams, math
equations, and syntax highlighting. Supports selecting a specific browser and port. Reports any errors encountered.

## Inputs

- **md_file** (required): Absolute or relative path to the markdown file to view.
- **browser** (optional): Name or full path of the browser to open. Accepted values: `chrome`,
  `firefox`, `msedge`, `brave`, `opera`, `safari`, `iexplore`, or any absolute path to a browser
  executable (e.g. `C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe`).
  If omitted, the system default browser is used.
- **port** (optional): Port number for the background Flask server (default: `5000`). Use a
  different port to run multiple servers simultaneously.

## Task Priorities

1. **Priority 1 – Run the command correctly**: Build and execute the exact `mdview` command
   with the supplied options. Never fabricate flags or guess paths.
2. **Priority 2 – Error reporting**: Capture all error output from `mdview` and report it
   verbatim so the user can act immediately.
3. **Priority 3 – Server lifecycle**: Execute the stop command correctly and report its outcome
   when the user asks to stop the server. Never proactively prompt the user to stop it.

## Workflow

### Step 1 – Verify mdview is available

Run:

```
mdview --version
```

If the command is not found, stop and notify the user:

> `mdview` is not available. Ensure `markdown-viewer-app` is installed
> (`pip install markdown-viewer-app`) and that it has been added to your PATH.
> On some systems you may need to restart your terminal or VS Code after installation.

Do not proceed further until `mdview` is confirmed available.

### Step 2 – Build the command

Start with the base command:

```
mdview <MD_FILE>
```

Append optional flags if the corresponding parameter was provided:

- `--browser <browser>` — if the `browser` parameter was supplied.
- `-p <port>` — if the `port` parameter was supplied.

Examples:

```
mdview README.md
mdview README.md --browser firefox
mdview README.md -p 5001
mdview README.md --browser msedge -p 5002
```

### Step 3 – Run the command

Execute the assembled command in a terminal. Capture both stdout and stderr.

### Step 4 – Handle the result

**On success (exit code 0):**

Confirm to the user that the file is open in the browser and show the full URL where it is
being served:

```
Markdown file is now open in the browser.
URL: http://127.0.0.1:<port>/view?file=<MD_FILE>
```

**On failure (non-zero exit code or error output):**

Display the full captured error output. Do not attempt to retry or guess a fix — report
the error and let the user decide:

```
mdview returned an error:
<captured stderr / stdout>
```

### Step 5 – Stopping the server

Only execute this step when the user explicitly asks to stop the markdown viewer server.
Do not suggest or prompt the user to stop the server unprompted.

Run:

```
mdview --stop
```

If a custom port was used, include the port flag:

```
mdview --stop -p <port>
```

Confirm to the user once the stop command completes. If the stop command itself fails,
report the error output verbatim:

```
Failed to stop the server on port <port>:
<captured error output>
```

## Output Format

**Viewing started successfully:**

```
Markdown file is now open in the browser.
URL: http://127.0.0.1:<port>/view?file=<MD_FILE>
```

**Command failed:**

```
mdview returned an error:
<captured stderr / stdout>
```

**Server stopped successfully:**

```
Server on port <port> has been stopped.
```

**Server stop failed:**

```
Failed to stop the server on port <port>:
<captured error output>
```

## Assumptions and Known Limits

- Assumes `markdown-viewer-app` is installed and `mdview` is on PATH. The `markdown-viewer`
  plugin's `SessionStart` hook handles installation automatically at session start.
- The server binds to `127.0.0.1` (localhost only) — it is not accessible from other machines.
- Default port is `5000`. If that port is already in use, pass a different port with `-p`.
- Browser name values use Python's `webbrowser` module identifiers — or a full executable path
  for browsers not on PATH.
- PDF and Word export are not part of this skill; they can be invoked directly with
  `mdview <file> --export-pdf` or `mdview <file> --export-word`.
