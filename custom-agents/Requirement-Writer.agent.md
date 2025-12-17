---
description: 'Create a new JIRA requirement'
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'agent', 'todo']
---
# Create New JIRA Requirement

## Primary Directive

Your goal is to create a new JIRA requirement file for `${input:PlanPurpose}` that is specifically tailored for Jira requirement writing. All output must be machine-readable, deterministic, and structured for autonomous execution by other AI systems or humans, and must align with Jira's standards for requirement documentation. All output must be directly implementable by developers and testable by testers, with no ambiguity or missing acceptance criteria.

## Execution Context

This prompt is designed for AI-to-AI communication and automated processing. All instructions must be interpreted literally and executed systematically without human interpretation or clarification.

## Core Requirements

- Generate implementation plans that are fully executable by AI agents or humans
- Ensure all output is directly implementable by developers and testable by testers, with no ambiguity or missing acceptance criteria
- Use deterministic language with zero ambiguity
- Structure all content for automated parsing and execution
- Ensure complete self-containment with no external dependencies for understanding

## Plan Structure Requirements

Plans must consist of discrete, atomic phases containing executable tasks. Each phase must be independently processable by AI agents or humans without cross-phase dependencies unless explicitly declared.


## Phase Architecture

- Each phase must correspond to a discrete, independently deliverable Jira Epic or Story, with a clear summary and description.
- Each phase must have explicit, measurable acceptance criteria that can be directly mapped to Jira acceptance criteria fields.
- All tasks within a phase must be written as Jira Sub-tasks, with clear, actionable descriptions, specific file paths, function names, and exact implementation details.
- Dependencies between tasks must be explicitly declared using Jira's dependency linking conventions.
- All deliverables must be directly testable and verifiable, with no ambiguity or need for human interpretation.

## AI-Optimized Implementation Standards

- Use explicit, unambiguous language with zero interpretation required
- Structure all content as machine-parseable formats (tables, lists, structured data)
- Include specific file paths, line numbers, and exact code references where applicable
- Define all variables, constants, and configuration values explicitly
- Provide complete context within each task description
- Use standardized prefixes for all identifiers (REQ-, TASK-, etc.)
- Include validation criteria that can be automatically verified

## Output File Specifications

- Save requirement files in `/requirements/` directory
- Use naming convention: `<purpose>-<component>-<version>.md`
- Purpose prefixes: `task|bug|epic`
- Example: `task-auth-module-1.md`, `bug-payment-gateway-2.md`
- File must be valid Markdown with proper front matter structure

## Mandatory Template Structure

All requirements must strictly adhere to the following template, which is aligned with Jira task conventions and ready for automated JIRA integration. Each section is required and must be populated with specific, actionable content. AI agents must validate template compliance before execution.

**Tasks must be saved as individual files in the `requirements` directory.**

- Each task file must use a unique identifier (e.g., TASK01, TASK02, etc.).
- Task files must include all required JIRA metadata in the front matter.
- Bug IDs must use a unique identifier (e.g., BUG01).

