# Python Testing Conventions

Apply when writing or editing Python tests, on top of the general testing conventions. Follow the project's existing layout and fixtures.

## Runner and layout

- Use pytest with plain functions and `assert`; do not write new `unittest.TestCase` classes. Group cases in classes without inheritance (`class TestJobQueue:`) only when grouping helps.
- Mirror the source layout under `tests/` (or co-locate per the project's convention): `src/queue/manager.py` gets `tests/queue/test_manager.py`.

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

## Fixtures and parametrization

- Use fixtures for shared setup instead of module-level state or copy-pasted arrangement blocks; keep fixtures small and composable.
- Use `@pytest.mark.parametrize` for input/output matrices instead of duplicating near-identical test bodies.
- Use built-in fixtures over hand-rolled equivalents: `tmp_path` for filesystem work, `monkeypatch` for environment and attribute patching, `caplog` for log assertions, `capsys` for stdout/stderr.
- Reset or isolate anything global: environment variables via `monkeypatch`, singletons via fixtures with teardown.

## Mocking

- When patching is unavoidable, patch where the name is looked up, not where it is defined.
- Async code is tested with the project's async pytest plugin (pytest-asyncio or anyio); do not run event loops by hand in tests.
