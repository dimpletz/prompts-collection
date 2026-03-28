---
name: pr-cloner
description: >
  Clones (fetches) a pull request from a remote Git repository into a local tracking branch. Supports both GitHub/GitLab-style remotes and Bitbucket remotes. Use this skill whenever the user wants to check out or fetch a PR/pull-request locally without merging it. Do NOT use this skill for creating, reviewing, or merging pull requests.
---

# PR Cloner

Fetches a pull request from a remote Git repository into a local branch so it can be inspected, reviewed, or tested locally without merging.

## Inputs

- **remote** (optional, default: `origin`): The remote name or URL of the repository (e.g. `origin`, `upstream`, or a full URL). If not provided, `origin` is used.
- **pr_number** (required): The pull request number to fetch (e.g. `42`).
- **platform** (optional): The hosting platform — `github` (default, also covers GitLab and other GitHub-compatible hosts) or `bitbucket`. If not provided, infer from the remote URL (presence of `bitbucket.org` → Bitbucket; otherwise → GitHub-style).

## Task Priorities

1. **Priority 1 – Correct fetch command**: Use the right ref path for the detected platform. Using the wrong ref path silently fetches nothing — this is the most common failure.
2. **Priority 2 – Safe local branch naming**: Always fetch into a branch named `PR<pr_number>` (e.g. `PR42`) to avoid polluting existing branches.
3. **Priority 3 – Clear user guidance**: After fetching, tell the user how to check out and use the branch.

## Workflow

### Step 1 – Determine the Platform

Examine the remote URL to detect the platform:

- If the remote URL contains `bitbucket.org` → use **Bitbucket** fetch syntax.
- Otherwise (GitHub, GitLab, Azure DevOps with GitHub-style PRs, etc.) → use **GitHub-style** fetch syntax.

If the platform cannot be determined from the URL, ask the user: _"Is this a Bitbucket repository or a GitHub/GitLab-compatible host?"_

### Step 2 – Verify Prerequisites

Before running any command, confirm:

1. The working directory is inside a Git repository (`git status` should not error).
2. If no remote is specified, default to `origin`. Verify the remote exists with `git remote get-url origin` (or the specified remote). If not, surface the error and stop — do not retry blindly.
3. A local branch named `PR<pr_number>` does not already exist. If it does, warn the user and offer to overwrite it by deleting it first (`git branch -D PR<pr_number>`), or to skip the fetch.

### Step 3 – Fetch the Pull Request

Run the appropriate command based on the detected platform:

**GitHub / GitLab / GitHub-compatible hosts:**
```bash
git fetch <remote> pull/<pr_number>/head:PR<pr_number>
```

**Bitbucket:**
```bash
git fetch <remote> pull-requests/<pr_number>/from:PR<pr_number>
```

Replace `<remote>` with the actual remote name or URL, and `<pr_number>` with the PR number.

**Examples:**

```bash
# GitHub – fetch PR #42 from origin
git fetch origin pull/42/head:PR42

# Bitbucket – fetch PR #42 from origin
git fetch origin pull-requests/42/from:PR42
```

### Step 4 – Check Out the Branch

After a successful fetch, check out the newly created local branch:

```bash
git checkout PR<pr_number>
```

### Step 5 – Confirm Success

After checkout, run:

```bash
git log -1 --oneline
```

Show the user the latest commit on the branch to confirm the correct PR was fetched.

## Common Pitfalls to Avoid

- **Wrong ref path for platform**: `pull/<n>/head` is GitHub-style; `pull-requests/<n>/from` is Bitbucket-style. Mixing them produces a silent no-op or an error.
- **Fetching into an existing branch**: Always use `PR<pr_number>` as the local branch name; if it exists, warn before overwriting.
- **Detached HEAD**: Always name the local branch in the fetch command (`:PR<pr_number>`) — do not fetch without a local ref, as that leaves no easy way to check out.
- **Using `%~2` / `%~3` syntax**: Those are Windows batch-script parameter expansions. When running commands directly in a shell (PowerShell, bash, cmd), substitute the actual remote and PR number values directly.

## Output Format

Always respond using this structure:

```markdown
## Summary
- What was fetched (remote, PR number, platform detected).
- Local branch created.
- Whether checkout succeeded.

## Commands Run
- The exact commands executed, in order.

## Result
- Confirmation of the latest commit on the checked-out branch, or a description of any errors encountered.

## Recommendations
- Suggested next steps (e.g. run tests, open a diff, create a review branch).

## Limitations
- Assumptions made (e.g. platform inferred from URL, remote is named `origin`).
- Any steps skipped due to errors.
```

## Assumptions and Known Limits

- Assumes the user has network access to the remote and appropriate read permissions.
- Bitbucket Server (self-hosted) uses the same `pull-requests/<n>/from` syntax but may require special authentication; credentials are out of scope for this skill.
- GitHub Enterprise uses the same `pull/<n>/head` syntax as GitHub.com.
- Does not handle forks where the PR head is in a different remote; in that case, the user must specify the fork's remote URL explicitly.
