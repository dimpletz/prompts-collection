### Java-Specific Review Categories

**Effective Java Guidelines**
- [MINOR] Prefer static factory methods over constructors where appropriate
- [MINOR] Enforce builder pattern for types with many optional parameters (≥ 4 parameters)
- [MAJOR] Override equals/hashCode consistently; use Objects.equals/Objects.hash
- [MINOR] Prefer composition over inheritance; use interface default methods judiciously
- [MINOR] Use enums instead of int constants; exploit enum capabilities (fields, methods)
- [MAJOR] Avoid finalizers and cleaners; prefer try-with-resources
- [MINOR] Minimize accessibility of classes and members
- [MAJOR] Return empty collections/optionals instead of null
- [MINOR] Prefer primitives over boxed types; be aware of autoboxing in loops
- [MAJOR] `default` methods in interfaces must not contain business logic; use them only to avoid breaking changes in existing implementors or to delegate to abstractions — business logic belongs in abstract classes or concrete implementations
- [MAJOR] Methods that may return null must declare `Optional<T>` as return type; raw null returns without `Optional` are forbidden on non-private methods
- [MINOR] Methods returning collections return unmodifiable views (`List.copyOf()`, `Collections.unmodifiableList()`, or `List.of()`); callers must not be able to mutate internal state through returned references
- [MINOR] Stream pipelines on collections do not collect to an intermediate `List` only to immediately stream it again; unnecessary materializations replaced with chained stream operations
- [MAJOR] All I/O streams (`InputStream`, `OutputStream`, `Reader`, `Writer`, `Connection`, `Statement`) opened inside try-with-resources blocks; not closed in `finally` blocks or left unclosed
- [MINOR] Legacy `java.io` file APIs (`File`, `FileInputStream`, `FileOutputStream`) replaced with NIO.2 equivalents (`Path`, `Files`, `FileChannel`) for new code
- [MINOR] `java.util.Date`, `java.util.Calendar`, `java.text.SimpleDateFormat` not used in new code; replaced with `java.time` APIs (`LocalDate`, `ZonedDateTime`, `DateTimeFormatter`, etc.)
- [MINOR] Immutable data carriers implemented as `record` types instead of traditional POJOs with constructors, getters, `equals`, `hashCode`, and `toString`
- [MINOR] Multiline string literals use text blocks (`"""..."""`); not string concatenation or `\n` escape sequences
- [MINOR] Local variable types inferred with `var` where the type is obvious from the right-hand side; `var` not used when the inferred type would be unclear to the reader
- [MINOR] Virtual threads (`Thread.ofVirtual()`, `Executors.newVirtualThreadPerTaskExecutor()`) preferred for I/O-bound concurrent tasks; platform threads justified only for CPU-bound work or when native thread-local state is required
- [MINOR] Unused import statements removed; no wildcard imports (`import java.util.*`) except in test files
- [MINOR] All public packages, classes, interfaces, and methods have Javadoc; `@param`, `@return`, and `@throws` tags present where applicable
- [MINOR] `@since` tag present in Javadoc on every public type and method, reflecting the version in which it was introduced
- [MINOR] Classes composed entirely of static members declared `final` with a private no-args constructor to prevent instantiation and subclassing

**Generics & Type Safety**
- [MAJOR] No raw types; use properly typed generics
- [MINOR] Bounded wildcards (? extends T, ? super T) used correctly
- [MAJOR] Unchecked cast warnings addressed with proper checks or suppression with comment

**Streams & Lambdas**
- [MINOR] Streams not used for simple loops where readability is better served by for-each
- [MAJOR] No side effects inside stream pipelines (filter, map)
- [MINOR] Collectors.toUnmodifiableList() / toList() (Java 16+) preferred over mutable collectors when immutability is intended
- [MINOR] Method references preferred over verbose lambdas where readability improves
- [MINOR] Each method parameter declared `final`; mutable parameter reassignment inside the method body flagged unless explicitly justified with a comment

**Concurrency**
- [CRITICAL] Shared mutable state protected by synchronization or concurrent data structures
- [CRITICAL] No calling Thread.stop(), suspend(), resume()
- [MAJOR] ExecutorService shut down properly (shutdown + awaitTermination or try-with-resources in Java 19+)
- [MAJOR] CompletableFuture chains handle exceptions via exceptionally/handle
- [MINOR] @Async Spring methods return CompletableFuture or void, not Future

**Spring Framework**
- [MAJOR] Business logic not in @Controller or @RestController — delegated to @Service
- [MINOR] @Repository used for data access; exceptions translated via PersistenceExceptionTranslation
- [MAJOR] Circular dependencies avoided; constructor injection preferred over @Autowired field injection
- [MAJOR] @Transactional on service layer, not repository; propagation understood
- [MINOR] No @Component, @Service, @Repository on abstract classes
- [CRITICAL] Spring Security: no disabling CSRF without stateless JWT justification; proper role-based access

**JPA / Hibernate**
- [CRITICAL] Entity classes: @Id always present; no-args constructor present (required by JPA spec)
- [MAJOR] Bidirectional relationships: owning side sets the FK; helper methods on both sides
- [MAJOR] FetchType.EAGER avoided on collections; N+1 detected via missing JOIN FETCH in JPQL/criteria
- [MAJOR] @Transactional boundaries respect lazy loading (no LazyInitializationException)
- [CRITICAL] Native queries parameterized; never concatenated
- [MAJOR] Cascade types justified; CascadeType.REMOVE on owned children only