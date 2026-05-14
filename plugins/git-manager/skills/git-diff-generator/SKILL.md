---
name: git-diff-generator
description: >
  Generates a diff file for a whole branch, a pull request, a remote branch, a commit range, a single commit, the first commit, or staged files. Use this skill whenever you need a saved `.diff` artifact from Git history or the index. Do NOT use this skill for merging, resolving conflicts, or reviewing code inline.
---

# Git Diff Generator

Produces a `.diff` file for one of several Git diff scenarios: a whole branch versus a target branch, a pull request, a remote branch, a commit range, a single commit, the repository's first commit, or the current staged changes.

## Inputs

- **source** (required, choose **exactly one**):
  - `pr_id` — a pull request number (integer, e.g. `42`)
  - `current_branch` — diff the currently checked-out local branch tip as a whole branch against `target_branch`
  - `remote_branch` — a branch name on the remote (string, e.g. `feature/my-feature`; do **not** include the remote prefix)
  - `first_commit` — use the repository's very first (root) commit as the source (no value needed; keyword only)
  - `commit_range` — diff between two commits using `from_commit` and `to_commit`
  - `commit` — diff for exactly one commit using `commit_sha`
  - `staged` — diff the currently staged files in the index (no value needed; keyword only)
- **target_branch** (required for `pr_id`, `current_branch`, and `remote_branch`): the branch to diff against (e.g. `main`, `develop`). Do **not** include the remote prefix — it will always be fetched and referenced as `<remote>/<target_branch>`. Not used for `first_commit`, `commit_range`, `commit`, or `staged`.
- **from_commit** (required when source is `commit_range`): the older boundary commit or ref.
- **to_commit** (required when source is `commit_range`): the newer boundary commit or ref.
- **commit_sha** (required when source is `commit`): the single commit to diff.
- **remote** (optional, default: `origin`): the remote repository name (e.g. `origin`, `upstream`).

If `source` is missing, **ask the user** before proceeding. If the selected source mode requires `target_branch`, `from_commit`, `to_commit`, or `commit_sha` and the value is missing, **ask the user** before proceeding. Do not guess these inputs.

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

1. **Priority 1 – Correct diff semantics**: Use the Git command that matches the requested scenario. Whole-branch, PR, and remote-branch comparisons use three-dot semantics; commit ranges use two-dot semantics; single-commit diffs compare the commit to its parent; staged diffs use `--cached`; the first commit diffs against Git's empty tree.
2. **Priority 2 – Always fetch target branches before branch-based comparisons**: For `pr_id`, `current_branch`, and `remote_branch`, always run `git fetch <remote> <target_branch>` before generating the diff.
3. **Priority 3 – Always use `git-pr-cloner` for PR fetching**: Whenever a `pr_id` is the source, **never** run a manual `git fetch pull/...` command. Always delegate to the `git-pr-cloner` skill.
4. **Priority 4 – Always generate a fresh diff file**: Never reuse an old diff artifact unless the user explicitly asks for it.
5. **Priority 5 – Safe file output**: Sanitize all filename components; confirm `GIT_DIFF_DIR` exists before writing there.
6. **Priority 6 – Clean up temporary branches**: After generating a PR diff, always delete the local `PR<id>` branch.

## Workflow

### Step 0 – Validate Inputs

1. Confirm that exactly one source type is provided (`pr_id`, `current_branch`, `remote_branch`, `first_commit`, `commit_range`, `commit`, or `staged`). If none or more than one is provided, ask the user to clarify.
2. Validate scenario-specific required inputs:
   - `target_branch` for `pr_id`, `current_branch`, and `remote_branch`
   - `from_commit` and `to_commit` for `commit_range`
   - `commit_sha` for `commit`
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

> **Skip this step** when source is `first_commit`, `commit_range`, `commit`, or `staged` — no target branch ref is needed.

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

### Step 2B – Scenario: Current Local Branch (Whole Branch Diff)

