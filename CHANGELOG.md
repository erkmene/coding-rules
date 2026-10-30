# Changelog

Each release is a git tag `vX.Y.Z`. Every entry starts with an **Action** that tells an updating agent what the update needs:

- **none**: rule text only. Updating the files is enough.
- **re-wire**: the scope table in `INSTALL.md` changed. The Update procedure handles it.
- **manual**: a step the agent must take or ask about, described in the entry.

Version numbers: the major version goes up when an Action is manual; the minor version for a re-wire action or any new or changed requirement; the patch version only for wording that doesn't change behavior.

## 1.0.0 (2026-10-30)

**Action: none.** This is the first release; install it by following `INSTALL.md`.

### Added

- Rules in `rules/`: universal, architecture, security, git, API design, data, i18n (opt-in), JavaScript, TypeScript, Python, new Python projects, React, and testing (general, JS/TS, Python).
- `checklists/review.md`: the definition of done, checked before work is handed off.
- `INSTALL.md`: the scope table, plus the install, update and uninstall procedures for personal and project mode.
- `docs/tooling.md`: the tools and settings that enforce the rules left out because a tool can check them.
