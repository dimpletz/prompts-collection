### Python-Specific Review Categories

**Modern Python Idioms**
- [MINOR] f-strings preferred over `%` formatting and `.format()` for string interpolation
- [MINOR] Walrus operator `:=` used appropriately to reduce repeated expressions in conditions/comprehensions
- [MINOR] Structural pattern matching (`match`/`case`) preferred over long if-elif chains on object types
- [MINOR] `dataclasses.dataclass` or `typing.NamedTuple` used for simple data containers instead of plain dicts or boilerplate classes
- [MINOR] `__slots__` declared on classes where memory efficiency or attribute restriction is important
- [MAJOR] Context managers (`with`) used for all resource acquisition (files, locks, DB connections, HTTP sessions)
- [MINOR] Generator expressions preferred over list comprehensions when only iteration is needed (memory efficiency)
- [MINOR] `pathlib.Path` preferred over `os.path` for file system operations

**Type Hints (PEP 484 / 526 / 585 / 604)**
- [MAJOR] All function parameters and return types annotated; no implicit `-> None` omissions on non-trivial functions
- [MINOR] `Optional[X]` replaced with `X | None` (Python 3.10+) where the codebase targets 3.10+
- [MINOR] `list[str]` preferred over `List[str]` (PEP 585, Python 3.9+)
- [MINOR] `TypeVar` and generics used correctly; `Protocol` preferred over ABC when structural subtyping suffices
- [MAJOR] `typing.cast()` used sparingly and justified; never used to silence errors without comment
- [MINOR] Deprecated `typing` aliases (`typing.List`, `typing.Dict`, `typing.Mapping`, etc.) replaced with `collections.abc` equivalents (`collections.abc.Mapping`, `collections.abc.Sequence`, etc.) or built-in generics (`list[str]`, `dict[str, int]`)

**Comprehensions and Functional Style**
- [MINOR] List/dict/set comprehensions used for simple transformations; generator expressions for lazy evaluation
- [MAJOR] Comprehensions not used for side effects (use for loops instead)
- [MINOR] `map()` and `filter()` with lambdas replaced by comprehensions for readability unless performance-critical
- [MINOR] `functools.lru_cache` / `functools.cache` applied to pure deterministic functions

**Async Programming**
- [CRITICAL] `async def` functions not blocking the event loop with synchronous I/O (file reads, DB calls without async driver)
- [MAJOR] `asyncio.gather()` used to run independent coroutines concurrently instead of sequential awaits
- [MAJOR] `asyncio.create_task()` used for fire-and-forget tasks with proper cancellation handling
- [CRITICAL] No mixing of sync and async code without proper executors (`loop.run_in_executor`)
- [MAJOR] `asyncio.timeout()` (Python 3.11+) or `asyncio.wait_for()` used for bounded awaits

**Django-Specific (when applicable)**
- [MAJOR] `QuerySet.select_related()` / `prefetch_related()` used to avoid N+1 queries
- [CRITICAL] `Model.objects.filter()` used with parameterized lookups; no `.extra()` with format strings
- [MAJOR] `FileField` / `ImageField`: file type validated server-side; upload directory outside MEDIA_ROOT web exposure
- [CRITICAL] CSRF middleware enabled; `@csrf_exempt` justified with comment
- [MINOR] Signals used sparingly; not used as a replacement for direct method calls within the same app

**FastAPI-Specific (when applicable)**
- [MAJOR] Pydantic models used for request/response validation; no raw `dict` inputs in endpoint signatures
- [MAJOR] Dependency injection via `Depends()` for shared logic (auth, DB sessions)
- [MINOR] Background tasks (`BackgroundTasks`) used for fire-and-forget work, not for long-running jobs (use Celery/RQ)
- [MAJOR] Response models (`response_model=`) set on all endpoints to control output schema

**Imports & Documentation**
- [MINOR] Relative imports (`from . import x`, `from ..module import y`) used within packages instead of absolute imports that repeat the package path
- [MINOR] All public modules, classes, and functions have docstrings in Google style; missing docstrings on public API surface flagged

**Testing**
- [MINOR] `pytest` fixtures used for test setup/teardown; no `setUp`/`tearDown` unless inheriting `unittest.TestCase`
- [MAJOR] Mocking via `unittest.mock.patch` / `pytest-mock`; no monkey-patching global state permanently
- [MINOR] Parametrize (`@pytest.mark.parametrize`) used for multiple input variants
- [MAJOR] Tests do not rely on execution order or shared mutable state