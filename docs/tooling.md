# Enforcing rules with tools

Rules that a tool can check were removed from `rules/`. A linter, type checker or CI job enforces them every time and for every author, whereas prose in an agent's context only asks. This page lists the tools and settings that take over from the removed rules. Configure the ones that fit each project. An existing project's tool choices win.

## Formatting

- JS/TS: Prettier. Python: Ruff's formatter (or Black).
- Run the formatter on save, in a pre-commit hook, and after every agent edit (see [Agent hooks](#agent-hooks)).

## JavaScript and TypeScript

Use ESLint with typescript-eslint's type-checked presets (`strictTypeChecked`, `stylisticTypeChecked`) where the project allows.

| Removed rule | Enforce with |
|---|---|
| Strict equality | `eqeqeq` (`smart` permits `== null`) |
| `const` by default, never `var` | `prefer-const`, `no-var` |
| Template literals, destructuring | `prefer-template`, `prefer-destructuring` |
| `?.` and `??` | `@typescript-eslint/prefer-optional-chain`, `@typescript-eslint/prefer-nullish-coalescing` |
| No floating promises; no `async` event handlers | `@typescript-eslint/no-floating-promises`, `@typescript-eslint/no-misused-promises` |
| Throw `Error` instances | `@typescript-eslint/only-throw-error` |
| No `any`, no `as any` | `@typescript-eslint/no-explicit-any`, the `no-unsafe-*` rules |
| Justified `@ts-expect-error`, no `@ts-ignore` | `@typescript-eslint/ban-ts-comment` with `allow-with-description` |
| Justified `eslint-disable` | `@eslint-community/eslint-comments/require-description` |
| No non-null assertions | `@typescript-eslint/no-non-null-assertion` |
| Exhaustive `switch` over unions | `@typescript-eslint/switch-exhaustiveness-check` |
| Explicit types on exports | `@typescript-eslint/explicit-module-boundary-types`, or `isolatedDeclarations: true` |
| `import type` for type-only imports | `@typescript-eslint/consistent-type-imports` plus `verbatimModuleSyntax: true` |
| Caught errors are `unknown` | `useUnknownInCatchVariables` (part of `strict`) |
| No stray `console.log` | `no-console` |
| No unused code | `@typescript-eslint/no-unused-vars`, `noUnusedLocals`, `noUnusedParameters` |
| No empty `catch` | `no-empty` |
| One level of nested ternary | `no-nested-ternary` |
| Function and file size, parameter count | `max-lines-per-function`, `max-lines`, `max-params` |
| Low cognitive complexity | `sonarjs/cognitive-complexity` |
| No commented-out code | `sonarjs/no-commented-code` |
| Named constants for magic values | `@typescript-eslint/no-magic-numbers` |
| `for...of` over index loops | `unicorn/no-for-loop` |
| Rules of React, Rules of Hooks | `eslint-plugin-react-hooks` (including its React Compiler rules) |
| Accessible names, labels, semantic elements, no positive `tabIndex` | `eslint-plugin-jsx-a11y` (`alt-text`, `control-has-associated-label`, `label-has-associated-control`, `prefer-tag-over-role`, `tabindex-no-positive`) |
| `rel="noopener"` on `target="_blank"` | `react/jsx-no-target-blank` |
| Testing Library: `findBy*` over sleeps, no needless `act()` | `eslint-plugin-testing-library` (`prefer-find-by`, `no-unnecessary-act`, `prefer-screen-queries`) |
| Strict compiler options | `tsconfig.json`: `strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, or extend `@tsconfig/strictest` |

## Python

Use Ruff for linting and a type checker (pyright, or mypy with `disallow_untyped_defs`) in CI.

| Removed rule | Ruff rules |
|---|---|
| PEP 8 naming | `N` |
| f-strings, modern typing syntax | `UP` (e.g. `UP006`, `UP007`, `UP031`, `UP032`) |
| Comprehensions over `map`/`filter` and accumulate loops | `C4`, `PERF401` |
| Type hints on public functions | `ANN` |
| No bare or swallowing `except` | `E722`, `BLE001`, `S110` |
| `raise ... from err` | `B904` |
| No blocking calls in `async def` | `ASYNC` |
| No unreferenced `create_task` | `RUF006` |
| Context managers for resources | `SIM115` |
| `pathlib` over `os.path` | `PTH` |
| No `print` for diagnostics | `T201` |
| Lazy log interpolation | `G004` |
| No mutable default arguments | `B006` |
| No `global` | `PLW0603` |
| Keyword arguments for booleans | `FBT` |
| Named constants for magic values | `PLR2004` |
| Function size, parameter count, complexity | `PLR0915`, `PLR0913`, `C901` |
| No commented-out code | `ERA001` |
| No unused imports, variables or arguments | `F401`, `F841`, `ARG` |
| pytest style; specific `pytest.raises` | `PT` (e.g. `PT009`, `PT011`, `PT027`) |
| Injection, `eval`, shell strings, insecure randomness | `S` (flake8-bandit), e.g. `S102`, `S307`, `S602`, `S311` |

## Architecture

- Layer direction, feature "doors" and import cycles:
  - JS/TS: `dependency-cruiser` or `eslint-plugin-boundaries`, plus `import/no-cycle` (or `madge --circular`) for cycles alone.
  - Python: `import-linter` contracts (`layers`, `independence`, `forbidden`).
- No scattered environment reads, except in the config module:
  - JS/TS: `n/no-process-env`.
  - Python: Ruff `TID251` (banned API) for `os.environ` and `os.getenv`.

## Repository and CI

- **Secrets:** gitleaks or trufflehog in a pre-commit hook and in CI; enable your host's push protection. A secret that reaches a commit must be rotated.
- **Commit messages:** commitlint (`header-max-length` 72, `subject-full-stop`, `subject-case`).
- **Shared branches:** protect them against force-pushes and history rewrites.
- **Lockfiles:** install in CI with `npm ci`, `pnpm install --frozen-lockfile` or `uv sync --locked`, so a missing or stale lockfile fails the build.
- **Vulnerabilities:** Dependabot or Renovate, plus `npm audit` or `pip-audit` in CI; triage new advisories.
- **Migrations:**
  - fail CI when a migration file that already exists on the main branch is modified;
  - lint migrations for destructive or locking operations (squawk for Postgres, or your framework's equivalent).
- **HTTP APIs:** `oasdiff breaking` against the published OpenAPI contract; Spectral for naming and casing.
- **Tests:**
  - run them in random order (`pytest-randomly`, Vitest `sequence.shuffle`, Jest `--randomize`);
  - reset mocks between tests in runner config (`restoreMocks`);
  - enforce coverage thresholds in runner config.

## Agent hooks

Most coding agents can run commands around their own actions. Wire these in your agent tool. The commands are project-specific.

- **After each file edit:** run the formatter and auto-fixable lint rules on that file.
- **When the agent finishes a task:** run lint, type checking and the affected tests, and hand any failures back to the agent.
- **Before shell commands:** block force-pushes to shared branches, `git commit --no-verify`, and edits that weaken compiler or linter settings.

For checks that should also apply to people and to every tool, prefer git hooks (pre-commit, lefthook) over agent-only hooks.
