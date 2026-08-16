---
name: attach-okf
description: >
  Hooks one or more OKF bundles into a project directory, agent file, or skill file so that the
  AI can search them for knowledge artifacts. For directories, writes to AGENTS.md, CLAUDE.md, or
  a newly created AGENTS.md. For agent (.agent.md) and skill (SKILL.md) files, appends or updates
  a ## Primary Knowledge Source section. Do NOT use this skill to create or modify OKF concept
  documents — use create-okf for that.
---

# Attach OKF

Hooks one or more OKF bundles into a target so the AI knows to search them for knowledge
artifacts. Supports three target types: a **project directory** (writes to `AGENTS.md` or
`CLAUDE.md`), an **agent file** (`.agent.md`), or a **skill file** (`SKILL.md`). For directories,
the skill locates or creates the instruction file. For agent and skill files, it appends or
updates a `## Primary Knowledge Source` section. Each bundle is processed independently —
already-attached bundles are skipped; the operation is idempotent per bundle.

## Inputs

- **bundle_directories** (required): One or more absolute paths to OKF bundle roots to hook in.
  Provide as a list when attaching multiple bundles at once. Each path must exist as a directory.
- **target_directory** (required when `target_file` is absent): Absolute path to the project
  directory that will receive the OKF bundle reference. The skill searches for and writes the
  instruction file at the top level of this directory only. Mutually exclusive with `target_file`.
- **target_file** (required when `target_directory` is absent): Absolute path to an existing
  `.agent.md` or `SKILL.md` file to attach the bundle to. The file must already exist. Mutually
  exclusive with `target_directory`.

Exactly one of `target_directory` or `target_file` must be provided. Providing both or neither is
an error.

## Task Priorities

1. **Priority 1 – Validate before writing**: Confirm every path in `bundle_directories` exists
   and the target input is valid before any file is created or modified. Abort and report on any
   failure.
2. **Priority 2 – Prefer AGENTS.md over CLAUDE.md** (directory mode only): When both `AGENTS.md`
   and `CLAUDE.md` exist in `target_directory`, select `AGENTS.md`.
3. **Priority 3 – Always confirm before writing**: After resolving the target file, present the
   resolved paths and mode to the user and ask for explicit confirmation before performing any
   write. Stop if the user declines.
4. **Priority 4 – Idempotency per bundle**: Before writing each bundle's entry, scan the target
   file for that bundle's path. Already-fully-configured bundles are skipped silently. Process
   only bundles not yet attached (or those missing the index.md reference).
5. **Priority 5 – Append only**: Never overwrite, truncate, or remove existing content. Only
   append the new content block.
6. **Priority 6 – Minimal creation** (directory mode only): When creating `AGENTS.md` from
   scratch, produce only a `## Rules` section with the OKF bundle reference. Do not add Purpose,
   Tree, or Note-taking placeholders.
7. **Priority 7 – File mode requires existing file**: In agent or skill file mode, `target_file`
   must already exist. Never create a `.agent.md` or `SKILL.md` from scratch.

## Workflow

### Step 1 – Validate Inputs

1. Confirm exactly one of `target_directory` or `target_file` is provided. If both or neither are
   given, abort:
   > Error: Provide exactly one of `target_directory` or `target_file`, not both (or neither).
2. Confirm `bundle_directories` contains at least one entry. If empty, abort:
   > Error: bundle_directories must contain at least one path.
3. For each path in `bundle_directories`, confirm it exists as a directory. If any path fails, abort:
   > Error: bundle_directory `<path>` does not exist or is not a directory.
4. If `target_directory` is provided, confirm it exists as a directory. Set `mode = instruction`.
   > Error: target_directory `<path>` does not exist or is not a directory.
5. If `target_file` is provided:
   - Confirm the file exists. If it does not, abort:
     > Error: target_file `<path>` does not exist.
   - Determine mode from the filename:
     - Filename ends with `.agent.md` → `mode = agent`
     - Filename is exactly `SKILL.md` → `mode = skill`
     - Otherwise → abort:
       > Error: target_file must be a `.agent.md` or `SKILL.md` file.

### Step 2 – Locate Target File

**Instruction mode** (`mode = instruction`):

1. Check whether `<target_directory>/AGENTS.md` exists. If yes → `selected_file = <target_directory>/AGENTS.md`, `will_create = false`.
2. Else check whether `<target_directory>/CLAUDE.md` exists. If yes → `selected_file = <target_directory>/CLAUDE.md`, `will_create = false`.
3. Else → `selected_file = <target_directory>/AGENTS.md`, `will_create = true`.

