---
name: code-review-report-appender
description: >
  Appends content to an existing code review report file.
  Use it when an agent wants to write findings or any other markdown content to the report.
  Do not use it for creating the report file — the Code Reviewer orchestrator creates the file before invoking sub-agents.
---

# Code Review Report Appender

This **skill** appends a block of markdown content to an existing report file. It uses a
platform-appropriate terminal command to write multiline content safely without corrupting
the file.

## Inputs

- **report_path** (required): The absolute path to the existing report file.
- **content** (required): The markdown text to append. May contain multiple lines, headings, bullet lists, and fenced code blocks.

## Task Priorities

1. **Priority 1 – Safety**: Never overwrite the report file. Always append only.
2. **Priority 2 – Fidelity**: The appended content must exactly match the `content` input,
   preceded by a single blank line separator.
3. **Priority 3 – Correctness**: Verify the report file exists before appending. If it does
   not exist, output an error message and stop — do not create the file.

## Workflow

### Step 1 — Verify the report file exists

Before appending, confirm that the file at `report_path` exists on disk. If it does not
exist, output the following error and stop:

```
ERROR: Report file not found: <report_path>
```

### Step 2 — Detect platform and append

Run the appropriate terminal command for the current platform.

**Windows (PowerShell)**:

Use `Add-Content` to append the content with a leading newline:

```powershell
$content = @'
<content>
'@
Add-Content -Path "<report_path>" -Value "`n$content"
```

Replace `<content>` with the actual content text and `<report_path>` with the actual absolute path.

**Linux / macOS (bash)**:

Use a heredoc appended with `>>`:

```bash
printf '\n%s' '<content>' >> "<report_path>"
```

For multiline content, use a heredoc delimiter that will not appear in the content:

```bash
cat >> "<report_path>" << 'CR_APPEND_EOF'

<content>
CR_APPEND_EOF
```

Replace `<content>` with the actual content text and `<report_path>` with the actual
absolute path.

### Step 3 — Confirm

After the terminal command completes successfully, no output is required. The skill's
deliverable is the updated file on disk.

## Assumptions and Limitations

- The report file must already exist. This skill does not create files.
- The content may include any Markdown syntax: headings, lists, code blocks, tables.
- The skill does not validate or format the content — it appends it verbatim.
- On Windows, PowerShell is assumed to be available. On Linux/macOS, bash and printf/cat
  are assumed to be available.
