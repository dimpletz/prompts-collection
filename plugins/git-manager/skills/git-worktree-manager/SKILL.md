---
name: git-worktree-manager
description: >
  Manages Git worktrees with a consistent naming convention. Use this skill whenever the user wants to create, list, move, remove, or purge a Git worktree. The worktree directory is always placed beside the repository root and follows the pattern `<REPO>-worktree-<BRANCH>`. Do NOT use this skill for general Git branching, merging, or cloning tasks.
---

# Git Worktree Manager

This skill handles the full lifecycle of Git worktrees: **Create**, **Read (list)**, **Update (move / lock / unlock)**, **Delete (remove)**, and **Purge (prune stale entries)**. All worktrees follow a fixed naming convention derived from the local repository root and the target branch name.

## Naming Convention

Given:
- `<LOCAL_REPO>` — the absolute path of the current local repository root (e.g. `C:\dev\codes\project`)
- `<BRANCH>` — the branch name for the worktree (e.g. `feature1`)

The worktree directory **must always** be:

```
<PARENT_OF_LOCAL_REPO>\<REPO_FOLDER_NAME>-worktree-<BRANCH>
```

**Example:**
| Variable | Value |
|---|---|
| `<LOCAL_REPO>` | `C:\dev\codes\project` |
| `<BRANCH>` | `feature1` |
| Worktree path | `C:\dev\codes\project-worktree-feature1` |

Branch names that contain `/` or `\` must have those characters replaced with `-` when constructing the directory name (e.g. `feat/login` → `feat-login`, giving `project-worktree-feat-login`).

## Inputs

- **operation** (required): One of `create`, `list`, `move`, `lock`, `unlock`, `remove`, `purge`.
- **branch** (required for `create`, `move`, `lock`, `unlock`, `remove`): The branch name associated with the worktree.
- **new_branch** (required for `move`): The new branch name (determines the new directory name, also following the naming convention).
- **repo_root** (optional): Absolute path to the local repository root. If omitted, detect it automatically via `git rev-parse --show-toplevel`.

## Task Priorities

1. **Priority 1 – Naming correctness**
   The worktree directory path must always match the `<REPO_FOLDER>-worktree-<BRANCH>` pattern. Never alter this.

2. **Priority 2 – Safety**
   Confirm destructive operations (`remove`, `purge`) with the user before running them. For `remove`, state the exact directory that will be deleted. For `purge`, list which stale entries will be removed.

3. **Priority 3 – Clear command output**
   Always show the exact commands run and their output so the user can reproduce or debug them independently.

## Workflow

### Step 1 – Resolve repository root

Run the following and capture the output:

```
git rev-parse --show-toplevel
```

Normalize path separators for the current OS. On Windows, convert forward slashes to backslashes.

Derive:
- `REPO_NAME` — the last segment of the resolved root path (e.g. `project`).
- `PARENT_DIR` — everything before the last segment (e.g. `C:\dev\codes`).

### Step 2 – Compute worktree path (for operations that need it)

```
WORKTREE_PATH = PARENT_DIR\REPO_NAME-worktree-<BRANCH_SAFE>
```

Where `BRANCH_SAFE` is the branch name with `/` and `\` replaced by `-`.

### Step 3 – Execute the requested operation

#### Create

Determine whether the target branch already exists locally or remotely, then choose the right command:

**Branch already exists locally:**
```
git worktree add "<WORKTREE_PATH>" <BRANCH>
```

**Branch does not exist yet (create and track):**
```
git worktree add -b <BRANCH> "<WORKTREE_PATH>"
```

**Branch exists on remote only (e.g. `origin/<BRANCH>`):**
```
git worktree add --track -b <BRANCH> "<WORKTREE_PATH>" origin/<BRANCH>
```

After creation, confirm the directory was created and print the full path.

#### Read (List)

```
git worktree list
```

Present the output in a readable table format, showing: worktree path, HEAD commit hash (short), and branch name. Highlight which is the main worktree.

#### Move

Compute both old and new paths:
- `OLD_PATH = PARENT_DIR\REPO_NAME-worktree-<BRANCH_SAFE>`
- `NEW_PATH = PARENT_DIR\REPO_NAME-worktree-<NEW_BRANCH_SAFE>`

Run:
```
git worktree move "<OLD_PATH>" "<NEW_PATH>"
```

#### Lock

Locks the worktree to prevent accidental pruning:
```
git worktree lock "<WORKTREE_PATH>"
```

Optionally accept a reason string and pass it via `--reason "<reason>"`.

#### Unlock

```
git worktree unlock "<WORKTREE_PATH>"
```

#### Remove

Before running, confirm with the user:
> "This will remove the worktree at `<WORKTREE_PATH>` and delete all untracked files in it. Proceed?"

If confirmed:
```
git worktree remove "<WORKTREE_PATH>"
```

If the directory contains uncommitted changes and the user still wants to force-remove, use:
```
git worktree remove --force "<WORKTREE_PATH>"
```

Never use `--force` without explicit user confirmation.

#### Purge

First preview what will be pruned (dry run):
```
git worktree prune --dry-run
```

Present the list to the user and ask for confirmation before actually pruning. If confirmed:
```
git worktree prune
```

Purge removes admin records for worktrees whose directories no longer exist on disk. It does **not** delete any directories itself.

### Step 4 – Report outcome

After every operation:
- Print the exact command(s) executed.
- Print the command output.
- State the result in plain language (e.g. "Worktree created at `C:\dev\codes\project-worktree-feature1`").
- If an error occurred, explain the likely cause and suggest a fix.

## Output Format

Respond using this structure:

**Command(s) run:**
```
<exact commands>
```

**Output:**
```
<terminal output>
```

**Result:** One-line plain-language summary of what happened.

**Next steps** (optional): Any follow-up actions the user may want (e.g. "Open the worktree in a new VS Code window with `code <WORKTREE_PATH>`").

## Assumptions and Limits

- **Assumes Git ≥ 2.17** is installed and available on `PATH` (`git worktree move` requires 2.17+; `git worktree lock` requires 2.19+).
- **Does not manage remote branches**; it only adds or tracks them locally.
- **Branch name sanitization** replaces only `/` and `\` — other characters (spaces, `#`, etc.) in branch names are passed through. If a branch name contains spaces, the worktree path is still constructed but you must quote it carefully in all commands.
- **Windows path length**: paths over 260 characters may fail without long path support enabled in Windows. Alert the user if the computed path approaches this limit.
- **Does not open the worktree** in a new window automatically; it only suggests the command.

## Validation Checks

1. **Create smoke test**: Create a worktree for a known branch and verify the directory appears at `<REPO>-worktree-<BRANCH>` relative to the repo parent.
2. **List accuracy**: Run `list` and compare paths against directories present on disk.
3. **Purge safety**: Delete a worktree directory manually (without `git worktree remove`), then run `purge --dry-run` and confirm the stale entry is listed before confirming the actual purge.
