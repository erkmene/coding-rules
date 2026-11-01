# Changelog

Each release is a git tag `vX.Y.Z`. Every entry starts with an **Action** that tells an updating agent what the update needs:

- **none**: no wiring changes or manual steps. Updating the files is enough.
- **re-wire**: the scope table in `INSTALL.md` changed. The Update procedure handles it.
- **manual**: a step the agent must take or ask about, described in the entry.

Version numbers: the major version goes up when an Action is manual; the minor version for a re-wire action or any new or changed requirement; the patch version only for wording that doesn't change behavior.

## 2.0.0 (2026-11-01)

**Action: manual.** The installed `INSTALL.md` predates this release's Update steps. In Update step 6:
1. In project mode, copy `docs/` into the rules folder as well, since the installed Install step 2 doesn't list it.
2. Read the target version's `INSTALL.md` and continue with its Update section from step 7. It re-wires (the scope table gained `rules/tooling.md`, and `rules/new-project-python.md` no longer covers tooling), fills in the new manifest fields in step 8, and runs Check in step 9. When filling in `declined`, record `"i18n": "declined before 2.0.0; at the 2.0.0 update: <the files matching its globs, or none>"` if i18n isn't in `optIn`, and in personal mode, when the update runs in a project, the same value as `i18n:<project root>`. Between Check and the report, when working in a project, offer Set up tooling; the user may decline.

### Added

- `rules/tooling.md`: propose missing linters, formatters, type checkers and test runners for the owner to accept, run them through project scripts, and wire agent hooks that run them. A formatter adopted in existing code reformats in a commit of its own, listed in `.git-blame-ignore-revs`; repositories with several packages keep tools per package; plugins beyond the chosen tools are proposed separately.
- `INSTALL.md`: a Set up tooling section. It proposes tools, wires an after-edit hook that formats and lints the edited file and hands remaining errors back to the agent, an optional finish hook for types and tests, and a git pre-commit hook. Install offers it; it can also be run alone.
- `INSTALL.md`: a Check section, run by every Update and on request, that catches install decisions later changes made wrong: a `CLAUDE.md` shadowing `AGENTS.md`, unwired agent tools, a declined i18n the project now needs, links in checkouts without symlink support, Cowork, and stale hooks. A table lists every install decision and what catches it.
- `INSTALL.md`: manifest fields `declined`, `tools`, `alwaysWiring`, `cowork` and `hooks`. `declined` records the questions the user said no to, so Check asks again only when something new turns up, and a later yes clears the key. Check keeps asking about Cowork until the user says yes or asks it to stop, since nothing in a project shows it. Install asks about Cowork instead of assuming.
- `docs/tooling.md`: a Choosing tools section with the default tools per stack, including notes on typescript-eslint's strict presets in Svelte. Coverage thresholds wait until the suite covers the main modules.

### Changed

- `INSTALL.md`: hard rule 3 allows creating a settings file, hook entries in settings files and lines in the repository's exclude file (found with `git rev-parse --git-path`, so worktrees and submodules work), all tracked in the manifest, and the project files the user agreed to during Set up tooling, which belong to the project. Hard rule 5 covers edited hook entries. In project mode, the ignore check covers hook scripts and settings files.
- `INSTALL.md`: project mode copies `docs/` too, since `rules/tooling.md` refers to it.
- `INSTALL.md`: Update follows the target version's procedure from step 6 on, fills in manifest fields the installed version lacked, and runs Check. Uninstall removes hook entries before deleting files, deletes a settings file it created only once every entry in it is handled and nothing else is left, and leaves the project's tools. Tooling fallback lines are recorded in `hooks`, so rewriting the managed block keeps them, and in personal mode they name their project.
- `INSTALL.md`: Update runs Check even when the install is already up to date.
- `INSTALL.md`: Set up tooling shows a formatter's reformat size before the user accepts it, routes the after-edit hook to each package's scripts in a repository with several packages, verifies each agent hook against what it runs (format and lint after edits, types and tests at the finish), and verifies the git pre-commit hook by running it through its manager on a staged lint error in each package, never by committing. Hook entries record their `event`. An install can track a branch other than `main`, to try changes before their release; when that branch is gone or released, Update offers to switch to the release. Check also looks for a shadowing `CLAUDE.md` from the working directory up, and only reports one outside the project root or in personal mode. It offers fallback lines again when symlink support changes. Uninstall never deletes an instructions file recorded with `null`, and removes exclude lines only after deciding which files stay.
- `INSTALL.md`: when a `CLAUDE.md` shadows the block, Check offers to add the block to it, recorded so Uninstall removes only the block, instead of an import that Uninstall couldn't track. Uninstall keeps exclude lines for the files it keeps.
- `rules/new-project-python.md`: tooling moved to `rules/tooling.md`; the Ruff starting selection moved to `docs/tooling.md`.

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
