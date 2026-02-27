---
name: git-merge-conflict-resolver
description: >
  This skill provides git merge support for resolving conflicts. Use this skill ONLY if the merge has conflict or if you are in the middle of a merge with conflict. Do NOT use this skill if the merge has no conflict. Do NOT attempt to resolve merge conflicts yourself - always use this skill instead. Indicators to use this skill include errors such as "error: Merging is not possible because you have unmerged files." or "fatal: Exiting because of an unresolved conflict."
---

# Git Merge Conflict Resolution Workflow

This workflow guides you through resolving merge conflicts that occur during a git merge operation.

## 1. Check and Reset Merge State

If you are already in the middle of a merge, abort it first to start fresh:

```bash
git status
```

If the output indicates you are in the middle of a merge (e.g., "You have unmerged paths" or "All conflicts fixed but you are still merging"), abort the current merge:

```bash
git merge --abort
```

Then initiate the merge again:

```bash
git merge <branch-name>
```

Replace `<branch-name>` with the actual branch you want to merge.

## 2. Identify Conflicted Files

After the merge command, identify which files have conflicts:

```bash
git status
```

Look for files marked as "both modified" or "unmerged paths". These are the files with conflicts that need resolution.

## 3. Understand Conflict Markers

Open each conflicted file and locate the conflict markers:

```
<<<<<<< HEAD
[Your current branch's code]
=======
[Incoming branch's code]
>>>>>>> branch-name
```

- `<<<<<<< HEAD`: Marks the beginning of your current branch's changes
- `=======`: Separates the two versions
- `>>>>>>> branch-name`: Marks the end of the incoming branch's changes

## 4. Analyze the Merge Base and Changes

Before resolving conflicts, understand what changed in both branches by examining the common ancestor (merge base):

### Find the Merge Base

Identify the common ancestor commit where both branches diverged:

```bash
git merge-base HEAD MERGE_HEAD
```

This returns the commit hash of the common ancestor.

### Examine Changes from Base

For each conflicted file, view what changed in each branch:

**View the base version (common ancestor):**
```bash
git show :1:<file-path>
```

**View the current branch's version:**
```bash
git show :2:<file-path>
```

**View the incoming branch's version:**
```bash
git show :3:<file-path>
```

**Compare changes using diff:**
```bash
# See what changed in your current branch from the base
git diff :1:<file-path> :2:<file-path>

# See what changed in the incoming branch from the base
git diff :1:<file-path> :3:<file-path>
```

### Analyze Both Updates

Compare the changes from both branches against the base to understand:

1. **What did the current branch change?** - Understand the intent and purpose of your branch's modifications
2. **What did the incoming branch change?** - Understand the intent and purpose of the incoming changes
3. **Are the changes addressing different concerns?** - If yes, both changes should likely be preserved
4. **Are the changes addressing the same concern differently?** - If yes, evaluate which approach is better or how to combine them
5. **Do any changes depend on other code?** - Check if either change relies on other modifications in its branch

## 5. Resolve Each Conflict

Based on your analysis, resolve each conflict using the most appropriate strategy:

### Strategy A: Keep Current Branch Version

Use when the incoming changes are obsolete, incorrect, or less appropriate:

```bash
git checkout --ours <file-path>
```

Or manually remove the conflict markers and the incoming branch's code.

### Strategy B: Accept Incoming Branch Version

Use when your current branch's changes are obsolete or the incoming changes supersede them:

```bash
git checkout --theirs <file-path>
```

Or manually remove the conflict markers and your current branch's code.

### Strategy C: Combine Both Versions (RECOMMENDED)

**This is the preferred approach to avoid losing important updates.** Manually merge changes from both branches:

1. **Identify independent changes**: Preserve changes that don't overlap
2. **Integrate dependent changes**: Ensure both sets of logic work together
3. **Preserve all important updates**: Include bug fixes, features, and improvements from both branches
4. **Maintain code quality**: Ensure the combined code follows consistent style and patterns

**Example of combining changes:**

```
Base version:
function calculate(x) {
    return x * 2;
}

Current branch (added validation):
function calculate(x) {
    if (x < 0) throw new Error("Negative not allowed");
    return x * 2;
}

Incoming branch (changed calculation):
function calculate(x) {
    return x * 3;
}

Combined resolution (preserves both updates):
function calculate(x) {
    if (x < 0) throw new Error("Negative not allowed");
    return x * 3;
}
```

### Strategy D: Refactor and Reconcile

When changes conflict in complex ways, write new code that:
- Achieves the goals of both branches
- Maintains or improves code quality
- Preserves all important functionality and fixes from both branches

## 6. Verify the Resolution

After resolving conflicts in each file:

1. **Remove all conflict markers**: Ensure no `<<<<<<<`, `=======`, or `>>>>>>>` markers remain
2. **Verify all important updates are preserved**: Review the resolution against both branch changes to confirm no critical updates were lost
3. **Test the code**: 
   - Check for syntax errors
   - Run tests if available
   - Build the project if applicable
4. **Review the changes**: Make sure the resolution makes logical sense and integrates both branches' intent

## 7. Stage the Resolved Files

Mark each resolved file as staged:

```bash
git add <resolved-file>
```

## 8. Verify All Conflicts Are Resolved

Check that all conflicts have been resolved:

```bash
git status
```

Ensure there are no files remaining in the "unmerged paths" section.

## 9. Complete the Merge

Once all conflicts are resolved and staged, commit with a message that includes the resolved files:

```bash
git commit -m "Merge branch 'branch-name' and resolve conflicts by an agent

Resolved files:
- file1.ext
- file2.ext
- file3.ext"
```

Replace `branch-name` with the actual name of the branch being merged, and list all the files that had conflicts and were resolved.

## 10. Abort the Merge (If Needed)

If you need to cancel the merge and start over:

```bash
git merge --abort
```

This will return your repository to the state before the merge was attempted. After aborting, you must:

1. Re-execute the merge command:
   ```bash
   git merge <branch-name>
   ```

2. Restart the conflict resolution process from **Step 1**

**IMPORTANT LIMITATION**: You can only abort and restart the merge process up to 3 times. After the 3rd restart attempt, you must give up on automated resolution and generate the output report using the Output Format structure below. Do not attempt to resolve conflicts further after 3 restarts.

## Best Practices

1. **Always check the merge base**: Examine the common ancestor to understand what changed in each branch
2. **Preserve all important updates**: Default to combining changes rather than choosing one version over another
3. **Understand the intent**: Analyze why each change was made before deciding how to resolve conflicts

## Common Pitfalls to Avoid

- **Losing important updates**: Blindly choosing one version without analyzing both changes
- **Ignoring the merge base**: Not understanding what changed in each branch from the common ancestor
- **Leaving conflict markers**: Forgetting to remove `<<<<<<<`, `=======`, or `>>>>>>>` markers
- **Deleting important code**: Accidentally removing critical updates from either branch
- **Limited understanding**: Resolving conflicts without understanding the intent of the changes
- **Premature staging**: Staging files before all conflicts are fully and correctly resolved
- **Incomplete analysis**: Not checking if changes in one branch depend on other changes in that branch

## Output format

Always respond using this structure:

```markdown
## Summary
- 2–5 bullets with the main outcome.

## List of Resolved Files
- List of files that had conflicts and were resolved.

## List of Unresolved Files
- List of files that still have conflicts after 3 resolution attempts (if any).

## Main Results
- Core findings, transformations, or answers.

## Recommendations
- Concrete next actions for the user.

## Limitations
- Assumptions and missing information that affect confidence.
```

