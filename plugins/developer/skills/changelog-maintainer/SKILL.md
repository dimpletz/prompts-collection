---
name: changelog-maintainer
description: >
  Maintains a CHANGELOG.md file by inserting new version entries at the top in a consistent, structured format. Use it whenever a release, version bump, or notable set of changes needs to be documented. Do not use it for general documentation, README updates, or commit-message generation.
---

# Changelog Maintainer

This **skill** is for developers, release managers, and CI workflows that need to keep a `CHANGELOG.md` up-to-date as new versions are released. It ensures every entry follows a uniform structure, appears at the top of the file (most recent first), and covers the three standard buckets: **Added**, **Changed**, and **Fixed**.

## Inputs

- **version** (optional): The new version string to document (e.g. `1.4.2`, `2.0.0-rc.1`). If not supplied, the skill **must** auto-detect it from the project directory (see Step 1). Ask the user only if detection fails.
- **release_date** (optional): The date of the release in `YYYY-MM-DD` format. Defaults to the current date if not provided.
- **added** (optional): List of new features or capabilities introduced in this version. If not supplied, the skill **must** auto-detect it from git history (see Step 2). Explicit values override auto-detection.
- **changed** (optional): List of modifications to existing behaviour, APIs, or configuration. If not supplied, the skill **must** auto-detect it from git history (see Step 2). Explicit values override auto-detection.
- **fixed** (optional): List of bug fixes and defect resolutions. If not supplied, the skill **must** auto-detect it from git history (see Step 2). Explicit values override auto-detection.
- **changelog_path** (optional): Relative path to the changelog file. Defaults to `CHANGELOG.md` at the repository root.

> If git history is unavailable and none of **added**, **changed**, or **fixed** could be determined, ask the user to provide the change details before proceeding.

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

2. **Step 2 – Detect changes from git history**
   - For each of **added**, **changed**, and **fixed** that was not explicitly provided, derive its content from the git commit log:
     1. Find the most recent git tag: `git describe --tags --abbrev=0` (or `git tag --sort=-creatordate` and take the first). If no tag exists, use the very first commit as the baseline.
     2. Collect all commits since that tag up to `HEAD`: `git log <last-tag>..HEAD --pretty=format:"%s"`.
     3. Classify each commit message using **Conventional Commits** prefixes:
        | Prefix | Section |
        |---|---|
        | `feat:` / `feat(<scope>):` | **Added** |
        | `fix:` / `fix(<scope>):` | **Fixed** |
        | `refactor:` / `perf:` / `style:` / `chore:` / `build:` / `ci:` / `docs:` | **Changed** |
     4. Strip the prefix and scope from each message to produce a clean description (e.g. `feat(auth): add OAuth2 login` → `Add OAuth2 login`).
     5. Deduplicate messages and discard merge commits (messages starting with `Merge `).
   - If a section was **explicitly provided** by the user, skip auto-detection for that section entirely.
   - If `git` is not available or the directory is not a git repository, skip this step and proceed with only the explicitly supplied values. If none are supplied, ask the user.
   - If commits exist but none match a conventional prefix, place all commit messages into **Changed** as a fallback.

3. **Step 3 – Validate inputs**
   - Confirm **version** is now known (detected or supplied).
   - Confirm **release_date** is set; default to today's date if not provided.
   - Confirm at least one of **added**, **changed**, or **fixed** is non-empty after detection. If none are available, ask the user to provide the change details before proceeding.
   - If the changelog file already exists, check whether the same **version** is already recorded. If it is, mark it for **in-place update** (see Step 6) rather than stopping.

4. **Step 4 – Read existing changelog**
   - If `CHANGELOG.md` (or the supplied path) exists, read its full contents.
   - Identify the position immediately after the top-level `# Changelog` heading (line 1). The new entry will be inserted there.
   - If the file does not exist, create it with only the `# Changelog` heading, then append the new entry.

5. **Step 5 – Compose the new entry**
   - Use the exact template below. Omit any section (`### Added`, `### Changed`, `### Fixed`) whose corresponding input is empty.
   - Each item in a section is a Markdown list item starting with `- `.

   ```markdown
   ## <version> - <release_date>

   ### Added
   - <item>

   ### Changed
   - <item>

   ### Fixed
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
- Sections populated (Added / Changed / Fixed).
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
- **Assumes** commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) for accurate classification into Added / Changed / Fixed. Non-conventional messages are placed in **Changed** as a fallback.
- **Does not** handle "Yanked" releases or the `[UNRELEASED]` pattern from Keep a Changelog without extension.
- **Does not** support monorepos with multiple versioned packages automatically; for those, supply **version** and **changelog_path** explicitly.
- **Does not** analyse file diffs or ASTs; change detection is solely based on git commit messages.

### Validation checks

1. Run the skill on a repository with an existing multi-version `CHANGELOG.md` and verify all previous entries are preserved unchanged below the new one.
2. Run it with only a **fixed** input and confirm only the `### Fixed` section appears (no empty `### Added` or `### Changed` headings).
3. Run it twice with the same version and confirm the second run updates the existing entry in-place without adding a duplicate or changing any other entries.
4. Run it without supplying a **version** in a project that has a recognisable manifest file (e.g. `package.json`, `pyproject.toml`, `pom.xml`, `*.csproj`, `composer.json`, `build.gradle`) and confirm the version is read from that file automatically.
5. Run it in a directory with no recognisable project file and confirm the skill stops and prompts for a version rather than proceeding silently.
6. Run it on a repo whose commits since the last tag use conventional prefixes and confirm messages are correctly classified into **Added**, **Changed**, and **Fixed**.
7. Run it on a repo with no git tags and confirm it falls back to using the first commit as the baseline.
8. Explicitly supply an **added** list and confirm that section is taken verbatim while **changed** and **fixed** are still auto-detected from git.