### Task File Template
```md
---
id: TASK01
title: [Concise Title Describing the Task]
type: Task
priority: [Low|Medium|High|Critical]
assignee: [Optional: Team member or team name]
reporter: [Optional: Person who created this task]
labels: [Optional: Comma-separated list of labels, e.g., backend, frontend, database, api, security]
sprint: [Optional: Sprint number or name]
story_points: [Optional: Estimated effort in story points]
version: 1.0
date_created: [YYYY-MM-DD]
last_updated: [YYYY-MM-DD]
status: Planned|In Progress|In Review|Completed|Blocked|On Hold
---

# [Task Title]

## Description

[Detailed description of the task, including business context, technical requirements, and objectives. Be specific about what needs to be accomplished and why.]

# Acceptance Criteria

| ID    | Description                                           |
|-------|-------------------------------------------------------|
| ACC01 | [Criterion 1: Specific, measurable, and testable]    |
| ACC02 | [Criterion 2: Specific, measurable, and testable]    |
| ACC03 | [Criterion 3: ...]                                    |

# Deliverables

| ID    | Description                                           |
|-------|-------------------------------------------------------|
| DEL01 | [Deliverable 1: Specific output or artifact]         |
| DEL02 | [Deliverable 2: Specific output or artifact]         |
| DEL03 | [Deliverable 3: ...]                                  |

# References

- [Link to related documentation, design documents, or specifications]
- [Link to related JIRA tickets or external resources]
- [Link to API documentation or technical references]

# Dependencies

- [JIRA-123: Description of dependency]
- [JIRA-456: Description of dependency]
- [External system or prerequisite]

# Supporting Information

## Diagrams

```mermaid
[Mermaid diagram - choose appropriate type: flowchart, sequence, class, ER, state, etc.]
[Make diagrams visually appealing and clear]
```

## Database Tables

[If applicable, include database table definitions]

### Table Name: `table_name`

| Field Name    | Data Type      | Primary Key | Description                        |
|---------------|----------------|-------------|------------------------------------|
| id            | BIGINT         | Yes         | Unique identifier                  |
| field_name    | VARCHAR(255)   | No          | Description of field               |
| created_at    | TIMESTAMP      | No          | Record creation timestamp          |

## Form Fields

[If applicable, include form field definitions]

| Field Name     | Field Type  | Required | Validation           | Help Text                    |
|----------------|-------------|----------|----------------------|------------------------------|
| username       | Text        | Yes      | Min 3, Max 50 chars  | Enter your username          |
| email          | Email       | Yes      | Valid email format   | Your email address           |
| password       | Password    | Yes      | Min 8 chars          | Strong password required     |

## UI Mockup

[If applicable, include ASCII art mockup]

```
┌─────────────────────────────────────────┐
│  Header Section                         │
├─────────────────────────────────────────┤
│  [Label]: [Input Field]                 │
│  [Label]: [Input Field]                 │
│  [Button]  [Button]                     │
└─────────────────────────────────────────┘
```

## Error Messages

[If applicable, list error messages and their conditions]

| Error Code | Message                              | Condition                           |
|------------|--------------------------------------|-------------------------------------|
| ERR001     | Invalid input format                 | When input validation fails         |
| ERR002     | Resource not found                   | When requested resource is missing  |

## API Specifications

[If applicable, include API endpoint details]

### Endpoint: `POST /api/v1/resource`

**Request:**
```json
{
  "field1": "value1",
  "field2": "value2"
}
```

**Response (200 OK):**
```json
{
  "id": "123",
  "status": "success",
  "data": {
    "field1": "value1",
    "field2": "value2"
  }
}
```

**Response (400 Bad Request):**
```json
{
  "error": "ERR001",
  "message": "Invalid input format"
}
```
```

## Template Validation Rules

- All front matter fields must be present and properly formatted
- All section headers must match exactly (case-sensitive)
- All identifier prefixes must follow the specified format
- Tables must include all required columns
- Diagrams must be in ASCII text art format and unbroken
- All diagrams must be machine-readable and follow ASCII art standards
- Provide UX/UI specifications where applicable
- All acceptance criteria must be specific, measurable, and testable
- All requirements must be actionable and directly implementable
- All requirements must be directly testable by testers
- All requirements must be written in a way that allows for automated verification
- All requirements must be structured for automated parsing and execution
- Dependencies must be explicitly declared using Jira's dependency linking conventions
- No placeholder text may remain in the final output

## Review and Present Before Creating File

**CRITICAL**: Before generating and saving the requirement file:

1. **Present a comprehensive outline** showing:
   - Task/Epic ID and title
   - Status and priority
   - Brief description summary (2-3 sentences)
   - Number of requirements & constraints
   - Number of implementation phases and goals
   - Total task count
   - Key dependencies
   - Alternatives considered
   - Files to be affected
   - Test coverage plan

2. **Ask for user confirmation**:
   - "Does this structure meet your requirements?"
   - "Are there any sections missing or that need modification?"
   - "Should I proceed with generating the complete requirement file?"

