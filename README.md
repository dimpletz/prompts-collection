# Prompts Collection

A curated collection of specialized AI prompts, designed to enhance productivity and automate common tasks through intelligent conversation interfaces.

[TOC]

## Custom Agents

### Documentation Generators

| Agent | Description |
|-------|-------------|
| [HowTo Document Generator](custom-agents/HowToDocumentGenerator.agent.md) | Creates clear, comprehensive, step-by-step instructional guides from user-provided links, inputs, and attachments. Adapts to both technical and business audiences with mermaid diagrams, tables, and lists. |
| [Quick Reference Guide Generator](custom-agents/QuickReferenceGuideGenerator.agent.md) | Creates concise, well-structured Quick Reference Guides from various sources including codebases, modules, folders, files, or selected code. Specializes in distilling complex information into easy-to-scan reference materials. |
| [Release Notes Generator](custom-agents/ReleaseNotesGenerator.agent.md) | Creates comprehensive, professional release notes based on module specifications, Jira tickets, and user-provided details. Produces clear documentation for technical and non-technical stakeholders. |
| [Solution Design Generator](custom-agents/SolutionDesignGenerator.agent.md) | Creates comprehensive solution design documents with detailed architecture diagrams, data flows, and technical specifications. Specialized in enterprise-grade designs with Mermaid diagrams and industry best practices. |
| [User Guide Generator](custom-agents/UserGuideGenerator.agent.md) | Creates clear, comprehensive user guides for non-technical users and business stakeholders. Translates complex technical functionality into simple, step-by-step instructions with visual aids and practical examples. |

### Requirement & Planning Tools

| Agent | Description |
|-------|-------------|
| [Presenter](custom-agents/Presenter.agent.md) | Professional presentation creator that generates comprehensive, engaging, and well-structured presentations on any topic. Features automated research, professional formatting, and autonomous operation until completion. |
| [Requirements Spec Writer](custom-agents/RequirementsSpecWriter.agent.md) | Expert requirements documentation agent that creates comprehensive, testable software requirements with user stories, acceptance criteria, database schemas, API specifications, and Mermaid diagrams. Produces well-structured deliverables for both developers and testers. |
| [Test Case Generator](custom-agents/TestCaseGenerator.agent.md) | Expert QA test case generator that creates comprehensive, JIRA-ready test cases from requirements, user stories, and acceptance criteria. Produces structured, tabular test cases ready for quality testing workflows. |

### Code Quality & Testing Tools

| Agent | Description |
|-------|-------------|
| [Code Quality Reviewer](custom-agents/CodeQualityReviewer.agent.md) | Expert code quality reviewer that performs comprehensive code reviews across multiple programming languages including Magento 2, Laravel, Symfony, .NET, JavaScript/TypeScript, and Python. Reviews for coding standards, security, performance, and maintainability. |
| [Universal Code Quality Reviewer](custom-agents/UniversalCodeQualityReviewer.agent.md) | Expert code quality reviewer that performs comprehensive, language-agnostic code reviews covering quality, coding standards, best practices, security, performance, and scalability across all major programming languages and frameworks. |
| [.NET Unit Test Generator](custom-agents/DotNetUnitTestGenerator.agent.md) | Automatically creates comprehensive unit tests for C# files, folders, projects, or code selections. Specialized in .NET frameworks including ASP.NET Core, Entity Framework Core, and Blazor. Ensures minimum 80% code coverage with xUnit, NUnit, or MSTest. |
| [PHP Unit Test Generator](custom-agents/PHPUnitTestGenerator.agent.md) | Automatically creates comprehensive unit tests for PHP files, folders, modules, or code selections. Specialized in PHP frameworks including Magento 2, Laravel, Symfony, and vanilla PHP. Ensures minimum 80% code coverage with PHPUnit. |
| [Universal Unit Test Generator](custom-agents/UniversalUnitTestGenerator.agent.md) | Comprehensive unit test generation for all major programming languages and frameworks. Supports C#/.NET, Java, PHP, Python, Go, Ruby, Rust, Kotlin, JavaScript, TypeScript, React, Vue, Angular, Swift, and more. Creates tests with 80%+ coverage including mocks, edge cases, and boundary conditions. |

### Evaluation & Assessment Tools

