# New Python Project Guidelines

Apply when creating a Python project or changing its packaging, dependency, or tooling setup. An existing project's choices win.

- `pyproject.toml` is the single source of truth for metadata, dependencies, and tool configuration. No `requirements.txt`, no `setup.py`.
- Use `uv` for environments, installs, and lockfiles; dev dependencies go in PEP 735 `[dependency-groups]`.
- Use Ruff for both linting and formatting, configured under `[tool.ruff]`. A good starting rule selection: `E`, `F`, `I`, `B`, `UP`, `SIM`, `RUF`.
- Use a `src/` layout for packages to prevent accidental imports from the repository root.
- Scripts and entry points stay thin — argument parsing and wiring only, delegating to importable functions (keeps the entry file a table of contents and the logic testable).
