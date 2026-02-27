---
name: readme-maintainer
description: >
  A skill for creating or updating README.md files. Use it whenever the user asks to write a new README.md from scratch or to update, improve, or extend an existing one. Do not use it for other documentation types (wikis, changelogs, API docs) unless explicitly directed.
---

# README Maintainer

This **skill** is for developers and technical writers who need to produce or keep up‑to‑date a `README.md` that is accurate, complete, and easy to navigate. It handles both greenfield creation (no existing README) and incremental updates (adding sections, reflecting new features, fixing stale content).

## Inputs

- **project_context** (derived automatically): Context is gathered by inspecting the current project directory. Do not ask the user to describe the project manually; instead, read the workspace files to determine the project's purpose, tech stack, and structure (see Step 2). For updates, the existing `README.md` is included as part of the gathered context.
- **version** (derived automatically): Read from the project directory manifest file (e.g. `version` field in `package.json`, `pyproject.toml`, `pom.xml`, etc.). If found, include it in the README title and any version-specific installation or usage instructions. If not found in any file, omit it from the output entirely — never ask the user for it.
- **scope** (optional): What specifically must be created or changed (e.g. "add a Contributing section", "update the installation steps for v2", "rewrite the entire file"). If omitted, create or refresh the full README.
- **target_audience** (optional): Who will read the README (e.g. end users, contributors, DevOps engineers). If omitted, assume "software developers evaluating or onboarding to the project".

## Task priorities

1. **Priority 1 – Accuracy**
   Every technical claim (commands, paths, version numbers, prerequisites) must match the actual project. Never invent commands or configurations that are not confirmed by context.

2. **Priority 2 – Completeness**
   A README must cover all sections relevant to the project. For greenfield files, always include at minimum: title/description, prerequisites, installation, usage, and license. Add optional sections (contributing, configuration, FAQ, badges) only when there is content to fill them.

3. **Priority 3 – Readability and maintainability**
   Use clear headings, short paragraphs, and code blocks for all commands. Keep the tone neutral and imperative. Make the file easy to diff and update incrementally (avoid walls of text or tightly coupled paragraphs).

## Workflow

1. **Step 1 – Assess the request**  
   - Determine whether this is a **create** or **update** task.  
   - For updates, read the existing README fully and identify sections that are stale, missing, or incorrectly scoped before touching anything.  
   - Confirm the target audience and scope from inputs or infer conservatively from context.

2. **Step 2 – Gather facts from the project directory**  
   - Scan the current project directory to extract context. Read the following files in order of priority (stop once sufficient context is found):  
     1. Manifest / descriptor: `package.json`, `composer.json`, `pyproject.toml`, `pom.xml`, `build.gradle`, `*.csproj`, `Cargo.toml`, `go.mod`.  
     2. Existing `README.md` (for updates).  
     3. Entry point files: `index.*`, `main.*`, `app.*`, `src/`.  
     4. Configuration samples: `.env.example`, `config.*`, `docker-compose.yml`, `Dockerfile`.  
     5. License file: `LICENSE`, `LICENSE.md`.  
   - From those files, derive: project name, one-sentence description, tech stack, entry point or main command, installation method, environment variables or config files, and license type.  
   - **version**: read from the manifest file (e.g. `version` in `package.json`, `pyproject.toml`, `<version>` in `pom.xml`, `Cargo.toml`). If found, include it in the README title. If not found in any file, omit it from the output silently — do not ask the user and do not insert a placeholder.  
   - If any other fact is unavailable after scanning the directory, insert a `<!-- TODO: ... -->` placeholder rather than fabricating information.

3. **Step 3 – Draft or apply changes**  
   - **Greenfield**: produce a complete README using the standard section order (see Output format below).  
   - **Update**: surgically edit only the sections affected by the scope. Preserve existing prose that is still accurate. Never rewrite unrelated sections unless explicitly asked.  
   - Use fenced code blocks (` ``` `) with language identifiers for all commands and code snippets.  
   - Use relative links for internal references (other files in the repository).  
   - **Visualizations**: whenever a diagram, flowchart, architecture overview, sequence, entity-relationship, or any other visual element would aid comprehension, render it as a [Mermaid](https://mermaid.js.org/) diagram inside a fenced ` ```mermaid ` block. Never use ASCII art, plaintext tables, or external image links as a substitute for a diagram that can be expressed in Mermaid.

4. **Step 4 – Review and flag**  
   - Verify that every command and path in the file is consistent with the project context provided.  
   - Call out any `<!-- TODO: ... -->` placeholders at the end so the user knows what still needs manual input.  
   - Never remove existing content without noting the deletion and the reason.

## Output format

Produce the README.md content directly, followed by a brief assistant note. Structure the README using this section order (omit sections that genuinely do not apply):

```markdown
# <Project Name> [<Version>]

> One-sentence description of what the project does and for whom.

## Prerequisites
## Installation
## Usage
## Components / Architecture  <!-- if the project has multiple components or a non-trivial architecture; always include a Mermaid diagram (e.g. graph TD, C4, sequenceDiagram) to visualize relationships -->
## Configuration              <!-- if env vars / config files exist -->
## API Reference              <!-- if the project exposes a public API -->
## [Changelog](CHANGELOG.md)  <!-- if the project has a changelog -->
## [License](LICENSE.md)      <!-- if the project has a license -->
## Author(s)                  <!-- if author information is available -->
```

After the README content, include a short assistant note (outside the file content) with this structure:

```markdown
---
**README Maintainer – Notes**

- Sections added / modified: <list>
- Placeholders requiring manual input: <list or "none">
- Assumptions made: <list or "none">
```

## Assumptions and known limits

- **Assumes** the project context provided is accurate and up to date. If context is incomplete, sections will contain `<!-- TODO: ... -->` markers.
- **Assumes** English as the target language. For non-English READMEs, the same structure applies but translation is out of scope.
- **Uses Mermaid** (` ```mermaid ` fenced blocks) for all diagrams and visual representations: architecture overviews, flowcharts, sequence diagrams, ER diagrams, state machines, Gantt charts, etc. No ASCII art or raster/vector image embeds are used for content that Mermaid can express.
- **Does not** generate badges (CI status, coverage, npm version) automatically; it will include placeholder badge lines when a badge section is requested.
- **Does not** update other documentation files (CHANGELOG.md, CONTRIBUTING.md, docs/) unless they are explicitly in scope.

## Validation

1. **Greenfield check**: run the exact commands from the Installation and Usage sections in a clean environment and confirm they work.
2. **Update check**: diff the modified README against the original and confirm that only the requested sections changed.
3. **Placeholder check**: grep the output for `<!-- TODO` and resolve each before merging.
