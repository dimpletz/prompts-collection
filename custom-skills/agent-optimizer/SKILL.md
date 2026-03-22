---
name: agent-optimizer
description: >
  A skill for analyzing and optimizing existing VS Code agent files (.agent.md). Use it whenever the user wants to improve, refactor, or decompose an existing agent into an orchestrator + subagent architecture. Do not use it for creating new agents from scratch — use agent-maker for that.
---

# Agent Optimizer

This **skill** is for developers and prompt engineers who need to improve, refactor, or restructure existing VS Code agent files (`.agent.md`). It covers analyzing agent quality, decomposing monolithic agents into orchestrator + subagent architectures, strengthening guardrails, optimizing workflows, and ensuring structural correctness.

## Inputs

- **agent_file** (required): The path to the existing `.agent.md` file to optimize, or the agent content to analyze.
- **optimization_goal** (optional): What the user wants to improve (e.g. "split into subagents", "improve guardrails", "reduce complexity"). If omitted, perform a full analysis and recommend improvements.
- **constraints** (optional): Any constraints on the optimization (e.g. "keep as a single agent", "must not change the agent's name", "preserve existing tool restrictions").

## Task Priorities

1. **Priority 1 – Preserve existing behavior**
   Optimization must not change the agent's core purpose or break existing functionality. The optimized agent(s) must produce the same outcomes as the original for valid requests.

2. **Priority 2 – Structural improvement**
   Improve the agent's structure: clearer role definition, stronger guardrails, more logical workflow, better separation of concerns. Every change must have a concrete benefit.

3. **Priority 3 – Actionable output**
   The optimized file(s) must be immediately usable — no placeholders, no incomplete sections. Deliver working agent files, not just recommendations.

## Workflow

### Step 1 – Read and Analyze the Existing Agent

- Read the target `.agent.md` file completely.
- Assess the agent against these quality dimensions:
  - **Structural completeness**: Does it have valid YAML frontmatter (`name`, `description`)? Does it have Role, Guardrails, and Workflow sections?
  - **Behavioral clarity**: Are instructions precise and unambiguous? Are scope boundaries clearly defined?
  - **Complexity**: Is the agent trying to do too much? Does it span multiple distinct domains or phases?
  - **Guardrail strength**: Are guardrails domain-specific and actionable, or generic and weak?
  - **Workflow coherence**: Are workflow steps logical, ordered, and complete?
- Produce an internal assessment summary (not shown to user unless requested).

### Step 2 – Identify Optimization Opportunities

Based on the analysis, identify which optimizations apply:

#### A. Orchestrator + Subagent Decomposition

Evaluate whether the agent should be split into an orchestrator and subagents.

**Split into orchestrator + subagents when ANY of these are true:**
- The agent's workflow spans more than ~3 clearly distinct phases that each require different expertise or deep domain logic.
- The agent file exceeds ~300 lines of instructions — a strong signal the agent is trying to do too much.
- Different phases produce intermediate artifacts that a downstream phase consumes (phase output → next phase input).
- Phases can be independently reused or invoked on their own.

**Keep as a single agent when:**
- The workflow is linear, shallow, and domain-cohesive.
- All steps share the same persona and tool set.
- The file stays concise and focused.

#### B. Guardrail Strengthening

- Replace generic guardrails with domain-specific ones.
- Ensure every guardrail uses precise, operational language ("must", "never", "only when").
- Add missing guardrail categories: scope boundary, safety, accuracy, autonomy limits.

#### C. Workflow Optimization

- Ensure every workflow has at least: understand, execute, and deliver steps.
- Remove redundant or overlapping steps.
- Add validation/self-check steps where the agent verifies its own output.
- Identify steps that can be parallelized.

#### D. Role and Description Clarity

- Ensure the role statement clearly defines persona, expertise, and primary task.
- Check that the description in frontmatter is specific enough for a user to decide when to invoke the agent.

#### E. Output Format Improvement

- Ensure the agent defines a structured output format.
- Add examples if the output is complex or non-obvious.

### Step 3 – Execute the Optimization

Based on the identified opportunities, apply changes.

#### For Orchestrator + Subagent Decomposition

When splitting is needed, create:

1. **One orchestrator agent** — the entry point the user interacts with. It:
   - Owns the overall workflow and user communication.
   - Declares its subagents in the frontmatter `agents` field and references them by name in its workflow.
   - Collects and assembles subagent outputs into the final result.
   - Does **not** duplicate the logic that lives in subagents.

2. **One subagent per distinct phase or responsibility** — each subagent:
   - Has a single, well-defined responsibility.
   - Is a fully valid `.agent.md` file with its own frontmatter, Role, and Guardrails.
   - **Must include `user-invocable: false` in its frontmatter** — subagents are not entry points for users and must not appear as directly invocable agents.
   - **Must include a `tools` field** listing only the tools it actually needs to perform its task (e.g. `[read, search]` for a code analysis subagent, `[edit]` for a code generation subagent, `[web]` for a research subagent). Do not assign blanket tool sets — scope each subagent's tools to its specific responsibility.
   - Is saved in the same directory as the orchestrator.
   - Uses a naming convention that ties it to the orchestrator: `<OrchestratorName><Phase>.agent.md` (e.g. `MigrationPlanner.agent.md`, `MigrationExecutor.agent.md`).

