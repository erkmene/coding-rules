# Changelog

Each release is a git tag `vX.Y.Z`. Every entry starts with an **Action** that tells an updating agent what the update needs:

- **none**: rule text only. Updating the files is enough.
- **re-wire**: the scope table in `INSTALL.md` changed. The Update procedure handles it.
- **manual**: a step the agent must take or ask about, described in the entry.

Version numbers: the major version goes up when an Action is manual, the minor version for re-wire actions or new rules, and the patch version for wording only.

## Unreleased

**Action: manual.** Projects set up with the old `install.sh` and submodule layout must follow "Migrating from the submodule layout" in `INSTALL.md`, then install.

### Changed

- The rules are installed by the user's coding agent following `INSTALL.md`, in personal mode (one clone wired at user level) or project mode (a copy committed in the project). The git submodule, `install.sh`, the Cursor and Claude stubs and the templates are gone.
- Git, API design and data rules no longer load in every session. They load for matching activities or files.
- The project's established conventions now explicitly win over the rules. Rule violations are fixed only within lines already being changed.
- Duplication: extract on the third occurrence, or at the second when the copies must change together. The old "told exactly once" wording is gone.
- Backward-compatibility shims are banned only within code that is built and deployed together.
- Errors are handled or propagated with context and logged once, not at every layer.
- Command/query separation, test-file layout, TLS, least privilege, pagination, `created_at`/`updated_at`, Server Actions and the `<h1>` rule are scoped to where they hold.
- `403` is "authenticated but not permitted", with `404` when existence is secret. Error identifiers build on the RFC 9457 `type` field.
- React: fix `exhaustive-deps` without reflexive memoization; with React Compiler, add no manual memoization.

### Added

- `INSTALL.md`: the scope table, plus the install, update, uninstall and migration procedures.
- `rules/testing.md`: testing rules shared by all languages.
- `rules/i18n.md` (opt-in) and `rules/new-project-python.md` (on demand), split out of `universal.md` and `python.md`.
- `checklists/review.md`: the definition of done and the review-time AI checks.
- `docs/tooling.md`: tools and settings that enforce the rules removed as checkable.

### Removed

- Rules that current Claude and GPT models already follow, and rules a tool can enforce. The README's "Deliberately omitted" section lists them.
