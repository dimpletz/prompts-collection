---
name: delete-okf
description: >
  Deprecates or removes an OKF concept document from a bundle. Use this skill whenever a concept
  should be marked as no longer current or permanently deleted. The default mode is deprecate
  (non-destructive). Use remove only when the file must be physically deleted. Do NOT use this
  skill to update a concept's content — use update-okf for that.
---

# Delete OKF

Marks an OKF concept as deprecated or removes it from the bundle entirely. The default `deprecate`
mode sets `status: deprecated` in the frontmatter and preserves the file for historical links
(§5.4). The `remove` mode deletes the file after user confirmation and cleans up any reference to
it in the parent `index.md`. Both modes append an entry to `log.md`.

## Inputs

- **bundle_directory** (required unless resolvable from context): Absolute path to the OKF bundle
  root. Resolution priority: (1) user-provided absolute path; (2) user-provided name or relative
  path joined with `OKF_DEFAULT_DIR` from context (`OKF_DEFAULT_DIR/<provided>`) — sibling
  directories under `OKF_DEFAULT_DIR` are never modified; (3) `OKF_DEFAULT_BUNDLE_DIR` from
  context as the default bundle. The user may still override any default per invocation.
- **concept_path** (inferred when possible): Path to the concept file, relative to
  `bundle_directory` (e.g. `tables/customer-orders.md`). When not provided, the bundle is searched
  for a concept matching the user's description — see Inference Rules.
- **mode** (inferred, default `deprecate`): `deprecate` — set `status: deprecated` and keep the
  file; `remove` — physically delete the file. Inferred from the user's wording — see Inference
  Rules.
- **reason** (optional): Brief note explaining the deprecation or deletion. Appended to the body
  in `deprecate` mode; recorded in `log.md` in both modes.

Apply Inference Rules before asking. Only ask when `bundle_directory` cannot be resolved — no
path, no name + `OKF_DEFAULT_DIR`, and no `OKF_DEFAULT_BUNDLE_DIR` in context — or no bundle
match is found for the concept.

## Inference Rules

Infer both `mode` and `concept_path` from the user's description. Only ask when no bundle
match is found for the concept.

### mode

| User wording | Inferred `mode` |
|---|---|
| "remove", "delete", "wipe", "permanently delete" | `remove` |
| "deprecate", "archive", "retire", "mark as old" | `deprecate` |
| (default when unclear) | `deprecate` |

### concept_path lookup

When `concept_path` is not provided, search the bundle:

1. Scan all non-reserved `.md` files under `bundle_directory`.
2. Score each file: exact filename stem match > `title` substring match > `type` + name combo.
3. **Exactly one match** → use it automatically and note the resolved path.
4. **Multiple matches** → use the highest-scored match automatically and list alternatives in the output.
5. **No match** → ask the user to provide the explicit `concept_path`.

## Task Priorities

1. **Priority 1 – Non-destructive default**: Default mode is `deprecate`. Never delete a file
   unless `mode: remove` is explicitly requested or inferred.
2. **Priority 2 – No reserved filename operations**: `concept_path` must not resolve to `index.md`
   or `log.md`. Abort immediately if it does.
3. **Priority 3 – Report before remove**: State the full path being deleted before proceeding.
4. **Priority 4 – index.md cleanup on remove**: After deleting a file, scan the parent `index.md`
   for any bullet linking to the removed file and remove that line.
5. **Priority 5 – Log coherence**: Append a **Deprecation** or **Deletion** entry to `log.md` in
   both modes.
6. **Priority 6 – Inbound link awareness**: Scan the bundle for concepts that link to the target
   concept. In `deprecate` mode, list them in the output (links remain valid; §5.4). In `remove`
   mode, update each linking concept to remove the now-broken link.

## Workflow

### Step 1 – Infer Inputs and Validate

**1A – Infer from the user's description**

1. Infer `mode` from the user's wording (Inference Rules).
2. If `concept_path` was not supplied, search the bundle using the concept_path lookup rules.
   Use the highest-scored match automatically; ask for an explicit path only when none match.