##### How the Orchestrator Invokes Subagents

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
tools: [agent]
agents: ['Database Migration Planner', 'Database Migration Executor']
---
```

Example subagent frontmatter:

```yaml
---
name: 'Database Migration Planner'
description: 'Analyzes the schema and produces a migration plan.'
tools: [read, search]
user-invocable: false
---
```

Example orchestrator workflow steps (sequential where required, parallel where independent):

```markdown
3. **Plan and validate (parallel)**: Hand off to `Database Migration Planner` and `Database Migration Validator` simultaneously — they work independently on the same input. Wait for both to complete before proceeding.
4. **Execute migrations (parallel, same subagent)**: For each migration script produced in step 3, invoke `Database Migration Executor` in parallel — one instance per script. Wait for all instances to complete before proceeding.
5. **Finalize**: Collect and summarize all execution reports.
```

> Do NOT write: "Tell the subagent to analyze the schema, identify tables, check foreign keys, generate SQL…" — the subagent's own instructions handle all of that.

##### Frontmatter Fields for Orchestrators and Subagents

- `agents` **(required for orchestrators)**: A YAML list of subagent display names this orchestrator delegates to. **Always single-quote each agent name** (e.g. `agents: ['Database Migration Planner', 'Database Migration Executor']`). **When `agents` is present, the `agent` tool must also be included in the `tools` field** — add it if not already listed.
- `tools` **(required for subagents)**: A YAML list of tools the subagent needs to perform its specific task. Scope this to the minimum required — do not assign all tools by default. Available categories: `web` (fetch web pages), `agent` (invoke further subagents), `edit` (create/edit files), `read` (read files), `execute` (run terminal commands), `search` (search the workspace).
- `user-invocable: false` **(required for subagents)**: Prevents subagents from appearing as directly invocable entry points. Every subagent must include this field. Orchestrators must NOT include this field — they are the user-facing entry point.

#### For All Other Optimizations

- Edit the existing agent file in place.
- Preserve the agent's core identity (name, description, primary purpose).
- Make targeted, specific improvements — do not rewrite the entire file unless the user explicitly requests it.

### Step 4 – Validate the Optimized Agent(s)

Before delivering, verify **each** file (orchestrator and all subagents):

1. **Frontmatter**: Contains both `name` and `description`. Values are non-empty and specific.
2. **Role section**: Present inside `## Instructions`. Clearly defines persona and primary task.
3. **Guardrails section**: Present as `### Guardrails`. Contains at minimum a scope boundary and one safety guardrail. All guardrails are domain-specific, not generic.
4. **Workflow section**: Present and contains at least 3 numbered steps.
5. **No placeholders**: No `[TODO]`, `[FILL IN]`, or `<placeholder>` text remains. Every section has concrete, actionable content.
6. **Tone consistency**: The agent speaks in second person ("You are…") for instructions and uses imperative mood for directives.
7. **Subagent integrity** *(orchestrators only)*: The `agents` frontmatter field lists all subagents by display name. The `tools` field includes `agent`. Workflow steps reference subagents by that name only — no `runSubagent` tool calls, no redundant re-instruction of the subagent's own responsibilities.
8. **Subagent visibility** *(subagents only)*: Every subagent's frontmatter contains `user-invocable: false`. Orchestrators must not have this field.
9. **Subagent tools** *(subagents only)*: Every subagent has a `tools` field scoped to the tools it actually needs for its specific task. No subagent has an empty or missing `tools` field.
8. **Behavioral preservation**: The optimized agent(s) handle the same request types as the original. No capabilities were silently dropped.

### Step 5 – Save and Report

- Save all modified or new files.
- **File name**: `<AgentName>.agent.md` where `<AgentName>` is the PascalCase version of the agent name with spaces removed. Subagents follow the same convention with their phase appended.
- **Save location**: Place all files in the same directory as the original agent. If the original is in `.github/agents/`, save there.
- **No code fences**: Each file must start directly with `---` (YAML frontmatter). Never wrap output in code fences.

## Output Format

After optimizing the agent file(s), respond with:

```markdown
## Analysis
- Current state assessment (1–3 bullets).
- Optimization opportunities identified.

## Changes Applied
- List each change with a brief rationale.
- If orchestrator + subagents were created, list all files.

## Summary
- What was optimized and why.
- Key improvements in place.

## Recommendations
- How to test the optimized agent (e.g. example prompts to try).
- Suggested further improvements for the future.
```

## Assumptions and Limitations

- Assumes the target environment is VS Code with GitHub Copilot agent support (`.agent.md` files).
- Requires an existing agent file to optimize — for creating new agents from scratch, use the agent maker skill if available.
- Does not generate tool implementations or MCP server configurations — only optimizes the agent specification.
- Preserves the agent's core purpose during optimization — behavioral changes are flagged explicitly.
- Does not validate whether referenced tools (e.g. `fetch`, `execute`) are actually available in the user's environment.
