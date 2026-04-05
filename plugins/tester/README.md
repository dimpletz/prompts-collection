# Tester `v1.0.0`

> A collection of agents for generating comprehensive, JIRA-ready test cases from requirements and acceptance criteria.

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) extension installed and active.

## Installation

Install via the VS Code Chat Plugin Marketplace using the `dimpletz/prompts-collection` marketplace source and enable the **tester** plugin.

## Usage

Open Copilot Chat, select the **Test Case Generator** agent, and provide the requirements, user stories, or acceptance criteria you want test cases for.

```
# Examples
"Generate test cases for this user story: As a user I want to reset my password"
"Create test cases for the checkout flow based on these acceptance criteria: ..."
"Generate test cases from this requirements document"
```

## Components

### Test Case Generator

An expert QA test case generator that transforms requirements, user stories, and acceptance criteria into comprehensive, immediately executable test cases. Produces structured, tabular test cases with:

- **Test case ID** — unique identifier for traceability
- **Test scenario** — what is being tested
- **Test steps** — clear, ordered steps to execute
- **Expected result** — the anticipated outcome
- **Priority** — High / Medium / Low
- **Type** — Functional, Negative, Edge Case, Boundary, etc.

**Key behaviors:**
- Works only from provided requirements — never invents features or business logic
- Produces test cases ready for direct import into JIRA (when JIRA tools are available)
- Does **not** generate test automation code unless explicitly requested

## Author

[Dimpletz](https://github.com/dimpletz)
