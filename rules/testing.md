# Testing Conventions

Apply when writing or editing tests in any language, before the language-specific testing rules. Follow the project's existing runner, layout, and helpers.

## Layout

- Unit tests: one test file per source file. Integration and end-to-end tests live where the project keeps them.

## What to test

- Behavior a caller or user would notice: return values, raised errors, emitted effects, what appears on screen.
- Branches worth existing are branches worth a test case.
- Every pure function covers the golden path, empty input, boundary values, and error input.
- Error paths: failed dependencies, missing values, wrong shapes.

## What NOT to test

- Implementation details: internal state, private helpers, the call order of internals. Exercise private helpers through the public surface; if they need direct tests, they may deserve to be public in their own module.
- Third-party code, trivial passthroughs, and generated code.
- Visual appearance; that belongs to visual regression tooling, not unit tests.

## Choosing the test level

Default to the lowest level that can catch the bug: unit tests for logic and pure transforms, integration tests for wiring, end-to-end tests only for the few critical user journeys. The higher the level, the fewer the tests — each E2E case must earn its runtime and maintenance cost. Do not re-prove at a higher level what a lower level already covers.

## Isolation

- Tests must pass in any order and in isolation. No test may depend on another test having run, on real network access, on the wall clock, or on leftover files.
- Control time with fakes or an injected clock, never the real clock.
- Mock at the boundary the code under test talks to (HTTP layer, database session, message bus client), not deep internals. Prefer injecting fakes through parameters over patching internals.

## Assertions

- One behavior per test. Several assertions are fine when they describe a single outcome (e.g. fields of one returned object); two unrelated behaviors means two tests.
- Assert on values and structure, not on string representations or log message substrings, unless the message itself is the contract.

## Flaky tests are bugs

Do not add retries or skips. The usual culprits are shared state, real time, real network, locale, and test-order dependence — fix the isolation, not the symptom.

## Coverage

- New code ships with tests that keep the project's coverage thresholds green.
- Coverage is a floor, not a goal — a covered line with no meaningful assertion is worse than an uncovered one, because it looks safe.
