# Prompts Collection

A curated collection of specialized AI prompts, designed to enhance productivity and automate common tasks through intelligent conversation interfaces.

[TOC]

## Plugins `v1.19.0`

The collection is organized into plugins. Each plugin groups related agents and/or skills by domain.

| Plugin | Description | Agents | Skills | Hooks |
|--------|-------------|--------|--------|-------|
| [analyst](plugins/analyst/) `v1.0.0` | Agents for writing requirements specifications and generating solution designs. | [Requirements Specification Writer](plugins/analyst/agents/RequirementsSpecificationWriter.agent.md), [Requirements Specification Writer Analyzer](plugins/analyst/agents/RequirementsSpecificationWriterAnalyzer.agent.md), [Requirements Specification Writer Documenter](plugins/analyst/agents/RequirementsSpecificationWriterDocumenter.agent.md), [Solution Design Generator](plugins/analyst/agents/SolutionDesignGenerator.agent.md) | — | — |
| [developer](plugins/developer/) `v1.2.0` | Agents and skills for code quality reviews, unit test generation, release notes, and developer name injection. | [Code Quality Reviewer](plugins/developer/agents/CodeQualityReviewer.agent.md), [Comprehensive Code Quality Reviewer](plugins/developer/agents/ComprehensiveCodeQualityReviewer.agent.md), [Universal Code Quality Reviewer](plugins/developer/agents/UniversalCodeQualityReviewer.agent.md), [Comprehensive Unit Test Generator](plugins/developer/agents/ComprehensiveUnitTestGenerator.agent.md), [Comprehensive Unit Test Analyzer](plugins/developer/agents/ComprehensiveUnitTestGeneratorAnalyzer.agent.md), [Comprehensive Unit Test Executor](plugins/developer/agents/ComprehensiveUnitTestGeneratorExecutor.agent.md), [Comprehensive Unit Test Code Generator](plugins/developer/agents/ComprehensiveUnitTestGeneratorGenerator.agent.md), [Comprehensive Unit Test Reporter](plugins/developer/agents/ComprehensiveUnitTestGeneratorReporter.agent.md), [Release Notes Generator](plugins/developer/agents/ReleaseNotesGenerator.agent.md), [Universal Unit Test Generator](plugins/developer/agents/UniversalUnitTestGenerator.agent.md) | [Changelog Maintainer](plugins/developer/skills/changelog-maintainer/SKILL.md), [README Maintainer](plugins/developer/skills/readme-maintainer/SKILL.md) | `SessionStart`, `SubagentStart` |
| [dotnet-developer](plugins/dotnet-developer/) `v1.0.0` | Agents for generating and maintaining unit tests for .NET/C# applications. | [.NET Unit Test Generator](plugins/dotnet-developer/agents/DotNetUnitTestGenerator.agent.md) | — | — |
| [git-manager](plugins/git-manager/) `v1.3.0` | Skills for managing Git repositories, worktrees, merge conflicts, pull requests, and diff generation. | — | [Git Merge Conflict Resolver](plugins/git-manager/skills/git-merge-conflict-resolver/SKILL.md), [Git Worktree Manager](plugins/git-manager/skills/git-worktree-manager/SKILL.md), [Git PR Cloner](plugins/git-manager/skills/git-pr-cloner/SKILL.md), [Git Merge Auditor](plugins/git-manager/skills/git-merge-auditor/SKILL.md), [Git Diff Generator](plugins/git-manager/skills/git-diff-generator/SKILL.md) | `SessionStart`, `SubagentStart` |
| [leader](plugins/leader/) `v1.0.0` | Agents for creating compelling presentations and communicating ideas effectively. | [Presenter](plugins/leader/agents/Presenter.agent.md) | — | — |
| [ai-engineer](plugins/ai-engineer/) `v1.3.0` | Skills for creating and optimizing VS Code agents, skills, hooks, plugins, and custom instruction files. | — | [Agent Maker](plugins/ai-engineer/skills/agent-maker/SKILL.md), [Agent Optimizer](plugins/ai-engineer/skills/agent-optimizer/SKILL.md), [Custom Instruction Maker](plugins/ai-engineer/skills/custom-instruction-maker/SKILL.md), [Skill Maker](plugins/ai-engineer/skills/skill-maker/SKILL.md), [Hook Maker](plugins/ai-engineer/skills/hook-maker/SKILL.md), [Plugin Maker](plugins/ai-engineer/skills/plugin-maker/SKILL.md), [Marketplace Maker](plugins/ai-engineer/skills/marketplace-maker/SKILL.md) | — |
| [php-developer](plugins/php-developer/) `v1.0.0` | Agents for generating and maintaining unit tests for PHP applications. | [PHP Unit Test Generator](plugins/php-developer/agents/PHPUnitTestGenerator.agent.md) | — | — |
| [software-evaluator](plugins/software-evaluator/) `v1.0.0` | Agents for evaluating cloud-native applications and software procurement decisions. | [Cloud Native App Evaluator](plugins/software-evaluator/agents/CloudNativeAppEvaluator.agent.md), [Software Procurement Evaluator](plugins/software-evaluator/agents/SoftwareProcurementEvaluator.agent.md) | — | — |
| [technical-writer](plugins/technical-writer/) `v1.0.0` | Agents for creating how-to documents, quick reference guides, and user guides. | [HowTo Document Generator](plugins/technical-writer/agents/HowToDocumentGenerator.agent.md), [Quick Reference Guide Generator](plugins/technical-writer/agents/QuickReferenceGuideGenerator.agent.md), [User Guide Generator](plugins/technical-writer/agents/UserGuideGenerator.agent.md) | — | — |
| [tester](plugins/tester/) `v1.0.0` | Agents for generating comprehensive test cases. | [Test Case Generator](plugins/tester/agents/TestCaseGenerator.agent.md) | — | — |
| [python-developer](plugins/python-developer/) `v1.3.0` | Hook that auto-formats all Python files with `black` and lints all non-test Python files with `pylint` after every file modification. | — | — | `PostToolUse` |
| [current-date-injector](plugins/current-date-injector/) `v1.3.0` | Hook that injects the commands to obtain the current date and current time in 24-hr format with timezone into the agent context at session start. | — | — | `SessionStart`, `SubagentStart` |
| [browser-path-provider](plugins/browser-path-provider/) `v1.0.0` | Returns the absolute path of major browser executables (Chrome, Edge, Firefox, Brave), or notifies the user if a browser is not installed. | — | [Chrome](plugins/browser-path-provider/skills/chrome-browser-path-provider/SKILL.md), [Edge](plugins/browser-path-provider/skills/edge-browser-path-provider/SKILL.md), [Firefox](plugins/browser-path-provider/skills/firefox-browser-path-provider/SKILL.md), [Brave](plugins/browser-path-provider/skills/brave-browser-path-provider/SKILL.md) | — |
| [markdown-viewer](plugins/markdown-viewer/) `v1.1.1` | Installs markdown-viewer-app via pip and provides a skill to view markdown files in a browser using the `mdview` command. | — | [Markdown Viewer](plugins/markdown-viewer/skills/markdown-viewer/SKILL.md) | `SessionStart` |
| [meeting-note-taker](plugins/meeting-note-taker/) `v1.1.2` | Guides you through structured meeting note capture and produces a formatted summary with optional Q&A, actions, and Mermaid diagrams saved to a configurable directory. | [Meeting Note Taker](plugins/meeting-note-taker/agents/MeetingNoteTaker.agent.md) | — | `SessionStart` |
| [python-user](plugins/python-user/) `v1.0.0` | Injects `DEFAULT_PYTHON_VERSION` into the agent context at session start, checks whether Python is installed and prompts the agent to offer installation if missing, and provides a skill to download and install Python from the official FTP server. | — | [Python Installer](plugins/python-user/skills/python-installer/SKILL.md) | `SessionStart` |
| [poetry-user](plugins/poetry-user/) `v1.0.0` | Detects whether the current workspace uses Poetry (via `poetry.lock`), injects context instructing the agent to prefer `poetry` commands, and automatically installs Poetry via pip if it is not already installed. | — | [VS Code Poetry Configurator](plugins/poetry-user/skills/vscode-poetry-configurator/SKILL.md) | `SessionStart` |
| [learner](plugins/learner/) `v1.1.0` | Agents for capturing and organising personal study notes by topic in structured Markdown files with sections, Mermaid diagrams, and a table of contents. | [Topic Scriber](plugins/learner/agents/TopicScriber.agent.md) | — | `SessionStart` |
| [code-reviewer](plugins/code-reviewer/) `v1.0.0` | Agents for performing comprehensive, evidence-based code quality reviews across multiple programming languages and frameworks. | [Code Reviewer](plugins/code-reviewer/agents/CodeReviewer.agent.md), [Language Rules Auditor](plugins/code-reviewer/agents/LanguageRulesAuditor.agent.md), [Code Quality Reviewer](plugins/code-reviewer/agents/CodeQualityReviewer.agent.md), [Comprehensive Code Quality Reviewer](plugins/code-reviewer/agents/ComprehensiveCodeQualityReviewer.agent.md), [Universal Code Quality Reviewer](plugins/code-reviewer/agents/UniversalCodeQualityReviewer.agent.md) | [Diff Chunker](plugins/code-reviewer/skills/diff-chunker/SKILL.md), [Review Rules Provider](plugins/code-reviewer/skills/review-rules-provider/SKILL.md) | `SessionStart`, `SubagentStop` |

