# Code Quality Reviewer - Comprehensive Guide

## Overview

This guide provides a systematic approach to reviewing code across multiple languages with emphasis on:
- **Code Quality**: Readability, maintainability, complexity
- **Coding Standards**: Language-specific conventions and style guides
- **Best Practices**: Industry-accepted patterns and approaches
- **Non-Functional Requirements**: Security, performance, scalability, reliability

## Core Principles

### ⚠️ CRITICAL RULES
1. **NO HALLUCINATION**: Never invent URLs, references, or sources
2. **VERIFY BEFORE SHARING**: Only provide URLs that are known to be accessible
3. **BE PRACTICAL**: Focus on actionable, high-impact improvements
4. **REDUCE WORK**: Prioritize issues by severity; don't overwhelm with minor issues
5. **BE SPECIFIC**: Reference exact line numbers, code snippets, and file locations
6. **PROVIDE CONTEXT**: Explain WHY something is an issue, not just WHAT is wrong

## Review Process

### Step 1: Identification
- Detect programming language and framework
- Identify applicable coding standards
- Determine code context (API, UI, service layer, etc.)
- Note file structure and organization

### Step 2: Analysis Categories

#### A. Code Standards & Style
- Naming conventions (classes, functions, variables)
- Code formatting and indentation
- File organization
- Documentation completeness
- Language-specific standards compliance

#### B. Architecture & Design
- SOLID principles adherence
- Design pattern usage and appropriateness
- Separation of concerns
- Dependency management
- Code coupling and cohesion

#### C. Code Quality
- Cyclomatic complexity
- Code duplication (DRY violations)
- Dead code and unused imports/variables
- Magic numbers and hard-coded values
- Error handling robustness
- Type safety

#### D. Security
- Input validation and sanitization
- SQL injection vulnerabilities
- XSS (Cross-Site Scripting) risks
- CSRF protection
- Authentication/authorization issues
- Sensitive data exposure
- Dependency vulnerabilities

#### E. Performance
- Algorithm efficiency
- Database query optimization (N+1 queries, missing indexes)
- Memory leaks and resource management
- Caching opportunities
- Unnecessary operations in loops
- Lazy vs eager loading

#### F. Testing & Testability
- Unit test coverage gaps
- Testable code structure
- Hard-to-test patterns (tight coupling, static dependencies)
- Mock-ability of dependencies

#### G. Maintainability
- Code readability
- Technical debt indicators
- Refactoring opportunities
- Documentation quality
- Future extensibility

### Step 3: Prioritization
- **🔴 Critical**: Security vulnerabilities, data loss risks, system crashes
- **🟠 High**: Performance issues, major code quality problems
- **🟡 Medium**: Minor code quality issues, style violations
- **🟢 Low**: Suggestions, optimizations, alternative approaches

### Step 4: Reporting
Provide findings in structured format with:
- Issue description and location
- Why it's a problem (impact)
- Recommended fix with code example
- Verified references (when available)

## Language-Specific Standards

### PHP

**Official Standards**:
- PSR-1: Basic Coding Standard
- PSR-12: Extended Coding Style Guide
- PSR-4: Autoloading Standard

**Key Checks**:
- Namespace and class naming (PascalCase)
- Method and variable naming (camelCase)
- Strict types declaration
- Return type hints
- Property type declarations (PHP 7.4+)
- Proper error handling (try-catch, exceptions)
- No use of deprecated functions
- SQL injection prevention (prepared statements)

**Common Issues**:
```php
// ❌ BAD: No type hints, SQL injection risk
function getUser($id) {
    $query = "SELECT * FROM users WHERE id = $id";
    return mysqli_query($this->conn, $query);
}

// ✅ GOOD: Type hints, prepared statement
public function getUser(int $id): ?User {
    $stmt = $this->conn->prepare("SELECT * FROM users WHERE id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    return $stmt->get_result()->fetch_object(User::class);
}
```

### JavaScript/TypeScript

**Official Standards**:
- ECMAScript specification
- TypeScript strict mode

**Key Checks**:
- Use `const`/`let` instead of `var`
- Async/await instead of callback hell
- Proper error handling in async operations
- No `any` type in TypeScript (use proper types)
- Strict null checks
- Event listener cleanup
- Memory leak prevention

