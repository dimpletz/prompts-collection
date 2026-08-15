---
name: attach-okf
description: >
  Hooks an OKF bundle into a project directory, agent file, or skill file so that the AI can
  search it for knowledge artifacts. For directories, writes to AGENTS.md, CLAUDE.md, or a newly
  created AGENTS.md. For agent (.agent.md) and skill (SKILL.md) files, appends a ## OKF Bundle
  section. Do NOT use this skill to create or modify OKF concept documents — use create-okf for
  that.
---

# Attach OKF

Hooks an OKF bundle into a target so the AI knows to search it for knowledge artifacts. Supports
three target types: a **project directory** (writes to `AGENTS.md` or `CLAUDE.md`), an **agent
file** (`.agent.md`), or a **skill file** (`SKILL.md`). For directories, the skill locates or
creates the instruction file. For agent and skill files, it appends a `## OKF Bundle` section.
The operation is idempotent — if the bundle path is already referenced in the target file, the
skill reports and stops without modifying anything.

## Inputs

- **bundle_directory** (required): Absolute path to the OKF bundle root to hook in.
- **target_directory** (required when `target_file` is absent): Absolute path to the project
  directory that will receive the OKF bundle reference. The skill searches for and writes the
  instruction file at the top level of this directory only. Mutually exclusive with `target_file`.
- **target_file** (required when `target_directory` is absent): Absolute path to an existing
  `.agent.md` or `SKILL.md` file to attach the bundle to. The file must already exist. Mutually
  exclusive with `target_directory`.

Exactly one of `target_directory` or `target_file` must be provided. Providing both or neither is
an error.

## Task Priorities

1. **Priority 1 – Validate before writing**: Confirm `bundle_directory` exists and the target
   input is valid before any file is created or modified. Abort and report on any failure.
2. **Priority 2 – Prefer AGENTS.md over CLAUDE.md** (directory mode only): When both `AGENTS.md`
   and `CLAUDE.md` exist in `target_directory`, select `AGENTS.md`.
3. **Priority 3 – Always confirm before writing**: After resolving the target file, present the
   resolved paths and mode to the user and ask for explicit confirmation before performing any
   write. Stop if the user declines.
4. **Priority 4 – Idempotency first**: Before any write, scan the target file for the exact
   `bundle_directory` string. If found, report "already configured" and stop without modifying
   the file.
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
2. Confirm `bundle_directory` exists as a directory. If it does not, abort:
   > Error: bundle_directory `<path>` does not exist or is not a directory.
3. If `target_directory` is provided, confirm it exists as a directory. Set `mode = instruction`.
   > Error: target_directory `<path>` does not exist or is not a directory.
4. If `target_file` is provided:
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

**All modes – Compute Injection Path**:

1. Find the common ancestor of `selected_file` and `bundle_directory` by walking up both paths.
2. Check whether a `.git` folder exists at or above this common ancestor (i.e. walk up from the
   ancestor until a `.git` folder or filesystem root is reached).
   - If a `.git` folder is found → both paths are in the same workspace.
   - If no `.git` folder is found → treat as different workspaces.
3. If same workspace, compute the relative path from `selected_file`'s parent directory to
   `bundle_directory` using forward slashes. Set `injection_path` to this relative path.
4. Otherwise, set `injection_path = bundle_directory` (absolute path).

### Step 3 – Confirm with User

Present a confirmation prompt before any file is created or modified. Tailor to the resolved mode:

**Instruction mode**:
> Ready to attach OKF bundle:
> - **Bundle directory**: `<bundle_directory>`
> - **Path in file**: `<injection_path>`
> - **Target directory**: `<target_directory>`
> - **Instruction file**: `<selected_file>` (<will_create = true → will be created | will_create = false → will be modified>)
>
> Proceed? (yes / no)

**Agent or skill file mode**:
> Ready to attach OKF bundle:
> - **Bundle directory**: `<bundle_directory>`
> - **Path in file**: `<injection_path>`
> - **Target file** (`<mode>`): `<selected_file>` (will be modified)
>
> Proceed? (yes / no)

If the user answers **no** (or any non-affirmative response) → output:
> Cancelled. No changes made.

Stop. Do not proceed further.

Only continue to Step 4 when the user explicitly confirms.

### Step 4 – Idempotency Check

Skip this step when `will_create = true`.

1. Read `selected_file` as UTF-8.
2. Search the full content for any occurrence of `injection_path` or `bundle_directory` (exact
   string, case-sensitive). If either is found → output:
   > Already configured: `<selected_file>` already references the OKF bundle. No changes made.

   Stop. Do not modify the file.

### Step 5 – Compose Injection Content

**Instruction mode** — build a single-line rule bullet:

```
- Search for knowledge artifacts in the OKF bundle at `<injection_path>` when relevant.
```

**Agent or skill file mode** — build a `## OKF Bundle` section block:

```

## OKF Bundle
- Search for knowledge artifacts in the OKF bundle at `<injection_path>` when relevant.
```

### Step 6 – Inject Instruction

**6A – Creating AGENTS.md from scratch** (instruction mode, `will_create = true`):

Write the following to `<target_directory>/AGENTS.md`:

```
## Rules
- Search for knowledge artifacts in the OKF bundle at `<injection_path>` when relevant.
```

Set `action = "created AGENTS.md with OKF rule"`.

**6B – Appending to an existing instruction file with a `## Rules` section** (instruction mode):

1. Find the first `## Rules` heading in the file.
2. Scan forward from that heading to find all bullet lines (lines starting with `- `). Stop
   scanning at the next `##`-level heading or end of file.
3. If at least one bullet line exists, insert the rule bullet as a new line immediately after the
   last bullet. If no bullet lines exist under the heading, insert the rule bullet on the line
   immediately following the `## Rules` heading (with a blank line separator after the heading if
   one is not already present).
4. Ensure the file ends with a trailing newline.

Set `action = "appended OKF rule under ## Rules"`.

**6C – Appending to an existing instruction file without a `## Rules` section** (instruction mode):

1. Append the following block to the end of the file (ensure a blank line precedes `## Rules`):
   ```

   ## Rules
   - Search for knowledge artifacts in the OKF bundle at `<injection_path>` when relevant.
   ```
2. Ensure the file ends with a trailing newline.

Set `action = "appended ## Rules section with OKF rule"`.

**6D – Appending to an agent or skill file** (agent or skill file mode):

1. Append the `## OKF Bundle` block composed in Step 5 to the end of `selected_file`
   (ensure a blank line precedes `## OKF Bundle`).
2. Ensure the file ends with a trailing newline.

Set `action = "appended ## OKF Bundle section"`.

### Step 7 – Report Result

Output a single confirmation line:

> Attached: OKF bundle `<injection_path>` → `<selected_file>` (<action>).

## Output Format

**Success path** — a single confirmation line:

> Attached: OKF bundle `<injection_path>` → `<selected_file>` (<action>).

**Already-configured path**:

> Already configured: `<selected_file>` already references the OKF bundle. No changes made.

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
- Does not validate `bundle_directory` as a conformant OKF bundle structure (no schema check).
- Idempotency uses exact string matching on `bundle_directory` — if the path appears anywhere in
  the target file, the skill skips injection regardless of surrounding context.
- Does not modify or remove pre-existing OKF rule bullets or `## OKF Bundle` sections, even if
  they reference a different bundle.
- Append-only; never deletes, truncates, or rewrites existing content.
- When a file contains multiple `## Rules` sections (instruction mode), appends under the first
  occurrence.
