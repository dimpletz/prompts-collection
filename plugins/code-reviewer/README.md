# Code Reviewer `v1.0.0`

> A collection of agents for performing comprehensive, evidence-based code quality reviews across multiple programming languages and frameworks.

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) extension installed and active.

## Installation

Install via the VS Code Chat Plugin Marketplace using the `dimpletz/prompts-collection` marketplace source and enable the **code-reviewer** plugin.

## Usage

Open Copilot Chat, select one of the code reviewer agents, and provide the diff file path or code to review.

```
# Code Reviewer (diff-based, full pipeline)
"Review the diff at /tmp/diff-files/my-feature.diff"
"Run a code review on C:\work\changes.diff"

# General code review agents (inline code, files, folders)
"Review this PHP class for security vulnerabilities and PSR-12 compliance"
"Analyze the src/services folder for performance bottlenecks and SOLID violations"
"Check this TypeScript component for best practices and accessibility issues"
```

## Components

| Component | Type | Invoke when… |
|-----------|------|--------------|
| **Code Reviewer** | Agent (orchestrator) | You have a diff file and want a full end-to-end review: diff splitting, language detection, cross-cutting and language-specific rule application, and a structured Markdown report saved automatically. |
| **Language Rules Auditor** | Agent (sub-agent) | Automatically dispatched by Code Reviewer for each diff chunk. Loads applicable rules via the review-rules-provider skill and returns structured findings. Not intended for direct invocation. |
| **Code Quality Reviewer** | Agent | You want a comprehensive, multi-language code review covering coding standards, architecture, security, performance, and maintainability across Magento 2, Laravel, Symfony, .NET, JavaScript/TypeScript, Python, and more. |
| **Comprehensive Code Quality Reviewer** | Agent | You need an in-depth, evidence-based review with every recommendation backed by verified official documentation, plus a Confluence-ready Markdown report with executive summary, production readiness assessment, and timestamped file output. |
| **Universal Code Quality Reviewer** | Agent | You want a language-agnostic review following a systematic process covering code quality, coding standards, best practices, security, performance, and scalability across any major programming language or framework. |
| **Diff Chunker** | Skill | You have a diff file that exceeds `CODE_REVIEW_DIFF_CHUNK_MAX_LINES` lines and need to split it into smaller, reviewable chunks before code review. |
| **Review Rules Provider** | Skill | Automatically invoked by the Language Rules Auditor to load the applicable rule set for a review pass (cross-cutting + primary-language + chunk-language rules). Not intended for direct invocation. |
| **Code Review Report Appender** | Skill | Automatically invoked by the Language Rules Auditor to append findings to the shared report file. Not intended for direct invocation. |

### Code Reviewer

Orchestrates the full diff-based code review pipeline. Accepts a diff file, splits it into reviewable chunks using the diff-chunker skill, detects the project-level primary language, and dispatches the **Language Rules Auditor** sub-agent once per chunk. The Language Rules Auditor uses the **code-review-report-appender** skill to append its findings directly to the shared report file. The report is saved to `CODE_REVIEW_REPORT_DIR` when set, otherwise to `<workspace root>/code-reviews/`. Report filename format: `<workspace-dir-name>-<diff-basename>-<YYYY-MM-DD-HH-mm>.md`.

**Report structure**:
- Header with reviewer name and date
- `[TOC]` placeholder
- Ignored files section (if any)
- Unreviewed oversized files section (if any)
- Per-file review sections appended by the Language Rules Auditor via the code-review-report-appender skill

### Language Rules Auditor

Sub-agent dispatched by the Code Reviewer orchestrator for each diff chunk. Detects which languages appear in the chunk, invokes the **review-rules-provider** skill to load the applicable rule set (cross-cutting + project primary-language + chunk-detected language rules), and applies those rules to every changed file. For files whose language has no matching rule file, the auditor applies cross-cutting rules and falls back to built-in expertise. Uses the **code-review-report-appender** skill to append findings directly to the shared report file.

### Code Quality Reviewer

Expert code quality reviewer with deep knowledge of PHP (Magento 2, Laravel, Symfony), .NET (C#, ASP.NET Core), JavaScript/TypeScript (React, Vue.js, Angular, Node.js), Python (Django, Flask, FastAPI), CSS/SCSS, SQL, and more. Reviews individual files, selections, modules, or entire codebases against coding standards, SOLID principles, security best practices, and performance guidelines. Produces structured, prioritized findings grouped by category.

### Comprehensive Code Quality Reviewer

Performs thorough, evidence-based code quality analysis against established quality standards and all non-functional requirements (NFRs): security, reliability, performance, scalability, maintainability, usability, portability, compatibility, compliance, and localization. Every finding is backed by a verified URL to official documentation. Generates a Confluence-ready Markdown report saved to the workspace root with a timestamp in the filename. Includes an executive summary, summary statistics table, production readiness verdict, and detailed findings with code snippets.

**Key guardrails**:
- Only reviews code — will not write new features or fix code directly.
- Asks for clarification before proceeding if the language or scope is ambiguous.
- Skips or marks findings as unverified if official documentation cannot be found.

### Universal Code Quality Reviewer

Language-agnostic reviewer that applies a consistent four-step process (Identification → Analysis → Prioritization → Reporting) across PHP, JavaScript/TypeScript, Python, C#/.NET, Java, Go, Ruby, and SQL. Findings are categorized as Critical, High, Medium, or Low and include the exact file location, code snippet, explanation of the problem, and a recommended fix with a code example. Strictly avoids hallucinating URLs or references.

### Diff Chunker

Splits a large diff file into smaller chunk files for code review by running a companion script. Diff sections whose line count exceeds `CODE_REVIEW_DIFF_CHUNK_MAX_LINES` are saved as standalone oversized files. All output files are placed in the same directory as the input diff file, named `<original>-chunk-<n>.diff` for chunks and `<original>-<sanitized-section-path>.diff` for oversized sections.

### Review Rules Provider

Loads and concatenates the applicable rule set for a review pass. Always includes the cross-cutting (language-agnostic) rules and the project primary-language rules. Appends rules for any additional languages detected in the diff chunk. Deduplicates rule files so each is included at most once. Invoked by the Language Rules Auditor; not intended for direct use.

### Code Review Report Appender

Appends markdown content to an existing code review report file using a platform-appropriate terminal command. Invoked by the Language Rules Auditor at the end of each chunk review to write its findings to the shared report. Requires the report file to exist — the Code Reviewer orchestrator creates it before dispatching any sub-agents. Not intended for direct invocation.

## Hook

| Event | Environment Variable | Default | What it does |
|-------|---------------------|---------|-------------|
| `SessionStart` | `CODE_REVIEW_DIFF_CHUNK_MAX_LINES` | `500` | Injects the maximum number of diff lines per chunk into the agent context so the `diff-chunker` skill picks it up automatically. Set the environment variable before starting VS Code to override the default. |
| `SessionStart` | `CODE_REVIEW_IGNORE_FILE` | _(none)_ | When set, injects the path to a gitignore-style file listing diff sections to exclude from review. If not set, the plugin's default `config/.ignore` file is used by the `diff-chunker` skill. |
| `SessionStart` | `CODE_REVIEW_REPORT_DIR` | _(none)_ | When set, injects the directory path where the Code Reviewer agent saves its Markdown report. If not set, the agent saves to `<workspace root>/code-reviews/`. |

## Author

[Ron Webb](https://github.com/dimpletz)
