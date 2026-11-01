# Changelog

Each release is a git tag `vX.Y.Z`. Every entry starts with an **Action** that tells an updating agent what the update needs:

- **none**: rule text only. Updating the files is enough.
- **re-wire**: the scope table in `INSTALL.md` changed. The Update procedure handles it.
- **manual**: a step the agent must take or ask about, described in the entry.

Version numbers: the major version goes up when an Action is manual; the minor version for a re-wire action or any new or changed requirement; the patch version only for wording that doesn't change behavior.

## Unreleased

**Action: re-wire.** The scope table gained `rules/svelte.md`, and the JavaScript and TypeScript rules now also match `**/*.svelte`.

### Added

- `rules/svelte.md`: Svelte 5 runes, `$derived` over `$effect`, mutating `$state`, snippets versus components.

### Changed

- `rules/javascript.md`: the no-mutation rule covers inputs and shared data; state owned by a framework's reactivity system follows that framework's idiom.
- `rules/universal.md`: the size caps are a signal; split only along a seam where each part stands alone.
- `rules/universal.md`: a duplicate whose extraction falls outside the task stays, cross-referenced, and the extraction is reported as a follow-up.
- `rules/typescript.md`: strictness options apply to code the project owns; code under another config is matched or isolated, and the gap noted.

## 1.0.0 (2026-10-30)

**Action: none.** This is the first release; install it by following `INSTALL.md`.

### Added

- Rules in `rules/`: universal, architecture, security, git, API design, data, i18n (opt-in), JavaScript, TypeScript, Python, new Python projects, React, and testing (general, JS/TS, Python).
- `checklists/review.md`: the definition of done, checked before work is handed off.
- `INSTALL.md`: the scope table, plus the install, update and uninstall procedures for personal and project mode.
- `docs/tooling.md`: the tools and settings that enforce the rules left out because a tool can check them.