## Agents

### Documentation Generators

| Agent | Plugin | Description |
|-------|--------|-------------|
| [HowTo Document Generator](plugins/technical-writer/agents/HowToDocumentGenerator.agent.md) | technical-writer | Creates clear, comprehensive, step-by-step instructional guides from user-provided links, inputs, and attachments. Adapts to both technical and business audiences with mermaid diagrams, tables, and lists. |
| [Quick Reference Guide Generator](plugins/technical-writer/agents/QuickReferenceGuideGenerator.agent.md) | technical-writer | Creates concise, well-structured Quick Reference Guides from various sources including codebases, modules, folders, files, or selected code. Specializes in distilling complex information into easy-to-scan reference materials. |
| [Release Notes Generator](plugins/developer/agents/ReleaseNotesGenerator.agent.md) | developer | Creates comprehensive, professional release notes based on module specifications, Jira tickets, and user-provided details. Produces clear documentation for technical and non-technical stakeholders. |
| [Solution Design Generator](plugins/analyst/agents/SolutionDesignGenerator.agent.md) | analyst | Creates comprehensive solution design documents with detailed architecture diagrams, data flows, and technical specifications. Specialized in enterprise-grade designs with Mermaid diagrams and industry best practices. |
| [User Guide Generator](plugins/technical-writer/agents/UserGuideGenerator.agent.md) | technical-writer | Creates clear, comprehensive user guides for non-technical users and business stakeholders. Translates complex technical functionality into simple, step-by-step instructions with visual aids and practical examples. |

