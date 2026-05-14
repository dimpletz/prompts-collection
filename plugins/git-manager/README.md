# Git Manager `v1.4.0`

> A collection of skills for managing Git repositories, worktrees, merge conflicts, pull requests, diff generation, and text normalization — with context injection for diff output directories.

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) extension installed and active.
- Git installed and available on the system `PATH`.

## Installation

Install via the VS Code Chat Plugin Marketplace using the `dimpletz/prompts-collection` marketplace source and enable the **git-manager** plugin.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GIT_DIFF_DIR` | Optional | Directory where generated diff files are saved. If not set, diff files are saved to the current workspace root. |

## Usage

All capabilities are provided as **skills** — describe your git task in Copilot Chat and the appropriate skill is automatically invoked.

| Skill | Invoke when… |
|-------|--------------|
| **Git Merge Conflict Resolver** | You encounter merge conflicts (e.g. "error: Merging is not possible because you have unmerged files."). |
| **Git Merge Auditor** | You want to verify that a target branch contains all commits and changes from a source branch. |
| **Git Worktree Manager** | You want to create, list, move, remove, or purge a Git worktree. |
| **Git PR Cloner** | You want to fetch a pull request locally to inspect or test it without merging. |
| **Git Diff Generator** | You want to generate a diff file for a whole branch, a PR, a remote branch, a commit range, a single commit, the first commit, or staged files. |
| **Encoding Normalizer** | You need to revert line-ending-only churn or restore a text file back to the encoding used in the previous commit. |

## Hooks

| Hook | Trigger | Behaviour |
|------|---------|-----------|
| `SessionStart` | At the start of every chat session | Reads `GIT_DIFF_DIR` and injects it into agent context when set. |
| `SubagentStart` | At the start of every sub-agent call | Same as `SessionStart`. |

## Components

```mermaid
graph TD
    A[git-manager plugin]
    A --> H[Hooks<br/>hooks/hooks.json]
    H --> S1[SessionStart → inject-git-diff-dir]
    H --> S2[SubagentStart → inject-git-diff-dir]
    A --> B[Git Merge Conflict Resolver<br/>skills/git-merge-conflict-resolver/SKILL.md]
    A --> C[Git Merge Auditor<br/>skills/git-merge-auditor/SKILL.md]
    A --> D[Git Worktree Manager<br/>skills/git-worktree-manager/SKILL.md]
    A --> E[Git PR Cloner<br/>skills/git-pr-cloner/SKILL.md]
    A --> F[Git Diff Generator<br/>skills/git-diff-generator/SKILL.md]
    A --> G[Encoding Normalizer<br/>skills/encoding-normalizer/SKILL.md]
```

### Git Merge Conflict Resolver

A structured workflow for resolving git merge conflicts. Guides through aborting a broken merge state, identifying conflicting files, resolving them, and completing the merge cleanly. Use this skill **only when a merge conflict is already present** — not for preventing conflicts before they occur.

### Git Merge Auditor

Audits whether a target branch fully contains all commits and changes from a source branch. Detects missing commits, unmerged file changes, and divergent history segments. Use this skill to verify merges, rebases, and cherry-picks — **not** to perform them.

### Git Worktree Manager

Manages the full lifecycle of Git worktrees: **Create**, **List**, **Move/Lock/Unlock**, and **Remove/Purge**. All worktrees are placed beside the repository root and follow the naming convention `<REPO>-worktree-<BRANCH>`.

### Git PR Cloner

Fetches a pull request from a remote Git repository into a local tracking branch for inspection, review, or testing. Supports GitHub/GitLab-style remotes and Bitbucket remotes. Does **not** merge the PR.

### Git Diff Generator

Generates a `.diff` file for several git workflows: whole-branch diffing from the current branch tip, pull requests, remote branches, commit ranges, single commits, the repository's first commit, and staged files. Uses three-dot semantics for branch-vs-branch comparisons, two-dot semantics for commit ranges and the first commit, `^!` for single-commit diffs, and `--cached` for staged files. Saves the diff to `GIT_DIFF_DIR` when available, otherwise to the current workspace root. Sanitizes all filename components and always fetches the target branch from the remote before branch-based diffing.

### Encoding Normalizer

Normalizes tracked text files when the diff is caused only by line-ending churn or mixed encodings. If the change is line-ending-only, it restores the file directly from Git. If the file has mixed encoding, it re-saves the file using the encoding from the previous committed version so Git history stays consistent.

## Author

[Dimpletz](https://github.com/dimpletz)