Use when `current_branch` is the source type and the user wants the diff for the whole checked-out branch, represented by its current tip (last commit) against `target_branch`.

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
first-commit-<YYYY-MM-DD-HH-MM>.diff
```

No target branch component — the diff is against Git's empty tree, not any branch.

Example: `first-commit-2026-04-21-14-30.diff`

**2D-3. Generate the diff:**

Diff the first commit against Git's empty tree SHA (`4b825dc642cb6eb9a060e54bf8d69288fbee4904`). This is the correct technique for a root commit that has no parent:

```bash
git diff 4b825dc642cb6eb9a060e54bf8d69288fbee4904..<first_commit_sha> > "<output_dir>/<filename>"
```

> **Why two-dot and not three-dot**: Three-dot finds the merge base between the two refs. The empty tree has no concept of a merge base, so three-dot would behave incorrectly here. Two-dot simply compares the two trees directly, which is what we want.

### Step 2E – Scenario: Commit Range

Use when `commit_range` is the source type.

**2E-1. Verify both refs resolve successfully:**

```bash
git rev-parse --verify <from_commit>
git rev-parse --verify <to_commit>
```

**2E-2. Assemble the filename:**

```
commits-<sanitized_from_commit>-<sanitized_to_commit>-<YYYY-MM-DD-HH-MM>.diff
```

**2E-3. Generate the diff using two-dot commit-range semantics:**

```bash
git diff <from_commit>..<to_commit> > "<output_dir>/<filename>"
```

### Step 2F – Scenario: Single Commit

Use when `commit` is the source type.

**2F-1. Verify the commit resolves successfully:**

```bash
git rev-parse --verify <commit_sha>
```

**2F-2. Assemble the filename:**

```
commit-<sanitized_commit_sha>-<YYYY-MM-DD-HH-MM>.diff
```

**2F-3. Generate the diff for that one commit against its first parent:**

```bash
git diff <commit_sha>^! > "<output_dir>/<filename>"
```

Use `^!` so the diff shows exactly the patch introduced by that commit.

### Step 2G – Scenario: Staged Files

Use when `staged` is the source type.

**2G-1. Confirm there are staged changes:**

```bash
git diff --cached --quiet
```

If the command reports no staged changes, stop and tell the user there is nothing staged to diff.

**2G-2. Assemble the filename:**

```
staged-<YYYY-MM-DD-HH-MM>.diff
```

**2G-3. Generate the staged diff:**

```bash
git diff --cached > "<output_dir>/<filename>"
```

### Step 3 – Verify the Diff File

After writing:

1. Confirm the file exists and is non-empty. An empty diff is valid (no changes) — report it explicitly so the user knows.
2. Report the file path and size.

## Common Pitfalls to Avoid

- **Not fetching the target branch first**: Always run `git fetch <remote> <target_branch>` before branch-based diffs. Stale local refs produce wrong diffs.
- **Wrong diff operator for the scenario**: Use `...` (three-dot) for whole-branch, PR, and remote-branch comparisons; `..` (two-dot) for commit ranges; `<commit>^!` for a single commit; `--cached` for staged files. The `first_commit` scenario uses two-dot against Git's empty tree.
- **Remote prefix in filename**: Strip `origin/`, `upstream/`, etc. from branch names used in filenames. The filename must contain only the branch name without the remote prefix.
- **Bypassing `git-pr-cloner` for PR fetching**: Never run `git fetch pull/<id>/head:PR<id>` manually. Always invoke the `git-pr-cloner` skill for any PR fetch. Running the fetch directly bypasses platform detection and safety checks.
- **Forgetting to delete the PR branch**: Always delete `PR<id>` after a PR diff. Leaving it pollutes the local repo.
- **Unsanitized filenames**: Slashes in branch names (e.g. `feature/my-feature`) must be replaced with `-` before use in a filename.
- **Writing to a non-existent GIT_DIFF_DIR**: Verify or create the directory before writing the diff.
- **Reading existing diff files**: Never read or load a previously generated diff file from the output directory. Always produce a fresh diff by running the git commands — this is the default behaviour. Only examine an existing diff file if the user explicitly requests it.
- **Multiple root commits for first_commit**: Using `git rev-list --reverse HEAD | head -1` (or `Select-Object -First 1` on PowerShell) always returns the single chronologically earliest ancestor reachable from `HEAD`, so multiple root commits do not affect the result.
- **Trying to diff staged files with no index changes**: Check for staged content first and stop with a clear message when nothing is staged.

## Output Format

Always respond using this structure:

```markdown
## Summary
- Source type used and the value(s).
- Target branch and remote used, when applicable.
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
