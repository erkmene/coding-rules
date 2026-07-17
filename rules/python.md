# Python Guidelines

Apply to all Python code (`.py`). Universal principles apply first. Target modern Python (3.12+) unless the project pins older.

## Style

- Follow PEP 8; let the project's formatter be the authority (Ruff's formatter or Black — do not hand-format against it).
- Naming: `snake_case` for functions, variables, and modules; `PascalCase` for classes; `UPPER_SNAKE_CASE` for constants; a leading underscore for internal helpers.
- f-strings for interpolation, never `%` formatting or `.format()` (exception: logging calls, below).
- Prefer comprehensions and generator expressions over `map`/`filter` with lambdas, and over accumulate-in-a-loop patterns — but never nest comprehensions past the point of readability.

## Type hints

- Type hints are mandatory on every public function (parameters and return type). Internal helpers may rely on inference where obvious, but anything crossing a module boundary is annotated.
- Use modern syntax: built-in generics (`list[str]`, `dict[str, int]`), `X | None` instead of `Optional[X]`, `X | Y` instead of `Union[X, Y]`.
- Run a static type checker (pyright or mypy) as part of the workflow; new code must pass it.
- Use `Literal`, `Protocol`, and `TypedDict`/dataclasses to make shapes explicit rather than passing bare dicts around.

## Structured data

- Prefer `dataclass` (or Pydantic models where validation at a boundary is needed) over dicts or tuples for structured data with known fields.
- Model closed sets of values with `Enum` or `Literal` types, not magic strings.

## Errors

- Raise and catch specific exception types. Bare `except:` and `except Exception:` that swallow the error are forbidden; catch broadly only at top-level boundaries where you log and translate the failure.
- Use exception chaining (`raise NewError(...) from err`) so causes are preserved.
- Prefer EAFP ("easier to ask forgiveness than permission") where it reads naturally: `try`/`except KeyError` over pre-checking, when the failure case is genuinely exceptional.
- Custom exception classes derive from a project base exception when callers need to branch on error kinds.

## Asynchrony

Applies when the project uses asyncio or an async framework built on it.

- Never make blocking calls inside `async def`: `time.sleep`, synchronous HTTP clients, synchronous DB drivers, heavy CPU work. Use the async equivalent (`asyncio.sleep`, an async client/driver) or push the blocking work to a thread (`asyncio.to_thread`).
- Prefer structured concurrency: `asyncio.TaskGroup` (3.11+) over bare `asyncio.create_task` or hand-rolled `gather` bookkeeping — tasks cannot outlive their scope, and one failure cancels the siblings and propagates.
- Never fire-and-forget a bare `create_task`: the event loop holds only weak references, so an unreferenced task can be garbage-collected mid-flight and its exception silently lost. Hold a reference and consume its result, or use a `TaskGroup`.
- Every await on external I/O gets a timeout (`asyncio.timeout(...)`); a hung dependency must not hang the service.

## Resources and I/O

- Use context managers (`with`) for anything that must be released: files, locks, connections, sessions. Never rely on garbage collection for cleanup.
- Use `pathlib.Path` for filesystem paths, not string concatenation or `os.path`.

## Logging

- Use the `logging` module with a module-level logger: `logger = logging.getLogger(__name__)`. The `__name__` namespace gives the story-telling, per-module context the universal rules require. Never use `print` for diagnostics in library or application code.
- Use lazy interpolation in log calls (`logger.info("loaded %s rooms", count)`) so formatting only happens when the level is enabled.
- Structured logging (e.g. `structlog`) is preferred for services; bind context (request id, job id) once and let child log lines inherit it.

## Project layout and tooling

These are defaults for new projects; an existing project's choices win.

- `pyproject.toml` is the single source of truth for metadata, dependencies, and tool configuration. No `requirements.txt`, no `setup.py`.
- Use `uv` for environments, installs, and lockfiles; dev dependencies go in PEP 735 `[dependency-groups]`.
- Use Ruff for both linting and formatting, configured under `[tool.ruff]`. A good starting rule selection: `E`, `F`, `I`, `B`, `UP`, `SIM`, `RUF`.
- Use a `src/` layout for packages to prevent accidental imports from the repository root.
- Scripts and entry points stay thin — argument parsing and wiring only, delegating to importable functions (keeps the entry file a table of contents and the logic testable).

## Idioms

- No mutable default arguments (`def f(items=[])`); default to `None` and create inside.
- Guard executable module behavior with `if __name__ == "__main__":`.
- Prefer explicit keyword arguments at call sites when a function takes more than two arguments of the same type or booleans — `retry(attempts=3, backoff=True)` reads; `retry(3, True)` does not.
- Avoid `global`; pass state explicitly or encapsulate it in a class when it is genuinely entity state.
