### PHP-Specific Review Categories

**Modern PHP Idioms (PHP 8.x)**
- [MINOR] Null coalescing operator `??` and null coalescing assignment `??=` preferred over isset() ternaries
- [MINOR] Match expression preferred over switch when returning a value (prevents fall-through bugs)
- [MINOR] Named arguments used for clarity when calling functions with many optional parameters
- [MINOR] Constructor property promotion used for simple DTO/value object classes
- [MINOR] Readonly properties used for immutable value objects
- [MINOR] Union types and intersection types used instead of docblock-only type hints
- [MINOR] First-class callable syntax `strlen(...)` preferred over `Closure::fromCallable('strlen')`
- [MAJOR] Fibers: ensure cooperative multitasking does not swallow exceptions; proper resume() error handling
- [MINOR] Enums preferred over class constants for fixed sets of values

**PSR Compliance**
- [MINOR] PSR-12: 4-space indentation, opening braces on same line for control structures, one class per file
- [MAJOR] PSR-4: namespace matches directory structure; autoloading compatible
- [MINOR] PSR-3: logger interface used (`$logger->error()` not `error_log()`); log levels appropriate
- [MINOR] PSR-7: immutable request/response objects; withX() methods used for mutation
- [MAJOR] PSR-14: event dispatcher used correctly; listeners do not throw uncaught exceptions

**Laravel-Specific (when applicable)**
- [CRITICAL] Eloquent: mass assignment guarded (`$fillable` or `$guarded` set); raw DB::select() with bindings when needed
- [CRITICAL] Validation: form requests used for complex validation; never trust unvalidated input
- [MAJOR] Middleware: authentication and authorization applied at route group level, not duplicated in controllers
- [MAJOR] Queue jobs: `Illuminate\Queue\InteractsWithQueue` used; failed jobs handled via `failed()` method
- [MAJOR] N+1 queries: Eager loading (`with()`) used when accessing relationships in loops

**Symfony-Specific (when applicable)**
- [MINOR] Services declared with explicit types in services.yaml; autowiring used consistently
- [CRITICAL] Forms: CSRF protection enabled; form types not built inline in controllers
- [MAJOR] Security: voters used for fine-grained authorization; `is_granted()` not scattered in templates
- [MINOR] Event subscribers declared as services with correct tags

**Type Safety**
- [MAJOR] `strict_types=1` declared at the top of every file
- [MAJOR] No loose comparisons (`==`) where strict comparison (`===`) is warranted
- [MINOR] `mixed` return type avoided unless genuinely required
- [MINOR] Nullable types `?string` used explicitly; not replaced by `string|null` docblocks without declaration

**Testing**
- [MAJOR] Classes are testable: dependencies injected, not instantiated with `new` inside methods
- [MAJOR] Test coverage for happy path, error path, and boundary conditions
- [MINOR] PHPUnit data providers used for parameterized tests instead of loops
- [MAJOR] Mocks used for external dependencies; no real HTTP calls or DB hits in unit tests