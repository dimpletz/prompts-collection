---
name: changelog-maintainer
description: >
  Maintains a CHANGELOG.md file by inserting new version entries at the top in a consistent, structured format. Use it whenever a release, version bump, or notable set of changes needs to be documented. Do not use it for general documentation, README updates, or commit-message generation.
---

# Changelog Maintainer

This **skill** is for developers, release managers, and CI workflows that need to keep a `CHANGELOG.md` up-to-date as new versions are released. It ensures every entry follows a uniform structure, appears at the top of the file (most recent first), and covers the four standard buckets: **Added**, **Changed**, **Fixed**, and **Removed**.

## Inputs

- **version** (optional): The new version string to document (e.g. `1.4.2`, `2.0.0-rc.1`). If not supplied, the skill **must** auto-detect it from the project directory (see Step 1). Ask the user only if detection fails.
- **release_date** (optional): The date of the release in `YYYY-MM-DD` format. Defaults to the current date if not provided.
- **added** (optional): List of new features or capabilities introduced in this version. If not supplied, the skill **must** auto-detect it from git history and the staged index (see Step 2). Explicit values override auto-detection.
- **changed** (optional): List of modifications to existing behaviour, APIs, or configuration. If not supplied, the skill **must** auto-detect it from git history and the staged index (see Step 2). Explicit values override auto-detection.
- **fixed** (optional): List of bug fixes and defect resolutions. If not supplied, the skill **must** auto-detect it from git history and the staged index (see Step 2). Explicit values override auto-detection.
- **removed** (optional): List of features, capabilities, or components no longer present in this version. If not supplied, the skill **must** auto-detect it from git history and the staged index (see Step 2). Explicit values override auto-detection.
- **changelog_path** (optional): Relative path to the changelog file. Defaults to `CHANGELOG.md` at the repository root.

> If git history is unavailable, the staged index is empty, and none of **added**, **changed**, **fixed**, or **removed** could be determined, ask the user to provide the change details before proceeding.

## Task priorities

1. **Priority 1 – Structural integrity**
   The CHANGELOG.md must always be well-formed: correct heading hierarchy, newest entry at the top, at most one entry per version (update in-place if the version already exists).

2. **Priority 2 – Completeness of the new entry**
   Every supplied field must appear verbatim and correctly formatted. Never invent, summarise, or omit content the user provided.

3. **Priority 3 – Preservation of existing content**
   All previously recorded versions must remain untouched below the new entry. Never delete, reorder, or reformat existing entries.

## Workflow

1. **Step 1 – Detect version from project directory**
   - If **version** was not explicitly provided, scan the current project directory for a version source in this priority order:
     1. `package.json` → `version` field
     2. `pyproject.toml` → `[project] version` or `[tool.poetry] version`
     3. `pom.xml` → first `<version>` element that is a direct child of `<project>`
     4. `*.csproj` → `<Version>` or `<VersionPrefix>` element
     5. `composer.json` → `version` field
     6. `gradle.properties` or `build.gradle` → `version` property
   - Use the first match found. If multiple files are present, prefer the highest-priority source.
   - If no version can be detected, stop and ask the user to provide it before continuing.