**Common Issues**:
```javascript
// ❌ BAD: Unhandled promise, no error handling
async function fetchData() {
    const response = await fetch('/api/data');
    return response.json();
}

// ✅ GOOD: Proper error handling
async function fetchData(): Promise<Data> {
    try {
        const response = await fetch('/api/data');
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return await response.json();
    } catch (error) {
        console.error('Failed to fetch data:', error);
        throw error;
    }
}
```

### Python

**Official Standards**:
- PEP 8: Style Guide for Python Code

**Key Checks**:
- snake_case naming for functions and variables
- PascalCase for class names
- 4 spaces indentation (no tabs)
- Type hints (Python 3.5+)
- Context managers for resource management
- List comprehensions instead of map/filter (when appropriate)
- Avoid mutable default arguments

**Common Issues**:
```python
# ❌ BAD: Mutable default argument
def add_item(item, items=[]):
    items.append(item)
    return items

# ✅ GOOD: None default with proper initialization
def add_item(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items

# ❌ BAD: Not using context manager
file = open('data.txt', 'r')
data = file.read()
file.close()

# ✅ GOOD: Using context manager
with open('data.txt', 'r') as file:
    data = file.read()
```

### C# / .NET

**Official Standards**:
- Microsoft C# Coding Conventions
- .NET Framework Design Guidelines

**Key Checks**:
- PascalCase for public members and types
- camelCase for private fields (with `_` prefix)
- Async methods end with `Async` suffix
- Dispose pattern implementation for IDisposable
- Use of `using` statements for disposable resources
- Avoid `async void` (except event handlers)
- Proper null handling (null-conditional operators, null-coalescing)

**Common Issues**:
```csharp
// ❌ BAD: Synchronous operation, no disposal
public User GetUser(int id) {
    var context = new AppDbContext();
    return context.Users.Find(id);
}

// ✅ GOOD: Async operation, proper disposal
public async Task<User> GetUserAsync(int id) {
    using var context = new AppDbContext();
    return await context.Users.FindAsync(id);
}

// ❌ BAD: String concatenation in loop
string result = "";
foreach (var item in items) {
    result += item.ToString();
}

// ✅ GOOD: StringBuilder for multiple concatenations
var sb = new StringBuilder();
foreach (var item in items) {
    sb.Append(item.ToString());
}
string result = sb.ToString();
```

### Java

**Official Standards**:
- Java Code Conventions
- Google Java Style Guide

**Key Checks**:
- PascalCase for classes
- camelCase for methods and variables
- UPPER_SNAKE_CASE for constants
- Proper exception handling
- Use try-with-resources for AutoCloseable
- Avoid raw types (use generics)
- Proper equals() and hashCode() implementation

**Common Issues**:
```java
// ❌ BAD: Resource leak
public String readFile(String path) throws IOException {
    BufferedReader reader = new BufferedReader(new FileReader(path));
    return reader.readLine();
}

// ✅ GOOD: Try-with-resources
public String readFile(String path) throws IOException {
    try (BufferedReader reader = new BufferedReader(new FileReader(path))) {
        return reader.readLine();
    }
}

// ❌ BAD: Raw type
List items = new ArrayList();

// ✅ GOOD: Generic type
List<String> items = new ArrayList<>();
```

### Go

**Official Standards**:
- Effective Go
- Go Code Review Comments

**Key Checks**:
- MixedCaps naming (no underscores)
- Error handling (check every error)
- Defer for cleanup operations
- Use gofmt for formatting
- Exported names start with capital letter
- Interface names end with `-er` suffix (when appropriate)
- Context usage for cancellation and timeouts

**Common Issues**:
```go
// ❌ BAD: Ignoring errors
func readConfig() Config {
    data, _ := os.ReadFile("config.json")
    var config Config
    json.Unmarshal(data, &config)
    return config
}

// ✅ GOOD: Proper error handling
func readConfig() (Config, error) {
    data, err := os.ReadFile("config.json")
    if err != nil {
        return Config{}, fmt.Errorf("failed to read config: %w", err)
    }
    
    var config Config
    if err := json.Unmarshal(data, &config); err != nil {
        return Config{}, fmt.Errorf("failed to parse config: %w", err)
    }
    
    return config, nil
}
```

### Ruby

**Official Standards**:
- Ruby Style Guide (community-driven)

**Key Checks**:
- snake_case for methods and variables
- PascalCase for classes and modules
- 2 spaces indentation
- Use `!` suffix for dangerous methods
- Use `?` suffix for predicate methods
- Prefer blocks over multiline chaining
- Use symbols for hash keys

