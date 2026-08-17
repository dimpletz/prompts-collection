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

### Decomposition check

When reviewing the concept being updated, assess whether it mixes concerns that should be split:

- If the concept body contains **procedural content** (numbered steps, how-to, runbook) alongside
  non-procedural content, suggest extracting the procedure into a separate `Playbook` concept and
  linking to it. Ask the user before splitting an existing concept.
- If the concept contains an inline computation that could be independently attested, suggest
  extracting it into a separate `Attested Computation` concept and linking to it.
- When the user's requested update would introduce mixed concerns (e.g. adding steps to a
  `Metric`), apply extraction automatically consistent with create-okf Decomposition rules, unless
  the user instructs otherwise.

## Linking Rules

Every concept MUST be self-contained: all cross-links in the body MUST target other concepts
inside the bundle. External URLs MUST NOT appear as inline body link targets.

### Body links (§6.1)

Use **bundle-relative paths** (begin with `/`, resolved from the bundle root — recommended) or
**relative paths** (e.g. `../tables/orders.md`). Never use an `http://` or `https://` URL as a
markdown link target in the body.

### External material (§5.1)

External sources belong in `sources` frontmatter entries, each with:

- `resource`: the absolute URL of the external material
- `id`: a stable key for per-claim attribution
- `title`: human-readable label (optional but recommended)

Cite an external source in the body with a markdown footnote keyed to the `id` (`[^<id>]`),
not with an inline URL link. Append a matching footnote definition at the end of the body
(`[^<id>]: <title>`).

### Frontmatter exceptions

