# coding-rules

Coding rules for AI coding agents, written once as plain, tool-agnostic Markdown. Your agent installs them by following [`INSTALL.md`](INSTALL.md); this repository contains no tool-specific files.

## Layout

```
rules/              the rules: plain Markdown, no frontmatter, no tool syntax
checklists/
  review.md         the definition of done, checked before work is handed off
docs/
  tooling.md        linters, type checkers, CI and hooks that enforce the checkable rules
INSTALL.md          instructions for the installing agent: scope table, install, update, uninstall
CHANGELOG.md        releases, each with the action an update needs
```

## Installing

Ask your coding agent:

> Install the coding rules from https://github.com/erkmene/coding-rules. Follow its INSTALL.md.

The agent asks you a few questions before it changes anything:

- **Mode:**
  - **Personal:** one clone (default `~/coding-rules`), wired into your agent tools' user-level configuration. It serves all your projects on that machine, and updating the clone updates all of them. It does not reach teammates, CI or cloud sessions.
  - **Project:** a copy in `coding-rules/` inside the project, committed with it, so the rules work for everyone who clones the project, including cloud sessions. Each project is updated separately.
- **Tools:** which agent tools to wire.
- **i18n:** whether the project translates its user-facing text, which enables the i18n rules.
- **Version:** the latest release or `main`.

The agent wires each rule with its own tool's native mechanism: always-on rules, path-scoped rules, on-demand skills, and a reviewer subagent where the tool has one. Where a mechanism is missing, it falls back to instructions in a marked block of the tool's instructions file (such as `AGENTS.md`). Wiring files only reference the rule files and never contain rule text, so they cannot drift from this repository. The agent records what it installed in `manifest.json` in the rules folder.

## Updating and removing

> Update the coding rules. Follow the INSTALL.md in the coding-rules folder.

The agent:
1. reads the manifest;
2. reads every changelog entry since your installed version;
3. fetches the new version and does any manual steps the changelog lists;
4. re-wires whatever changed, asking before it overwrites anything you edited;
5. tells you what changed in how it should work.

To remove the rules, ask the agent to uninstall them; it removes exactly what the manifest lists.

## The rules

| File | Covers | Loads |
|------|--------|-------|
| `rules/universal.md` | Code as a story, abstraction discipline, naming, function design, errors, logging, docs, scope of work | always |
| `rules/architecture.md` | Dependency direction, feature boundaries, functional core, adapters, configuration | always |
| `rules/security.md` | Sensitive data, object-level authorization, fail closed, least privilege | always |
| `rules/git.md` | Commits, branches, pull requests | when doing version-control work |
| `rules/api-design.md` | HTTP APIs: compatibility, versioning, errors, pagination, idempotency | for API work or API files |
| `rules/data.md` | Schema compatibility, migrations, transactions, queries | for schema and query work or data files |
| `rules/i18n.md` | Translated user-facing text | opt-in |
| `rules/javascript.md` | JavaScript (and TypeScript) | JS/TS files |
| `rules/typescript.md` | TypeScript, on top of JavaScript | TS files |
| `rules/python.md` | Python | Python files |
| `rules/new-project-python.md` | Python packaging and tooling choices | when setting up a Python project |
| `rules/react.md` | React components and hooks | React files |
| `rules/testing.md` | Testing in any language | test files |
| `rules/testing-js.md` | JS/TS tests | JS/TS test files |
| `rules/testing-python.md` | Python tests | Python test files |
| `checklists/review.md` | Definition of done | before handing work off |

The exact paths and activity descriptions live only in the scope table in `INSTALL.md`.

Precedence: the project's own established conventions win over these rules. Among the rules, the more specific one wins: universal, then language, then framework, then testing.

## Models

The rules were written for, and checked against, current frontier coding agents from the **Claude** (Anthropic) and **GPT** (OpenAI) families. They assume an agent that:
- already follows mainstream good practice without being told;
- reads files it is pointed to;
- follows multi-step written procedures such as `INSTALL.md`.

With smaller or older models, the rules listed below may need to be added back as project rules.

## Deliberately omitted

To keep every line in an agent's context worth its cost, two kinds of rules were removed in October 2026.

**Things current Claude and GPT models already do by default**, including:
- naming functions as verbs, values as nouns and booleans as predicates; no Hungarian notation;
- guard clauses and early returns;
- failing fast on programmer errors and handling expected runtime failures;
- choosing log levels;
- keeping comments current;
- storing timestamps in UTC and not doing arithmetic on local wall-clock time;
- not storing money as binary floating point;
- locale-aware formatting;
- performance basics: measure first, avoid N+1 queries, pick the right data structure;
- parameterized queries and safe path handling; no user data in `eval` or shell strings; secure randomness for security;
- keeping secrets out of source and taking configuration from the environment;
- adaptive password hashing;
- not trusting client-supplied identity;
- HTTP method and status-code semantics; plural resource names;
- not leaking internals in error responses;
- wrapping multi-write operations in a transaction;
- imperative commit subjects;
- rotating leaked secrets;
- the Rules of React;
- standard pytest and Testing Library practice.

**Things a tool can enforce**, including:
- formatting and style;
- `===`, `const`, template literals and destructuring;
- floating promises;
- `any` and non-null assertions;
- `import type`;
- unused and commented-out code;
- `console.log` and `print`;
- empty `catch` blocks;
- size and complexity limits;
- most Python idioms;
- accessibility basics;
- lockfiles and dependency audits;
- force-push protection;
- commit message format;
- immutable migrations.

[`docs/tooling.md`](docs/tooling.md) lists the tool and setting for each one.

## Changing the rules

1. Edit or add the file in `rules/` (or `checklists/`): plain Markdown, no frontmatter, no tool-specific syntax.
2. For a new rule or a scope change, update the scope table in `INSTALL.md`; nowhere else defines scope.
3. Add an entry under `Unreleased` in `CHANGELOG.md`, with its **Action**.
4. To release, rename `Unreleased` to the version, then tag and publish `vX.Y.Z`.
