---
name: create-okf
description: >
  Creates a new OKF v0.2 concept document in an OKF bundle directory. Use this skill whenever you
  need to add a new concept (table, metric, playbook, API endpoint, attested computation, etc.) to
  an OKF bundle. Do NOT use it to update an existing concept — use update-okf for that.
---

# Create OKF

Creates a new Open Knowledge Format (OKF) v0.2 concept document as a markdown file with YAML
frontmatter inside a bundle directory. The generated file is fully conformant with OKF v0.2 (§11):
a parseable frontmatter block with a non-empty `type` field plus any optional metadata supplied.
After writing the file the skill optionally updates the parent `index.md` and appends a
**Creation** entry to `log.md`.

## Inputs

- **bundle_directory** (required unless `OKF_DEFAULT_BUNDLE_DIR` is in context): Absolute path to
  the OKF bundle root. When the `OKF_DEFAULT_BUNDLE_DIR` context variable is present (injected by
  the hook) it is used as the default; the user may still override it per invocation.
- **concept_path** (inferred when possible): Path to the new concept file, relative to
  `bundle_directory` (e.g. `tables/customer-orders.md`). When not provided, derived from `type`
  (directory) and `title` slug — see Inference Rules. Must end in `.md`. Must not resolve to a
  reserved filename (`index.md` or `log.md`) at any level (§3.1).
- **type** (inferred when possible): OKF concept type string (e.g. `BigQuery Table`, `Metric`,
  `Playbook`, `API Endpoint`, `Reference`, `Attested Computation`). Any non-empty string is valid
  per §4.1. When not explicit, infer from the user's wording — see Inference Rules.
- **title** (optional): Human-readable display name. Omit to let consumers derive it from the
  filename (§4.1).
- **description** (optional): A single sentence summarizing the concept.
- **resource** (optional): Canonical URI of the underlying asset (absolute URL or bundle-relative
  path). Omit for abstract concepts.
- **tags** (optional): Comma-separated list of short tag strings.
- **status** (optional, default `stable`): `draft` | `stable` | `deprecated`.
- **generated_by** (optional): Actor in OKF actor convention (§7): `<producer>/<version>`,
  `human:<id>`, or `process:<id>`.
- **sources** (optional): One or more OKF `sources` entries (§5.1) provided as YAML.
- **body** (optional): Markdown body placed after the frontmatter. If omitted, a placeholder
  heading appropriate for the `type` is written.

Apply Inference Rules before asking for any input. Only ask when `bundle_directory` is absent
and `OKF_DEFAULT_BUNDLE_DIR` is not in context, or when two equally valid inferences conflict.
All other fields — `title`, `description`, `tags`, `status`, `body` — should be populated from
the user's description where possible.

## Inference Rules

Derive as many inputs as possible from the user's description. Proceed without asking unless
`bundle_directory` is unavailable or two equally plausible inferences genuinely conflict.

### type

| User wording | Inferred `type` |
|---|---|
| table, view, column | `BigQuery Table` |
| dataset, schema | `BigQuery Dataset` |
| metric, KPI, measure, rate, count | `Metric` |
| playbook, runbook, procedure, steps | `Playbook` |
| API, endpoint, route, webhook | `API Endpoint` |
| computation, formula, query, calculation | `Attested Computation` |
| reference, doc, glossary, term | `Reference` |
| other nouns | title-case the user's noun verbatim |

### concept_path

Derive as `<directory>/<slug>.md`. A concept is **always** placed inside a subdirectory —
never directly at the bundle root.

1. **Directory** — map `type` to a conventional bundle subdirectory; prefer an existing directory
   in the bundle root over a newly derived name.

   | Type | Directory |
   |---|---|
   | `BigQuery Table`, `Table`, `View` | `tables/` |
   | `BigQuery Dataset`, `Dataset` | `datasets/` |
   | `Metric`, `KPI` | `metrics/` |
   | `Playbook`, `Runbook` | `playbooks/` |
   | `API Endpoint` | `apis/` |
   | `Attested Computation` | `computations/` |
   | `Reference` | `references/` |
   | other | kebab-case of the type + `/` (e.g. `Custom Thing` → `custom-things/`) |

   If the user explicitly supplies a bundle-root path (no directory component), move it into
   the appropriate subdirectory using the table above.