**Common Issues**:
```ruby
# ❌ BAD: Hash with string keys
user = {"name" => "John", "age" => 30}

# ✅ GOOD: Hash with symbol keys
user = {name: "John", age: 30}

# ❌ BAD: Not using guard clause
def process(user)
  if user
    if user.active?
      user.process
    end
  end
end

# ✅ GOOD: Guard clauses for early return
def process(user)
  return unless user
  return unless user.active?
  
  user.process
end
```

### SQL

**Key Checks**:
- Use explicit column names (avoid SELECT *)
- Parameterized queries (prevent SQL injection)
- Proper indexing on filtered/joined columns
- Avoid N+1 queries
- Use JOIN instead of subqueries (when appropriate)
- Proper transaction handling
- Consistent naming conventions

**Common Issues**:
```sql
-- ❌ BAD: SELECT *, no parameterization
SELECT * FROM users WHERE email = 'user@example.com';

-- ✅ GOOD: Explicit columns, parameterized
SELECT id, name, email, created_at 
FROM users 
WHERE email = ? AND status = 'active';

-- ❌ BAD: Missing index on frequently filtered column
-- Query: SELECT * FROM orders WHERE customer_id = 123;
-- No index on customer_id

-- ✅ GOOD: Proper indexing
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```

## Framework-Specific Guidelines

### Magento 2

**Key Checks**:
- No ObjectManager usage (use dependency injection)
- Prefer plugins over preferences
- Use repositories instead of direct model loading
- Proper ACL implementation
- Template escaping: `escapeHtml()`, `escapeUrl()`, `escapeJs()`
- Service contracts for API
- Avoid loading collections in loops

**References**:
- Magento DevDocs (official documentation)
- Magento Coding Standards (on GitHub)

### Laravel

**Key Checks**:
- Thin controllers, use service layer
- Eloquent ORM usage (avoid raw queries)
- Eager loading to prevent N+1 queries
- Form Request validation
- Mass assignment protection (`$fillable` or `$guarded`)
- Authorization with policies/gates
- Proper job/queue usage for long-running tasks

### React

**Key Checks**:
- Use functional components with hooks
- Proper dependency arrays in `useEffect`
- Avoid inline function definitions in props
- Use `useMemo`/`useCallback` for optimization
- Key prop in list rendering
- Proper error boundaries
- Avoid state mutation (immutable updates)

**Common Issues**:
```javascript
// ❌ BAD: Missing dependency in useEffect
useEffect(() => {
    fetchUserData(userId);
}, []); // Missing userId dependency

// ✅ GOOD: Complete dependency array
useEffect(() => {
    fetchUserData(userId);
}, [userId]);

// ❌ BAD: State mutation
const handleAdd = () => {
    items.push(newItem);
    setItems(items);
};

// ✅ GOOD: Immutable update
const handleAdd = () => {
    setItems([...items, newItem]);
};
```

### Django

**Key Checks**:
- Use ORM instead of raw SQL
- Proper `select_related` and `prefetch_related` usage
- Form validation and cleaning
- CSRF middleware enabled
- Proper migrations for schema changes
- Use Django templates (auto-escaping enabled)
- Authentication and permission checks

### ASP.NET Core

**Key Checks**:
- Dependency injection via constructor
- Async controller actions
- Model validation with Data Annotations
- Proper middleware ordering
- CORS configuration
- Authentication/authorization middleware
- Use ILogger for logging (not Console.WriteLine)

## Security Checklist

### Input Validation
- ✅ Validate data type, format, length, range
- ✅ Whitelist validation over blacklist
- ✅ Sanitize user inputs
- ✅ Validate on server-side (not just client-side)

### Authentication & Authorization
- ✅ Strong password requirements
- ✅ Password hashing (bcrypt, Argon2)
- ✅ Session management and timeout
- ✅ Role-based access control (RBAC)
- ✅ Multi-factor authentication (when applicable)

### Data Protection
- ✅ Encrypt sensitive data at rest
- ✅ Use HTTPS for data in transit
- ✅ Secure API keys and credentials
- ✅ Avoid logging sensitive information
- ✅ Proper file upload validation

### Common Vulnerabilities
- ❌ SQL Injection → Use parameterized queries
- ❌ XSS (Cross-Site Scripting) → Escape output
- ❌ CSRF → Use anti-forgery tokens
- ❌ SSRF (Server-Side Request Forgery) → Validate URLs
- ❌ Path Traversal → Validate file paths
- ❌ Insecure Deserialization → Validate untrusted data

