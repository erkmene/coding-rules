# JavaScript / TypeScript Testing Conventions

Apply when writing or editing tests for JS/TS code, on top of the general testing conventions. Assumes a Jest- or Vitest-style runner; for UI, Testing Library. Follow the project's existing runner and helpers.

## Files

- Co-locate the test next to its source: `Foo.ts` gets `Foo.test.ts` in the same folder (`useFoo.test.ts`, `mapFoo.test.ts` likewise).

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

## UI tests

- Test event handlers and callbacks: called with the right arguments at the right time.
- Test the props you pass to third-party components, not their rendering.
- Query the way users and assistive technology find things: by role and accessible name first, test IDs last. Do not add test IDs to production markup when a semantic query works.
- Do not assert on class names (fragile to refactors) except when the class is itself the state contract (`disabled`, `loading`).

## Mocking

- Mock at the network layer (MSW or the runner's network interception), not by stubbing `fetch` or the HTTP client — it is closer to reality.
- Keep happy-path handlers/fixtures in one shared place and extend them; override per-test only for deviations (errors, empty responses).
- Type mocks the same as production code. If the types make mocking impossible, the source types have a problem.

## State

- Every test starts from a clean slate: reset stores to initial state and clear `localStorage`/`sessionStorage` in `beforeEach` when the code under test touches them.
- Pin the locale and the system time (fake timers) in test setup.

## Snapshots

Appropriate for: the default render of a small leaf component, one snapshot per visual variant, stable output guarding against accidental DOM regressions.

Not appropriate for: output that varies per locale/timestamp/UUID, container or page components, or anything over ~50 lines — use targeted assertions instead.

When a snapshot fails: read the diff; update only if the change is intentional, otherwise fix the regression. Delete snapshots in the same commit as the component they belong to.