**Agent or skill file mode** (`mode = agent` or `mode = skill`):

1. Set `selected_file = target_file`, `will_create = false`.

**All modes – Compute Injection Path** (repeat for each entry in `bundle_directories`):

For each `bundle_directory` in `bundle_directories`, compute `injection_path` as follows:
1. Find the common ancestor of `selected_file` and `bundle_directory` by walking up both paths.
2. Check whether a `.git` folder exists at or above this common ancestor (i.e. walk up from the
   ancestor until a `.git` folder or filesystem root is reached).
   - If a `.git` folder is found → both paths are in the same workspace.
   - If no `.git` folder is found → treat as different workspaces.
3. If same workspace, compute the relative path from `selected_file`'s parent directory to
   `bundle_directory` using forward slashes. Set `injection_path` to this relative path.
4. Otherwise, set `injection_path = bundle_directory` (absolute path).

Store the resulting `(bundle_directory, injection_path)` pairs as `bundle_pairs`.

### Step 3 – Confirm with User

Present a confirmation prompt before any file is created or modified. Tailor to the resolved mode:

**Instruction mode**:
> Ready to attach OKF bundle(s):
> - **Bundles**:
>   - `<injection_path1>` (from `<bundle_directory1>`)
>   - `<injection_path2>` (from `<bundle_directory2>`) _(repeat for each)_
> - **Target directory**: `<target_directory>`
> - **Instruction file**: `<selected_file>` (<will_create = true → will be created | will_create = false → will be modified>)
>
> Proceed? (yes / no)

**Agent or skill file mode**:
> Ready to attach OKF bundle(s):
> - **Bundles**:
>   - `<injection_path1>` (from `<bundle_directory1>`)
>   - `<injection_path2>` (from `<bundle_directory2>`) _(repeat for each)_
> - **Target file** (`<mode>`): `<selected_file>` (will be modified)
>
> Proceed? (yes / no)

If the user answers **no** (or any non-affirmative response) → output:
> Cancelled. No changes made.

Stop. Do not proceed further.

Only continue to Step 4 when the user explicitly confirms.

### Step 4 – Idempotency Check (per bundle)

Skip this step when `will_create = true`; all bundles proceed directly to Step 5.

Read `selected_file` as UTF-8 once. For each `(bundle_directory, injection_path)` pair in
`bundle_pairs`:

1. Search for any occurrence of `injection_path` or `bundle_directory` (exact string,
   case-sensitive).
   - If neither is found → mark this bundle **pending** (needs full injection).
   - If found, additionally check whether the exact string `<injection_path>/index.md` appears
     in the file.
     - If yes → mark this bundle **skip** (already fully configured).
     - If no → mark this bundle **fix** (referenced but index entry missing). Compose the
       missing index line based on mode:
       - **Instruction mode**: `- Consult \`<injection_path>/index.md\` before any external lookup for knowledge from this source.`
       - **Agent or skill file mode**: `- Knowledge source: \`<injection_path>\` (entry point: \`<injection_path>/index.md\`)`

       Append this line immediately after the last existing bullet that references `injection_path`
       or `bundle_directory` in the target section.

After evaluating all pairs:
- If all bundles are **skip** → output for each:
  > Already configured: `<injection_path>` is already attached. No changes made.
  Stop.
- Collect all **pending** bundles into `pending_bundles` for Steps 5–6.
- Apply all **fix** patches immediately; report each with `action = "updated index.md reference"`.

### Step 5 – Compose Injection Content

Build injection content for each bundle in `pending_bundles`.

**Instruction mode** — for each pending bundle, build two rule bullets:

```
- Consult `<injection_path>/index.md` before any external lookup for knowledge from this source.
- Only read or search from `<injection_path>`; never write to or modify it.
```

**Agent or skill file mode** — determine whether a `## Primary Knowledge Source` section already
exists in `selected_file`:

- **Section does not exist** (first bundle or fresh file): build a full section block with shared
  rules followed by one `Knowledge source` entry per pending bundle:

```

## Primary Knowledge Source
- Only read or search from these knowledge sources; never write to or modify them.
- Consult each source's index.md before any external lookup.
- Knowledge source: `<injection_path1>` (entry point: `<injection_path1>/index.md`)
- Knowledge source: `<injection_path2>` (entry point: `<injection_path2>/index.md`)
```
_(include one `- Knowledge source:` line per pending bundle)_

