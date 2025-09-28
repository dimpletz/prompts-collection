---
mode: 'agent'
description: 'Create a new JIRA requirement'
author: 'Ofelia B Webb'
tools: ['changes', 'codebase', 'editFiles', 'fetch', 'openSimpleBrowser', 'search', 'searchResults']
---
# Create Implementation Plan

## Primary Directive

Your goal is to create a new implementation plan file for `${input:PlanPurpose}` that is specifically tailored for Jira requirement writing. All output must be machine-readable, deterministic, and structured for autonomous execution by other AI systems or humans, and must align with Jira's standards for requirement documentation. All output must be directly implementable by developers and testable by testers, with no ambiguity or missing acceptance criteria.

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
- Purpose prefixes: `user-story|bug|task|epic`
- Example: `user-story-auth-module-1.md`, `bug-payment-gateway-2.md`
- File must be valid Markdown with proper front matter structure


## Mandatory Template Structure

All requirements must strictly adhere to the following template, which is aligned with Jira user story and subtask conventions. Each section is required and must be populated with specific, actionable content. AI agents must validate template compliance before execution.


**User stories and subtasks must be saved as separate files, and grouped in the same directory.**

- Each user story and its subtasks must be placed in a dedicated folder under `/requirements/`.
- The folder name must be the user story ID and the user story title, separated by a hyphen (e.g., `US01-login-authentication`).
- The user story file must use a unique identifier (e.g., US01).
- Each subtask must be a separate file, named using the user story ID as a prefix and a subtask number (e.g., US01-1, US01-2, etc.).
- Subtask files must reference their parent user story ID.
**User stories and subtasks must be saved as separate files, and grouped in the same directory.**

- Each user story and its subtasks must be placed in a dedicated folder under `/requirements/`.
- The folder name must be the user story ID and the user story title, separated by a hyphen (e.g., `M2-US01-login-authentication`).
- The user story file must use a unique identifier prefixed with `M2-` (e.g., M2-US01).
- Each subtask must be a separate file, named using the user story ID as a prefix and a subtask number (e.g., M2-US01-1, M2-US01-2, etc.).
- Subtask files must reference their parent user story ID (e.g., parent_id: M2-US01).
- Bug IDs must be prefixed with `M2-` as well (e.g., M2-BUG01).

### User Story File Template
```md
id: M2-US01
goal: [Concise Title Describing the Requirement's Goal]
version: [Optional: e.g., 1.0, Date]
date_created: [YYYY-MM-DD]
last_updated: [Optional: YYYY-MM-DD]
owner: [Optional: Team/Individual responsible for this spec]
status: 'Completed'|'In progress'|'Planned'|'Deprecated'|'On Hold'
tags: [Optional: List of relevant tags or categories, e.g., `feature`, `upgrade`, `chore`, `architecture`, `migration`, `bug` etc]
---

# User Story

## Title
[Short, clear title for the user story]

## Description
[Detailed description of the user story, including business context and objectives.]

## Acceptance Criteria
| ID    | Acceptance Criteria                        |
|-------|--------------------------------------------|
| AC01  | [Criterion 1: Specific, measurable, and testable] |
| AC02  | [Criterion 2: ...]                         |

## Dependencies
- [Jira issue key or description of dependency]

## Reference
- [Link to related documentation, specs, or tickets]

## Supporting Information
- [ASCII text art diagram (use sequence diagram if applicable), tables, mockups, or other supporting artifacts]
```

### Subtask File Template
```md
id: M2-US01-1
parent_id: M2-US01
goal: [Concise Title Describing the Subtask Goal]
version: [Optional: e.g., 1.0, Date]
date_created: [YYYY-MM-DD]
last_updated: [Optional: YYYY-MM-DD]
owner: [Optional: Team/Individual responsible for this subtask]
status: 'Completed'|'In progress'|'Planned'|'Deprecated'|'On Hold'
tags: [Optional: List of relevant tags or categories]
---

# Subtask

## Description
[Detailed description of the subtask, including context and objectives.]

## Deliverables
| ID    | Description                |
|-------|----------------------------|
| DEL01 | [Deliverable 1 description]|
| DEL02 | [Deliverable 2 description]|

## Dependencies
- [Jira issue key, subtask, or description of dependency]

## Role
- [DEV/QA/BA]

## Reference
- [Link to related documentation, specs, or tickets]

## Supporting Information
- [ASCII text art diagram (use sequence diagram if applicable), tables, mockups, or other supporting artifacts]
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

- **M2-REQ-001**: Requirement 1
- **M2-SEC-001**: Security Requirement 1
- **M2-REQ-002**: Other Requirement 1

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