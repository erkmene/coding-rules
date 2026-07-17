# Coding Rules

Canonical, tool-agnostic coding rules for AI-assisted development. The rule content lives in [`coding-rules/rules/`](coding-rules/rules/) (a git submodule) — a single source of truth shared by every tool (Cursor, Claude Code, and anything that reads `AGENTS.md`). Tool-specific activation stubs live in `.cursor/rules/` and `.claude/rules/` and contain no rule content of their own.

## Philosophy

Code is a story told step by step toward a definite purpose: the entry file is the table of contents, every module is a chapter that is also a story in itself, details are extracted and referenced rather than told inline (never twice), names are explicit and right-sized, and the logs narrate the same story at runtime. The full statement of these principles is in [`coding-rules/rules/universal.md`](coding-rules/rules/universal.md).

## Which rules apply where

| Rule file | Applies to |
|-----------|------------|
| [`coding-rules/rules/universal.md`](coding-rules/rules/universal.md) | Every file, every language — always in effect |
| [`coding-rules/rules/architecture.md`](coding-rules/rules/architecture.md) | Every file — module boundaries, dependency direction, configuration — always in effect |
| [`coding-rules/rules/security.md`](coding-rules/rules/security.md) | Every file — always in effect; extends the universal security items |
| [`coding-rules/rules/git.md`](coding-rules/rules/git.md) | Version-control activity: commits, branches, pull requests |
| [`coding-rules/rules/api-design.md`](coding-rules/rules/api-design.md) | HTTP (REST) API design and implementation — self-scoped, skip if no API surface |
| [`coding-rules/rules/data.md`](coding-rules/rules/data.md) | Schema, migrations, and queries — self-scoped, skip if no database |
| [`coding-rules/rules/javascript.md`](coding-rules/rules/javascript.md) | `**/*.{js,jsx,mjs,cjs}` and, together with the TypeScript rules, `**/*.{ts,tsx}` |
| [`coding-rules/rules/typescript.md`](coding-rules/rules/typescript.md) | `**/*.{ts,tsx}` (on top of the JavaScript rules) |
| [`coding-rules/rules/python.md`](coding-rules/rules/python.md) | `**/*.py` |
| [`coding-rules/rules/react.md`](coding-rules/rules/react.md) | React UI code only: components and hooks in `**/*.{jsx,tsx}` |
| [`coding-rules/rules/testing-js.md`](coding-rules/rules/testing-js.md) | JS/TS tests: `**/*.{test,spec}.{js,jsx,ts,tsx}`, `**/__tests__/**` |
| [`coding-rules/rules/testing-python.md`](coding-rules/rules/testing-python.md) | Python tests: `**/test_*.py`, `**/*_test.py`, `tests/**` |

Precedence: the more specific rule wins. Universal < language < framework (React) < testing conventions, and this project's own established conventions win over all of these.

## Scope notes

- The React rules apply only where React is actually in use; never apply React patterns to non-React code.
- The API design and data rules are self-scoped: they are always loaded but apply only when the project has an HTTP API surface or a durable store, respectively.
- The git rules govern workflow (commits, branches, PRs), not file content.
- Language rules do not assume a framework. Framework-scoped guidance (currently React) lives in its own file.
- Tooling recommendations inside the rules (uv, Ruff, typescript-eslint, ...) are defaults for new projects; an existing project's tool choices take precedence.
