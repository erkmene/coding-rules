# JavaScript / TypeScript Testing Conventions

Apply when writing or editing tests for JS/TS code (`*.test.*`, `*.spec.*`, `__tests__/`). Assumes a Jest- or Vitest-style runner; for UI, Testing Library. Follow the project's existing runner and helpers.

## Files and structure

- Co-locate the test next to its source: `Foo.ts` gets `Foo.test.ts` in the same folder (`useFoo.test.ts`, `mapFoo.test.ts` likewise).
- One test file per source file; never group tests for multiple modules in one file.
- Structure with `describe` per unit under test and `it` per case.

## Test names read as behavior

`it(...)` strings read like a sentence: verb + condition + expected outcome.

```ts
// GOOD
it('renders nothing when label is empty', ...);
it('shows error toast when search fails', ...);
it('calls onSubmit with form values', ...);

// BAD
it('test 1', ...);          // useless
it('label', ...);           // ambiguous
it('should render', ...);   // no condition, no outcome
```

## What to test

- User-visible behavior — what someone using the code (or app) would notice.
- Conditional branches: output appears/changes based on input or state.
- Event handlers and callbacks: called with the right arguments at the right time.
- Pure transform functions (mappers, formatters): input shape to output shape, branches covered exhaustively — including the golden path, empty input, boundary values, and error input.
- Error paths: what happens on a 500, a null, a wrong shape.

## What NOT to test

- Implementation details: internal state values, private helpers, call order of internals.
- Library code (that the query cache caches, that the store subscribes).
- Third-party components — test the props you pass them, not their rendering.
- CSS and visual appearance (that belongs to visual regression tooling, not unit tests).
- Trivial getters and one-line passthroughs.

## UI queries (Testing Library)

Use the highest-priority query that works, most to least preferred:

1. `getByRole(role, { name })` — matches what assistive tech sees
2. `getByLabelText`, `getByPlaceholderText` — form fields
3. `getByText` — non-interactive content
4. `getByTitle`, `getByDisplayValue`
5. `getByTestId` — last resort, only when no semantic query works

Do not add test IDs to production markup just to make a test pass — try a semantic query first. Do not assert on class names (fragile to refactors) except when the class is itself the state contract (`disabled`, `loading`).

## Async

- Await UI updates with `findBy*` or `waitFor`; never sleep with `setTimeout`.
- Never wrap in `act()` just to silence warnings — the warning means an update was not awaited; fix that.
- Control time-dependent code with fake timers and a fixed system time, never real clocks.

## Mocking

- Mock at the network layer (MSW or the runner's network interception), not by stubbing `fetch` or the HTTP client — it is closer to reality.
- Keep happy-path handlers/fixtures in one shared place and extend them; override per-test only for deviations (errors, empty responses).
- Reset handlers and mocks between tests.
- Never mock the framework itself (no `jest.mock('react', ...)`).
- Type mocks the same as production code — no `as any` / `@ts-ignore` in tests. If the types make mocking impossible, the source types have a problem.

## State isolation

- Every test starts from a clean slate: reset stores to initial state and clear `localStorage`/`sessionStorage` in `beforeEach` when the code under test touches them.
- Tests must pass in any order and in isolation; shared mutable state between tests is a bug.

## Snapshots

Appropriate for: the default render of a small leaf component, one snapshot per visual variant, stable output guarding against accidental DOM regressions.

Not appropriate for: output that varies per locale/timestamp/UUID, container or page components, or anything over ~50 lines — use targeted assertions instead.

When a snapshot fails: read the diff; update only if the change is intentional, otherwise fix the regression. Delete snapshots in the same commit as the component they belong to.

## Flaky tests are bugs

Do not add retries or skip them. Common causes and fixes:

| Symptom | Cause | Fix |
|---------|-------|-----|
| Passes alone, fails in suite | Shared state leak | Reset state/storage in `beforeEach` |
| Assertion fires before update | Missing `await` | `findBy*` / `await waitFor(...)` |
| Time-based mismatch | Real `new Date()` | Fake timers + fixed system time |
| Locale-dependent output | Real locale formatting | Pin the locale in test setup |

## Coverage

- New code ships with tests that keep the project's coverage thresholds green. Test files, stories, type declarations, constants, and re-export indexes are excluded from coverage, not tested for its own sake.
- Coverage is a floor, not a goal — a covered line with no meaningful assertion is worse than an uncovered one, because it looks safe.
