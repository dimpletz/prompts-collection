# Completion Verification (Step 8)

Shared by create-okf and update-okf. Run once after all concepts in the run have been processed
(a single concept is a roster of one). Passing criteria: every roster concept is written, every
bundle-relative link in a touched concept resolves, and every `index.md` in a touched directory
is complete.

**Touched concepts** are the roster plus any back-linked concepts modified in Step 7. In
create-okf, "processed" means created; in update-okf, it means updated.

**Scope of writes**: Step 8 may edit only touched concepts and the `index.md` files in their
directories (plus the bundle root `index.md`). For any other concept or `index.md` in the
bundle, report the problem and do not edit it.

1. **Concept roster check**: Confirm that every concept identified in Step 1D (or from
   Decomposition, or the single target concept) has been written. List any that are missing or
   skipped and process them before reporting completion.

2. **Cross-reference validation**: For every bundle-relative link in the body of each touched
   concept, resolve the target path and confirm the file exists. Also scan the rest of the bundle
   and report (do not fix) any broken link or leading-`/` link in untouched concepts.

   Path resolution rules:
   - Link begins with `/`: a violation of the Linking Rules. Resolve it as
     `<bundle_directory>/<path with leading slash removed>` to find the intended target, then
     rewrite the link as a file-relative path.
     e.g. `/tables/orders.md` in `metrics/revenue.md` → `../tables/orders.md`.
   - Link begins with `../` or `./` (file-relative): resolve from the directory of the concept
     file that contains the link.
     e.g. `../tables/orders.md` in `metrics/revenue.md` → `<bundle_directory>/tables/orders.md`.
   - Link is a bare filename with no path separator: resolve relative to the concept file's own
     directory.

   In a touched concept, correct a broken path when the intended target is unambiguous; otherwise
   report it and flag the missing concept for creation.

3. **index.md completeness**: For each `index.md` in a directory containing a touched concept
   (and the bundle root `index.md`):
   - **Bundle root** `index.md` (progressive disclosure only): every subdirectory in the bundle
     root has a subdirectory bullet linking to its `index.md`. Concepts live in subdirectories,
     so the root `index.md` has no concept bullets. If a concept file is found directly in the
     bundle root, report it to the user rather than listing it.
   - **Non-root** `index.md` files: every `.md` file in the same directory (excluding `index.md`
     and `log.md`) has a concept bullet, and every subdirectory has a subdirectory bullet linking
     to its `index.md`.
   - Every bullet has a description meeting the description quality rule in Step 5.

   Add missing entries and fix empty or placeholder descriptions in these files before reporting
   completion. Report problems in any other `index.md` without editing it.

4. **Single-concept acceptance**: Each written file re-parses, has a non-empty `type`, and has
   `generated.at` set.

5. **Report**: Summarise the verification outcome — concepts confirmed written, broken links
   found/fixed, `index.md` gaps filled, and problems reported in untouched files. List any item
   that could not be resolved explicitly.
