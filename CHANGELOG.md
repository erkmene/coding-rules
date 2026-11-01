# Changelog

Each release is a git tag `vX.Y.Z`. Every entry starts with an **Action** that tells an updating agent what the update needs:

- **none**: no wiring changes or manual steps. Updating the files is enough.
- **re-wire**: the scope table in `INSTALL.md` changed. The Update procedure handles it.
- **manual**: a step the agent must take or ask about, described in the entry.

Version numbers: the major version goes up when an Action is manual; the minor version for a re-wire action or any new or changed requirement; the patch version only for wording that doesn't change behavior.

## 1.2.0 (2026-11-01)

**Action: none.** Clarifications from the first update to 1.1.0.

### Changed

- `INSTALL.md`: `installedAt` is the date of the last install or update.
- `INSTALL.md`: in Claude Code, the verify step checks the always rules with `claude -p "/context"`.
- `INSTALL.md`: Update step 7 leaves wiring that already matches the target table as it is, even when the manifest's version predates it, and adds it to the manifest if it isn't listed.
- `INSTALL.md`: when an update changes rule files, the report notes that changed rules may make existing code non-compliant, as follow-ups rather than part of the update.
- `CHANGELOG.md`: the 1.1.0 entry for duplicates now also mentions the comment on the original, as `rules/universal.md` says.
- `CHANGELOG.md`: the **none** Action means no wiring changes or manual steps, not only rule text changes.

## 1.1.0 (2026-11-01)

**Action: re-wire.** The scope table gained `rules/svelte.md`, and the JavaScript and TypeScript rules now also match `**/*.svelte`. Claude Code installs that used fallback lines for the always rules link them from the tool's rules folder instead, and those fallback lines leave the managed block, except where `INSTALL.md` still calls for them (personal mode with Cowork, or checkouts without symlink support).

### Added

- `rules/svelte.md`: Svelte 5 runes, `$derived` over `$effect`, mutating `$state`, snippets versus components.

### Changed

- `rules/javascript.md`: the no-mutation rule covers inputs and shared data; state owned by a framework's reactivity system follows that framework's idiom.
- `rules/universal.md`: the size caps are a signal; split only along a seam where each part stands alone.
- `rules/universal.md`: a duplicate whose extraction falls outside the task stays, with a comment naming the original, and the extraction is reported as a follow-up. The original gets a matching comment when it is in the same repository and that comment is the only change there.
- `rules/typescript.md`: strictness options apply to code the project owns; code under another config is matched or isolated, and the gap noted.
- `INSTALL.md`: an always rule can be wired as a symlink to the rule file (with Claude Code's details); the manifest records a symlink's target path instead of a hash; uninstall removes links, not targets.
- `INSTALL.md`: never create a `CLAUDE.md`, `.claude/CLAUDE.md` or `CLAUDE.local.md` anywhere in a project that has an `AGENTS.md`, since by default Claude Code then stops reading `AGENTS.md`.
- `INSTALL.md`: the install and update reports tell the user to start a new session.
- `checklists/review.md`: an area with no test setup is reported in the handoff; adding a test framework is the owner's decision.
- `rules/universal.md`: new code avoids deprecated APIs and options unless the replacement needs out-of-scope work, which the handoff notes.
- `docs/tooling.md`: a minimum release age for new dependency versions.

## 1.0.0 (2026-10-30)

**Action: none.** This is the first release; install it by following `INSTALL.md`.

### Added

- Rules in `rules/`: universal, architecture, security, git, API design, data, i18n (opt-in), JavaScript, TypeScript, Python, new Python projects, React, and testing (general, JS/TS, Python).
- `checklists/review.md`: the definition of done, checked before work is handed off.
- `INSTALL.md`: the scope table, plus the install, update and uninstall procedures for personal and project mode.
- `docs/tooling.md`: the tools and settings that enforce the rules left out because a tool can check them.
