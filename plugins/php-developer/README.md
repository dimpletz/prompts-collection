# PHP Developer `v1.0.0`

> A collection of agents for generating and maintaining comprehensive PHPUnit test suites for PHP applications.

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) extension installed and active.
- A PHP project with Composer-managed dependencies.

## Installation

Install via the VS Code Chat Plugin Marketplace using the `dimpletz/prompts-collection` marketplace source and enable the **php-developer** plugin.

## Usage

Open Copilot Chat, select the **PHP Unit Test Generator** agent, and point it at the file, folder, module, or code selection you want tests for.

```
# Examples
"Generate PHPUnit tests for UserRepository.php"
"Create unit tests for the app/Services folder"
"Write tests for this Magento 2 observer class"
"Generate tests for this Laravel controller"
```

## Components

### PHP Unit Test Generator

An expert PHP unit test generation agent that automatically creates high-quality PHPUnit tests for any PHP codebase. Targets a minimum of 80% code coverage with maintainable, idiomatic test code.

**Supported frameworks:**

| Framework | Notes |
|-----------|-------|
| Magento 2 | Unit, integration, and functional tests |
| Laravel | PHPUnit and Pest |
| Symfony | PHPUnit with Symfony test utilities |
| Vanilla PHP | Standard PHPUnit |

**Test coverage includes:**
- Positive paths, negative paths, edge cases, and boundary conditions
- Dependency injection and IoC container testing
- PHPUnit mock objects and dependency mocking
- Testing design patterns (factories, repositories, services)
- Data providers for parameterized tests
- Exception testing and error-state coverage

## Author

[Dimpletz](https://github.com/dimpletz)
