---
name: encoding-normalizer
description: >
  Normalizes tracked text files whose diffs are caused only by line-ending churn or mixed text encodings. Use this skill when a Git diff looks suspiciously large because of CRLF/LF-only changes or when a text file has been saved with inconsistent encoding. Do NOT use it for binary files, content rewrites, or merge conflict resolution.
---

# Encoding Normalizer

Detects whether a tracked text file changed only because of line-ending churn or mixed text encodings, then restores the file to the encoding and newline style that should be kept in Git history.

## Inputs

- **file_path** (required): Path to the tracked file that needs inspection.
- **reference_commit** (optional): Commit to compare against when the user wants a baseline other than `HEAD`. Defaults to `HEAD`.
- **restore_to_index** (optional): When `true`, also re-stage the normalized file if it was staged before. Defaults to `true` when the file was already staged, otherwise `false`.

If `file_path` is missing, ask the user before proceeding. Do not guess the file.

## Task Priorities

1. **Priority 1 – Preserve real content**
   Only normalize line endings or encoding issues. Never discard semantic text changes.

2. **Priority 2 – Prefer Git history as the source of truth**
   When mixed encoding is detected, restore the file to the encoding used in the previous committed version before re-saving it.

3. **Priority 3 – Avoid binary-file damage**
   Stop if the target is binary or if the previous committed version cannot be decoded safely.

## Workflow

### Step 1 – Verify the file can be normalized safely

1. Confirm the file is tracked:

   ```bash
   git ls-files --error-unmatch -- <file_path>
   ```

2. Confirm the file exists in the working tree.
3. Determine whether the file is currently staged:

   ```bash
   git diff --cached --name-only -- <file_path>
   ```

4. Read the previous committed blob from `<reference_commit>:<file_path>` with:

   ```bash
   git show <reference_commit>:<file_path>
   ```

   If the path does not exist in the reference commit, stop and tell the user this skill only restores files that already exist in Git history.
5. Treat the file as **text-only**. If Git reports it as binary, or if the previous committed blob cannot be decoded as text, stop and report that manual handling is required.

### Step 2 – Check whether the diff is only line-ending churn

Compare the working tree file to the reference commit while ignoring line-ending-only changes:

```bash
git diff --ignore-cr-at-eol --ignore-space-at-eol <reference_commit> -- <file_path>
```

- If this diff is empty, the change is only a line-ending difference.
- In that case, restore the file from Git instead of trying to rewrite it manually:

  ```bash
  git restore --source=<reference_commit> -- <file_path>
  ```

- If the file had been staged before restoration and **restore_to_index** is enabled, stage the restored file again:

  ```bash
  git add -- <file_path>
  ```

This is the required behavior for pure line-ending churn: **restore the file from the committed content instead of keeping the line-ending-only diff**.

### Step 3 – Check for mixed-encoding corruption

Use this step only when Step 2 shows there are real byte-level changes.

1. Inspect the current working tree bytes and the reference-commit bytes with a charset detector (`file`, Python, or another installed text-decoding tool).
2. If the working tree file contains decode errors, replacement characters, or mixed encodings while the reference blob cleanly decodes as a single text encoding, treat the file as a mixed-encoding case.
3. Determine the encoding used by the reference commit. Prefer the previous committed file's successfully decoded encoding as the target encoding.
4. Re-save the working tree file using that same encoding, preserving the intended text content and the newline style already stored in Git history.
5. Re-check the diff. If only encoding noise was removed and the intended content now matches the reference-encoding representation, keep the normalized file. If the rewrite changes real content unexpectedly, stop and tell the user.

### Step 4 – Validate the result

After normalization:

1. Run a normal diff:

   ```bash
   git diff -- <file_path>
   ```

2. If the file was staged, also run:

   ```bash
   git diff --cached -- <file_path>
   ```

3. Report whether the file was restored completely, re-encoded successfully, or still needs manual review.

## Common Pitfalls to Avoid

- **Using this on binary files**: Stop instead of rewriting binary data.
- **Discarding real content edits**: Only restore the file automatically when the diff is line-ending-only.
- **Guessing the target encoding**: Use the encoding from the previous committed version, not an arbitrary default.
- **Ignoring staged state**: If the file was already staged, restore its staged state when requested.
- **Normalizing new untracked files**: This skill relies on Git history and is not for brand-new files.

## Output Format

Always respond using this structure:

```markdown
## Summary
- File inspected.
- Whether the issue was line-ending-only, mixed encoding, or neither.
- Final file state (restored, re-encoded, or manual review required).

## Commands Run
- The exact commands executed, in order.

## Result
- Whether the file now matches the committed line endings / encoding expectations.
- Whether the file was re-staged.

## Recommendations
- Suggested next step (commit, keep reviewing, or fix manually).

## Limitations
- Reference commit used.
- Any assumptions, skipped steps, or decoding uncertainties.
```

## Assumptions and Known Limits

- Assumes the file already exists in Git history.
- Assumes a charset-detection tool or standard runtime library is available to inspect text encoding.
- Does not attempt to repair binary files or intentionally changed file contents.
- Does not infer the user's preferred encoding; it follows the previous committed version.