2. **Step 2 – Detect changes from git history and staged index**
   - For each of **added**, **changed**, **fixed**, and **removed** that was not explicitly provided, derive its content from both the git commit log and the staged index:

   **2a – Collect committed changes**
     1. Find the most recent git tag: `git describe --tags --abbrev=0` (or `git tag --sort=-creatordate` and take the first). If no tag exists, use the very first commit as the baseline.
     2. Check whether there are any commits since that tag: `git log <last-tag>..HEAD --oneline`; if the output is empty, skip this sub-step silently.
     3. Run `git diff <last-tag>..HEAD` to obtain the full unified diff of all changes since the baseline.
     4. **Before analysis**, apply these file filters:
        - **Skip lock files**: `package-lock.json`, `package.lock`, `yarn.lock`, `composer.lock`, `Pipfile.lock`, `poetry.lock`, `Gemfile.lock`, `pnpm-lock.yaml`, and any file ending in `.lock`. Do not generate a changelog entry for these files.
        - **For binary files** (e.g. `*.jar`, `*.exe`, `*.dll`, `*.zip`, `*.war`, `*.class`, `*.png`, `*.jpg`, `*.gif`, `*.pdf`): skip diff content analysis. Record a single high-level entry — `Add <filename>`, `Replace <filename>`, or `Remove <filename>` — based on whether the file was added, replaced, or deleted.
     5. For each remaining file in the diff, analyse the added (`+`) and removed (`-`) lines to understand **what actually changed** inside the file. Write a **high-level, concise** description — one brief line per logical change (e.g. "Add OAuth2 login support", "Replace deprecated HTTP client", "Fix null pointer in login flow"). Do not enumerate individual method names, config keys, or code lines.
     6. Determine the section for each file using the following heuristic applied to the diff content:
        - File is entirely new (only added lines, no prior content): **Added**
        - File is entirely removed (deleted file, only removed lines): **Removed**
        - File introduces new public functions, classes, endpoints, or features not previously present: **Added**
        - File removes or replaces existing behaviour, updates logic, renames symbols, or fixes a defect detectable in the diff: **Changed** or **Fixed** as appropriate
     7. Deduplicate descriptions and discard entries that correspond solely to merge commits (identifiable by merge commit SHAs in `git log --merges <last-tag>..HEAD`).

   **2b – Collect staged index changes**
     1. Check whether there are any staged changes: `git diff --cached --quiet`; if the exit code is `0` (nothing staged), skip this sub-step silently.
     2. Run `git diff --cached` to obtain the full unified diff of all staged files.
     3. **Before analysis**, apply these file filters:
        - **Skip lock files**: `package-lock.json`, `package.lock`, `yarn.lock`, `composer.lock`, `Pipfile.lock`, `poetry.lock`, `Gemfile.lock`, `pnpm-lock.yaml`, and any file ending in `.lock`. Do not generate a changelog entry for these files.
        - **For binary files** (e.g. `*.jar`, `*.exe`, `*.dll`, `*.zip`, `*.war`, `*.class`, `*.png`, `*.jpg`, `*.gif`, `*.pdf`): skip diff content analysis. Record a single high-level entry — `Add <filename>`, `Replace <filename>`, or `Remove <filename>` — based on whether the file was added, replaced, or deleted.
     4. For each remaining file in the diff, analyse the added (`+`) and removed (`-`) lines to understand **what actually changed** inside the file. Write a **high-level, concise** description — one brief line per logical change (e.g. "Add OAuth2 login support", "Replace deprecated HTTP client", "Fix null pointer in login flow"). Do not enumerate individual method names, config keys, or code lines.
     5. Determine the section for each file using the following heuristic applied to the diff content:
        - File is entirely new (only added lines, no prior content): **Added**
        - File is entirely removed (deleted file, only removed lines): **Removed**
        - File introduces new public functions, classes, endpoints, or features not previously present: **Added**
        - File removes or replaces existing behaviour, updates logic, renames symbols, or fixes a defect detectable in the diff: **Changed** or **Fixed** as appropriate
     6. Deduplicate against entries already collected from the commit log to avoid repetition.

   **2c – Merge results**
     - Combine items from 2a and 2b into a single de-duplicated list per section (**Added**, **Changed**, **Fixed**, **Removed**). Items from the staged index (2b) are appended after committed-diff items (2a) within each section.

   - If a section was **explicitly provided** by the user, skip auto-detection for that section entirely (both 2a and 2b).
   - If `git` is not available or the directory is not a git repository, skip this step and proceed with only the explicitly supplied values. If none are supplied, ask the user.

3. **Step 3 – Validate inputs**
   - Confirm **version** is now known (detected or supplied).
   - Confirm **release_date** is set; default to today's date if not provided.
   - Confirm at least one of **added**, **changed**, **fixed**, or **removed** is non-empty after detection. If none are available, ask the user to provide the change details before proceeding.
   - If the changelog file already exists, check whether the same **version** is already recorded. If it is, mark it for **in-place update** (see Step 6) rather than stopping.

4. **Step 4 – Read existing changelog**
   - If `CHANGELOG.md` (or the supplied path) exists, read its full contents.
   - Identify the position immediately after the top-level `# Changelog` heading (line 1). The new entry will be inserted there.
   - If the file does not exist, create it with only the `# Changelog` heading, then append the new entry.

5. **Step 5 – Compose the new entry**
   - Use the exact template below. Omit any section (`### Added`, `### Changed`, `### Fixed`, `### Removed`) whose corresponding input is empty.
   - Each item in a section is a Markdown list item starting with `- `.

   ```markdown
   ## <version> - <release_date>

   ### Added
   - <item>

   ### Changed
   - <item>

   ### Fixed
   - <item>

   ### Removed
   - <item>
   ```

6. **Step 6 – Insert or update the entry**
   - **If the version does not yet exist** in the file:
     - Place the new entry directly after the `# Changelog` heading, separated by a single blank line.
     - Separate it from the first existing version entry with a single blank line.
   - **If the version already exists** in the file:
     - Locate the existing `## <version>` block (from its heading line down to, but not including, the next `## ` heading or end of file).
     - Replace that entire block in-place with the newly composed entry.
     - Do **not** change its position relative to other versions.
   - Do **not** modify any other content in the file.

