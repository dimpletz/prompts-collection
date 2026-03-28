# Prompts Collection

A curated collection of specialized AI prompts, designed to enhance productivity and automate common tasks through intelligent conversation interfaces.

[TOC]

## Plugins

The collection is organized into plugins. Each plugin groups related agents and/or skills by domain.

| Plugin | Description | Agents | Skills |
|--------|-------------|--------|--------|
| [analyst](plugins/analyst/) `v1.0.0` | Agents for writing requirements specifications and generating solution designs. | [Requirements Specification Writer](plugins/analyst/agents/RequirementsSpecificationWriter.agent.md), [Requirements Specification Writer Analyzer](plugins/analyst/agents/RequirementsSpecificationWriterAnalyzer.agent.md), [Requirements Specification Writer Documenter](plugins/analyst/agents/RequirementsSpecificationWriterDocumenter.agent.md), [Solution Design Generator](plugins/analyst/agents/SolutionDesignGenerator.agent.md) | — |
| [developer](plugins/developer/) `v1.0.0` | Agents and skills for code quality reviews, unit test generation, and release notes. | [Code Quality Reviewer](plugins/developer/agents/CodeQualityReviewer.agent.md), [Comprehensive Code Quality Reviewer](plugins/developer/agents/ComprehensiveCodeQualityReviewer.agent.md), [Universal Code Quality Reviewer](plugins/developer/agents/UniversalCodeQualityReviewer.agent.md), [Comprehensive Unit Test Generator](plugins/developer/agents/ComprehensiveUnitTestGenerator.agent.md), [Comprehensive Unit Test Analyzer](plugins/developer/agents/ComprehensiveUnitTestGeneratorAnalyzer.agent.md), [Comprehensive Unit Test Executor](plugins/developer/agents/ComprehensiveUnitTestGeneratorExecutor.agent.md), [Comprehensive Unit Test Code Generator](plugins/developer/agents/ComprehensiveUnitTestGeneratorGenerator.agent.md), [Comprehensive Unit Test Reporter](plugins/developer/agents/ComprehensiveUnitTestGeneratorReporter.agent.md), [Release Notes Generator](plugins/developer/agents/ReleaseNotesGenerator.agent.md), [Universal Unit Test Generator](plugins/developer/agents/UniversalUnitTestGenerator.agent.md) | [Changelog Maintainer](plugins/developer/skills/changelog-maintainer/SKILL.md), [README Maintainer](plugins/developer/skills/readme-maintainer/SKILL.md) |
| [dotnet-developer](plugins/dotnet-developer/) `v1.0.0` | Agents for generating and maintaining unit tests for .NET/C# applications. | [.NET Unit Test Generator](plugins/dotnet-developer/agents/DotNetUnitTestGenerator.agent.md) | — |
| [git-manager](plugins/git-manager/) `v1.0.0` | Skills for managing Git repositories, worktrees, merge conflicts, and pull requests. | — | [Git Merge Conflict Resolver](plugins/git-manager/skills/git-merge-conflict-resolver/SKILL.md), [Git Worktree Manager](plugins/git-manager/skills/git-worktree-manager/SKILL.md), [PR Cloner](plugins/git-manager/skills/pr-cloner/SKILL.md) |
| [leader](plugins/leader/) `v1.0.0` | Agents for creating compelling presentations and communicating ideas effectively. | [Presenter](plugins/leader/agents/Presenter.agent.md) | — |
| [makers](plugins/makers/) `v1.0.0` | Skills for creating and optimizing VS Code agents and skills. | — | [Agent Maker](plugins/makers/skills/agent-maker/SKILL.md), [Agent Optimizer](plugins/makers/skills/agent-optimizer/SKILL.md), [Skill Maker](plugins/makers/skills/skill-maker/SKILL.md) |
| [php-developer](plugins/php-developer/) `v1.0.0` | Agents for generating and maintaining unit tests for PHP applications. | [PHP Unit Test Generator](plugins/php-developer/agents/PHPUnitTestGenerator.agent.md) | — |
| [software-evaluator](plugins/software-evaluator/) `v1.0.0` | Agents for evaluating cloud-native applications and software procurement decisions. | [Cloud Native App Evaluator](plugins/software-evaluator/agents/CloudNativeAppEvaluator.agent.md), [Software Procurement Evaluator](plugins/software-evaluator/agents/SoftwareProcurementEvaluator.agent.md) | — |
| [technical-writer](plugins/technical-writer/) `v1.0.0` | Agents for creating how-to documents, quick reference guides, and user guides. | [HowTo Document Generator](plugins/technical-writer/agents/HowToDocumentGenerator.agent.md), [Quick Reference Guide Generator](plugins/technical-writer/agents/QuickReferenceGuideGenerator.agent.md), [User Guide Generator](plugins/technical-writer/agents/UserGuideGenerator.agent.md) | — |
| [tester](plugins/tester/) `v1.0.0` | Agents for generating comprehensive test cases. | [Test Case Generator](plugins/tester/agents/TestCaseGenerator.agent.md) | — |

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
| [Comprehensive Code Quality Reviewer](plugins/developer/agents/ComprehensiveCodeQualityReviewer.agent.md) | developer | Comprehensive code quality reviewer that performs in-depth analysis across all aspects of code quality including coding standards, best practices, security, performance, scalability, and maintainability for all programming languages and frameworks. |
| [Universal Code Quality Reviewer](plugins/developer/agents/UniversalCodeQualityReviewer.agent.md) | developer | Expert code quality reviewer that performs comprehensive, language-agnostic code reviews covering quality, coding standards, best practices, security, performance, and scalability across all major programming languages and frameworks. |
| [Comprehensive Unit Test Generator](plugins/developer/agents/ComprehensiveUnitTestGenerator.agent.md) | developer | **Production-ready orchestrator** that generates, executes, and validates comprehensive unit tests with 80%+ coverage for multiple languages (JavaScript/TypeScript, Python, Java, C#, PHP, Ruby, Go, Rust). Includes full mocking, all test paths (positive/negative/edge cases), automated execution with iterative fixing, and HTML coverage reports. Ensures 100% test pass rate before delivery. |
| [.NET Unit Test Generator](plugins/dotnet-developer/agents/DotNetUnitTestGenerator.agent.md) | dotnet-developer | Automatically creates comprehensive unit tests for C# files, folders, projects, or code selections. Specialized in .NET frameworks including ASP.NET Core, Entity Framework Core, and Blazor. Ensures minimum 80% code coverage with xUnit, NUnit, or MSTest. |
| [PHP Unit Test Generator](plugins/php-developer/agents/PHPUnitTestGenerator.agent.md) | php-developer | Automatically creates comprehensive unit tests for PHP files, folders, modules, or code selections. Specialized in PHP frameworks including Magento 2, Laravel, Symfony, and vanilla PHP. Ensures minimum 80% code coverage with PHPUnit. |
| [Universal Unit Test Generator](plugins/developer/agents/UniversalUnitTestGenerator.agent.md) | developer | Comprehensive unit test generation for all major programming languages and frameworks. Supports C#/.NET, Java, PHP, Python, Go, Ruby, Rust, Kotlin, JavaScript, TypeScript, React, Vue, Angular, Swift, and more. Creates tests with 80%+ coverage including mocks, edge cases, and boundary conditions. |

### Evaluation & Assessment Tools

| Agent | Plugin | Description |
|-------|--------|-------------|
| [Cloud Native App Evaluator](plugins/software-evaluator/agents/CloudNativeAppEvaluator.agent.md) | software-evaluator | Research-first cloud native readiness evaluator that tailors every assessment to the user's specific tech stack and deployment platform. Researches framework defaults from the web, then interviews only about unknowns — scoring 12-factor compliance and producing a context-specific remediation roadmap. |
| [Software Procurement Evaluator](plugins/software-evaluator/agents/SoftwareProcurementEvaluator.agent.md) | software-evaluator | Research-first software procurement evaluator that autonomously researches an off-the-shelf product before interviewing the user. Scores fit across 10 ISO/IEC 25010-derived dimensions and produces a prioritized procurement recommendation report. |

## Custom Instructions

| Instruction File | Description | Apply To |
|------------------|-------------|----------|
| [Universal Coding Standards](custom-instructions/copilot-instructions.md) | Universal coding standards and best practices for all programming languages covering SOLID principles, DRY/KISS/YAGNI, naming conventions, code structure, security, performance, and testing. Applies globally across all file types. | All Files (`**/*`) |
| [PHP-Magento-Instructions](custom-instructions/PHP-Magento.instructions.md) | Comprehensive PHP & Magento 2 development standards covering PSR compliance, SOLID principles, Magento architecture, security, performance optimization, and testing requirements. | PHP & Magento 2 Projects |

## Skills

| Skill | Plugin | Description |
|-------|--------|-------------|
| [Agent Maker](plugins/makers/skills/agent-maker/SKILL.md) | makers | Creates well-structured, production-ready VS Code agent files (`.agent.md`). Use it whenever defining a new custom agent persona, workflow, or specification. |
| [Agent Optimizer](plugins/makers/skills/agent-optimizer/SKILL.md) | makers | Analyzes and optimizes existing VS Code agent files (`.agent.md`). Use it whenever improving, refactoring, or decomposing an existing agent into an orchestrator + subagent architecture. |
| [Changelog Maintainer](plugins/developer/skills/changelog-maintainer/SKILL.md) | developer | Maintains a `CHANGELOG.md` file by inserting new version entries at the top in a consistent, structured format. Use it whenever a release, version bump, or notable set of changes needs to be documented. |
| [Git Merge Conflict Resolver](plugins/git-manager/skills/git-merge-conflict-resolver/SKILL.md) | git-manager | Provides structured workflow for resolving git merge conflicts. Use this skill when encountering merge conflicts during git operations. |
| [Git Worktree Manager](plugins/git-manager/skills/git-worktree-manager/SKILL.md) | git-manager | Manages the full lifecycle of Git worktrees (create, list, move, lock, remove, purge) using a consistent `<repo>-worktree-<branch>` naming convention. Use it whenever creating or managing worktrees alongside the repository root. |
| [PR Cloner](plugins/git-manager/skills/pr-cloner/SKILL.md) | git-manager | Fetches a pull request from a remote Git repository (GitHub, GitLab, Bitbucket) into a local tracking branch for inspection and testing without merging. |
| [README Maintainer](plugins/developer/skills/readme-maintainer/SKILL.md) | developer | Creates or updates `README.md` files to be accurate, complete, and easy to navigate. Use it to write a new README from scratch or to update, improve, or extend an existing one. |
| [Skill Maker](plugins/makers/skills/skill-maker/SKILL.md) | makers | A meta-skill for designing, specifying, and refining new AI skills (SKILL.md files) in a consistent, production-ready way. Use it whenever defining or updating instructions for an AI assistant. |

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