2. **Filename slug** — from `title`: lowercase, replace spaces and special characters with `-`,
   collapse consecutive `-`, append `.md`.
   e.g. `Customer Orders (2026)` → `customer-orders-2026.md`

### Other frontmatter fields

- **title**: extract the subject noun phrase from the user's description.
- **description**: compose a single sentence from the user's stated purpose.
- **tags**: extract domain keywords (e.g. `sales`, `oncall`, `revenue`).
- **status**: default `stable`; use `draft` when the user says "draft", "WIP", or "not ready".
- **generated_by**: default to the agent's own actor string; use `human:<id>` only when the user
  explicitly states they are the author.
- **body**: write the placeholder heading (Step 3) unless the user provides content.

### Decomposition

A concept must represent a single unified idea. If the description spans multiple distinct ideas,
split into separate concepts before writing — one file per idea.

Signals that decomposition is needed:

- The description mentions multiple entities joined by "and" (e.g. "revenue and gross profit").
- The concept would require multiple independent `# Schema` sections, SQL queries, or formulas.
- Different parts of the description would have independent consumers or independent trust states.
- One part could become stale or unverified independently of another.

How to decompose:

1. Identify each distinct idea from the description.
2. Derive a separate `concept_path`, `title`, and `description` for each.
3. Place all sibling concepts in the same directory — they are part of the same group.
4. Apply Steps 2–6 for each concept in sequence.
5. After creating all concepts, optionally create a narrative concept (e.g. `Metric` or
   `Reference`) that describes the relationship and links to the individual concepts using
   standard markdown links (§6.1).

## Task Priorities

1. **Priority 1 – Single unified idea**: Each concept file must represent exactly one idea.
   Detect multi-idea descriptions and apply the Decomposition rules before writing anything.
2. **Priority 2 – OKF conformance**: The generated file must contain a parseable YAML frontmatter
   block with a non-empty `type` field (§11).
3. **Priority 3 – No reserved path collisions**: `concept_path` must never resolve to `index.md`
   or `log.md` at any directory level (§3.1). Abort and ask the user to supply a different path if
   a collision is detected.
4. **Priority 4 – No accidental overwrites**: If a file already exists at the resolved path, abort
   and notify the user without writing.
5. **Priority 5 – Accurate timestamps**: Set `generated.at` to the current system time in ISO 8601
   (`YYYY-MM-DDTHH:MM:SSZ`).
6. **Priority 6 – Log and index coherence**: Append a **Creation** entry to `log.md` when found;
   update `index.md` automatically when found in the parent directory.
7. **Priority 7 – Bundle root index.md**: The bundle root must always have an `index.md`. Create
   one if absent whenever a concept is written to the bundle.
8. **Priority 8 – Bundle root log.md**: The bundle root must always have a `log.md`. Create
   one if absent whenever a concept is written to the bundle.

## Workflow

### Step 1 – Infer Inputs and Validate

**1A – Infer from the user's description**

1. Derive `type` from the user's wording (Inference Rules).
2. Derive `title`, `description`, `tags`, and `status` from the stated intent.
3. Check for decomposition: if the description spans multiple distinct ideas, apply the
   Decomposition rules to split into N concept requests. Steps 2–6 run once per concept.
4. Derive `concept_path` from the inferred `type` (directory) and `title` (filename slug).
5. Proceed with inferred values without asking — unless `bundle_directory` is unavailable or two
   equally plausible inferences genuinely conflict.

**1B – Validate**

1. If `bundle_directory` is absent, check context for `OKF_DEFAULT_BUNDLE_DIR`. If neither is
   available, ask the user.
2. Verify `bundle_directory` exists as a directory.
3. Resolve the full path: `<bundle_directory>/<concept_path>`.
4. Confirm `concept_path` ends in `.md`.
5. Confirm neither the filename component nor any ancestor directory name in `concept_path` equals
   `index.md` or `log.md`.
