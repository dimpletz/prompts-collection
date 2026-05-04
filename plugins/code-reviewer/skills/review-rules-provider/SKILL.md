---
name: review-rules-provider
description: >
  Loads and concatenates code review rules for a given combination of languages. Use this skill
  whenever a code reviewer needs the applicable rule set for a specific review session.
  Do not use it for performing the review itself — that is the Language Rules Auditor's job.
---

# Review Rules Provider

This skill assembles the full rule set needed by the **Language Rules Auditor** for a
single review pass. It reads rule files from `./config/rules/` and
returns their concatenated content in a deterministic order: cross-cutting rules first,
primary-language rules second, then any additional chunk-language rules.

## Inputs

- **primary_language** (required): The project-level language detected by the Code Reviewer
  orchestrator (e.g., `"java"`, `"python"`, `"csharp"`). This language's rules are
  always included regardless of what appears in the diff chunk.
- **chunk_languages** (optional): A list of language tokens detected from the actual files in
  the diff chunk (e.g., `["javascript", "python"]`). Rules for each entry are appended after
  the primary-language rules. If omitted or empty, only the cross-cutting and primary-language
  rules are returned.

## Language → Rule File Mapping

| Language token(s) | Rule file |
|-------------------|-----------|
| `csharp`, `c#`, `cs` | `csharp-rules.md` |
| `java` | `java-rules.md` |
| `javascript`, `typescript`, `js`, `ts` | `javascript-rules.md` |
| `php` | `php-rules.md` |
| `magento` | `magento-rules.md` |
| `python`, `py` | `python-rules.md` |

Language tokens are matched case-insensitively. Tokens that do not match any entry in the
table are silently skipped.

## Task Priorities

1. **Priority 1 – Completeness**: Cross-cutting rules and primary-language rules must always
   be present in the output. Never omit them.
2. **Priority 2 – Deduplication**: Each rule file is included at most once, regardless of how
   many input tokens map to it (e.g., `"js"` and `"javascript"` both map to `javascript-rules.md`
   — include it only once).
3. **Priority 3 – Deterministic order**: Output follows the fixed order below. Within
   chunk-language rules, sort rule file names alphabetically for repeatability.

## Workflow

### Step 1 — Resolve the rules directory

Determine the absolute path to `./config/rules/` relative to the
plugin root. This directory contains `cross-cutting-rules.md` and the language-specific
rule files.

### Step 2 — Build the ordered read list

Construct the list of rule files to read in this exact order:

1. `cross-cutting-rules.md` (always first)
2. The rule file for `primary_language` (normalize to lowercase and map via the table above)
3. For each language in `chunk_languages` (normalized, mapped, deduplicated against already-
   added files, sorted alphabetically by filename), append its rule file

If `primary_language` maps to the same rule file as a `chunk_languages` entry, include it
only once (in the primary-language slot).

### Step 3 — Read and concatenate

Read each file in the ordered list. Concatenate them into a single text block separated by
a `---` divider line between sections. If a file cannot be read or does not exist, skip it
silently (do not error).

### Step 4 — Return the result

Return the concatenated rule content as plain text. Do not wrap it in a code fence. Do not
add any preamble, explanation, or metadata — only the raw rule content.

## Output Format

The output is plain text with this structure:

```
<contents of cross-cutting-rules.md>

---

<contents of <primary_language>-rules.md>

---

<contents of <chunk_language_1>-rules.md>

---

<contents of <chunk_language_2>-rules.md>
```

Trailing `---` dividers are omitted if there are no further sections.

## Example

**Input:**
- `primary_language`: `"java"`
- `chunk_languages`: `["javascript"]`

**Output:** `cross-cutting-rules.md` + `---` + `java-rules.md` + `---` + `javascript-rules.md`

**Input:**
- `primary_language`: `"python"`
- `chunk_languages`: `[]`

**Output:** `cross-cutting-rules.md` + `---` + `python-rules.md`

**Input:**
- `primary_language`: `"java"`
- `chunk_languages`: `["js", "java"]`   ← java duplicated

**Output:** `cross-cutting-rules.md` + `---` + `java-rules.md` + `---` + `javascript-rules.md`
(java-rules.md included only once; javascript-rules.md added for the `js` token)

## Assumptions and Limits

- The skill assumes the rule files exist at their expected paths. Missing files are skipped
  silently; the caller (Language Rules Auditor) is responsible for applying built-in knowledge
  when no rule file is available.
- The skill does not perform any review — it only provides rules. Applying the rules to a diff
  is the exclusive responsibility of the Language Rules Auditor.
