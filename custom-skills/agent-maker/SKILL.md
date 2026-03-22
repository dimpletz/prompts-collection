---
name: agent-maker
description: >
  A skill for creating new VS Code agent files (.agent.md). Use it whenever the user asks to create a new custom agent, define an agent persona, or scaffold an agent specification. Do not use it for editing or optimizing existing agents, creating skills, or writing general documentation. For optimizing existing agents or decomposing them into orchestrator + subagent architectures, use the agent optimizer skill instead if available.
---

# Agent Maker

This **skill** is for developers and prompt engineers who need to create well-structured, production-ready VS Code agent files (`.agent.md`). It enforces a consistent structure with required frontmatter fields and mandatory body sections, while allowing flexibility for domain-specific content.

> **Note**: This skill creates new single-focus agents. If the agent's intent suggests it needs an orchestrator + subagent architecture, create a single agent first using this skill, then use an agent optimizer skill to decompose it into an orchestrator and subagents if available.

## Inputs

- **agent_intent** (required): A short description of what the agent should do and in what context (e.g. "an agent that generates database migration scripts for PostgreSQL").
- **agent_name** (optional): The display name for the agent in Title Case (e.g. "Database Migration Generator"). If omitted, derive a concise, readable title from the intent. The PascalCase variant is used only for the file name (e.g. `DatabaseMigrationGenerator.agent.md`).
- **target_audience** (optional): Who will interact with the agent (e.g. "backend engineers", "QA testers"). If omitted, assume a regular user with no specialized technical background.
- **tools** (optional): Specific VS Code tools the agent should be allowed or required to use (e.g. `web`, `edit`, `agent`, `edit`, `read`, `execute`, `search`). If omitted, do not restrict tools — let the agent use whatever is available.

## Task Priorities

1. **Priority 1 – Structural correctness**
   The generated `.agent.md` must always contain valid YAML frontmatter with `name` and `description` fields, and the body must always include the **Role** and **Guardrails** sections. A file missing any of these is invalid.

2. **Priority 2 – Behavioral clarity**
   The agent's instructions must clearly specify what it does, how it does it, and what it refuses to do. Use precise, operational language ("must", "never", "only when") to minimize ambiguity.

3. **Priority 3 – Practical usefulness**
   The agent should be immediately usable after creation — no placeholder sections or incomplete instructions. Every section must contain actionable content tailored to the agent's intent.

## Workflow

### Step 1 – Understand the Request

- Read the provided **agent_intent** carefully.
- Classify the agent's primary mode:
  - **Generative**: creates artifacts (code, docs, configs)
  - **Evaluative**: reviews, critiques, or validates
  - **Transformative**: refactors, converts, or migrates
  - **Orchestrative**: plans, routes, or chains multiple steps
  - **Interactive**: conversational Q&A within a bounded domain
- Determine the domain, target audience, and any tool requirements from the inputs or infer them conservatively.
- **Ask clarifying questions** if any of the following are ambiguous or missing and cannot be reliably inferred:
  - What specific tools the agent needs (e.g. does it need web access? terminal execution? file editing?).
  - Whether the agent should operate autonomously or pause for user confirmation at key steps.
  - The scope boundary — what the agent should refuse to do.
  Keep questions concise (max 3–4 at a time). Do not ask about information that can be reasonably inferred from the intent.
- **Tool preference**: Always use the `vscode/askQuestions` tool to ask clarifying questions whenever it is available. Prefer it over inline prose questions in all cases — it provides a structured, user-friendly interaction. Only fall back to asking questions in plain text if `vscode/askQuestions` is not available.

### Step 2 – Compose the Agent File

Build the `.agent.md` file with the following structure. All sections listed below are **mandatory** unless marked otherwise.

#### A. YAML Frontmatter (MANDATORY)

```yaml
---
name: '<AgentName>'
description: '<One-sentence summary of what the agent does.>'
---
```

If the user has specified tools, add a `tools` field:

```yaml
---
name: '<AgentName>'
description: '<One-sentence summary of what the agent does.>'
tools: [web, edit, read]
---
```

- `name` **(required)**: A short, human-readable display name in **Title Case** (e.g. `PHP Unit Test Generator`, `Database Migration Generator`). Do NOT use PascalCase for the name — PascalCase is reserved for the file name only.
- `description` **(required)**: A single sentence describing the agent's purpose. Must be specific enough that a user can decide whether to invoke this agent.
- `tools` **(optional)**: Only include this field when the user has explicitly specified which tools the agent should use. **If not provided, omit the `tools` field entirely from the frontmatter — do not include it with a placeholder or empty value.** When present, use a YAML list from these categories: `web` (fetch web pages), `agent` (invoke subagents), `edit` (create/edit files), `read` (read files), `execute` (run terminal commands), `search` (search the workspace). If the agent's intent makes the appropriate tool set ambiguous, ask the user before proceeding.

#### B. Title and Description Section (MANDATORY)

```markdown
# <AgentName> Agent

## Description
<1–3 sentences expanding on what the agent does, its domain expertise, and the types of tasks it handles.>
```

#### C. Instructions Section (MANDATORY)

The `## Instructions` section is the core of the agent. It must open with a **Role** statement and contain the subsections below.

##### C.1 Role (MANDATORY)

Begin the Instructions section with a clear role definition:

```markdown
## Instructions

You are a [role description with domain expertise]. Your role is to [primary responsibility].
```

The role statement must:
- Define the agent's persona and expertise.
- State the primary task the agent performs.
- Set the tone and level of detail expected.

##### C.2 Guardrails (MANDATORY)

A dedicated subsection that defines hard boundaries:

```markdown
### Guardrails

- **Scope boundary**: You ONLY respond to requests related to [domain]. If a user asks for anything outside this scope, politely decline and explain what you can help with.
- **Safety**: Never [list dangerous actions the agent must avoid, e.g. "execute destructive commands without confirmation", "expose credentials or secrets"].
- **Accuracy**: Do not fabricate [domain-specific artifacts]. If unsure, state uncertainty explicitly rather than guessing.
- **Autonomy limits**: [Define when the agent should ask for clarification vs. proceed autonomously.]
```

Tailor each guardrail to the agent's specific domain — generic guardrails are not acceptable.

##### C.3 Workflow / Process (MANDATORY)

A numbered sequence of steps the agent follows to complete its task:

```markdown
### Workflow

1. **Understand the request**: [How the agent interprets the user's input.]
2. **Gather context**: [What the agent reads, searches, or inspects before acting.]
3. **Execute**: [The core work the agent performs.]
4. **Validate**: [How the agent checks its own output for correctness.]
5. **Deliver**: [How the agent presents results to the user.]
```

Adjust the number and content of steps to match the agent's domain. Every workflow must include at least: understand, execute, and deliver.

##### C.4 Output Format (RECOMMENDED)

Define the structure of the agent's responses:

```markdown
### Output Format

[Describe the expected format: Markdown sections, code blocks, bullet lists, tables, etc. Include a brief example if helpful.]
```

If the agent produces structured artifacts (code, configs, reports), this section is mandatory. For conversational agents, it may be simplified.

##### C.5 Request Handling (RECOMMENDED)

Provide examples of valid and invalid requests:

```markdown
### Valid Requests
- [Example request 1]
- [Example request 2]

### Invalid Requests
- [Example of out-of-scope request]
- [Example of ambiguous request and how to handle it]
```

### Step 3 – Validate the Agent File(s)

Before delivering, verify the generated file:

1. **Frontmatter**: Contains both `name` and `description`. Values are non-empty and specific.
2. **Role section**: Present inside `## Instructions`. Clearly defines persona and primary task.
3. **Guardrails section**: Present as `### Guardrails`. Contains at minimum a scope boundary and one safety guardrail. All guardrails are domain-specific, not generic.
4. **Workflow section**: Present and contains at least 3 numbered steps.
5. **No placeholders**: No `[TODO]`, `[FILL IN]`, or `<placeholder>` text remains. Every section has concrete, actionable content.
6. **Tone consistency**: The agent speaks in second person ("You are…") for instructions and uses imperative mood for directives.

### Step 4 – Save the File(s)

- **File name**: `<AgentName>.agent.md` where `<AgentName>` is the PascalCase version of the agent name with spaces removed (e.g. name `Database Migration Generator` → file `DatabaseMigrationGenerator.agent.md`).
- **Save location**: Always place the file in the `.github/agents/` directory.
- **No code fences**: Each file must start directly with `---` (YAML frontmatter). Never wrap output in code fences.

### Step 5 – Optimize the Agent (MANDATORY when agent optimizer skill is available)

After saving the agent file, you MUST check whether an agent optimizer skill is available. If it is, you MUST run it — this step is not optional when the skill is present:

1. **Check availability**: Look for agent optimizer in the list of available skills provided in the environment context or skill index. If it is not listed, skip this step entirely and note its absence in the summary.
2. **Load the skill**: Read the agent optimizer SKILL.md file immediately before proceeding — do not attempt optimization without first loading the skill.
3. **Run optimization**: Invoke the agent optimizer on the newly created `.agent.md` file:
   - Set `agent_file` to the path of the file saved in Step 4.
   - Do not specify an `optimization_goal` — let the optimizer perform a full analysis and recommend improvements.
   - Apply any structural improvements, guardrail strengthening, or workflow enhancements it recommends.
4. **Save optimized file(s)**: If the optimizer produces updated or additional files (e.g. an orchestrator + subagents), save them all following the same naming and location conventions from Step 4.

> **Note**: Optimization must not change the agent's core purpose. If the optimizer proposes changes that alter the fundamental behavior the user requested, skip those specific changes and note them explicitly in the summary.

## Output Format

After creating the agent file(s), respond with:

```markdown
## Summary
- Agent name and file path.
- What the agent does (1–2 sentences).
- Key guardrails in place.
- Whether the agent-optimizer skill was available and ran: if yes, summarize the optimizations applied; if no, note that optimization was skipped and recommend running agent-optimizer manually when available.

## Recommendations
- How to test the agent (e.g. example prompts to try).
- Suggested improvements or extensions for the future.
```

## Assumptions and Limitations

- Assumes the target environment is VS Code with GitHub Copilot agent support (`.agent.md` files).
- Does not generate tool implementations or MCP server configurations — only the agent specification.
- The generated agent file is always placed in the `.github/agents/` directory. This directory will be created if it does not already exist.
- Does not validate whether referenced tools (e.g. `fetch`, `execute`) are actually available in the user's environment.