6. Confirm no file already exists at the resolved path.

### Step 2 – Compose Frontmatter

Build the YAML frontmatter block applying these rules:

- Always include `type`.
- Include `title`, `description`, `resource` only when provided.
- Include `tags` as a YAML list when provided.
- Omit `status` when the value is `stable` (absent ⇒ `stable` per §5.4).
- Include `generated: { by: <generated_by>, at: <now_iso8601> }` when `generated_by` is supplied;
  otherwise `generated: { at: <now_iso8601> }`.
- Include `sources` block when provided.

Example output:

```yaml
---
type: Metric
title: Monthly Active Users
description: Count of distinct users who performed at least one action in a calendar month.
tags: [product, engagement]
status: draft
generated: { by: human:ron, at: 2026-08-16T10:00:00Z }
---
```

### Step 3 – Compose Body

Use the provided `body` verbatim. If no body is provided, write a minimal placeholder heading
based on `type`:

| Type pattern | Placeholder heading |
|---|---|
| `BigQuery Table`, `API Endpoint`, or similar asset types | `# Schema` |
| `Metric` | `# Definition` |
| `Playbook` | `# Steps` |
| `Attested Computation` | `# Computation` |
| All other types | `# Overview` |

### Step 4 – Write the File

1. Record which directories in `concept_path` do not yet exist — these are **new directories**.
2. Create all intermediate directories.
3. Write the complete file (frontmatter + body) as UTF-8.
4. Confirm the write and report the resolved path to the user.

### Step 5 – Update index.md and Initialize New Groups

OKF bundles use subdirectories to group related concepts (§3). When a new subdirectory is
created, it may need its own `index.md`, and its parent may need a subdirectory entry added.
Handle each case separately. Update all relevant `index.md` files automatically.

**5A – Concept entry in the parent directory**

If `index.md` already exists in the concept's parent directory, append a concept
bullet (§8):

```
* [<title>](<filename>) - <description>
```

**5B – New subdirectory initialization**

For each **new directory** created in step 4 (bottom-up, innermost first):

1. If no `index.md` exists in that directory, create a minimal one:
   ```markdown
   # <directory-name>
   
   * [<title>](<filename>) - <description>
   ```
2. If `index.md` already exists in the new directory (e.g. it was pre-seeded), append the
   concept bullet as in 5A.

**5C – Subdirectory entry in the parent directory**

For every new intermediate directory created, ensure its **parent** directory (up to and
including the bundle root) has an `index.md`:

1. If `index.md` already exists in the parent, append a subdirectory bullet (§8):
   ```
   * [<directory-name>](<directory-name>/) - <short description of the group>
   ```
2. If `index.md` does not exist in the parent, create a minimal one and include the
   subdirectory bullet:
   ```markdown
   # <parent-directory-name or bundle name>
   
   * [<directory-name>](<directory-name>/) - <short description of the group>
   ```

This guarantees the bundle root always has an `index.md` for progressive disclosure (§8).

### Step 6 – Write to log.md

Write to `log.md` at the bundle root (§9). If absent, create it first with the heading
`# Bundle Update Log`, then proceed with the date entry.

1. Determine today's date heading: `## YYYY-MM-DD`.
2. If the heading is absent, insert it above the previous date entries (below any `#`-level title
   heading if one exists).
3. Append under the date heading:
   `* **Creation**: Added [<title or filename>](<bundle-relative path>).`

## Output Format

- Confirm the created file path.
- Confirm whether `index.md` entries were added, created, or skipped (per 5A–5C).
- Confirm whether `log.md` was updated or created.

## Assumptions and Limits

- `bundle_directory` must be a locally accessible file system path.
- Does not validate `type` values against any registry — any non-empty string is accepted (§4.1).
- Does not generate `attester`, `executor`, or `computation` fields for `Attested Computation`
  concepts; supply those in `body` or `sources`.
- Does not auto-generate a missing `index.md` at the bundle root; only at newly created
  subdirectories (Step 5B) or via appending to existing ones (Steps 5A, 5C), all after user
  confirmation.
- Assumes the system clock is correct when setting `generated.at`.
