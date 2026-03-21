---
name: agent-maker
description: >
  A skill for creating VS Code agent files (.agent.md). Use it whenever the user asks to create a new custom agent, define an agent persona, or scaffold an agent specification. Do not use it for editing existing agents beyond structural fixes, creating skills, or writing general documentation.
---

# Agent Maker

This **skill** is for developers and prompt engineers who need to create well-structured, production-ready VS Code agent files (`.agent.md`). It enforces a consistent structure with required frontmatter fields and mandatory body sections, while allowing flexibility for domain-specific content.

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

### Step 1.5 – Decide: Single Agent or Orchestrator + Subagents

Before composing any file, assess whether the agent can be expressed as a single, focused agent or needs to be split into an orchestrator and subagents.

**Split into orchestrator + subagents when ANY of these are true:**
- The agent's workflow spans more than ~3 clearly distinct phases that each require different expertise or deep domain logic.
- The resulting single-agent file would exceed ~300 lines of instructions — a strong signal the agent is trying to do too much.
- Different phases produce intermediate artifacts that a downstream phase consumes (phase output → next phase input).
- Phases can be independently reused or invoked on their own.

**Keep as a single agent when:**
- The workflow is linear, shallow, and domain-cohesive.
- All steps share the same persona and tool set.
- The file stays concise and focused.

#### Orchestrator + Subagent Architecture

When splitting is needed, create:

1. **One orchestrator agent** — the entry point the user interacts with. It:
   - Owns the overall workflow and user communication.
   - Declares its subagents in the frontmatter `agents` field and references them by name in its workflow.
   - Collects and assembles subagent outputs into the final result.
   - Does **not** duplicate the logic that lives in subagents.

2. **One subagent per distinct phase or responsibility** — each subagent:
   - Has a single, well-defined responsibility.
   - Is a fully valid `.agent.md` file with its own frontmatter, Role, and Guardrails.
   - Is saved in the same `.github/agents/` directory as the orchestrator.
   - Uses a naming convention that ties it to the orchestrator: `<OrchestratorName><Phase>.agent.md` (e.g. `MigrationPlanner.agent.md`, `MigrationExecutor.agent.md`).

#### How the Orchestrator Invokes Subagents

The orchestrator declares its subagents in its frontmatter using the `agents` field and references them by name in its workflow instructions. **Do not use `runSubagent` tool calls** — just name the agent.

- **Parallel by default**: When two or more subagents do not depend on each other's output, instruct the orchestrator to invoke them in parallel. Only sequence subagents when one step's output is required as input to the next.
- **Same subagent in parallel**: A single subagent can also be invoked multiple times in parallel when the same task must be applied to independent inputs (e.g. running a `Code Reviewer` agent on each file in a batch simultaneously). Make this explicit in the orchestrator's workflow when applicable.
- **Minimal invocation**: When referencing a subagent in the workflow, pass only the essential context it needs (e.g. the artifact from the previous step, or the user's original input). Do not re-explain the subagent's job — it already knows what to do from its own instructions.
- **Wait for output**: After delegating to a subagent (or a parallel group), wait for all outputs before proceeding. Do not assume or pre-fill results.
- **Use output as-is**: Trust and use the subagent's output directly. Do not re-validate or rewrite it unless the orchestrator's role explicitly requires a synthesis step.

Example orchestrator frontmatter:

```yaml
---
name: 'Database Migration Generator'
description: 'Orchestrates database migration planning and execution.'
agents: ['Database Migration Planner', 'Database Migration Executor']
---
```

Example orchestrator workflow steps (sequential where required, parallel where independent):

```markdown
3. **Plan and validate (parallel)**: Hand off to `Database Migration Planner` and `Database Migration Validator` simultaneously — they work independently on the same input. Wait for both to complete before proceeding.
4. **Execute migrations (parallel, same subagent)**: For each migration script produced in step 3, invoke `Database Migration Executor` in parallel — one instance per script. Wait for all instances to complete before proceeding.
5. **Finalize**: Collect and summarize all execution reports.
```

> Do NOT write: "Tell the subagent to analyze the schema, identify tables, check foreign keys, generate SQL…" — the subagent's own instructions handle all of that.

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
- `agents` **(optional, orchestrators only)**: A YAML list of subagent display names this orchestrator delegates to. **Always single-quote each agent name** (e.g. `agents: ['Database Migration Planner', 'Database Migration Executor']`). Only include when the agent uses subagents. Omit entirely for single agents.

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

Before delivering, verify **each** generated file (orchestrator and all subagents):

1. **Frontmatter**: Contains both `name` and `description`. Values are non-empty and specific.
2. **Role section**: Present inside `## Instructions`. Clearly defines persona and primary task.
3. **Guardrails section**: Present as `### Guardrails`. Contains at minimum a scope boundary and one safety guardrail. All guardrails are domain-specific, not generic.
4. **Workflow section**: Present and contains at least 3 numbered steps.
5. **No placeholders**: No `[TODO]`, `[FILL IN]`, or `<placeholder>` text remains. Every section has concrete, actionable content.
6. **Tone consistency**: The agent speaks in second person ("You are…") for instructions and uses imperative mood for directives.
7. **Subagent calls** *(orchestrators only)*: The `agents` frontmatter field lists all subagents by display name. Workflow steps reference subagents by that name only — no `runSubagent` tool calls, no redundant re-instruction of the subagent's own responsibilities.

### Step 4 – Save the File(s)

- **File name**: `<AgentName>.agent.md` where `<AgentName>` is the PascalCase version of the agent name with spaces removed (e.g. name `Database Migration Generator` → file `DatabaseMigrationGenerator.agent.md`). Subagents follow the same convention with their phase appended (e.g. `DatabaseMigrationPlanner.agent.md`).
- **Save location**: Always place all files (orchestrator and subagents) in the `.github/agents/` directory.
- **No code fences**: Each file must start directly with `---` (YAML frontmatter). Never wrap output in code fences.

## Output Format

After creating the agent file(s), respond with:

```markdown
## Summary
- Agent name(s) and file path(s). If an orchestrator + subagents were created, list all files.
- What the agent does (1–2 sentences).
- Key guardrails in place.

## Recommendations
- How to test the agent (e.g. example prompts to try).
- Suggested improvements or extensions for the future.
```

## Assumptions and Limitations

- Assumes the target environment is VS Code with GitHub Copilot agent support (`.agent.md` files).
- Does not generate tool implementations or MCP server configurations — only the agent specification.
- The generated agent file is always placed in the `.github/agents/` directory. This directory will be created if it does not already exist.
- Does not validate whether referenced tools (e.g. `fetch`, `execute`) are actually available in the user's environment.
