# Python Guidelines

Apply to all Python code. Universal principles apply first. Target modern Python (3.12+) unless the project pins older.

## Types and structured data

- Use `Literal`, `Protocol`, and `TypedDict`/dataclasses to make shapes explicit rather than passing bare dicts around.
- Prefer `dataclass` (or Pydantic models where validation at a boundary is needed) over dicts or tuples for structured data with known fields.
- Model closed sets of values with `Enum` or `Literal` types, not magic strings.

## Errors

- Catch broad exceptions only at top-level boundaries, where you log and translate the failure.
- Prefer EAFP ("easier to ask forgiveness than permission") where it reads naturally: `try`/`except KeyError` over pre-checking, when the failure case is genuinely exceptional.
- Custom exception classes derive from a project base exception when callers need to branch on error kinds.

## Asynchrony

Applies when the project uses asyncio or an async framework built on it.

- Prefer structured concurrency: `asyncio.TaskGroup` (3.11+) over bare `asyncio.create_task` or hand-rolled `gather` bookkeeping — tasks cannot outlive their scope, and one failure cancels the siblings and propagates.
- External I/O has a timeout, set on the client or per call (`asyncio.timeout(...)`); a hung dependency must not hang the service.

## Logging

- `print` is only for a CLI's actual output, never for diagnostics.
- Structured logging (e.g. `structlog`) is preferred for services; bind context (request id, job id) once and let child log lines inherit it.

## Call sites

- Prefer explicit keyword arguments at call sites when a function takes more than two arguments of the same type or booleans — `retry(attempts=3, backoff=True)` reads; `retry(3, True)` does not.