- **Section already exists**: for each pending bundle, build only the new entry line to append
  inside the existing section:

```
- Knowledge source: `<injection_path>` (entry point: `<injection_path>/index.md`)
```

### Step 6 – Inject Instruction

For instruction mode (6A–6C), process all bundles in `pending_bundles` in a single pass — write
all their rule bullets together rather than one write per bundle.

**6A – Creating AGENTS.md from scratch** (instruction mode, `will_create = true`):

Write the following to `<target_directory>/AGENTS.md`, with one bullet pair per pending bundle:

```
## Rules
- Consult `<injection_path1>/index.md` before any external lookup for knowledge from this source.
- Only read or search from `<injection_path1>`; never write to or modify it.
- Consult `<injection_path2>/index.md` before any external lookup for knowledge from this source.
- Only read or search from `<injection_path2>`; never write to or modify it.
```

Set `action = "created AGENTS.md with OKF rule"`.

**6B – Appending to an existing instruction file with a `## Rules` section** (instruction mode):

1. Find the first `## Rules` heading in the file.
2. Scan forward from that heading to find all bullet lines (lines starting with `- `). Stop
   scanning at the next `##`-level heading or end of file.
3. Insert all pending-bundle bullet pairs as new lines immediately after the last existing bullet
   (or directly after the `## Rules` heading if no bullets exist yet, with a blank line separator).
4. Ensure the file ends with a trailing newline.

Set `action = "appended primary knowledge source rules under ## Rules"`.

**6C – Appending to an existing instruction file without a `## Rules` section** (instruction mode):

1. Append the following block to the end of the file (ensure a blank line precedes `## Rules`),
   with one bullet pair per pending bundle:
   ```

   ## Rules
   - Consult `<injection_path>/index.md` before any external lookup for knowledge from this source.
   - Only read or search from `<injection_path>`; never write to or modify it.
   ```
2. Ensure the file ends with a trailing newline.

Set `action = "appended ## Rules section with primary knowledge source rules"`.

**6D – Appending to an agent or skill file** (agent or skill file mode):

- **No existing `## Primary Knowledge Source` section**: Append the full section block composed in
  Step 5 to the end of `selected_file` (ensure a blank line precedes `## Primary Knowledge
  Source`). Set `action = "appended ## Primary Knowledge Source section"`.
- **Section already exists**: For each pending bundle, append its `- Knowledge source:` entry line
  to the end of the existing `## Primary Knowledge Source` section (before the next `##`-level
  heading or end of file). Set `action = "updated ## Primary Knowledge Source section"`.

Ensure the file ends with a trailing newline.

### Step 7 – Report Result

Output one line per bundle processed (attached or fixed):

> Attached: `<injection_path>` → `<selected_file>` (<action>).

For each skipped bundle:

> Skipped: `<injection_path>` already attached to `<selected_file>`.

## Output Format

**Success path** — one line per bundle attached or fixed:

> Attached: `<injection_path>` → `<selected_file>` (<action>).

**Skip path** — one line per already-configured bundle:

> Skipped: `<injection_path>` already attached to `<selected_file>`.

**All-skip path** — when every bundle was already fully configured:

> Already configured: all bundles are already attached to `<selected_file>`. No changes made.

**Cancelled path**:

> Cancelled. No changes made.

**Error path** (validation failure):

> Error: `<message>`

## Assumptions and Limits

- In directory mode, only searches the top level of `target_directory` for `AGENTS.md` and
  `CLAUDE.md`; does not recurse into subdirectories.
- In agent/skill file mode, the target file must already exist; this skill never creates
  `.agent.md` or `SKILL.md` files from scratch.
- Supported `target_file` types: any filename ending with `.agent.md`, or the exact filename
  `SKILL.md`. Other file types are rejected.
- Does not validate any entry in `bundle_directories` as a conformant OKF bundle structure (no schema check).
- Idempotency uses exact string matching per `bundle_directory` — if a bundle's path appears
  anywhere in the target file, that bundle is skipped regardless of surrounding context.
- Does not modify or remove pre-existing `## Primary Knowledge Source` sections, even if they
  reference a different bundle, unless the `index.md` reference is missing (see Step 4).
- Append-only; never deletes, truncates, or rewrites existing content.
- When a file contains multiple `## Rules` sections (instruction mode), appends under the first
  occurrence.