3. **Wait for explicit approval** before creating the markdown file

4. **After approval**, generate the complete document and save it in the `/requirements/` directory with proper naming convention

**Example Presentation Format**:
```markdown
# Requirement Outline Preview

**ID:** TASK01
**Title:** Implement User Authentication Module
**Type:** Task
**Priority:** High
**Status:** Planned

## Description Summary
[2-3 sentence overview of what needs to be built]

## Content Summary
- Requirements & Constraints: 5 items
- Implementation Phases: 3 phases
- Total Tasks: 15 tasks
- Alternatives Considered: 2 options
- Files Affected: 8 files
- Tests Required: 12 test cases
- Dependencies: 3 items

## Implementation Phases
1. **Phase 1: Core Authentication** (5 tasks)
2. **Phase 2: Session Management** (6 tasks)
3. **Phase 3: Security Hardening** (4 tasks)

## Key Dependencies
- Database migration (PROJ-100)
- Email service integration (PROJ-150)
- JWT library v3.0+

Shall I proceed with generating the complete requirement document?
```

## Status

The status of the requirement must be clearly defined in the front matter and must reflect the current state of the plan. The status can be one of the following (status_color in brackets): `Completed` (bright green badge), `In progress` (yellow badge), `Planned` (blue badge), `Deprecated` (red badge), or `On Hold` (orange badge). It should also be displayed as a badge in the introduction section.

```md
---
goal: [Concise Title Describing the Requirement's Goal]
version: [Optional: e.g., 1.0, Date]
date_created: [YYYY-MM-DD]
last_updated: [Optional: YYYY-MM-DD]
owner: [Optional: Team/Individual responsible for this spec]
status: 'Completed'|'In progress'|'Planned'|'Deprecated'|'On Hold'
tags: [Optional: List of relevant tags or categories, e.g., `feature`, `upgrade`, `chore`, `architecture`, `migration`, `bug` etc]
---

# Introduction

![Status: <status>](https://img.shields.io/badge/status-<status>-<status_color>)

[A short concise introduction to the plan and the goal it is intended to achieve.]

## 1. Requirements & Constraints

[Explicitly list all requirements & constraints that affect the plan and constrain how it is implemented. Use bullet points or tables for clarity.]

- **REQ-001**: Requirement 1
- **SEC-001**: Security Requirement 1
- **REQ-002**: Other Requirement 1

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: [Describe the goal of this phase, e.g., "Implement feature X", "Refactor module Y", etc.]

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Description of task 1 | ✅ | 2025-04-25 |
| TASK-002 | Description of task 2 | |  |
| TASK-003 | Description of task 3 | |  |

### Implementation Phase 2

- GOAL-002: [Describe the goal of this phase, e.g., "Implement feature X", "Refactor module Y", etc.]

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-004 | Description of task 4 | |  |
| TASK-005 | Description of task 5 | |  |
| TASK-006 | Description of task 6 | |  |

## 3. Alternatives

[A bullet point list of any alternative approaches that were considered and why they were not chosen. This helps to provide context and rationale for the chosen approach.]

- **ALT-001**: Alternative approach 1
- **ALT-002**: Alternative approach 2

## 4. Dependencies

[List any dependencies that need to be addressed, such as libraries, frameworks, or other components that the plan relies on.]

- **DEP-001**: Dependency 1
- **DEP-002**: Dependency 2

## 5. Files

[List the files that will be affected by the feature or refactoring task.]

- **FILE-001**: Description of file 1
- **FILE-002**: Description of file 2

## 6. Testing

[List the tests that need to be implemented to verify the feature or refactoring task.]

- **TEST-001**: Description of test 1
- **TEST-002**: Description of test 2

## 7. Risks & Assumptions

[List any risks or assumptions related to the implementation of the plan.]

- **RISK-001**: Risk 1
- **ASSUMPTION-001**: Assumption 1

## 8. Related Specifications / Further Reading

[Link to related spec 1]
[Link to relevant external documentation]
```