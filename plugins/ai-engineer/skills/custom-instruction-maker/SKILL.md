---
name: custom-instruction-maker
description: >
  A skill for creating AGENTS.md, copilot-instructions.md, CLAUDE.md, or similar AI instruction files that follow the Purpose → Tree → Rules structure with a built-in self-improving note-taking engine. Use it whenever the user wants to create an AGENTS.md, copilot-instructions.md, CLAUDE.md, or custom instruction file. Do not use it for creating agent files (.agent.md), skill files (SKILL.md), or general documentation.
---

# Custom Instruction Maker

This **skill** is for developers who need to create structured AI instruction files (AGENTS.md, copilot-instructions.md) for a codebase or project. These files teach AI assistants the project's purpose, where code and config live, how to operate within the repo, and how to improve over time through self-correcting note-taking.

> **Important**: Create exactly the file type the user requests. If the user asks for CLAUDE.md, create CLAUDE.md. If the user asks for AGENTS.md, create AGENTS.md. If the file type is unspecified or unclear, default to AGENTS.md. The structure and content are identical across all types — only the filename differs.

## Inputs

- **project_purpose** (required): A description of what the project or repo does — the product, service, library, or system. If not provided, inspect the workspace (README, package files, configs) to infer it.
- **folder_scope** (optional): Whether the instruction file covers the entire repo root or a specific subfolder/package. If omitted, default to the repo root.
- **tech_stack** (optional): Key languages, frameworks, and tools used (e.g. "TypeScript, React, PostgreSQL, Docker"). If omitted, infer from project files.
- **coding_conventions** (optional): Team-specific conventions (e.g. "no default exports", "use kebab-case for file names", "prefer composition over inheritance"). If omitted, infer from linter configs, editorconfig, or existing code patterns.
- **existing_structure** (optional): Whether the workspace already has folders and files to map. If omitted, scan the workspace to discover the current structure.

## Task Priorities

1. **Priority 1 – Structural correctness**
   The generated file must always contain all three core sections — **Purpose**, **Tree**, and **Rules** — in that order. A file missing any of these is incomplete.

2. **Priority 2 – Self-improving note-taking**
   The file must always include a **Note-taking** section that enables the AI to log corrections, preferences, and patterns after every task, creating a compounding knowledge loop.

3. **Priority 3 – Operational usefulness**
   Rules must be specific to the actual project, not generic. They should reference real files, real folders, and real workflows. Every rule should be actionable on the very next task.

## Workflow

### Step 1 – Understand the Request

- Read the provided inputs carefully.
- Determine which file to create:
  - `AGENTS.md` — for general AI instruction files, and the **default** when the file type is not specified.
  - `CLAUDE.md` — when the user explicitly requests a CLAUDE.md file.
  - `copilot-instructions.md` — when the user specifically asks for GitHub Copilot custom instructions (typically placed in `.github/copilot-instructions.md`).
- If the file type is ambiguous or not mentioned, default to AGENTS.md.
- Identify the target directory: repo root for AGENTS.md and CLAUDE.md, or `.github/` for copilot-instructions.md.

### Step 2 – Gather Context

- Scan the workspace folder structure to understand what exists.
- Look for existing README, package.json/pom.xml/Cargo.toml, linter configs, CI pipelines, Dockerfiles, and documentation that reveal the project's purpose and stack.
- Identify key folders and their roles (source code, tests, docs, scripts, configs, infrastructure, etc.).
- If key information is missing and cannot be inferred, ask the user concise clarifying questions (max 3–4 at a time).

### Step 3 – Compose the Instruction File

Build the file with the following mandatory sections in this exact order:

#### A. Purpose (MANDATORY)

A short paragraph describing what this project does and how the AI should approach it. Must include:
- What the project builds or provides (product, library, service).
- Tech stack and key architectural patterns.
- Build/run/test commands if known.
- Any critical domain knowledge needed to work in this codebase.

Example:
```
## Purpose

This repo is an event-driven order processing service built with
TypeScript, NestJS, and PostgreSQL. It consumes events from Kafka,
applies business rules, and persists order state. Run `npm run dev`
to start locally. Tests use Jest — run `npm test`.
```

#### B. Tree (MANDATORY)

A map of the folder's top-level structure with a one-line description for each entry. This serves as the AI's mental model of where things live.

- List main folders and important root-level files only — do not enumerate every source file.
- Use `- path/to/item — description` format.
- Include top-level source directories, test directories, config files, scripts, docs, and infrastructure. Stop at the folder level unless a specific file within is particularly important.
- Keep it current — the Rules section will instruct the AI to update this list when new files are created.

Example:
```
## Tree

- src/ — application source code (NestJS modules)
- src/orders/ — order processing domain logic and handlers
- src/shared/ — shared utilities, types, and middleware
- test/ — unit and integration tests (Jest)
- scripts/ — build, deploy, and migration scripts
- docs/ — architecture decisions and API documentation
- docker-compose.yml — local development stack (Postgres, Kafka, app)
- .github/workflows/ — CI/CD pipeline definitions
```

#### C. Rules (MANDATORY)

Operational rules that govern how the AI should behave in this folder. Rules must be:
- Specific to this project (not generic AI rules).
- Actionable (the AI can follow them on the very next task).
- Written as imperative statements with "Before…", "Never…", "When…", "Always…" patterns.

