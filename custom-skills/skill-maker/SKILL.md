---
name: skill-maker
description: >
  A meta-skill that helps you design, specify, and refine new AI skills (SKILL.md files) in a consistent, production-ready way. Use it whenever you’re defining or updating instructions for an AI assistant. Do not use it for solving the end-user task itself (coding, writing, analysis); it is only for designing the *skill* that will do that work.
---

# Skill Maker

This **skill** is for engineers, tech leads, and prompt designers who need to define new AI skills in a structured, repeatable way (per repo, per product area, per workflow, or per ticket type). It focuses on the meta-task: clarifying purpose, inputs, priorities, and workflow of a future skill, so that downstream assistants behave predictably and are easy to maintain. 

## Inputs

- **skill_intent** (required): A short description of what the new skill should achieve and where it will run (e.g. “review PRs for Java services in repo X”).
- **primary_user** (optional): Who will use the skill (role, experience level, constraints); if omitted, assume “software engineer with mid-senior experience in the target domain”.
- **operating_context** (optional): Scope and boundaries: codebase, document types, tools available (RAG, tests, CI), latency/quality trade-offs; if omitted, infer from intent with conservative assumptions.

## Task priorities

1. **Priority 1 – Behavioral correctness**
   The generated skill must clearly specify what the assistant should and should not do, minimizing ambiguity and hallucinations.

2. **Priority 2 – Operational usefulness**
   The skill should be practical in a real workflow: clear triggers (“when to use”), crisp outputs, and failure modes (what to do when unsure).

3. **Priority 3 – Maintainability and extensibility**
   The skill text should be easy to tweak, version, and extend as the product or codebase evolves, following a consistent template.

## Workflow

1. **Step 1 – Understand the request**  
   - Read the provided **skill_intent**, **primary_user**, and **operating_context** carefully.
   - Identify whether the skill is: evaluative (e.g. review, critique), generative (e.g. draft, propose), transformative (e.g. refactor, summarize), or orchestration (e.g. plan, route, chain tools).

2. **Step 2 – Analyze**  
   - Extract constraints: file types, languages, tools, performance/latency tolerance, safety considerations, and any must-follow house style.
   - Decide what the skill must explicitly avoid (e.g. “do not modify business logic”, “do not auto-fix tests”) and where it should defer or ask for clarification.

3. **Step 3 – Produce output**  
   - Fill the SKILL.md template sections: frontmatter (name, description), human-readable overview, Inputs, Task priorities, Workflow, and Output format.
   - Use precise, operational language (“must”, “never”, “only when”) rather than vague suggestions, and keep sections short but unambiguous.
   - **CRITICAL – NO CODE FENCES**: The generated SKILL.md content **must never** be wrapped in any code fence — not ` ```skill `, not ` ```markdown `, not ` ``` `, not any other fence. The file must start directly with `---` (YAML frontmatter) and contain only plain Markdown. Wrapping in any code fence is always wrong and must not happen under any circumstances.
   - **CRITICAL – SAVE LOCATION**: You **must** create the file at exactly `.agents/skills/<skill-name>/SKILL.md` inside the workspace root (e.g. if the skill name is `foo-bar`, the path is `.agents/skills/foo-bar/SKILL.md`). Use the file-creation tool to write it — do **not** skip, defer, or ask the user to do it. Create the directory if it does not exist. Saving anywhere else (e.g. `.github/skills/`) is wrong.
   
4. **Step 4 – Summarize and flag limits**  
   - At the end of SKILL.md, explicitly call out assumptions (e.g. “assumes tests exist”, “assumes access to git diff”) and known limits (e.g. “does not handle binary files”).
   - Suggest 1–3 concrete validation checks the user can run to confirm the skill behaves as intended (e.g. “run on this PR type”, “run on this doc set”).

## Output format

Always respond using this structure:

```markdown
## Summary
- 2–5 bullets with the main outcome.
- Mention the skill’s purpose and when it should be invoked.
- Note any high‑risk behaviors the skill explicitly avoids.

## Main Results
- The full SKILL.md content for the requested capability, following the standard template.
- Any important behavioral notes (safety, performance, compliance).

## Recommendations
- The generated SKILL.md has already been saved to `.agents/skills/<skill-name>/SKILL.md` in the workspace root (done as part of Step 3 — mandatory). It is a plain Markdown file starting with `---` frontmatter; it contains no code fences.
- Concrete next actions for the user (e.g. how to plug the skill into their AI assistant).
- Optional suggestions for test scenarios and future extensions.

## Limitations
- Assumptions about the environment, users, and tools.
- Known cases where the skill may underperform or should not be used.
```

### Simple example and validation

**Example input**

You call this meta-skill with:

- `skill_intent`: “Create a skill that reviews Python pull requests for style, complexity, and missing tests, but does not suggest API-level design changes.”  
- `primary_user`: “Senior backend engineer working in a microservices repo.”  
- `operating_context`: “Git-based workflow with CI, flake8, pytest; latency under ~15 seconds is acceptable.”

**Expected behavior**

This meta-skill returns a complete `SKILL.md` for “python-pr-reviewer” that:

- States the skill’s purpose and when it should be used (reviewing Python PRs before merge).  
- Defines required inputs (diff, file list, test status) and priorities (correctness > style > suggestions).  
- Specifies a stepwise workflow (scan diff, detect hotspots, propose focused comments).  
- Defines output sections under the “Output format” heading (Summary, Main Results, Recommendations, Limitations), ready to be dropped into your assistant configuration.

**How to validate**

1. Wire the generated SKILL.md into your assistant configuration (e.g. repo-level AI settings or orchestrator).  
2. Run it on:  
   - A PR with obvious style issues but correct logic.  
   - A PR with missing or weak tests.  
   - A PR attempting an API redesign.  
3. Confirm:  
   - It flags style and testing issues with concrete, scoped comments.  
   - It does not propose API redesigns beyond light, clearly marked suggestions.  
   - Its responses respect the described output sections (Summary, Main Results, Recommendations, Limitations).