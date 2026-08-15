---
name: update-okf
description: >
  Updates an existing OKF v0.2 concept document — changing frontmatter fields and/or body content.
  Use this skill whenever you need to modify a concept already present in an OKF bundle. Do NOT use
  it to create a new concept — use create-okf for that.
---

# Update OKF

Reads an existing OKF concept document, applies frontmatter and body changes, refreshes
`generated.at`, and writes the result back. All unknown frontmatter keys are preserved (§11).
`verified` is cleared when content-bearing fields change, since the previous verification no
longer covers the new content (§5.2). Appends an **Update** entry to `log.md` when found.

## Inputs

- **bundle_directory** (required unless `OKF_DEFAULT_BUNDLE_DIR` is in context): Absolute path to
  the OKF bundle root. When the `OKF_DEFAULT_BUNDLE_DIR` context variable is present (injected by
  the hook) it is used as the default; the user may still override it per invocation.
- **concept_path** (inferred when possible): Path to the concept file, relative to
  `bundle_directory` (e.g. `tables/customer-orders.md`). When not provided, the bundle is searched
  for a concept matching the user's description — see Inference Rules.
- **fields** (optional, inferred when possible): Frontmatter key-value pairs to add or overwrite.
  When the user describes a change in natural language (e.g. "mark as deprecated", "update the
  description to X"), translate the intent into the appropriate field changes — see Inference Rules.
- **body** (optional): Replacement body content. Replaces the entire existing body.
- **append_body** (optional): Markdown content to append (with a blank-line separator) to the
  existing body. Ignored when `body` is also supplied.
- **generated_by** (optional): Actor performing the update, in OKF actor convention (§7):
  `<producer>/<version>`, `human:<id>`, or `process:<id>`.

Apply Inference Rules before asking. Only ask when `bundle_directory` is absent
and `OKF_DEFAULT_BUNDLE_DIR` is not in context, or no bundle match is found.

## Inference Rules

Infer `concept_path` and the changes to apply from the user's description. Only ask when no
bundle match is found for the concept.

### concept_path lookup

When `concept_path` is not provided, search the bundle for a matching concept:

1. Scan all non-reserved `.md` files under `bundle_directory`.
2. Score each file: exact filename stem match > `title` substring match > `type` + name combo.
3. **Exactly one match** → use it automatically and note the resolved path.
4. **Multiple matches** → use the highest-scored match automatically and list alternatives in the output.
5. **No match** → ask the user to provide the explicit `concept_path`.

### fields inference

Translate natural language intent into frontmatter changes:

| User says | Inferred `fields` change |
|---|---|
| "mark as deprecated" / "deprecate it" | `status: deprecated` |
| "mark as draft" / "still in progress" | `status: draft` |
| "mark as stable" / "it's ready" | `status: stable` |
| "set stale after YYYY-MM-DD" | `stale_after: YYYY-MM-DD` |
| "update the description to X" | `description: X` |
| "add tag X" | append `X` to existing `tags` list |
| "remove tag X" | remove `X` from existing `tags` list |
| "update the title to X" | `title: X` |

## Task Priorities

1. **Priority 1 – Preserve unknown keys**: Never drop frontmatter keys not present in `fields`
   (§11). Touch only keys explicitly supplied or the standard `generated` fields.
2. **Priority 2 – Accurate timestamps**: Always set `generated.at` to the current system time in
   ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`).
3. **Priority 3 – Trust state on content change**: Remove the `verified` key when `type`, `title`,
   `description`, `resource`, or body content is meaningfully changed. Do not remove `verified` for
   metadata-only changes (`status`, `tags`, `stale_after`).
4. **Priority 4 – Conformance**: The updated file must still have a parseable frontmatter block with
   a non-empty `type` (§11). Reject any `fields` input that would set `type` to an empty string.
5. **Priority 5 – index.md and log.md coherence**: When `title` or `description` changes, sync
   the concept’s entry in the parent directory’s `index.md`. Always write to `log.md` at the
   bundle root, creating it if absent.

## Workflow

### Step 1 – Infer Inputs and Validate

**1A – Infer from the user's description**

1. If `concept_path` was not supplied, search the bundle using the concept_path lookup rules.
   Use the highest-scored match automatically; ask for an explicit path only when no match
   is found.
2. Infer `fields`, `body`, or `append_body` from the user's stated changes.
3. Proceed without asking.

**1B – Validate**

1. If `bundle_directory` is absent, check context for `OKF_DEFAULT_BUNDLE_DIR`. If neither is
   available, ask the user.
2. Verify both `bundle_directory` and the resolved concept file exist.
3. Confirm the file is not a reserved filename (`index.md`, `log.md`).

### Step 2 – Parse the Existing File

1. Read the file as UTF-8.
2. Split at the YAML frontmatter delimiters (`---`): extract frontmatter YAML and body.
3. Parse frontmatter into a key-value map; retain unknown keys as-is.

### Step 3 – Apply Changes

**Frontmatter:**

1. Merge supplied `fields` into the map, overwriting matched keys and adding new ones.
2. Set `generated.at` to the current system time in ISO 8601.
3. Set `generated.by` to `generated_by` when provided.
4. If any of `type`, `title`, `description`, or `resource` appears in the changed keys, or if `body`
   or `append_body` is supplied, remove the `verified` key entirely.

**Body:**

- If `body` is supplied, replace the existing body with it.
- Otherwise, if `append_body` is supplied, append it to the existing body separated by a blank
  line.
- If neither is supplied, leave the body unchanged.

### Step 4 – Write the Updated File

1. Serialize the merged frontmatter back to YAML, preserving key order where possible.
2. Compose the full file: `---\n<frontmatter>\n---\n<body>`.
3. Write as UTF-8, overwriting the original.
4. Confirm the write and report the resolved path.

### Step 5 – Sync index.md

If `title` or `description` was changed and `index.md` exists in the concept’s parent
directory, locate the bullet entry for this concept filename and update it in-place:

```
* [<new-title>](<filename>) - <new-description>
```

If the concept has no entry in `index.md` yet, append one.

### Step 6 – Write to log.md

Write to `log.md` at the bundle root (§9). If absent, create it first with the heading
`# Bundle Update Log`, then proceed with the date entry.

1. Determine today's date heading: `## YYYY-MM-DD`.
2. If the heading is absent, insert it above the previous date entries.
3. Append under the date heading:
   `* **Update**: Updated [<title or filename>](<bundle-relative path>).`

## Output Format

- Confirm the updated file path.
- List which frontmatter fields changed.
- Note if `verified` was cleared and which field change triggered it.
- Confirm `index.md` was synced (or note it was not present).
- Confirm `log.md` was updated or created.

## Assumptions and Limits

- `bundle_directory` must be a locally accessible file system path.
- Does not validate field values against OKF semantics beyond the `type` non-empty requirement.
- Does not re-generate body content — only accepts verbatim replacement or append strings.
- `verified` is cleared conservatively: only content-bearing field changes trigger it; pure
  metadata changes (`stale_after`, `status`, `tags`) do not.
- Assumes the system clock is correct when setting `generated.at`.
