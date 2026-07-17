# Python Testing Conventions

Apply when writing or editing Python tests (`test_*.py`, `*_test.py`, `tests/`). Follow the project's existing layout and fixtures.

## Runner and layout

- Use pytest. Do not write new `unittest.TestCase` classes; plain functions with `assert` are the standard.
- Mirror the source layout under `tests/` (or co-locate per the project's convention): `src/queue/manager.py` gets `tests/queue/test_manager.py`.
- One test module per source module; group cases with plain functions, or classes without inheritance (`class TestJobQueue:`) when grouping helps.

## Test names read as behavior

Function names state the unit, the condition, and the expected outcome:

```python
# GOOD
def test_load_profile_returns_none_when_user_missing(): ...
def test_enqueue_raises_when_queue_is_closed(): ...
def test_parse_config_uses_defaults_for_absent_keys(): ...

# BAD
def test_1(): ...
def test_load_profile(): ...   # no condition, no outcome
```

## What to test

- Behavior visible to callers: return values, raised exceptions, emitted side effects.
- Every pure function covers the golden path, empty input, boundary values, and error input.
- Error paths: assert the specific exception with `pytest.raises(SpecificError)` — never a bare `Exception`.
- Branches worth existing are branches worth a test case.

## What NOT to test

- Private helpers directly — exercise them through the public surface; if they need direct tests, they may deserve to be public in their own module.
- The standard library or third-party packages.
- Trivial passthroughs and generated code.

## Choosing the test level

Default to the lowest level that can catch the bug: unit tests for pure logic, integration tests for wiring (route + service + a real test database or faked boundary), end-to-end tests only for the few critical user journeys. The higher the level, the fewer the tests — each E2E case must earn its runtime and maintenance cost. Do not re-prove at a higher level what a lower level already covers.

## Fixtures and parametrization

- Use fixtures for shared setup instead of module-level state or copy-pasted arrangement blocks; keep fixtures small and composable.
- Use `@pytest.mark.parametrize` for input/output matrices instead of duplicating near-identical test bodies.
- Use built-in fixtures over hand-rolled equivalents: `tmp_path` for filesystem work, `monkeypatch` for environment and attribute patching, `caplog` for log assertions, `capsys` for stdout/stderr.

## Isolation

- Tests must pass in any order and in isolation. No test may depend on another test having run, on real network access, on the wall clock, or on leftover files.
- Reset or isolate anything global: environment variables via `monkeypatch`, singletons via fixtures with teardown, the filesystem via `tmp_path`.
- Freeze or inject time (e.g. a clock parameter or a freezing helper) rather than asserting against `datetime.now()`.

## Mocking

- Mock at the boundary the code under test talks to (HTTP layer, database session, message bus client), not deep internals.
- Prefer injecting fakes/stubs through parameters over patching module internals; reach for `monkeypatch`/`unittest.mock.patch` when injection is not available, and patch where the name is looked up, not where it is defined.
- Async code is tested with `pytest-asyncio`; do not run event loops by hand in tests.

## Assertions

- One behavior per test. Multiple `assert` lines are fine when they describe a single outcome (e.g. fields of one returned object); asserting two unrelated behaviors means two tests.
- Assert on values and structure, not on `repr` strings or log message substrings, unless the message itself is the contract.

## Flaky tests are bugs

Do not add retries or skips. The usual culprits are shared state, real time, real network, and test-order dependence — fix the isolation, not the symptom. Running with randomized order (`pytest-randomly`) keeps ordering honesty enforced.