- `resource` (the concept's canonical asset URI) MAY be an external URL — it identifies the
  underlying asset, not a body cross-link.
- `sources[].resource` MAY be an external URL — it records external provenance.

### Reference concept materialization (§6.3)

When an external document has been read and its content is available (e.g. fetched during this
session), assess whether it warrants a standalone `Reference` concept in the bundle's
`references/` subdirectory before updating the current concept:

- **Create a reference concept** when the content is substantive, reusable, or likely to be
  linked by more than one concept in the bundle. Apply create-okf logic to write it as
  `references/<slug>.md` with `type: Reference`.
- **Link to it** from the current concept's body using a bundle-relative path
  (e.g. `/references/my-source.md`), not the original external URL.
- **Record the original URL** in the new reference concept's `resource` frontmatter field and in
  the current concept's `sources[].resource` for provenance.
- When the external content is trivial or already captured by an existing bundle concept, skip
  materialization and use a `sources` entry + footnote instead.

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
6. **Priority 6 – Bundle cross-linking**: Scan the bundle for concepts related to the one being
   updated. Ensure the updated concept links to related existing concepts. After update, check
   whether related concepts need back-links (Step 7).
7. **Priority 7 – Full detail, no summarizing**: Write or append body content as completely and
   thoroughly as possible. Never shorten, abbreviate, or summarize content to save space. If the
   update warrants multiple sections, examples, or explanations, include them all in full.
8. **Priority 8 – Exhaust all concepts from a source**: When a file, document, or list is
   provided as input, identify and update EVERY concept in it — never stop after a partial subset.
   Build the complete concept list before modifying any file, then run Steps 2–7 for each concept
   in sequence.
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

**1C – Bundle scan for related concepts**

Scan all non-reserved `.md` files in `bundle_directory`, excluding the concept being updated. For
each existing concept, score its relevance using title/description keyword overlap, type proximity,
and tag intersection. For each concept with meaningful relevance:

1. Note its bundle-relative path, title, and relationship direction:
   - **Outbound** (updated concept should link to it): the existing concept defines something the
     updated concept depends on, references, or is an instance of — and the link is currently absent.
   - **Back-link** (existing concept should link to updated): the existing concept relates to the
     updated concept but lacks a link to it.
2. Keep the scored list for use in Step 3 (outbound links) and Step 7 (back-links).

**1D – Source file exhaustive extraction**

When the user provides a file, document, specification, or list as the source of concepts to
update:

1. Read the entire source exhaustively — scan every section, table, row, and entry without
   stopping early.
2. Identify ALL concepts it contains that require an update.
3. Build a complete ordered list of all N concepts before modifying any file.
4. Do not skip, defer, or approximate any concept in the list.
5. Process each concept in sequence through Steps 2–7. The task is NOT complete until every
   concept in the list has been updated. Proceed through the full list without pausing for
   confirmation unless `bundle_directory` is missing.

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

**Link processing**: After applying body changes, scan all markdown links in the new or appended
content. For each link whose target is an external URL (`http://` or `https://`):

1. If the URL's content was read during this session → apply the Reference concept
   materialization rule (Linking Rules). Create the reference concept first (type: `Reference`,
   path: `references/<slug>.md`), replace the body link with the bundle-relative path, and record
   the original URL in the reference concept's `resource` and in the current concept's
   `sources[].resource`.
2. If the URL's content is not available → move the URL to a new `sources` entry with a
   generated `id` and the link text as `title`. Replace the inline link with `[^<id>]`. Append
   `[^<id>]: <title>` at the end of the body. Merge the new entry into the frontmatter `sources`
   block (create the block if absent; treat the `sources` change as a content change for the
   purpose of clearing `verified` per Priority 3).

**Related concept links**: Using the outbound concepts from Step 1C not already linked in the
body, add bundle-relative cross-links where contextually natural. Integrate links into existing
prose or append a `# Related` section. Only link concepts with clear subject overlap or dependency.

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
**Description quality rule**: The description field in every bullet entry MUST be a clear,
complete, human-readable sentence. Never leave it empty, use a placeholder like "TODO" or
"Overview", or truncate it. If the existing entry has a weak description, rewrite it as part
of this step.
### Step 6 – Write to log.md

Write to `log.md` at the bundle root (§9). If absent, create it first with the heading
`# Bundle Update Log`, then proceed with the date entry.

1. Determine today's date heading: `## YYYY-MM-DD`.
2. If the heading is absent, insert it above the previous date entries.
3. Append under the date heading:
   `* **Update**: Updated [<title or filename>](<bundle-relative path>).`

### Step 7 – Update back-linked concepts

For each existing concept flagged for back-linking in Step 1C:

1. Read the existing concept file.
2. Confirm that adding a link to the updated concept genuinely improves it (avoid redundant or
   forced links).
3. If yes: apply update-okf logic — append or insert the bundle-relative link into the existing
   concept's body. Append an additional **Update** bullet to the same `log.md` date entry.
4. Do not trigger back-link updates recursively.

Report all back-linked concepts in the output summary.

### Step 8 – Completion Verification

After all concepts have been updated, perform a final integrity check across the entire bundle.

1. **Concept roster check**: Confirm that every concept identified in Step 1D has been updated.
   List any that were skipped and process them before reporting completion.

2. **Cross-reference validation**: For every bundle-relative link found in any updated concept
   body, confirm the target file exists in the bundle. Report any broken links and attempt to
   resolve them by correcting the path or flagging the missing concept for creation.

3. **index.md completeness**: For each `index.md` in the bundle:
   - Every `.md` file in the same directory (excluding `index.md` and `log.md`) has a bullet entry.
   - Every subdirectory has a subdirectory bullet linking to its `index.md`.
   - Every bullet entry has a non-empty, human-readable description (no placeholders).
   Add missing entries and fix empty or placeholder descriptions before reporting completion.

4. **Report**: Summarise the verification outcome — concepts confirmed updated, broken links
   found/fixed, and `index.md` gaps filled. If any item could not be resolved, list it explicitly
   for the user.

## Output Format

- Confirm the updated file path.
- List which frontmatter fields changed.
- Note if `verified` was cleared and which field change triggered it.
- Confirm `index.md` was synced (or note it was not present).
- Confirm `log.md` was updated or created.
- List any existing bundle concepts linked to from the updated concept (outbound links, Step 3).
- List any existing concepts updated with back-links (Step 7).

## Assumptions and Limits

- `bundle_directory` must be a locally accessible file system path.
- Does not validate field values against OKF semantics beyond the `type` non-empty requirement.
- Does not re-generate body content — only accepts verbatim replacement or append strings.
- `verified` is cleared conservatively: only content-bearing field changes trigger it; pure
  metadata changes (`stale_after`, `status`, `tags`) do not.
- Assumes the system clock is correct when setting `generated.at`.
