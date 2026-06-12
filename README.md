# Prompts Collection

A curated collection of specialized AI prompts, designed to enhance productivity and automate common tasks through intelligent conversation interfaces.

[TOC]

## Marketplace v1.26.0

The collection is organized into plugins. Each plugin groups related agents and/or skills by domain.

| Plugin | Description | Requires | Agents | Skills | Hooks |
|--------|-------------|----------|--------|--------|-------|
| [analyst](plugins/analyst/) `v1.0.0` | Agents for writing requirements specifications and generating solution designs. | — | [Requirements Specification Writer](plugins/analyst/agents/RequirementsSpecificationWriter.agent.md), [Requirements Specification Writer Analyzer](plugins/analyst/agents/RequirementsSpecificationWriterAnalyzer.agent.md), [Requirements Specification Writer Documenter](plugins/analyst/agents/RequirementsSpecificationWriterDocumenter.agent.md), [Solution Design Generator](plugins/analyst/agents/SolutionDesignGenerator.agent.md) | — | — |
| [developer](plugins/developer/) `v1.2.0` | Agent and skills for release notes generation, project file maintenance, and developer name injection. | — | [Release Notes Generator](plugins/developer/agents/ReleaseNotesGenerator.agent.md) | [Changelog Maintainer](plugins/developer/skills/changelog-maintainer/SKILL.md), [README Maintainer](plugins/developer/skills/readme-maintainer/SKILL.md) | `SessionStart`, `SubagentStart` |
| [dotnet-developer](plugins/dotnet-developer/) `v1.0.0` | Agents for generating and maintaining unit tests for .NET/C# applications. | — | [.NET Unit Test Generator](plugins/dotnet-developer/agents/DotNetUnitTestGenerator.agent.md) | — | — |
| [git-manager](plugins/git-manager/) `v1.4.0` | Skills for managing Git repositories, worktrees, merge conflicts, pull requests, diff generation, and text normalization. | — | — | [Git Merge Conflict Resolver](plugins/git-manager/skills/git-merge-conflict-resolver/SKILL.md), [Git Worktree Manager](plugins/git-manager/skills/git-worktree-manager/SKILL.md), [Git PR Cloner](plugins/git-manager/skills/git-pr-cloner/SKILL.md), [Git Merge Auditor](plugins/git-manager/skills/git-merge-auditor/SKILL.md), [Git Diff Generator](plugins/git-manager/skills/git-diff-generator/SKILL.md), [Git Encoding Normalizer](plugins/git-manager/skills/git-encoding-normalizer/SKILL.md) | `SessionStart`, `SubagentStart` |
| [leader](plugins/leader/) `v1.0.0` | Agents for creating compelling presentations and communicating ideas effectively. | — | [Presenter](plugins/leader/agents/Presenter.agent.md) | — | — |
| [ai-engineer](plugins/ai-engineer/) `v1.4.0` | Skills for creating and optimizing VS Code agents, skills, hooks, plugins, and custom instruction files. | — | — | [Agent Maker](plugins/ai-engineer/skills/agent-maker/SKILL.md), [Agent Optimizer](plugins/ai-engineer/skills/agent-optimizer/SKILL.md), [Custom Instruction Maker](plugins/ai-engineer/skills/custom-instruction-maker/SKILL.md), [Skill Maker](plugins/ai-engineer/skills/skill-maker/SKILL.md), [Hook Maker](plugins/ai-engineer/skills/hook-maker/SKILL.md), [Plugin Maker](plugins/ai-engineer/skills/plugin-maker/SKILL.md), [Marketplace Maker](plugins/ai-engineer/skills/marketplace-maker/SKILL.md) | `SessionStart`, `SubagentStart` |
| [php-developer](plugins/php-developer/) `v1.0.0` | Agents for generating and maintaining unit tests for PHP applications. | — | [PHP Unit Test Generator](plugins/php-developer/agents/PHPUnitTestGenerator.agent.md) | — | — |
| [software-evaluator](plugins/software-evaluator/) `v1.0.0` | Agents for evaluating cloud-native applications and software procurement decisions. | — | [Cloud Native App Evaluator](plugins/software-evaluator/agents/CloudNativeAppEvaluator.agent.md), [Software Procurement Evaluator](plugins/software-evaluator/agents/SoftwareProcurementEvaluator.agent.md) | — | — |
| [technical-writer](plugins/technical-writer/) `v1.2.0` | Agents for creating how-to documents, quick reference guides, user guides, structured document reviews, proposals, and architectural design documents. | — | [HowTo Document Generator](plugins/technical-writer/agents/HowToDocumentGenerator.agent.md), [Quick Reference Guide Generator](plugins/technical-writer/agents/QuickReferenceGuideGenerator.agent.md), [User Guide Generator](plugins/technical-writer/agents/UserGuideGenerator.agent.md), [Document Reviewer](plugins/technical-writer/agents/DocumentReviewer.agent.md), [Proposal Writer](plugins/technical-writer/agents/ProposalWriter.agent.md), [Architectural Designer](plugins/technical-writer/agents/ArchitecturalDesigner.agent.md) | — | `SessionStart` |
| [tester](plugins/tester/) `v1.0.0` | Agents for generating comprehensive test cases. | — | [Test Case Generator](plugins/tester/agents/TestCaseGenerator.agent.md) | — | — |
| [python-developer](plugins/python-developer/) `v1.3.0` | Hook that auto-formats all Python files with `black` and lints all non-test Python files with `pylint` after every file modification. | — | — | — | `PostToolUse` |
| [current-date-injector](plugins/current-date-injector/) `v1.3.0` | Hook that injects the commands to obtain the current date and current time in 24-hr format with timezone into the agent context at session start. | — | — | — | `SessionStart`, `SubagentStart` |
| [browser-path-provider](plugins/browser-path-provider/) `v1.0.0` | Returns the absolute path of major browser executables (Chrome, Edge, Firefox, Brave), or notifies the user if a browser is not installed. | — | — | [Chrome](plugins/browser-path-provider/skills/chrome-browser-path-provider/SKILL.md), [Edge](plugins/browser-path-provider/skills/edge-browser-path-provider/SKILL.md), [Firefox](plugins/browser-path-provider/skills/firefox-browser-path-provider/SKILL.md), [Brave](plugins/browser-path-provider/skills/brave-browser-path-provider/SKILL.md) | — |
| [markdown-viewer](plugins/markdown-viewer/) `v1.2.0` | Installs markdown-viewer-app via pip and provides a skill to view markdown files in a browser using the `mdview` command. | — | — | [Markdown Viewer](plugins/markdown-viewer/skills/markdown-viewer/SKILL.md) | `SessionStart` |
| [meeting-note-taker](plugins/meeting-note-taker/) `v1.1.2` | Guides you through structured meeting note capture and produces a formatted summary with optional Q&A, actions, and Mermaid diagrams saved to a configurable directory. | — | [Meeting Note Taker](plugins/meeting-note-taker/agents/MeetingNoteTaker.agent.md) | — | `SessionStart` |
| [python-user](plugins/python-user/) `v1.0.0` | Injects `DEFAULT_PYTHON_VERSION` into the agent context at session start, checks whether Python is installed and prompts the agent to offer installation if missing, and provides a skill to download and install Python from the official FTP server. | — | — | [Python Installer](plugins/python-user/skills/python-installer/SKILL.md) | `SessionStart` |
| [poetry-user](plugins/poetry-user/) `v1.1.0` | Detects whether the current workspace uses Poetry (via `poetry.lock`), injects context instructing the agent to prefer `poetry` commands, and automatically installs Poetry via pip if it is not already installed. | — | — | [VS Code Poetry Configurator](plugins/poetry-user/skills/vscode-poetry-configurator/SKILL.md) | `SessionStart` |
| [learner](plugins/learner/) `v1.1.0` | Agents for capturing and organising personal study notes by topic in structured Markdown files with sections, Mermaid diagrams, and a table of contents. | — | [Topic Scriber](plugins/learner/agents/TopicScriber.agent.md) | — | `SessionStart` |
| [code-reviewer](plugins/code-reviewer/) `v1.0.2` | Agents for performing comprehensive, evidence-based code quality reviews across multiple programming languages and frameworks. | — | [Code Reviewer](plugins/code-reviewer/agents/CodeReviewer.agent.md), [Language Rules Auditor](plugins/code-reviewer/agents/LanguageRulesAuditor.agent.md) | [Code Review Report Appender](plugins/code-reviewer/skills/code-review-report-appender/SKILL.md), [Diff Chunker](plugins/code-reviewer/skills/diff-chunker/SKILL.md), [Review Rules Provider](plugins/code-reviewer/skills/review-rules-provider/SKILL.md) | `SessionStart`, `SubagentStop` |

## Custom Instructions

| Instruction File | Description | Apply To |
|------------------|-------------|----------|
| [Universal Coding Standards](custom-instructions/copilot-instructions.md) | Universal coding standards and best practices for all programming languages covering SOLID principles, DRY/KISS/YAGNI, naming conventions, code structure, security, performance, and testing. Applies globally across all file types. | All Files (`**/*`) |
| [PHP-Magento-Instructions](custom-instructions/PHP-Magento.instructions.md) | Comprehensive PHP & Magento 2 development standards covering PSR compliance, SOLID principles, Magento architecture, security, performance optimization, and testing requirements. | PHP & Magento 2 Projects |

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
