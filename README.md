# coding-rules

Canonical, tool-agnostic coding rules for AI-assisted development (Cursor, Claude Code, and anything that reads `AGENTS.md`), designed to be shared across projects as a git submodule with zero duplicated rule content.

## Layout

```
rules/             # THE rules — plain, tool-agnostic markdown (single source of truth)
stubs/
  cursor/*.mdc     # activation stubs for Cursor  (copied into a project's .cursor/rules/)
  claude/*.md      # activation stubs for Claude Code (copied into .claude/rules/)
templates/
  AGENTS.md        # root index for consuming projects (also read natively by Cursor)
  CLAUDE.md        # one-line @AGENTS.md import shim for Claude Code
install.sh         # copies stubs + templates into a consuming project
```

Rule content lives **only** in `rules/`. Stubs carry activation metadata (Cursor `globs`, Claude `paths`) and a pointer/import — never content. Both tools therefore read the same words and cannot drift.

## Rules

| File | Scope |
|------|-------|
| `rules/universal.md` | Every file, every language |
| `rules/javascript.md` | JS (and TS, together with the TypeScript rules) |
| `rules/typescript.md` | TS, on top of the JavaScript rules |
| `rules/python.md` | Python |
| `rules/react.md` | React UI code only |
| `rules/testing-js.md` | JS/TS tests |
| `rules/testing-python.md` | Python tests |

## Using in a project

```bash
cd your-project
git submodule add <repo-url> coding-rules
./coding-rules/install.sh
```

The install script copies the stubs into `.cursor/rules/` and `.claude/rules/` under a `coding-rules-` filename prefix, and creates root `AGENTS.md` / `CLAUDE.md` from the templates if the project doesn't have them. It never overwrites the project's own files: the prefix prevents name collisions with existing rules, re-runs replace exactly the prefixed set, and existing `AGENTS.md` / `CLAUDE.md` are left untouched. Commit all of it — the stubs are tiny and stable, and the submodule pins the exact rules version the project uses.

Cloning a project that uses this repo:

```bash
git clone --recurse-submodules <project-url>
# or, after a plain clone:
git submodule update --init
```

## Updating the rules in a project

```bash
git submodule update --remote coding-rules
./coding-rules/install.sh   # only needed if the stub set changed
git add coding-rules && git commit -m "Update coding rules"
```

## Changing or adding rules

1. Edit or add the canonical file in `rules/` — tool-agnostic markdown, no frontmatter, no Cursor/Claude syntax.
2. For a new rule: add a matching stub in `stubs/cursor/` (`description` + `globs` frontmatter, pointer body) and `stubs/claude/` (`paths` frontmatter + `@../../coding-rules/rules/<name>.md` import), and add a row to `templates/AGENTS.md`.
3. Commit and push; consuming projects pick it up with `git submodule update --remote`.

Never put rule content in a stub.

## Assumptions

- The repo is mounted at `coding-rules/` in the consuming project's root; stub references are written against that path.
- Claude Code loads `CLAUDE.md` → `@AGENTS.md` at launch and the `.claude/rules/` stubs when files matching their `paths` are touched; each stub `@`-imports its canonical file.
- Cursor reads `AGENTS.md` natively and activates `.cursor/rules/*.mdc` by `globs` (the `universal` stub is `alwaysApply`).
