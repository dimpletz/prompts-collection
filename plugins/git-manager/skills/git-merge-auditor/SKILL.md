---
name: git-merge-auditor
description: >
  Audits whether a target branch contains all commits and changes from a source branch. Use this skill whenever you want to verify that a merge, rebase, or cherry-pick operation did not miss any updates — before or after merging. Do NOT use this skill to perform the merge itself; for that, use the git-merge-conflict-resolver skill.
---

# Git Merge Auditor

This **skill** is for developers, tech leads, and CI reviewers who need to confirm that a target branch is fully up-to-date with a source branch. It detects missing commits, unmerged file changes, and divergent history segments so that nothing is silently dropped during integration workflows.

## Inputs

- **source_branch** (required): The branch whose changes must be present in the target branch (e.g. `main`, `develop`, `hotfix/1.2.3`).
- **target_branch** (required): The branch being audited — the branch that is expected to contain all changes from the source (e.g. `release/2.0`, `feature/payment`).
- **remote** (optional): The remote name to fetch from before auditing (e.g. `origin`). Defaults to `origin`. If not applicable (local-only repo), the fetch step is skipped.
- **ignore_merge_commits** (optional): Whether to exclude merge commits from the missing-commit list. Defaults to `true`, because merge commits are not cherry-pickable and their absence is usually expected.

## Task priorities

1. **Priority 1 – Completeness of detection**
   Every commit and file change present in the source branch but absent from the target branch must be identified. False negatives (missed divergences) are worse than false positives.

2. **Priority 2 – Clarity of reporting**
   Results must be concise and actionable: exact commit hashes, messages, and affected files. The developer must be able to act on the report without further investigation.

3. **Priority 3 – Safety**
   This skill is read-only. It must never modify any branch, commit, or working tree. No `git merge`, `git rebase`, `git reset`, or `git push` commands are executed.

## Workflow

### Step 1 – Fetch latest remote state

Ensure local refs are up to date before comparing:

```bash
git fetch <remote>
```

If the repository is local-only (no remote configured) or **remote** was explicitly set to `none`, skip this step.

Verify that both branches exist:

```bash
git rev-parse --verify <source_branch>
git rev-parse --verify <target_branch>
```

If either branch does not exist, stop and report the error to the user.

### Step 2 – Identify the merge base

Find the common ancestor commit of both branches:

```bash
git merge-base <target_branch> <source_branch>
```

Record this as `<merge_base>`. All comparisons are relative to this point.

### Step 3 – List commits in source branch not in target branch

Enumerate commits that exist in **source_branch** but are not reachable from **target_branch**:

```bash
git log <target_branch>..<source_branch> --oneline --no-merges
```

If **ignore_merge_commits** is `false`, also include merge commits:

```bash
git log <target_branch>..<source_branch> --oneline
```

Record the full list as **missing commits**. If the list is empty, proceed to Step 4 to confirm at the file level before declaring the audit clean.

### Step 4 – Check for unmerged file differences

Even when all commits appear present (e.g. after a squash merge), individual file content may differ. Compare the diff between the merge base and the tip of each branch:

```bash
# Changes introduced by source_branch since the merge base
git diff <merge_base>..<source_branch> --name-status

# Changes introduced by target_branch since the merge base
git diff <merge_base>..<target_branch> --name-status
```

Identify files that were modified in **source_branch** but whose changes are not reflected in **target_branch** by comparing the two diff outputs. Any file path that appears in the source diff but is absent from or has a different final state in the target diff is flagged as a **divergent file**.

For each flagged file, produce a focused diff to show what is missing:

```bash
git diff <target_branch>..<source_branch> -- <file-path>
```

### Step 5 – Detect cherry-pick equivalence (optional refinement)

When commits are missing by hash (Step 3) but the target branch may have applied equivalent changes via cherry-pick or rebase, check whether the patch content is already present:

```bash
git log <target_branch> --oneline --grep="<commit-subject>"
```

For each commit in the missing list whose subject is found in the target history, mark it as **possibly included (different hash)**. These are lower-severity findings that still warrant manual review.

### Step 6 – Compile and present the audit report

Produce a structured Markdown report using the format defined in **Output format**. Always include the report regardless of whether findings exist.

## Output format

Always respond using this structure:

```markdown
## Git Merge Audit Report

**Source branch:** `<source_branch>`
**Target branch:** `<target_branch>`
**Merge base:** `<merge_base_hash>`
**Audit date:** <YYYY-MM-DD>

---

### Summary

| Check | Result |
|---|---|
| Missing commits | <count or "None"> |
| Divergent files | <count or "None"> |
| Possibly included (different hash) | <count or "None"> |
| **Overall status** | ✅ Clean / ⚠️ Needs Review / ❌ Missing Changes |

---

### Missing Commits

> Commits present in `<source_branch>` but not reachable from `<target_branch>`.

| Hash | Message | Author | Date |
|---|---|---|---|
| `<hash>` | <message> | <author> | <date> |

_None_ — if no missing commits.

---

### Divergent Files

> Files changed in `<source_branch>` whose changes are not fully present in `<target_branch>`.

| File | Status in Source | Notes |
|---|---|---|
| `<file-path>` | Added / Modified / Deleted | <optional note> |

For each divergent file, include the focused diff:

\`\`\`diff
<output of git diff <target_branch>..<source_branch> -- <file-path>>
\`\`\`

_None_ — if no divergent files.

---

### Possibly Included (Different Hash)

> Source commits not present by hash, but whose subject line was found in target history. Manual review recommended.

| Source Hash | Source Message | Matching Target Commit |
|---|---|---|
| `<hash>` | <message> | `<target_hash>` |

_None_ — if no such commits.

---

### Recommendations

- List concrete next actions (e.g. "Cherry-pick commit `abc1234` into `<target_branch>`", "Review divergence in `src/payments/processor.ts`").
- If the audit is clean, state: "No action required. `<target_branch>` contains all changes from `<source_branch>`."
```

## Assumptions and known limits

- **Assumes** both branches are accessible in the local repository (after the optional fetch step). Branches on forks not configured as remotes are out of scope.
- **Assumes** a linear or standard merge-based history. Orphan branches or `--orphan` histories may produce misleading merge-base results.
- **Does not** account for reverted commits — a commit that was applied and then reverted in the target branch will appear as missing even though its net effect is zero. Flag these for manual review.
- **Does not** perform the merge or any write operation. It is strictly diagnostic.
- **Cherry-pick equivalence** (Step 5) is a best-effort heuristic based on commit subject line matching. It may produce false positives when two unrelated commits share the same summary.

## Validation

1. Create a test scenario: branch `feature` off `main`, add two commits to `feature`, merge only one into `target`. Run the audit and confirm exactly one commit and its associated file appear in the report.
2. Run the audit on a branch that is fully merged; confirm the report shows "✅ Clean" with zero missing commits and zero divergent files.
3. Test squash-merge detection: squash-merge `feature` into `target`, then run the audit. Confirm missing commits are flagged but the divergent-files section shows "None" (since content was applied).
