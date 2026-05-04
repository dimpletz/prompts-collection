---
name: diff-chunker
description: >
  A skill for splitting an oversized diff file into smaller chunk files for code review.
  Do not use it for performing the code review itself — use a code reviewer agent on each output file after splitting.
---

# Diff Chunker

This **skill** splits a large diff file into smaller, reviewable chunks by invoking a companion processing script. Diff sections that are individually larger than `CODE_REVIEW_DIFF_CHUNK_MAX_LINES` are saved as standalone oversized files instead of being included in any chunk. Diff sections whose file path matches a pattern in `CODE_REVIEW_IGNORE_FILE` are excluded entirely from all output. All output files are placed in the same directory as the input diff file.

## Inputs

- **diff_file** (required): The absolute path to the diff file to split.
- **max_lines** (optional): Maximum diff-section lines per chunk. Read from `CODE_REVIEW_DIFF_CHUNK_MAX_LINES` in the session context, falling back to `500` if not available.
- **ignore_file** (optional): Path to a gitignore-style ignore file. Read from `CODE_REVIEW_IGNORE_FILE` in the session context. If not available, use an empty string (no filtering).

## Task Priorities

1. **Priority 1 – Correct filtering**: Any diff section whose file path matches a pattern in the ignore file must be excluded from all output and reported as ignored.
2. **Priority 2 – Correct splitting**: Every remaining eligible diff section must land in exactly one chunk. Sections must never be split mid-file across chunks.
3. **Priority 3 – Correct oversized handling**: Any single diff section whose line count exceeds `max_lines` must be written as a separate standalone file and excluded from all chunks.
4. **Priority 4 – Accurate reporting**: Report every output file with its type (chunk, oversized, or ignored). State clearly when no splitting is needed.

## Workflow

### Step 1 — Resolve max_lines and ignore_file

- Read `CODE_REVIEW_DIFF_CHUNK_MAX_LINES` from the session context. If unavailable or empty, use `500`.
- Read `CODE_REVIEW_IGNORE_FILE` from the session context. If it is present, use that path. If it is absent, pass an empty string — the split-diff script automatically falls back to its sibling `config/.ignore` when no ignore file is supplied.

### Step 2 — Run the split-diff script

Detect the current platform and run the appropriate script with the diff file path, `max_lines`, and `ignore_file` as positional arguments.

**Windows** (PowerShell):
```
powershell -ExecutionPolicy Bypass -File ".\scripts\split-diff.ps1" "<diff-file-path>" <max-lines> "<ignore-file-path>"
```

**Linux / macOS** (bash):
```
bash "./scripts/split-diff.sh" "<diff-file-path>" <max-lines> "<ignore-file-path>"
```

If `ignore_file` is empty, omit the third argument or pass an empty string — the script handles both gracefully.

### Step 3 — Parse script output

Each stdout line from the script indicates one result:

| Prefix | Meaning |
|--------|---------|
| `WITHIN_LIMIT:<path>` | Diff is within the line limit; no output files were created. |
| `CHUNK:<path>` | A chunk file was written at the given path. |
| `OVERSIZED:<path>` | A section exceeded the limit and was written as a standalone file. |
| `IGNORED:<path>` | A section was excluded because its file path matched a pattern in the ignore file. |

### Step 4 — Report results

- If `WITHIN_LIMIT`: confirm no splitting was needed and state the file path.
- Otherwise: list all output files in creation order with their type and path; list any ignored paths separately.
- Suggest running a code reviewer agent on each chunk or oversized file separately.

## Output Format

When splitting occurred:

```
## Diff Chunker Results

**Input**: `<diff-file-path>`
**Max lines per chunk**: <max-lines>
**Ignore file**: `<ignore-file-path>` (or "none")

| # | File | Type |
|---|------|------|
| 1 | `<path>` | Chunk |
| 2 | `<path>` | Oversized |

**Ignored sections** (excluded from all chunks):
- `<file-path>`
```

When no splitting was needed:
```
The diff file `<path>` has <N> lines, which is within the CODE_REVIEW_DIFF_CHUNK_MAX_LINES limit of <max-lines>. No splitting was performed.
```

## Ignore File Format

The ignore file follows gitignore conventions:
- Blank lines and lines starting with `#` are ignored.
- A pattern ending with `/` matches any file under that directory (e.g. `vendor/`).
- A pattern containing `/` (but not at the end) is matched against the full file path from the root (e.g. `src/generated/`).
- A pattern without `/` matches any file or directory component anywhere in the path (e.g. `*.lock`, `node_modules`).

## Assumptions and Limitations

- Assumes the companion scripts (`.\scripts\split-diff.ps1` / `./scripts/split-diff.sh`) are present.
- Expects standard `git diff` output with `diff --git a/<path> b/<path>` section headers.
- Content before the first `diff --git` header (commit metadata, index lines) is treated as a preamble and is prepended to every chunk and oversized file so each output is a valid standalone diff.
- A section whose line count exactly equals `max_lines` is treated as eligible (not oversized).
- Does not perform the code review itself — pass each output file to a code reviewer agent after splitting.