### Requirement & Planning Tools

| Agent | Plugin | Description |
|-------|--------|-------------|
| [Presenter](plugins/leader/agents/Presenter.agent.md) | leader | Professional presentation creator that generates comprehensive, engaging, and well-structured presentations on any topic. Features automated research, professional formatting, and autonomous operation until completion. |
| [Requirements Spec Writer](plugins/analyst/agents/RequirementsSpecificationWriter.agent.md) | analyst | Expert requirements documentation agent that creates comprehensive, testable software requirements with user stories, acceptance criteria, database schemas, API specifications, and Mermaid diagrams. Produces well-structured deliverables for both developers and testers. |
| [Test Case Generator](plugins/tester/agents/TestCaseGenerator.agent.md) | tester | Expert QA test case generator that creates comprehensive, JIRA-ready test cases from requirements, user stories, and acceptance criteria. Produces structured, tabular test cases ready for quality testing workflows. |

### Code Quality & Testing Tools

| Agent | Plugin | Description |
|-------|--------|-------------|
| [Code Quality Reviewer](plugins/developer/agents/CodeQualityReviewer.agent.md) | developer | Expert code quality reviewer that performs comprehensive code reviews across multiple programming languages including Magento 2, Laravel, Symfony, .NET, JavaScript/TypeScript, and Python. Reviews for coding standards, security, performance, and maintainability. |
| [Comprehensive Code Quality Reviewer](plugins/developer/agents/ComprehensiveCodeQualityReviewer.agent.md) | developer | Performs in-depth, evidence-based code quality analysis with executive summary, production readiness assessment, and Confluence-ready reports. Evaluates coding standards, best practices, security, performance, scalability, and all NFRs across all languages/frameworks. Every recommendation backed by verified official documentation. Generates timestamped Markdown reports ready for stakeholder communication. |
| [Universal Code Quality Reviewer](plugins/developer/agents/UniversalCodeQualityReviewer.agent.md) | developer | Expert code quality reviewer that performs comprehensive, language-agnostic code reviews covering quality, coding standards, best practices, security, performance, and scalability across all major programming languages and frameworks. |
| [Code Reviewer](plugins/code-reviewer/agents/CodeReviewer.agent.md) | code-reviewer | Orchestrates end-to-end diff-based code reviews. Splits diffs with the diff-chunker skill, detects the project primary language, dispatches the Language Rules Auditor sub-agent per chunk, and saves a structured Markdown report to `CODE_REVIEW_REPORT_DIR` or `<workspace root>/code-reviews/`. The `SubagentStop` hook appends each auditor's findings to the report. |
| [Language Rules Auditor](plugins/code-reviewer/agents/LanguageRulesAuditor.agent.md) | code-reviewer | Sub-agent dispatched by Code Reviewer for each diff chunk. Loads applicable rules via the review-rules-provider skill (cross-cutting + primary-language + chunk-language rules), applies them to every changed file, and returns structured Markdown findings. For files with no matching rule file, uses built-in expertise. |
| [Code Quality Reviewer](plugins/code-reviewer/agents/CodeQualityReviewer.agent.md) | code-reviewer | Expert code quality reviewer that performs comprehensive code reviews across multiple programming languages including Magento 2, Laravel, Symfony, .NET, JavaScript/TypeScript, and Python. Reviews for coding standards, security, performance, and maintainability. |
| [Comprehensive Code Quality Reviewer](plugins/code-reviewer/agents/ComprehensiveCodeQualityReviewer.agent.md) | code-reviewer | Performs in-depth, evidence-based code quality analysis with executive summary, production readiness assessment, and Confluence-ready reports. Evaluates coding standards, best practices, security, performance, scalability, and all NFRs across all languages/frameworks. Every recommendation backed by verified official documentation. Generates timestamped Markdown reports ready for stakeholder communication. |
| [Universal Code Quality Reviewer](plugins/code-reviewer/agents/UniversalCodeQualityReviewer.agent.md) | code-reviewer | Expert code quality reviewer that performs comprehensive, language-agnostic code reviews covering quality, coding standards, best practices, security, performance, and scalability across all major programming languages and frameworks. |
| [Comprehensive Unit Test Generator](plugins/developer/agents/ComprehensiveUnitTestGenerator.agent.md) | developer | **Production-ready orchestrator** that generates, executes, and validates comprehensive unit tests with 80%+ coverage for multiple languages (JavaScript/TypeScript, Python, Java, C#, PHP, Ruby, Go, Rust). Includes full mocking, all test paths (positive/negative/edge cases), automated execution with iterative fixing, and HTML coverage reports. Ensures 100% test pass rate before delivery. |
| [Comprehensive Unit Test Analyzer](plugins/developer/agents/ComprehensiveUnitTestGeneratorAnalyzer.agent.md) | developer | Analyzes code structure to identify testable units, dependencies, code paths, and test requirements across multiple languages. Sub-agent of Comprehensive Unit Test Generator. |
| [Comprehensive Unit Test Executor](plugins/developer/agents/ComprehensiveUnitTestGeneratorExecutor.agent.md) | developer | Executes unit tests, validates results, measures coverage, and iteratively fixes failures until all tests pass with 80%+ coverage. Sub-agent of Comprehensive Unit Test Generator. |
| [Comprehensive Unit Test Code Generator](plugins/developer/agents/ComprehensiveUnitTestGeneratorGenerator.agent.md) | developer | Generates comprehensive, standards-compliant unit test code with proper mocking, following official framework best practices. Sub-agent of Comprehensive Unit Test Generator. |
| [Comprehensive Unit Test Reporter](plugins/developer/agents/ComprehensiveUnitTestGeneratorReporter.agent.md) | developer | Generates comprehensive final reports with HTML coverage links, statistics, test breakdowns, and complete "How to Run" guides. Sub-agent of Comprehensive Unit Test Generator. |
| [.NET Unit Test Generator](plugins/dotnet-developer/agents/DotNetUnitTestGenerator.agent.md) | dotnet-developer | Automatically creates comprehensive unit tests for C# files, folders, projects, or code selections. Specialized in .NET frameworks including ASP.NET Core, Entity Framework Core, and Blazor. Ensures minimum 80% code coverage with xUnit, NUnit, or MSTest. |
| [PHP Unit Test Generator](plugins/php-developer/agents/PHPUnitTestGenerator.agent.md) | php-developer | Automatically creates comprehensive unit tests for PHP files, folders, modules, or code selections. Specialized in PHP frameworks including Magento 2, Laravel, Symfony, and vanilla PHP. Ensures minimum 80% code coverage with PHPUnit. |
| [Universal Unit Test Generator](plugins/developer/agents/UniversalUnitTestGenerator.agent.md) | developer | Comprehensive unit test generation for all major programming languages and frameworks. Supports C#/.NET, Java, PHP, Python, Go, Ruby, Rust, Kotlin, JavaScript, TypeScript, React, Vue, Angular, Swift, and more. Creates tests with 80%+ coverage including mocks, edge cases, and boundary conditions. |

### Evaluation & Assessment Tools

| Agent | Plugin | Description |
|-------|--------|-------------|
| [Cloud Native App Evaluator](plugins/software-evaluator/agents/CloudNativeAppEvaluator.agent.md) | software-evaluator | Research-first cloud native readiness evaluator that tailors every assessment to the user's specific tech stack and deployment platform. Researches framework defaults from the web, then interviews only about unknowns — scoring 12-factor compliance and producing a context-specific remediation roadmap. |
| [Software Procurement Evaluator](plugins/software-evaluator/agents/SoftwareProcurementEvaluator.agent.md) | software-evaluator | Research-first software procurement evaluator that autonomously researches an off-the-shelf product before interviewing the user. Scores fit across 10 ISO/IEC 25010-derived dimensions and produces a prioritized procurement recommendation report. |

### Productivity Tools

| Agent | Plugin | Description |
|-------|--------|-------------|
| [Meeting Note Taker](plugins/meeting-note-taker/agents/MeetingNoteTaker.agent.md) | meeting-note-taker | Interactive agent that guides you through structured meeting note capture and produces a formatted document with a prose summary, optional Mermaid diagrams, Q&A table, actions checklist, facilitators list, attendees list, and verbatim original notes — all saved to a configurable directory. |
| [Topic Scriber](plugins/learner/agents/TopicScriber.agent.md) | learner | Interactive agent that guides the learner through creating and updating topic-based study notes, capturing text, pasted content, and images, then writing structured Markdown files with named sections, auto-generated Mermaid diagrams, and a table of contents. |

## Custom Instructions

| Instruction File | Description | Apply To |
|------------------|-------------|----------|
| [Universal Coding Standards](custom-instructions/copilot-instructions.md) | Universal coding standards and best practices for all programming languages covering SOLID principles, DRY/KISS/YAGNI, naming conventions, code structure, security, performance, and testing. Applies globally across all file types. | All Files (`**/*`) |
| [PHP-Magento-Instructions](custom-instructions/PHP-Magento.instructions.md) | Comprehensive PHP & Magento 2 development standards covering PSR compliance, SOLID principles, Magento architecture, security, performance optimization, and testing requirements. | PHP & Magento 2 Projects |

## Skills

| Skill | Plugin | Description |
|-------|--------|-------------|
| [Agent Maker](plugins/ai-engineer/skills/agent-maker/SKILL.md) | ai-engineer | Creates well-structured, production-ready VS Code agent files (`.agent.md`). Use it whenever defining a new custom agent persona, workflow, or specification. |
| [Agent Optimizer](plugins/ai-engineer/skills/agent-optimizer/SKILL.md) | ai-engineer | Analyzes and optimizes existing VS Code agent files (`.agent.md`). Use it whenever improving, refactoring, or decomposing an existing agent into an orchestrator + subagent architecture. |
| [Changelog Maintainer](plugins/developer/skills/changelog-maintainer/SKILL.md) | developer | Maintains a `CHANGELOG.md` file by inserting new version entries at the top in a consistent, structured format. Use it whenever a release, version bump, or notable set of changes needs to be documented. |
| [Custom Instruction Maker](plugins/ai-engineer/skills/custom-instruction-maker/SKILL.md) | ai-engineer | Creates structured AI instruction files (`AGENTS.md`, `copilot-instructions.md`, `CLAUDE.md`) following the Purpose → Tree → Rules structure with a built-in self-improving note-taking engine. |
| [Git Merge Auditor](plugins/git-manager/skills/git-merge-auditor/SKILL.md) | git-manager | Audits whether a target branch contains all commits and changes from a source branch. Use it to verify that a merge, rebase, or cherry-pick operation did not miss any updates — before or after merging. |
| [Git Merge Conflict Resolver](plugins/git-manager/skills/git-merge-conflict-resolver/SKILL.md) | git-manager | Provides structured workflow for resolving git merge conflicts. Use this skill when encountering merge conflicts during git operations. |
| [Git Worktree Manager](plugins/git-manager/skills/git-worktree-manager/SKILL.md) | git-manager | Manages the full lifecycle of Git worktrees (create, list, move, lock, remove, purge) using a consistent `<repo>-worktree-<branch>` naming convention. Use it whenever creating or managing worktrees alongside the repository root. |
| [Git Diff Generator](plugins/git-manager/skills/git-diff-generator/SKILL.md) | git-manager | Generates a `.diff` file comparing a source (PR ID, current local branch, remote branch, or first commit) against a target branch using three-dot diff semantics. Saves to `GIT_DIFF_DIR` when available, otherwise to the workspace root. |
| [Git PR Cloner](plugins/git-manager/skills/git-pr-cloner/SKILL.md) | git-manager | Fetches a pull request from a remote Git repository (GitHub, GitLab, Bitbucket) into a local tracking branch for inspection and testing without merging. |
| [README Maintainer](plugins/developer/skills/readme-maintainer/SKILL.md) | developer | Creates or updates `README.md` files to be accurate, complete, and easy to navigate. Use it to write a new README from scratch or to update, improve, or extend an existing one. |
| [Skill Maker](plugins/ai-engineer/skills/skill-maker/SKILL.md) | ai-engineer | A meta-skill for designing, specifying, and refining new AI skills (SKILL.md files) in a consistent, production-ready way. Use it whenever defining or updating instructions for an AI assistant. |
| [Hook Maker](plugins/ai-engineer/skills/hook-maker/SKILL.md) | ai-engineer | Creates VS Code Copilot agent hook configurations (hooks.json and companion scripts) for any lifecycle event (SessionStart, SubagentStart, PostToolUse). Use it whenever adding automated behavior to an agent plugin. |
| [Plugin Maker](plugins/ai-engineer/skills/plugin-maker/SKILL.md) | ai-engineer | Scaffolds a complete VS Code Copilot agent plugin with the correct manifest (always .claude-plugin/plugin.json for hook-based plugins), directory structure, README, and marketplace registration. Use it whenever creating a new installable plugin. |
| [Marketplace Maker](plugins/ai-engineer/skills/marketplace-maker/SKILL.md) | ai-engineer | Registers, synchronizes, and updates the project's plugins in the VS Code Chat Plugin Marketplace by keeping marketplace.json and the global README.md in sync with the actual plugin contents. |
| [Chrome Browser Path Provider](plugins/browser-path-provider/skills/chrome-browser-path-provider/SKILL.md) | browser-path-provider | Returns the absolute path of the Google Chrome browser executable on Windows, macOS, and Linux. Notifies the user if Chrome is not installed and provides a download link. |
| [Edge Browser Path Provider](plugins/browser-path-provider/skills/edge-browser-path-provider/SKILL.md) | browser-path-provider | Returns the absolute path of the Microsoft Edge browser executable on Windows, macOS, and Linux. Notifies the user if Edge is not installed and provides a download link. |
| [Firefox Browser Path Provider](plugins/browser-path-provider/skills/firefox-browser-path-provider/SKILL.md) | browser-path-provider | Returns the absolute path of the Mozilla Firefox browser executable on Windows, macOS, and Linux. Notifies the user if Firefox is not installed and provides a download link. |
| [Brave Browser Path Provider](plugins/browser-path-provider/skills/brave-browser-path-provider/SKILL.md) | browser-path-provider | Returns the absolute path of the Brave browser executable on Windows, macOS, and Linux. Notifies the user if Brave is not installed and provides a download link. |
| [Markdown Viewer](plugins/markdown-viewer/skills/markdown-viewer/SKILL.md) | markdown-viewer | Opens any markdown file in a browser using `mdview`. Supports optional `--browser` and `-p` (port) flags. Handles server startup, error reporting, and stopping the background server. |
| [Python Installer](plugins/python-user/skills/python-installer/SKILL.md) | python-user | Downloads and silently installs a specific Python version from the official python.org FTP server. Supports Windows (`python-<version>-amd64.exe` with `/quiet PrependPath=1 InstallPip=1`) and macOS/Linux (`.tgz` compiled from source). Uses `DEFAULT_PYTHON_VERSION` from the agent context by default. |
| [VS Code Poetry Configurator](plugins/poetry-user/skills/vscode-poetry-configurator/SKILL.md) | poetry-user | Configures VS Code to use a Poetry virtual environment as its Python interpreter and ensures all integrated PowerShell terminals automatically activate that virtual environment. Use it whenever a Poetry-managed project needs its VS Code workspace wired up to the correct Poetry venv. |
| [Diff Chunker](plugins/code-reviewer/skills/diff-chunker/SKILL.md) | code-reviewer | Splits a large diff file into smaller chunk files for code review by running a companion script. Sections exceeding `CODE_REVIEW_DIFF_CHUNK_MAX_LINES` are saved as standalone oversized files. All output files are placed in the same directory as the input diff file. |
| [Review Rules Provider](plugins/code-reviewer/skills/review-rules-provider/SKILL.md) | code-reviewer | Loads and concatenates the applicable code review rule set for a given language combination: always includes cross-cutting rules and primary-language rules; appends rules for any additional languages detected in the diff chunk. Invoked by the Language Rules Auditor. |

## Hooks

Hooks are scripts that run automatically at specific points in the agent lifecycle.

| Plugin | Hook event | What it does |
|--------|-----------|--------------|
| [developer](plugins/developer/) | `SessionStart`, `SubagentStart` | Injects developer identity (`DEVELOPER_NAME`, `DEVELOPER_EMAIL`, `DEVELOPER_COUNTRY`) as `additionalContext` so every session and subagent knows the author without being told explicitly. Variables that are not set are silently skipped. |
| [current-date-injector](plugins/current-date-injector/) | `SessionStart`, `SubagentStart` | Injects the commands to obtain the current date and the current time in 24-hr format with timezone as `additionalContext` so agents can always determine the current date and time when needed. |
| [python-developer](plugins/python-developer/) | `PostToolUse` | After every Python file modification, runs `black` to auto-format and `pylint` to lint all non-test Python files. Missing tools produce a blocking error with installation instructions. |
| [markdown-viewer](plugins/markdown-viewer/) | `SessionStart` | At session start, checks whether `markdown-viewer-app` is installed and installs it via `pip` if Python is available. Notifies the user if Python is not available or installation fails. |
| [meeting-note-taker](plugins/meeting-note-taker/) | `SessionStart` | Reads the `MEETING_DIR` environment variable (falls back to `%USERPROFILE%\Documents\MeetingNotes` on Windows or `$HOME/Documents/MeetingNotes` on Linux/macOS) and injects the resolved path into the agent context. |
| [python-user](plugins/python-user/) | `SessionStart` | Injects `DEFAULT_PYTHON_VERSION` into the agent context (falls back to `3.14.4`). Checks whether Python is installed; if not, injects a permission-request prompt instructing the agent to offer installation via the python-installer skill. |
| [poetry-user](plugins/poetry-user/) | `SessionStart` | Detects `poetry.lock` in the workspace and injects context instructing the agent to prefer `poetry` commands. If `poetry.lock` is present but Poetry is not installed, automatically installs it via `pip`; injects success, failure, or "poetry requires python" messages as appropriate. |
| [git-manager](plugins/git-manager/) | `SessionStart`, `SubagentStart` | Reads the `GIT_DIFF_DIR` environment variable and injects its value into agent context so generated diff files are saved to the configured directory. |
| [learner](plugins/learner/) | `SessionStart` | Reads the `LEARNER_NOTES_DIR` environment variable (falls back to `%USERPROFILE%\Documents\LearnerNotes` on Windows or `$HOME/Documents/LearnerNotes` on Linux/macOS) and injects the resolved path into the agent context. |
| [code-reviewer](plugins/code-reviewer/) | `SessionStart`, `SubagentStop` | Reads `CODE_REVIEW_DIFF_CHUNK_MAX_LINES` (falls back to `500`), `CODE_REVIEW_IGNORE_FILE` (optional), and `CODE_REVIEW_REPORT_DIR` (optional) environment variables and injects their values into agent context. `CODE_REVIEW_DIFF_CHUNK_MAX_LINES` is used by the `diff-chunker` skill; `CODE_REVIEW_REPORT_DIR` tells the `Code Reviewer` agent where to save its report. On `SubagentStop`, when a Language Rules Auditor completes, appends its findings output to the report file located via a temporary state file written by the orchestrator. |

### Hook events reference

| Event | When it fires |
|-------|--------------|
| `SessionStart` | Once when a new agent session begins. |
| `SubagentStart` | Once each time a subagent is spawned within a session. |
| `SubagentStop` | Once each time a subagent completes within a session. |
| `PostToolUse` | After every tool invocation (e.g. file write). |

## Usage

### Installing via Plugin Marketplace (recommended)

The easiest way to install plugins is directly from VS Code using the GitHub Copilot Plugin Marketplace:

1. Open VS Code and open the settings. Add `dimpletz/prompts-collection` under **Chat › Plugins: Marketplaces**.
2. Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and run **Chat: Manage Plugin Marketplaces**.
3. Select **`dimpletz/prompts-collection`** from the marketplace list.
4. Select **Show Plugins**.
5. Select the plugins you want to install.

### Managing Installed Plugins

To view and manage your installed plugins:

1. Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and run **Chat: Open Customizations**.
2. Select **Plugins** to see all installed plugins.

### Agents

#### User-level (available across all projects)
1. Copy the desired agent file (`.agent.md`) from `plugins/<plugin>/agents/` to `%APPDATA%\Code\User\prompts\` in your VS Code user profile
2. On Windows: `C:\Users\<YourUsername>\AppData\Roaming\Code\User\prompts\<agent-name>.agent.md`
3. The agent will be available in GitHub Copilot Chat across all your projects

#### Project-level (scoped to a single project)
1. Copy the desired agent file (`.agent.md`) from `plugins/<plugin>/agents/` to the `.github\agents\` directory in your project repository
2. The agent will be available in GitHub Copilot Chat only within that project

### Skills

#### User-level (available across all projects)
1. Copy the desired skill directory from `plugins/<plugin>/skills/` to `%USERPROFILE%\.copilot\skills\` in your user profile
2. On Windows: `C:\Users\<YourUsername>\.copilot\skills\<skill-name>\SKILL.md`
3. Skills are available to GitHub Copilot across all your projects

#### Project-level (scoped to a single project)
1. Copy the desired skill directory from `plugins/<plugin>/skills/` to `.github\skills\` in your project repository
2. Path structure: `.github\skills\<skill-name>\SKILL.md`
3. Skills are available to GitHub Copilot only within that project

Skills provide domain-specific capabilities to GitHub Copilot and are invoked automatically based on context and requirements.

### Hooks

#### User-level (available across all projects)
1. Copy the desired hook directory from `plugins/<plugin>/hooks/` to `%USERPROFILE%\.copilot\hooks\` in your user profile
2. On Windows: `C:\Users\<YourUsername>\.copilot\hooks\<hook-name>.json`
3. Hooks are executed by GitHub Copilot across all your projects

#### Project-level (scoped to a single project)
1. Copy the desired hook JSON file from `plugins/<plugin>/hooks/` to `.github\hooks\` in your project repository
2. Path structure: `.github\hooks\<hook-name>.json`
3. Hooks are executed by GitHub Copilot only within that project

Hooks execute shell commands automatically at specific agent lifecycle points (`SessionStart`, `SubagentStart`, `PostToolUse`, etc.) and require no manual invocation. See the [VS Code hooks documentation](https://code.visualstudio.com/docs/copilot/customization/hooks) for the full list of lifecycle events and configuration options.

### Custom Instructions

Custom instructions can be applied in two ways:

#### Global instructions (applied to all Copilot interactions in a project)

1. Copy the instruction content to `.github\copilot-instructions.md` in your project directory
2. Instructions are automatically applied to all Copilot interactions in that project
3. Multiple instruction sets can be combined in the single `copilot-instructions.md` file

#### Scoped instructions (applied to specific files via `applyTo`)

1. Copy the `.instructions.md` file to `.github\instructions\` in your project repository (e.g. `.github\instructions\PHP-Magento.instructions.md`)

2. Ensure the frontmatter includes an `applyTo` glob pattern to scope which files trigger the instructions:

   ```yaml
   ---
   applyTo: '**/*.php,**/*.phtml'
   ---
   ```

3. GitHub Copilot will automatically apply the instructions when working on matching files