Must include at minimum:
1. Which files or docs to read before specific types of work (e.g. read ADRs before architectural changes).
2. Coding conventions — naming, patterns, file structure expectations.
3. Safety gates — what requires human approval before modifying (e.g. DB migrations, CI config, public APIs).
4. Tree maintenance — update the Tree section when creating or discovering new files.

Learned rules (added by the note-taking engine over time) should be appended with a dated annotation:

Example:
```
## Rules

- Before changing any module's public API, read docs/api-contracts.md
- Before writing a migration, read docs/database-conventions.md
- Follow the existing pattern in src/orders/ when creating new domain modules
- Never modify CI workflows or docker-compose.yml without my approval
- All new code must have unit tests — place them in test/ mirroring the src/ structure
- When you create or discover new files, update the Tree above
- Prefer named exports over default exports (learned 3/15)
```

#### D. Note-taking (MANDATORY)

This section implements the **self-improving engine** — a set of instructions that tell the AI to log corrections, preferences, and patterns after every task so that knowledge compounds across sessions.

The note-taking section must include all of the following rules:

1. **When to note**: After each task, log any correction, preference, or pattern learned.
2. **Where to write**: Write to the matching context file's "Session learnings" section; if none fits, add to the Rules section above.
3. **How to write**: One dated line, plain language. (e.g. `Team uses discriminated unions, not class hierarchies for domain events (learned 3/15)`)
4. **Graduation rule**: When 3 or more related notes accumulate on a topic, create a new `docs/` context file, move the notes there, and update the Tree. Keep the instruction file under 100 lines.

Example:
```
## Note-taking

- After each task, log any correction, preference, or pattern learned.
- Write to the matching docs file's "Session learnings" section;
  if none fits, add to Rules above. One dated line, plain language.
  e.g. "Team uses discriminated unions for domain events (learned 3/15)"
- 3+ related notes → create a new docs/ file. Move notes there.
  Update the Tree. Keep this file under 100 lines.
```

### Step 4 – Validate the File

Before saving, verify:

1. **All four sections present**: Purpose, Tree, Rules, Note-taking — in that order.
2. **Purpose is specific**: References the actual project, stack, and build commands — not a generic description.
3. **Tree is accurate**: Reflects the real folder structure discovered in Step 2. No placeholder paths.
4. **Rules are actionable**: Each rule references real files or folders. No vague guidelines like "be careful" or "follow best practices".
5. **Note-taking is complete**: Contains all four sub-rules (when, where, how, graduate).
6. **Under 100 lines**: The entire file should stay concise — under 100 lines. If it exceeds this, trim redundant rules or consolidate.
7. **No code fences**: The file is plain Markdown. Never wrap the content in code fences.

### Step 5 – Save the File

- **AGENTS.md**: Save at the workspace root or the specified subfolder root.
- **CLAUDE.md**: Save at the workspace root or the specified subfolder root.
- **copilot-instructions.md**: Save at `.github/copilot-instructions.md`.
- If the file type was not specified, save as AGENTS.md and note that this is the default.
- Create any referenced directories (e.g. `docs/`, `scripts/`) if they do not already exist and the user confirms.
- **No code fences**: The file must start directly with `## Purpose` or a top-level heading. Never wrap output in code fences.

### Step 6 – Bootstrap Context Files (RECOMMENDED)

If the Tree references docs or context files that do not yet exist, offer to create starter versions:

- `docs/architecture.md` — high-level architecture overview, key design decisions, system boundaries, and a "Session learnings" section at the bottom.
- `docs/coding-conventions.md` — naming rules, file organization, preferred patterns, linting expectations, plus a "Session learnings" section.
- `docs/api-contracts.md` — public API surface, versioning policy, breaking change rules, plus a "Session learnings" section.
- Other docs as appropriate for the project domain (e.g. `docs/database-conventions.md`, `docs/testing-strategy.md`).

Each context file should end with an empty "Session learnings" section ready for the note-taking engine:

```
## Session learnings

(Notes will be added here as the AI learns from each task.)
```

## Output Format

After creating the file(s), respond with:

```markdown
## Summary
- File created and its path.
- What the instruction file covers (1–2 sentences).
- Key rules and note-taking behavior established.

## Files Created
- List of all files created (instruction file + any bootstrapped context files).

## Next Steps
- Suggest the user review the Purpose, Tree, and Rules for accuracy.
- Recommend running a first coding task to test the note-taking loop.
- Note any docs that were bootstrapped and may need real content filled in.

## Limitations
- Assumptions made about the project structure or workflow.
- Any sections that may need refinement after the first few tasks.
```

## Limitations and Assumptions

- Assumes the workspace is organized around a single project or package per folder.
- The Tree section is a snapshot — it must be maintained by the AI via the Rules, but may drift if files are created outside the AI workflow (e.g. direct git operations, IDE refactors).
- The note-taking engine depends on the AI reading this file at the start of each session. If the AI does not load the instruction file, notes will not compound.
- Does not handle monorepo workspace structures with multiple unrelated packages — each instruction file covers one project scope. For monorepos, consider one instruction file per package.
- Bootstrapped docs contain placeholder content. The user should fill in real architectural details and conventions before relying on them.
