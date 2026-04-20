---
name: git-diff-generator
description: >
  Generates a diff file comparing a source (pull request ID, current local branch, remote branch, or first commit) against a target branch. Use this skill whenever you need to produce a diff file based on a PR, locally checked-out branch, remote branch, or the repository's first commit versus a target branch. Do NOT use this skill for merging, resolving conflicts, or reviewing code inline.
---

# Git Diff Generator

Produces a `.diff` file comparing a source ref (pull request, current local branch, remote branch, or the repository's first commit) against a target branch, using three-dot (`A...B`) diff semantics to capture only the changes introduced by the source.

## Inputs

- **source** (required, choose **exactly one**):
  - `pr_id` — a pull request number (integer, e.g. `42`)
  - `current_branch` — use the currently checked-out local branch (no value needed; keyword only)
  - `remote_branch` — a branch name on the remote (string, e.g. `feature/my-feature`; do **not** include the remote prefix)
  - `first_commit` — use the repository's very first (root) commit as the source (no value needed; keyword only)
- **target_branch** (required): the branch to diff against (e.g. `main`, `develop`). Do **not** include the remote prefix — it will always be fetched and referenced as `<remote>/<target_branch>`.
- **remote** (optional, default: `origin`): the remote repository name (e.g. `origin`, `upstream`).

If `source` or `target_branch` is missing, **ask the user** before proceeding. Do not guess or use defaults for these two inputs.

## Output Location

- If `GIT_DIFF_DIR` is present in the agent context (injected by the git-manager hook), save the diff file to that directory.
- Otherwise, save the diff file to the current workspace root.

## Filename Sanitization

Strip the remote prefix from both the source branch name and the target branch name when they are used in the filename (e.g. `origin/main` → `main`). Then sanitize the resulting filename components:

- Replace `/`, `\`, `:`, `*`, `?`, `"`, `<`, `>`, `|`, and spaces with `-`.
- Convert the entire filename to lowercase.
- Collapse consecutive `-` characters into a single `-`.

Apply sanitization to every variable component of the filename before assembling the final path.

## Timestamp Format

The `<YYYY-MM-DD-HH-MM>` timestamp in all filenames must be obtained from the system clock at the moment of diff generation:

- **PowerShell / Windows**: `(Get-Date).ToString('yyyy-MM-dd-HH-mm')`
- **bash / Linux / macOS**: `date +"%Y-%m-%d-%H-%M"`

## Task Priorities

1. **Priority 1 – Correct diff content**: Use `git diff <remote>/<target_branch>...<source_ref>` (three-dot) so the diff captures only the changes introduced by the source and not unrelated commits on the target.
2. **Priority 2 – Always fetch target branch**: Always run `git fetch <remote> <target_branch>` before generating any diff. The target branch reference must always come from the named remote.
3. **Priority 3 – Always use `git-pr-cloner` for PR fetching**: Whenever a `pr_id` is the source, **never** run a manual `git fetch pull/...` command. Always delegate to the `git-pr-cloner` skill. This is non-negotiable — it ensures consistent branch naming (`PR<id>`), platform detection, and prerequisite checks.
4. **Priority 4 – Safe file output**: Sanitize all filename components; confirm `GIT_DIFF_DIR` exists before writing there.
5. **Priority 5 – Clean up temporary branches**: After generating a PR diff, always delete the local `PR<id>` branch.

## Workflow

### Step 0 – Validate Inputs

1. Confirm that exactly one source type is provided (`pr_id`, `current_branch`, `remote_branch`, or `first_commit`). If none or more than one is provided, ask the user to clarify.
2. Confirm that `target_branch` is provided. If missing, ask the user.
3. Set `remote` to `origin` if not specified.
4. Determine the output directory:
   - If `GIT_DIFF_DIR` is in context, use that directory. Verify it exists; if not, create it or ask the user — do not silently fall back.
   - Otherwise, use the current workspace root (result of `git rev-parse --show-toplevel`).

### Step 1 – Fetch the Target Branch

Always fetch the target branch from the named remote before any diff operation:

```bash
git fetch <remote> <target_branch>
```

This ensures `<remote>/<target_branch>` reflects the latest state.

### Step 2A – Scenario: PR ID

Use when `pr_id` is provided.

**2A-1. Clone the PR locally** by invoking the `git-pr-cloner` skill with `pr_number = <pr_id>` and `remote = <remote>`. **Never** run the fetch command manually — always delegate to `git-pr-cloner`. It handles platform detection (GitHub vs Bitbucket), prerequisite checks, and consistent branch naming. On success it creates a local branch named `PR<pr_id>`.

**2A-2. Assemble the filename:**

```
pr<pr_id>-<sanitized_target_branch>-<YYYY-MM-DD-HH-MM>.diff
```

where `<sanitized_target_branch>` is the target branch name with the remote prefix stripped and then sanitized.

Example: `pr42-main-2026-04-21-14-30.diff`

**2A-3. Generate the diff:**

```bash
git diff <remote>/<target_branch>...PR<pr_id> > "<output_dir>/<filename>"
```

**2A-4. Delete the local PR branch:**

```bash
git branch -D PR<pr_id>
```

Do not skip this step. If deletion fails, report the error but still deliver the diff file.

### Step 2B – Scenario: Current Local Branch

Use when `current_branch` is the source type.

**2B-1. Detect the current branch:**

```bash
git rev-parse --abbrev-ref HEAD
```

If the result is `HEAD` (detached HEAD state), stop and tell the user they must check out a named branch first.

**2B-2. Assemble the filename:**

```
local-<sanitized_current_branch>-<sanitized_target_branch>-<YYYY-MM-DD-HH-MM>.diff
```

Example: `local-feature-my-feature-main-2026-04-21-14-30.diff`

**2B-3. Generate the diff:**

```bash
git diff <remote>/<target_branch>...<current_branch> > "<output_dir>/<filename>"
```

### Step 2C – Scenario: Remote Branch

Use when `remote_branch` is provided.

**2C-1. Fetch the remote branch:**

```bash
git fetch <remote> <remote_branch>
```

**2C-2. Assemble the filename** (strip remote prefix from both components, then sanitize):

```
remote-<sanitized_remote_branch>-<sanitized_target_branch>-<YYYY-MM-DD-HH-MM>.diff
```

Example: `remote-feature-my-feature-main-2026-04-21-14-30.diff`

**2C-3. Generate the diff:**

```bash
git diff <remote>/<target_branch>...<remote>/<remote_branch> > "<output_dir>/<filename>"
```

### Step 2D – Scenario: First Commit

Use when `first_commit` is the source type.

**2D-1. Resolve the first commit SHA** by reversing the commit history and taking the first entry:

- **bash / Linux / macOS**:

  ```bash
  git rev-list --reverse HEAD | head -1
  ```

- **PowerShell / Windows**:

  ```powershell
  git rev-list --reverse HEAD | Select-Object -First 1
  ```

This always yields the single chronologically earliest ancestor reachable from `HEAD`, regardless of how many root commits exist in the repository. If the command returns nothing, stop and tell the user the repository has no commits.

**2D-2. Assemble the filename:**

```
first-commit-<sanitized_target_branch>-<YYYY-MM-DD-HH-MM>.diff
```

where `<sanitized_target_branch>` is the target branch name with the remote prefix stripped and then sanitized.

Example: `first-commit-main-2026-04-21-14-30.diff`

**2D-3. Generate the diff:**

```bash
git diff <first_commit_sha>...<remote>/<target_branch> > "<output_dir>/<filename>"
```

### Step 3 – Verify the Diff File

After writing:

1. Confirm the file exists and is non-empty. An empty diff is valid (no changes) — report it explicitly so the user knows.
2. Report the file path and size.

## Common Pitfalls to Avoid

- **Not fetching the target branch first**: Always run `git fetch <remote> <target_branch>` before diffing. Stale local refs produce wrong diffs.
- **Two-dot vs three-dot**: Use `...` (three-dot), not `..` (two-dot). Three-dot shows only what was introduced by the source branch since it diverged from the target; two-dot compares tips and can include commits already on the target.
- **Remote prefix in filename**: Strip `origin/`, `upstream/`, etc. from branch names used in filenames. The filename must contain only the branch name without the remote prefix.
- **Bypassing `git-pr-cloner` for PR fetching**: Never run `git fetch pull/<id>/head:PR<id>` manually. Always invoke the `git-pr-cloner` skill for any PR fetch. Running the fetch directly bypasses platform detection and safety checks.
- **Forgetting to delete the PR branch**: Always delete `PR<id>` after a PR diff. Leaving it pollutes the local repo.
- **Unsanitized filenames**: Slashes in branch names (e.g. `feature/my-feature`) must be replaced with `-` before use in a filename.
- **Writing to a non-existent GIT_DIFF_DIR**: Verify or create the directory before writing the diff.
- **Multiple root commits for first_commit**: Using `git rev-list --reverse HEAD | head -1` (or `Select-Object -First 1` on PowerShell) always returns the single chronologically earliest ancestor reachable from `HEAD`, so multiple root commits do not affect the result.

## Output Format

Always respond using this structure:

```markdown
## Summary
- Source type used (PR ID / current branch / remote branch / first commit) and the value.
- Target branch and remote used.
- Diff file path and size.

## Commands Run
- The exact commands executed, in order.

## Result
- Confirmation that the diff file was written (path, size, empty/non-empty).
- For PR scenario: confirmation that the local PR branch was deleted.

## Recommendations
- Suggested next steps (e.g. attach the diff to a PR review, import into a review tool).

## Limitations
- Assumptions made (e.g. remote defaulted to `origin`, GIT_DIFF_DIR used).
- Any steps skipped or errors encountered.
```

## Assumptions and Known Limits

- Assumes Git is installed and the working directory is inside a Git repository.
- Assumes the user has network access to the remote and read permissions for the target and source refs.
- Binary files are included in the diff output but may not render meaningfully in all diff viewers.
- Does not handle forks; if the PR head is on a different remote, the user must configure that remote separately.
- `GIT_DIFF_DIR` is injected into context by the git-manager `SessionStart`/`SubagentStart` hook. If the hook is not active, the variable will not be present and the workspace root will be used instead.