7. **Step 7 – Write the file**
   - Save the updated content to the changelog path.
   - Confirm the file was written successfully.

8. **Step 8 – Summary**
   - Report the version recorded, the date, and which sections were populated.
   - Indicate whether the entry was **created** (new version), **updated** (existing version replaced), or whether a new `CHANGELOG.md` was created from scratch.

## Output format

After completing all steps, respond with:

```markdown
## Summary
- Version recorded and its release date.
- Sections populated (Added / Changed / Fixed / Removed).
- Whether the entry was inserted (new version), updated in-place (existing version), or the file was created from scratch.

## Main Results
The updated (or newly created) CHANGELOG.md content, shown in full.

## Recommendations
- Next actions (e.g. commit the file, tag the release, open a PR).
- Reminders about keeping the changelog in sync with version tags.

## Limitations
- Assumptions made (e.g. version format, date source).
- Edge cases not handled (e.g. pre-release metadata, yanked releases).
```

## Example

**Input**

- `version`: `1.2.0`
- `release_date`: `2026-02-28`
- `added`: `["Support for dark mode", "CSV export for reports"]`
- `changed`: `["Improved load time for dashboard"]`
- `fixed`: `["Resolved crash on empty search query"]`

**Expected CHANGELOG.md output** (excerpt)

```markdown
# Changelog

## 1.2.0 - 2026-02-28

### Added
- Support for dark mode
- CSV export for reports

### Changed
- Improved load time for dashboard

### Fixed
- Resolved crash on empty search query

## 1.1.0 - 2026-01-10

### Fixed
- Minor UI alignment issues
```

## Assumptions and known limits

- **Assumes** the file uses `# Changelog` as its sole H1 heading; a non-standard header may cause incorrect insertion.
- **Assumes** version strings are matched by exact string comparison; partial or fuzzy matches are not supported.
- **Assumes** the version field in the detected project file reflects the version being released (i.e. it has already been bumped before the skill is invoked).
- **Assumes** commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) format for reference, but change descriptions are derived from the actual diff content of committed (`git diff <last-tag>..HEAD`) and staged (`git diff --cached`) files. Section classification is based on what was added, modified, or removed in the diff rather than on commit message prefixes.
- **Assumes** staged file paths reflect the intended change intent; descriptions are derived from the actual diff content (`git diff --cached`) of each staged file, not from file names or status codes.
- **Does not** handle "Yanked" releases or the `[UNRELEASED]` pattern from Keep a Changelog without extension.
- **Does not** support monorepos with multiple versioned packages automatically; for those, supply **version** and **changelog_path** explicitly.
- **Does not** analyse ASTs; change detection for both committed and staged changes reads unified diff output (`git diff <last-tag>..HEAD` and `git diff --cached`) and derives human-readable descriptions from the actual line-level changes.

### Validation checks

1. Run the skill on a repository with an existing multi-version `CHANGELOG.md` and verify all previous entries are preserved unchanged below the new one.
2. Run it with only a **fixed** input and confirm only the `### Fixed` section appears (no empty `### Added` or `### Changed` headings).
3. Run it twice with the same version and confirm the second run updates the existing entry in-place without adding a duplicate or changing any other entries.
4. Run it without supplying a **version** in a project that has a recognisable manifest file (e.g. `package.json`, `pyproject.toml`, `pom.xml`, `*.csproj`, `composer.json`, `build.gradle`) and confirm the version is read from that file automatically.
5. Run it in a directory with no recognisable project file and confirm the skill stops and prompts for a version rather than proceeding silently.
6. Run it on a repo with commits since the last tag and confirm descriptions are derived from the actual diff content — not from commit message prefixes — and classified correctly into **Added**, **Changed**, **Fixed**, and **Removed**.
7. Run it on a repo with no git tags and confirm it falls back to using the first commit as the baseline.
8. Explicitly supply an **added** list and confirm that section is taken verbatim while **changed** and **fixed** are still auto-detected from the committed and staged diffs.
9. Stage a new file, a modified file, and a deleted file without committing, then run the skill and confirm the staged entries are described from the actual diff content and placed in the correct sections.
10. Stage changes that overlap with already-committed diffs and confirm the final output contains no duplicate entries.
11. Commit a change that includes a lock file (e.g. `package-lock.json`) alongside source changes and confirm no lock-file entry appears in the changelog.
12. Commit or stage a binary file (e.g. `app.jar`) that is new, replaced, or deleted, and confirm the entry reads `Add app.jar`, `Replace app.jar`, or `Remove app.jar` respectively, with no diff analysis.
