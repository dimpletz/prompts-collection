### C#-Specific Review Categories

**Modern C# Idioms**
- [MINOR] Record types used for immutable data transfer objects and value objects
- [MINOR] Primary constructors used for simple DI classes (C# 12+) instead of boilerplate constructor + fields
- [MINOR] Pattern matching (`is`, `switch` expressions, positional patterns, list patterns) preferred over chains of `if/else` type checks and casts
- [MINOR] `required` modifier on properties that must always be set during object initialization
- [MINOR] File-scoped namespaces used for single-namespace files (C# 10+)
- [MINOR] Collection expressions (`[1, 2, 3]`, `[..items]`) preferred over `new List<T> { }` (C# 12+)
- [MAJOR] Null-conditional operators (`?.`, `??`, `??=`) used to avoid null reference exceptions
- [MINOR] `nameof()` used instead of hardcoded string names for property/parameter names

**Nullable Reference Types**
- [MAJOR] `<Nullable>enable</Nullable>` enabled in project file; not disabled to suppress warnings
- [MAJOR] Non-nullable reference type parameters validated with `ArgumentNullException.ThrowIfNull()` (not manual null checks)
- [MAJOR] Nullable annotations (`?`) on reference types accurate; not used to suppress warnings without understanding
- [MAJOR] Null-forgiving operator (`!`) used only when null is provably impossible; never as a blanket suppressor

**Async / Await**
- [CRITICAL] `async void` methods only in top-level event handlers; not in services, controllers, or command handlers (use `async Task` instead)
- [MINOR] `ConfigureAwait(false)` used in library code where the original context is not needed after the await
- [MAJOR] `CancellationToken` accepted and passed through the entire async call chain; not silently ignored
- [CRITICAL] `Task.Result` and `.Wait()` not called on hot tasks from synchronous code (deadlock risk in ASP.NET classic sync context)
- [MINOR] `ValueTask` used for hot-path operations that frequently complete synchronously; not used where multiple awaits or caching is involved
- [MINOR] `IAsyncEnumerable<T>` used for streaming result sets; `List<T>` not returned from methods that query large datasets

**LINQ**
- [MINOR] LINQ query syntax and method syntax chosen based on readability; complex queries use query syntax with `join`/`group`
- [MAJOR] Deferred execution understood: no calling `.Count()` or `.ToList()` multiple times on the same query when one materialization suffices
- [MINOR] `Select` + `FirstOrDefault` vs `Find`: `Find` on `DbSet` hits identity map first; used appropriately
- [MINOR] `Any()` preferred over `.Count() > 0` for existence checks
- [MAJOR] `OrderBy` followed by `ThenBy` correctly; not chained `OrderBy().OrderBy()` which resets ordering

**IDisposable / Resource Management**
- [MAJOR] Classes owning unmanaged resources implement `IDisposable` / `IAsyncDisposable` with the standard dispose pattern
- [MAJOR] `using` declarations or `using` statements wrap all `IDisposable` instances; no manual `Dispose()` outside `finally`
- [MAJOR] `HttpClient` not instantiated per-request; `IHttpClientFactory` used instead
- [CRITICAL] `DbContext` not used as a singleton; scoped lifetime enforced in DI container

**ASP.NET Core**
- [MAJOR] Controllers thin: request parsing and response shaping only; business logic delegated to services
- [MINOR] Model validation: `[ApiController]` attribute enables automatic model state validation; not manually checked with `if (!ModelState.IsValid)`
- [MINOR] `IActionResult` / `Results<T>` return types used for varied HTTP responses; not returning raw objects from Minimal API handlers without status code
- [CRITICAL] Middleware order: authentication before authorization; exception handling middleware at the top of the pipeline
- [MINOR] `IOptions<T>` / `IOptionsSnapshot<T>` used for typed configuration; not `IConfiguration["key"]` scattered throughout services

**Entity Framework Core**
- [MAJOR] No N+1 queries: `Include()` / `ThenInclude()` or explicit `Load()` used for related data accessed in loops
- [MINOR] `AsNoTracking()` used for read-only queries where change tracking is not needed
- [MAJOR] Migrations in version control; no `EnsureCreated()` in production startup
- [CRITICAL] `FromSqlInterpolated()` used for raw SQL (safely parameterized); not `FromSqlRaw()` with string interpolation
- [MINOR] Concurrency tokens (`[ConcurrencyCheck]` or `RowVersion`) used for entities requiring optimistic concurrency

**Testing**
- [MINOR] Tests structured with Arrange / Act / Assert; not mixed together
- [MINOR] `FluentAssertions` `.Should()` chains used for readable assertions; not bare `Assert.Equal()` where the failure message would be unclear
- [MINOR] Mocks verify only meaningful interactions; not set up for every method regardless of relevance
- [MINOR] Test class names describe the subject under test; method names describe the scenario and expected outcome