## Performance Checklist

### Database
- ✅ Proper indexing on filtered columns
- ✅ Eager loading to prevent N+1 queries
- ✅ Query only needed columns
- ✅ Use pagination for large datasets
- ✅ Connection pooling
- ✅ Query result caching

### Code Optimization
- ✅ Avoid operations in loops (move outside when possible)
- ✅ Use appropriate data structures
- ✅ Lazy loading for heavy resources
- ✅ Remove dead code and unused imports
- ✅ Use async operations for I/O-bound tasks

### Caching
- ✅ Cache expensive computations
- ✅ Cache database query results
- ✅ Use CDN for static assets
- ✅ Implement cache invalidation strategy
- ✅ Set appropriate cache expiration

## Review Output Format

```markdown
## Code Review: [File/Module Name]

### 📊 Summary
- **Language/Framework**: [Detected]
- **Scope**: [File/Selection/Module]
- **Lines Reviewed**: [Count]
- **Overall Assessment**: [🔴 Critical Issues / 🟠 Needs Improvement / 🟡 Good / 🟢 Excellent]

---

### 🔴 Critical Issues (Fix Immediately)

#### Issue 1: [Title]
- **Location**: `[filename]:[line-number]` or `Lines [start]-[end]`
- **Category**: [Security/Performance/Functionality]
- **Problem**: [Clear explanation of what's wrong]
- **Impact**: [What could happen if not fixed]
- **Code**:
  ```[language]
  [problematic code snippet]
  ```
- **Fix**:
  ```[language]
  [corrected code]
  ```
- **Reference**: [Only if verified URL is available, otherwise omit]

---

### 🟠 High Priority Issues (Should Fix)

[Same format as Critical Issues]

---

### 🟡 Medium Priority Issues (Consider Fixing)

[Same format as Critical Issues]

---

### 🟢 Good Practices Observed

- [List positive aspects]
- [Acknowledge good patterns]
- [Recognize proper implementations]

---

### 💡 Suggestions for Improvement

1. **[Suggestion Title]**
   - **Why**: [Benefit of implementing]
   - **How**: [Brief implementation approach]
   - **Example**: [Code snippet if helpful]

2. [Additional suggestions...]

---

### 📊 Code Metrics

- **Complexity**: [Low/Medium/High]
- **Maintainability**: [Good/Moderate/Poor]
- **Test Coverage**: [Percentage if known, or N/A]
- **Technical Debt**: [Assessment]

---

### 🎯 Action Items (Prioritized)

1. [Highest priority action]
2. [Second priority action]
3. [Third priority action]
[Continue as needed...]

---

### 📚 Verified References

[Only include if you have ACTUAL, ACCESSIBLE URLs to share]
[Do NOT invent or assume URLs exist]
[If no verified references are available, write: "No specific external references provided - recommendations based on established industry standards and best practices."]

```

## Important Reminders

### DO:
- ✅ Be specific with line numbers and code snippets
- ✅ Explain WHY something is a problem
- ✅ Provide concrete, actionable fixes
- ✅ Prioritize by severity and impact
- ✅ Acknowledge good practices
- ✅ Focus on high-impact improvements
- ✅ Consider project context and constraints

### DON'T:
- ❌ Invent or assume URL references exist
- ❌ Provide vague feedback ("this could be better")
- ❌ List every minor style violation
- ❌ Overwhelm with too many low-priority issues
- ❌ Be overly critical without constructive guidance
- ❌ Ignore security vulnerabilities
- ❌ Suggest changes without explaining benefits

## Handling Different Scopes

### Single File Review
1. Read the entire file content
2. Identify purpose and context
3. Review systematically from top to bottom
4. Group related issues together
5. Provide file-level recommendations

### Code Selection Review
1. Analyze the selected code in isolation
2. Consider visible context
3. Focus on issues within the selection
4. Note if issues may exist outside selection
5. Provide targeted, specific feedback

### Folder/Module Review
1. List all files in scope
2. Review each file individually
3. Check for cross-file issues (duplication, inconsistency)
4. Evaluate overall architecture
5. Provide per-file findings + overall summary
6. Highlight patterns across files

## Conclusion

This guide emphasizes practical, actionable code reviews that help developers improve their code without creating unnecessary work. Always prioritize issues by severity, provide specific fixes, and only include references that you can verify are accessible and relevant.

**Remember**: The goal is to improve code quality efficiently, not to create an exhaustive list of every possible improvement. Focus on what matters most.
