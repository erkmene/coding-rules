# Testing Conventions

Apply when writing or editing tests in any language, before the language-specific testing rules. Follow the project's existing runner, layout, and helpers.

## Choosing the test level

Default to the lowest level that can catch the bug: unit tests for logic and pure transforms, integration tests for wiring (component + hook + mocked network together), end-to-end tests only for the few critical user journeys. The higher the level, the fewer the tests — each E2E case must earn its runtime and maintenance cost. Do not re-prove at a higher level what a lower level already covers.

## Flaky tests are bugs

Do not add retries or skips. The usual culprits are shared state, real time, real network, and test-order dependence — fix the isolation, not the symptom. Running with randomized order (`pytest-randomly`) keeps ordering honesty enforced.

## Coverage

- New code ships with tests that keep the project's coverage thresholds green. Test files, stories, type declarations, constants, and re-export indexes are excluded from coverage, not tested for its own sake.
- Coverage is a floor, not a goal — a covered line with no meaningful assertion is worse than an uncovered one, because it looks safe.
