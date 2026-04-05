# DotNet Developer `v1.0.0`

> A collection of agents for generating and maintaining comprehensive unit tests for .NET/C# applications.

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) extension installed and active.
- A .NET project with C# source files.

## Installation

Install via the VS Code Chat Plugin Marketplace using the `dimpletz/prompts-collection` marketplace source and enable the **dotnet-developer** plugin.

## Usage

Open Copilot Chat, select the **.NET Unit Test Generator** agent, and point it at the file, folder, project, or code selection you want tests for.

```
# Examples
"Generate unit tests for UserService.cs"
"Create tests for the Controllers folder using xUnit"
"Write unit tests for this code selection using NUnit"
```

## Components

### .NET Unit Test Generator

An expert unit test generation agent specialized in C# and the .NET ecosystem. Analyzes source files, infers dependencies, and generates high-quality, maintainable tests that achieve at least 80% code coverage.

**Supported frameworks:**

| Category | Libraries |
|----------|-----------|
| Test frameworks | xUnit, NUnit, MSTest |
| Mocking | Moq, NSubstitute, FakeItEasy |
| .NET stacks | ASP.NET Core, Entity Framework Core, Blazor, vanilla .NET |

**Test coverage includes:**
- Positive paths, negative paths, edge cases, and boundary conditions
- Dependency injection and IoC container testing
- Async/await patterns
- Controller, middleware, and service testing
- Entity Framework Core `DbContext` and repository patterns
- Integration testing with `WebApplicationFactory`

## Author

[Dimpletz](https://github.com/dimpletz)
