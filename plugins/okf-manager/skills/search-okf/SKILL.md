---
name: search-okf
description: >
  Searches an OKF bundle for concept documents matching filters and/or a free-text query. Returns
  a table of matching concepts with key metadata. Use this skill whenever you need to discover,
  audit, or enumerate concepts in an OKF bundle. Do NOT use it to create or modify concepts.
---

# Search OKF

Walks all concept documents in an OKF bundle, parses their frontmatter, applies the requested
filters, and returns a results table. Reserved filenames (`index.md`, `log.md`) are always
skipped. Trust tiers are derived per §5.3 and staleness per §5.5 so results can be immediately
acted on. This skill is strictly read-only.

## Inputs

- **bundle_directory** (required unless resolvable from context): Absolute path to the OKF bundle
  root. Resolution priority: (1) user-provided absolute path; (2) user-provided name or relative
  path joined with `OKF_DEFAULT_DIR` from context (`OKF_DEFAULT_DIR/<provided>`); (3)
  `OKF_DEFAULT_BUNDLE_DIR` from context as the default bundle. The user may still override any
  default per invocation.
- **query** (optional): Free-text string matched case-insensitively against `title`, `description`,
  and body content.
- **type** (optional): Filter to concepts whose `type` exactly matches this value
  (case-insensitive).
- **tags** (optional): Comma-separated list of tags. A concept matches if it carries **any** of
  the listed tags.
- **status** (optional): Filter by `status` value: `draft`, `stable`, or `deprecated`. Omit to
  return all statuses.
- **stale_only** (optional, default `false`): When `true`, return only concepts where
  `today >= stale_after`.
- **trust_tier** (optional): Filter by derived trust tier — `unverified`, `machine-confirmed`, or
  `human-reviewed` (§5.3).

Apply Inference Rules before asking. Translate the user's natural language request into filter
parameters — see Inference Rules. Only ask when `bundle_directory` cannot be resolved — no path,
no name + `OKF_DEFAULT_DIR`, and no `OKF_DEFAULT_BUNDLE_DIR` in context.

## Inference Rules

Translate the user's natural language request into filter parameters. Apply all matching filters;
omit filters not implied by the request.

| User says | Inferred filter |
|---|---|
| "find all tables" / "show tables" | `type: BigQuery Table` |
| "find all metrics" / "list metrics" | `type: Metric` |
| "deprecated" / "archived" | `status: deprecated` |
| "draft" / "in progress" / "not ready" | `status: draft` |
| "stale" / "out of date" / "expired" | `stale_only: true` |
| "unverified" / "not verified" | `trust_tier: unverified` |
| "machine-confirmed" / "auto-verified" | `trust_tier: machine-confirmed` |
| "human-reviewed" / "human-verified" | `trust_tier: human-reviewed` |
| topic words (e.g. "revenue", "orders") | `query: <words>` |
| "tagged X" / "with tag X" | `tags: X` |

Combine multiple filters when the request implies them (e.g. "find all stale deprecated metrics"
→ `type: Metric`, `status: deprecated`, `stale_only: true`).

## Task Priorities

1. **Priority 1 – Strictly read-only**: This skill must never write, create, or delete any file.
2. **Priority 2 – Skip reserved filenames**: Do not parse or include `index.md` or `log.md` at
   any directory level (§3.1).
3. **Priority 3 – Tolerate malformed files**: If a file cannot be parsed (missing frontmatter,
   invalid YAML), include it in results with a parse-error flag rather than aborting (§11).
4. **Priority 4 – Accurate derivations**: Derive trust tier and staleness from parsed frontmatter
   values, not from filenames or directory structure.
5. **Priority 5 – Useful output ordering**: Sort results by bundle-relative path by default.

## Workflow

### Step 1 – Infer Filters and Validate

**1A – Infer from the user's request**

Translate the user's natural language into filter parameters (Inference Rules). Proceed with the
inferred filters without asking; omit any filter that cannot be inferred.

**1B – Validate**

1. Resolve `bundle_directory` in priority order:
   a. User-provided absolute path → use as-is.
   b. User-provided name or relative path + `OKF_DEFAULT_DIR` in context →
      `OKF_DEFAULT_DIR/<provided>`.
   c. No path provided + `OKF_DEFAULT_BUNDLE_DIR` in context → use `OKF_DEFAULT_BUNDLE_DIR`.
   d. None of the above → ask the user.
2. Verify `bundle_directory` exists as a directory.
3. If `status` was provided or inferred, confirm it is `draft`, `stable`, or `deprecated`.
4. If `trust_tier` was provided or inferred, confirm it is `unverified`, `machine-confirmed`,
   or `human-reviewed`.

### Step 2 – Walk the Bundle

Recursively enumerate all `.md` files under `bundle_directory`. For each file:

1. Skip any file named `index.md` or `log.md` regardless of directory depth.
2. Read the file as UTF-8.
3. Attempt to parse the YAML frontmatter block. If parsing fails, record the file with
   `parse_error: true` and continue — do not abort.

### Step 3 – Derive Metadata per Concept

For each successfully parsed concept, derive:

- **trust_tier**:
  - `human-reviewed` — `verified` is present and at least one entry has `by` starting with
    `human:`.
  - `machine-confirmed` — `verified` is present but no `human:` actor appears.
  - `unverified` — `verified` is absent.
- **stale**: `true` when `stale_after` is set and today's date ≥ `stale_after`; `false` otherwise.
- **effective_status**: the `status` frontmatter value, or `stable` when absent (§5.4).

### Step 4 – Apply Filters

Exclude a concept when any of the following conditions apply:

- `query` is set and the query string is not found (case-insensitive) in `title`, `description`,
  or body.
- `type` is set and the concept's `type` does not match (case-insensitive).
- `tags` is set and the concept shares none of the requested tags.
- `status` is set and the effective status does not match.
- `stale_only` is `true` and the concept is not stale.
- `trust_tier` is set and the derived trust tier does not match.

### Step 5 – Format and Return Results

Return a markdown table:

| Path | Type | Title | Status | Trust Tier | Stale | Tags |
|------|------|-------|--------|------------|-------|------|

- **Path**: bundle-relative path (e.g. `tables/customer-orders.md`).
- **Type**: `type` frontmatter value; `(parse error)` for unparseable files.
- **Title**: `title` frontmatter value, or the filename stem if absent.
- **Status**: effective status.
- **Trust Tier**: derived trust tier.
- **Stale**: ✓ when stale, blank otherwise.
- **Tags**: comma-separated tag list; blank if none.

After the table, append a summary line: `N concept(s) found` and, when applicable,
`M file(s) with parse errors`.

## Assumptions and Limits

- Purely read-only; never modifies the bundle.
- Free-text `query` matches raw file text — no stemming, ranking, or semantic matching.
- Large bundles (hundreds of files) may be slow; no pagination is implemented in v1.0.0.
- Trust tier derivation follows §5.3 only; it does not evaluate runtime attestation results (§10).
- `bundle_directory` must be a locally accessible file system path.