3. Proceed without asking.

**1B – Validate**

1. Resolve `bundle_directory` in priority order:
   a. User-provided absolute path → use as-is.
   b. User-provided name or relative path + `OKF_DEFAULT_DIR` in context →
      `OKF_DEFAULT_DIR/<provided>`. Do not modify sibling directories under `OKF_DEFAULT_DIR`.
   c. No path provided + `OKF_DEFAULT_BUNDLE_DIR` in context → use `OKF_DEFAULT_BUNDLE_DIR`.
   d. None of the above → ask the user.
2. Verify both `bundle_directory` and the resolved concept file exist.
3. Confirm the resolved filename is not `index.md` or `log.md`. Abort if it is.
4. If `mode` could not be inferred, default to `deprecate`.

**1C – Bundle scan for inbound links**

Scan all non-reserved `.md` files in `bundle_directory`, excluding the target concept. For each
file, check whether its body contains a markdown link whose target resolves to the target
concept's bundle-relative path (match both the literal bundle-relative form and any relative-path
variants that point to the same file). Collect the list of **inbound concepts** — those whose
body links point to the concept being deprecated or removed.

### Step 2A – Deprecate Mode

1. Read the file as UTF-8 and parse frontmatter.
2. Set `status: deprecated` in the frontmatter.
3. Update `generated.at` to the current system time in ISO 8601.
4. If `reason` is provided, append a deprecation note to the body with a blank-line separator:
   ```
   > **Deprecated**: <reason>
   ```
5. Write the updated file as UTF-8 (overwrite in place).
6. Confirm the update and report the path.
7. List all inbound concepts from Step 1C in the output with their paths and titles. Do NOT
   modify them — links to a deprecated concept remain valid (§5.4); this is informational only.

Skip to Step 3.

### Step 2B – Remove Mode

1. State the full resolved path being deleted.
2. Delete the file.
3. If `index.md` exists in the same directory, read it and remove every bullet entry that links
   to the deleted filename (any line containing the filename in a markdown link). Write the
   updated `index.md`.
4. For each inbound concept from Step 1C:
   a. Read the concept file.
   b. Replace every markdown link whose target resolves to the deleted concept with its link text
      only — strip the link syntax but preserve the visible text. For example,
      `[Customer Orders](/tables/customer-orders.md)` → `Customer Orders`.
   c. Write the updated concept as UTF-8.
   d. Append an **Update** bullet to the same `log.md` date entry (Step 3):
      `* **Update**: Removed broken link to deleted concept in [<title>](<path>).`
5. Report the deleted path, `index.md` changes, and all inbound concepts updated.

### Step 3 – Write to log.md

Write to `log.md` at the bundle root (§9). If absent, create it first with the heading
`# Bundle Update Log`, then proceed with the date entry.

1. Determine today's date heading: `## YYYY-MM-DD`.
2. If the heading is absent, insert it above the previous date entries.
3. Append under the date heading, using `<reason_suffix>` = ` Reason: <reason>.` when a reason
   was provided, or empty otherwise:
   - Deprecate mode: `* **Deprecation**: Deprecated [<title or filename>](<bundle-relative path>).<reason_suffix>`
   - Remove mode: `* **Deletion**: Deleted [<title or filename>](<bundle-relative path>).<reason_suffix>`

## Output Format

- Confirm mode executed (`deprecated` or `deleted`) with the concept path and title.
- In deprecate mode, list all inbound concepts that link to the deprecated concept (informational;
  no modifications made).
- In remove mode, confirm `index.md` was cleaned up or note it was not present.
- In remove mode, list all inbound concepts updated to remove the broken link (Step 2B.4).
- Confirm `log.md` was updated or created.

## Assumptions and Limits

- `bundle_directory` must be a locally accessible file system path.
- Deprecate mode lists inbound links for awareness but does not modify them — deprecated
  concepts remain accessible at their path (§5.4).
- Remove mode scans and updates all inbound concept links but does not recurse into the
  newly-modified concepts to check their own links.
- `log.md` entries are append-only; existing entries are never modified.
