### Base Review Categories

**SOLID Principles**

- [MAJOR] Single Responsibility: classes or modules taking on multiple unrelated concerns
- [MAJOR] Open/Closed: direct modification of shared utilities or stable abstractions instead of extending them
- [MAJOR] Liskov Substitution: overriding methods in a way that narrows contracts or changes observable behaviour
- [MINOR] Interface Segregation: large all-purpose interfaces or abstract base classes with unrelated methods
- [MAJOR] Dependency Inversion: instantiating concrete dependencies directly inside business logic instead of injecting abstractions

**DRY (Don't Repeat Yourself)**

- [MAJOR] Duplicated logic in multiple files or methods that could be extracted into a shared helper
- [MAJOR] Copy-pasted error handling, validation, or mapping logic

**KISS (Keep It Simple, Stupid)**

- [MINOR] Unnecessarily complex control flow where a simpler approach exists
- [MINOR] Over-engineered abstractions for one-time operations

**YAGNI (You Aren't Gonna Need It)**

- [MINOR] Dead code or commented-out blocks
- [MINOR] Speculative features, unused parameters, or unused imports/declarations

**General Clean Code**

- [MAJOR] Meaningless or misleading names (variables, functions, classes)
- [MINOR] Magic numbers or hardcoded string literals that should be named constants
- [MAJOR] Functions or methods doing more than one thing
- [MINOR] Inconsistent formatting or coding style across files in the same diff
- [MINOR] Cyclomatic complexity kept low; methods ideally ≤ 20 lines