| Agent | Description |
|-------|-------------|
| [Cloud Native App Evaluator](custom-agents/CloudNativeAppEvaluator.agent.md) | Research-first cloud native readiness evaluator that tailors every assessment to the user's specific tech stack and deployment platform. Researches framework defaults from the web, then interviews only about unknowns — scoring 12-factor compliance and producing a context-specific remediation roadmap. |
| [Software Procurement Evaluator](custom-agents/SoftwareProcurementEvaluator.agent.md) | Research-first software procurement evaluator that autonomously researches an off-the-shelf product before interviewing the user. Scores fit across 10 ISO/IEC 25010-derived dimensions and produces a prioritized procurement recommendation report. |

## Custom Instructions

| Instruction File | Description | Apply To |
|------------------|-------------|----------|
| [Universal Coding Standards](custom-instructions/copilot-instructions.md) | Universal coding standards and best practices for all programming languages covering SOLID principles, DRY/KISS/YAGNI, naming conventions, code structure, security, performance, and testing. Applies globally across all file types. | All Files (`**/*`) |
| [PHP-Magento-Instructions](custom-instructions/PHP-Magento.instructions.md) | Comprehensive PHP & Magento 2 development standards covering PSR compliance, SOLID principles, Magento architecture, security, performance optimization, and testing requirements. | PHP & Magento 2 Projects |

## Custom Skills

| Skill | Description |
|-------|-------------|
| [Agent Maker](custom-skills/agent-maker/SKILL.md) | Creates well-structured, production-ready VS Code agent files (`.agent.md`). Use it whenever defining a new custom agent persona, workflow, or specification. |
| [Agent Optimizer](custom-skills/agent-optimizer/SKILL.md) | Analyzes and optimizes existing VS Code agent files (`.agent.md`). Use it whenever improving, refactoring, or decomposing an existing agent into an orchestrator + subagent architecture. |
| [Changelog Maintainer](custom-skills/changelog-maintainer/SKILL.md) | Maintains a `CHANGELOG.md` file by inserting new version entries at the top in a consistent, structured format. Use it whenever a release, version bump, or notable set of changes needs to be documented. |
| [Git Merge Conflict Resolver](custom-skills/git-merge-conflict-resolver/SKILL.md) | Provides structured workflow for resolving git merge conflicts. Use this skill when encountering merge conflicts during git operations. |
| [PR Cloner](custom-skills/pr-cloner/SKILL.md) | Fetches a pull request from a remote Git repository (GitHub, GitLab, Bitbucket) into a local tracking branch for inspection and testing without merging. |
| [README Maintainer](custom-skills/readme-maintainer/SKILL.md) | Creates or updates `README.md` files to be accurate, complete, and easy to navigate. Use it to write a new README from scratch or to update, improve, or extend an existing one. |
| [Skill Maker](custom-skills/skill-maker/SKILL.md) | A meta-skill for designing, specifying, and refining new AI skills (SKILL.md files) in a consistent, production-ready way. Use it whenever defining or updating instructions for an AI assistant. |

## Usage

### Custom Agents

#### User-level (available across all projects)
1. Copy the desired agent file (`.agent.md`) to `%APPDATA%\Code\User\prompts\` in your VS Code user profile
2. On Windows: `C:\Users\<YourUsername>\AppData\Roaming\Code\User\prompts\<agent-name>.agent.md`
3. The agent will be available in GitHub Copilot Chat across all your projects

#### Project-level (scoped to a single project)
1. Copy the desired agent file (`.agent.md`) to the `.github\agents\` directory in your project repository
2. The agent will be available in GitHub Copilot Chat only within that project

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

### Custom Skills

#### User-level (available across all projects)
1. Copy the desired skill directory from `custom-skills/` to `%USERPROFILE%\.copilot\skills\` in your user profile
2. On Windows: `C:\Users\<YourUsername>\.copilot\skills\<skill-name>\SKILL.md`
3. Skills are available to GitHub Copilot across all your projects

#### Project-level (scoped to a single project)
1. Copy the desired skill directory from `custom-skills/` to `.github\skills\` in your project repository
2. Path structure: `.github\skills\<skill-name>\SKILL.md`
3. Skills are available to GitHub Copilot only within that project

Skills provide domain-specific capabilities to GitHub Copilot and are invoked automatically based on context and requirements.
