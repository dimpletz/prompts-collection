### JavaScript/TypeScript-Specific Review Categories

**TypeScript Type Safety**
- [MAJOR] `strict: true` (or equivalent strict flags) enabled in tsconfig
- [MAJOR] `any` type avoided; `unknown` preferred for truly unknown inputs with proper narrowing
- [MAJOR] Type assertions (`as X`) justified; not used to silence type errors without understanding
- [MAJOR] Non-null assertions (`!`) used only when null is provably impossible at that point
- [MINOR] `satisfies` operator used when the full type should be inferred but shape validated
- [MINOR] Generic types not over-constrained or under-constrained
- [MINOR] Discriminated unions preferred over optional properties for variant types
- [MINOR] `enum` preferred with `const enum` only when value stability across compilation is guaranteed; union of string literals often cleaner

**Modern JS Idioms**
- [MINOR] Optional chaining (`?.`) preferred over null checks for property access chains
- [MINOR] Nullish coalescing (`??`) preferred over `||` when falsy values (0, '') are valid
- [MINOR] Logical assignment operators (`&&=`, `||=`, `??=`) used for conditional assignment
- [MINOR] Destructuring used for function parameters and return values to improve readability
- [MAJOR] Spread operator used correctly; not used to deep-clone objects (use `structuredClone` or libraries)
- [MINOR] Array methods (`map`, `filter`, `reduce`, `find`, `some`, `every`, `flat`, `flatMap`) preferred over imperative loops where readability improves
- [MINOR] Template literals used instead of string concatenation for multi-variable strings
- [MINOR] `async/await` preferred over `.then()` chains; mixed usage in the same function avoided

**React-Specific (when applicable)**
- [CRITICAL] Hooks rules: hooks called only at the top level and only inside React functions; no conditional hooks
- [MAJOR] `useEffect` dependencies array complete and accurate; no empty-array workarounds that hide stale closures
- [MAJOR] State updates: functional updater form `setState(prev => ...)` used when new state depends on previous
- [MAJOR] Props not mutated; components remain pure
- [MAJOR] Keys in lists are stable and unique (not array indices unless list is static and never reordered)
- [MINOR] `useCallback` / `useMemo` used for referential stability of callbacks/values passed to optimized children; not applied indiscriminately
- [MINOR] Context not used for high-frequency updates (prefer Zustand, Jotai, or similar for that)
- [MAJOR] Server Components do not import client-only code; `'use client'` directive placed at the appropriate boundary

**Vue 3-Specific (when applicable)**
- [MINOR] Composition API (`<script setup>`) preferred over Options API for new components
- [MINOR] `ref` for primitives, `reactive` for objects; not mixed arbitrarily
- [MINOR] `watchEffect` used for side effects that depend on reactive state; `watch` used when old/new value comparison is needed
- [MAJOR] Props not mutated directly; emit used for parent communication
- [MAJOR] `v-if` and `v-for` not on the same element; `v-if` takes priority — extract to wrapper element

**Node.js-Specific (when applicable)**
- [MAJOR] Asynchronous APIs (fs.promises, stream.pipeline) preferred over synchronous equivalents in production code paths
- [MAJOR] `process.env` values validated at startup; not accessed scattered throughout the codebase without defaults
- [MINOR] Error-first callbacks pattern followed when using older-style async APIs
- [MAJOR] Streams backpressure respected; `pipe` / `pipeline` preferred over manual `data` event handlers
- [MINOR] Worker threads used for CPU-bound tasks; not for I/O (use async APIs instead)
- [MAJOR] No `require()` calls in ESM modules; no `import` in CJS without dynamic import wrapper

**Testing**
- [MINOR] Tests describe behaviour, not implementation; `it('should ...', ...)` naming used
- [MINOR] `Testing Library` queries: `getByRole` / `getByLabelText` preferred over `getByTestId` for accessibility-first testing
- [MAJOR] Mocks reset between tests; no shared mutable mock state across test files
- [MAJOR] Async tests use `async/await` or return a Promise; never fire-and-forget inside `it()`
- [MINOR] Snapshot tests used sparingly; not applied to large components where they become noise