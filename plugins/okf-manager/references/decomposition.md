# Decomposition

A concept represents a single, focused idea, so that each one can be linked, verified, and
deprecated independently. Split a description into separate concepts, one file per idea, when
any signal below applies. When none applies, keep one concept.

## Mandatory extractions

Split these out instead of embedding them. Embedded procedures and computations go stale
independently of the asset they describe.

- **Procedural content**: any numbered steps, runbook, how-to, or instructional sequence becomes
  a separate concept with the most applicable procedural type (typically `Playbook`). A `Metric`,
  `BigQuery Table`, `API Endpoint`, or similar asset concept must not contain a procedure body.
- **Computations**: any inline SQL, formula, or independently attestable derivation becomes a
  separate `Attested Computation` concept. The parent concept links to it using a file-relative
  path.

## Additional signals

- The description mentions multiple entities joined by "and" (e.g. "revenue and gross profit").
- The concept would require multiple independent `# Schema` sections, SQL queries, or formulas.
- Different parts of the description would have independent consumers or independent trust states.
- One part could become stale or unverified independently of another.

## How to decompose

1. Identify each distinct idea from the description.
2. Derive a separate `concept_path`, `title`, and `description` for each.
3. Use the most specific applicable type for each extracted concept: `Playbook` for procedures,
   `Attested Computation` for computations, `Metric` for measures, etc.
4. Place all sibling concepts in the same directory — they are part of the same group.
5. Run Steps 2–7 for each concept in sequence; Step 8 runs once after all concepts.
6. After creating all concepts, optionally create a narrative concept (e.g. `Metric` or
   `Reference`) that describes the relationship and links to the individual concepts using
   standard markdown links (§6.1).
