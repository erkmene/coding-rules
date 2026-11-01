# Installing coding-rules

These instructions are for a coding agent. A person starts an install, update or removal by asking their agent, for example:

> Install the coding rules from https://github.com/erkmene/coding-rules. Follow its INSTALL.md.

Read this whole file before acting, then follow the section that matches the request: [Install](#install), [Set up tooling](#set-up-tooling), [Update](#update), [Check](#check), or [Uninstall](#uninstall).

## Terms

- **Source**: this repository, at one release tag (`vX.Y.Z`) or at a commit on `main`.
- **Rules folder**: the folder your tools read the rules from. In personal mode it is the user's clone of the source. In project mode it is `coding-rules/` in the project root, holding a copy of `rules/`, `checklists/`, `docs/`, `INSTALL.md` and `CHANGELOG.md`.
- **Wiring**: the files you create in a tool's own configuration so that each rule loads at the right time.
- **Instructions file**: the plain-text instructions file your tool reads at the start of every session, such as `AGENTS.md` or your tool's own equivalent. In personal mode, use the user-level instructions file. In project mode, use the file in the project root. By default, a `CLAUDE.md`, `.claude/CLAUDE.md` or `CLAUDE.local.md` in the working directory or above it stops Claude Code from reading any `AGENTS.md` file, and one in a subdirectory stops that subdirectory's `AGENTS.md`. So never create a `CLAUDE.md`, `.claude/CLAUDE.md` or `CLAUDE.local.md` anywhere in a project that has an `AGENTS.md`; write the block into the instructions file the project already uses, or create a root `AGENTS.md`.
- **Settings file**: the file where a tool declares its hooks, such as `.claude/settings.json`. It holds the user's own settings too; only the hook entries you add are yours.
- **Manifest**: `manifest.json` in the rules folder. It records what was installed.

## Hard rules

1. A wiring file contains activation metadata and a reference to its rule file, nothing else; a symlink to the rule file counts as a reference. Never copy, summarise or paraphrase rule text into a wiring file or an instructions file. Copies drift from the source, and preventing that drift is the point of this repository.
2. Name every wiring file `coding-rules-<rule>`, using the extension your tool expects, e.g. `coding-rules-git.md`. When your tool needs one folder per item, name the folder that way.
3. Create, change or delete only:
   - the rules folder;
   - `coding-rules-*` files and folders that the manifest lists or that you are creating now;
   - the text between `<!-- coding-rules:begin -->` and `<!-- coding-rules:end -->` in an instructions file;
   - an instructions file or settings file that does not exist yet, and the parent directories that wiring or hook scripts need. Record them in the manifest;
   - hook entries you add to a settings file, and lines you add to `.git/info/exclude`, all recorded in the manifest's `hooks`;
   - during [Set up tooling](#set-up-tooling), the project files the user agreed to add or change. They belong to the project from then on: don't list them in the manifest, and Uninstall leaves them.
   
   If anything else is in the way, stop and ask the user.
4. Use only mechanisms your tool documents. If you are not sure your tool supports a mechanism, check its documentation. If you still cannot confirm it, use the fallback for that class. Never guess at a configuration format.
5. Before you replace or delete a file whose hash (for a symlink, whose target) differs from the one in the manifest, the user has edited it. Show them the difference and ask what to do. The same goes for a hook entry that no longer matches the manifest.

## The rules and when they load

This table is the only place where rule scope is defined.

| Rule file | Class | Load when |
|---|---|---|
| `rules/universal.md` | always | every session |
| `rules/architecture.md` | always | every session |
| `rules/security.md` | always | every session |
| `rules/git.md` | activity | committing, writing commit messages, creating branches, opening or updating pull requests |
| `rules/api-design.md` | activity + paths | designing or changing HTTP endpoints, error responses, pagination or an OpenAPI contract; files matching `**/{routes,controllers,handlers}/**`, `**/openapi*.{yaml,yml,json}`, `**/*.{controller,route,router}.{ts,js}` |
| `rules/data.md` | activity + paths | designing a schema, writing a migration, writing queries; files matching `**/migrations/**`, `**/alembic/**`, `**/*.sql`, `**/schema.prisma`, `**/drizzle/**`, `**/{repositories,db}/**` |
| `rules/i18n.md` | opt-in, activity + paths | only if the user opts in; then when writing or changing user-facing text or translations, and for files matching `**/{locales,i18n,messages}/**` |
| `rules/javascript.md` | paths | `**/*.{js,jsx,mjs,cjs,ts,tsx,mts,cts}`, `**/*.svelte` |
| `rules/typescript.md` | paths | `**/*.{ts,tsx,mts,cts}`, `**/*.svelte` |
| `rules/python.md` | paths | `**/*.py` |
| `rules/new-project-python.md` | activity | creating a Python project, or changing its packaging or dependency setup |
| `rules/tooling.md` | activity | adding or changing a linter, formatter, type checker or test runner, including when creating a project |
| `rules/react.md` | paths | `**/*.{jsx,tsx}`, `**/use[A-Z]*.{ts,js}`, `**/hooks/**/*.{ts,js}` |
| `rules/svelte.md` | paths | `**/*.svelte`, `**/*.svelte.{ts,js}` |
| `rules/testing.md` | activity + paths | writing or changing tests in any language; files matching any of `**/*.{test,spec}.{js,jsx,mjs,cjs,ts,tsx,mts,cts}`, `**/__tests__/**`, `**/test_*.py`, `**/*_test.py`, `**/{test,tests}/**/*.py`, `**/conftest.py`, `**/tests.py` |
| `rules/testing-js.md` | paths | `**/*.{test,spec}.{js,jsx,mjs,cjs,ts,tsx,mts,cts}`, `**/__tests__/**` |
| `rules/testing-python.md` | paths | `**/test_*.py`, `**/*_test.py`, `**/{test,tests}/**/*.py`, `**/conftest.py`, `**/tests.py` |
| `checklists/review.md` | review | before handing work off |

Keep the `testing.md` globs equal to the union of the `testing-js.md` and `testing-python.md` globs.

How to wire each class:

- **always**: use your tool's always-on mechanism. If that mechanism can include a file by reference, reference the rule file; otherwise, add a fallback line to the managed block: "Read `<path>` at the start of every task." A symlink to the rule file is a reference, not a copy, where your tool documents following symlinks. In Claude Code, a rule without `paths` in a rules folder loads at the start of every session:
  - project mode: link `.claude/rules/coding-rules-<rule>.md` to the rule file with a relative path, so the target stays inside the working directory. A link whose target is outside the session's working directory loads only after the user approves external imports.
  - personal mode: link `~/.claude/rules/coding-rules-<rule>.md` to the rule file in the clone. User-level links load without approval, except in Cowork sessions on the desktop, which skip a symlinked user rule that points outside the working directory. If the user works in Cowork, also add the fallback line.

  Where links don't survive a checkout (Git on Windows with `core.symlinks=false` writes them as plain files), use the fallback line.
- **paths**: use your tool's path-scoped rules with the globs above, referencing the rule file. If your tool cannot scope by path, add a fallback line: "When working on files matching `<globs>`, read `<path>`."
- **activity**: use your tool's on-demand mechanism (for example a skill, or a rule the agent pulls in by its description). Use the "Load when" text as the description and reference the rule file. If there is none, add a fallback line: "When `<activity>`, read `<path>`."
- **activity + paths**: wire the activity and the paths as two separate pieces of wiring: the on-demand mechanism without any path restriction, plus a path-scoped rule. Do not combine them into one item when your tool's path field restricts it to matching files only (in Claude Code, a skill with `paths` loads only for matching files and is no longer offered for the activity). Name the two pieces so they don't collide, e.g. `coding-rules-data` for the on-demand item and `coding-rules-data-paths` for the path-scoped rule.
- **opt-in**: wire this rule only if the user said yes during install, then wire it by its other classes.
- **review**: if your tool supports subagents, create one named `coding-rules-reviewer` with these instructions: read `<path to checklists/review.md>`, then review the current diff against the checklist and every rule that applies to the change: the **always** rules, rules whose globs match a changed file, and rules whose activity the change involves (opt-in rules only if installed). Report findings without editing. In every case, add a review line to the managed block (see below).

Write references as paths your tool resolves:
- project mode: paths relative to the project root, e.g. `coding-rules/rules/git.md`;
- personal mode: absolute paths into the clone.

## The managed block

Put this block in each instructions file you wire. Keep only the line for the current mode, without its `<project mode:>` or `<personal mode:>` label. Fill in the remaining angle-bracket parts, and keep everything else exactly as written:

```markdown
<!-- coding-rules:begin -->
## Coding rules

<project mode:> This project follows the coding rules in `<rules folder>` (`<version>`, project install). The project's own established conventions win over these rules.
<personal mode:> Follow the coding rules in `<rules folder>` (`<version>`, personal install) in every project. Each project's own established conventions win over these rules.

<one fallback line per rule that some tool reading this file could not wire natively, or nothing>

Before handing work off, run the `coding-rules-reviewer` subagent if your tool has it; otherwise go through `<path to checklists/review.md>`.
<!-- coding-rules:end -->
```

Several tools may read the same instructions file (for example `AGENTS.md`). Include a fallback line if any tool reading the file needs it, and start each fallback line with "Unless your tool already loads it:", so a tool that wired the rule natively doesn't load it twice.

If the instructions file does not exist, create it with only the block. If it already has a block, replace the block and leave the rest of the file alone.

## The manifest

`manifest.json` in the rules folder, with these fields. Write every path in it as an absolute path in personal mode, and relative to the project root in project mode.

- `source`: the repository URL.
- `version`: the release tag, or `main`.
- `commit`: the full commit hash that was installed.
- `installedAt`: the date of the last install or update, as `YYYY-MM-DD`.
- `mode`: `personal` or `project`.
- `optIn`: the opt-in rules that were installed, e.g. `["i18n"]`.
- `declined`: what the user said no to, so Check doesn't ask again: an object with one key per question, and as its value what you knew when they said no. Keys:
  - an opt-in rule (`i18n`), and in personal mode `i18n:<project root>` for a no given in one project;
  - `tool:<name>` for a tool they chose not to wire;
  - `cowork`, `fallback-lines` and `shadow:<path>` for the offers they turned down;
  - `hooks:<project root>` for agent hooks they turned down in that project.

  For example `{"i18n": "no locale files", "tool:Cursor": ".cursor/ found"}`.
- `tools`: the agent tools you wired, by the names the user would recognise, e.g. `["Claude Code", "Cursor"]`.
- `alwaysWiring`: an object mapping each tool in `tools` to how its **always** rules are wired: `link` (a symlink to the rule file), `reference` (the tool includes the file by reference) or `fallback` (a line in the managed block).
- `cowork`: in personal mode, whether the user said they work in Cowork; `null` in project mode.
- `hooks`: an array with one object per hook entry you added (empty if none), each with:
  - `project`: the project root;
  - `tool`: the tool, as named in `tools`;
  - `settingsFile`: the settings file the entry is in;
  - `entry`: the entry exactly as you wrote it;
  - `exclude`: the lines you added to `.git/info/exclude` for it (empty if none);
  - `createdSettingsFile`: `true` if you created the settings file for this entry.

  Hook scripts go in `files` with their hashes.
- `directories`: every directory you created, deepest first, e.g. `[".claude/skills/coding-rules-git", ".claude/skills"]` in project mode. Do not list a directory that already existed.
- `files`: an object mapping the path of every file you created or manage to its SHA-256 hash. Include:
  - wiring files. For a symlink, record its target exactly as `readlink` prints it, instead of a hash; unlike the keys, a relative target is relative to the link's folder;
  - instructions files you created (record `null` for an instructions file that already existed, since only its block is yours);
  - hook scripts;
  - in project mode, each copied file: rules, checklists, docs, `INSTALL.md` and `CHANGELOG.md`.

## Install

1. **Ask the user**, in one message:
   - **Mode.** Personal: one clone serves all their projects on this machine, it is wired into their tools' user-level configuration, and updating it updates every project at once. Project: a copy is committed into this project, so it works for everyone who clones the project and in cloud or CI sessions, and each project is updated on its own. Recommend personal for someone working alone on one machine, and project for shared repositories or cloud sessions.
   - **Tools.** Which agent tools to wire. List the ones you detected from configuration folders in the project and in the user's home directory, plus yourself.
   - **i18n.** Whether the project translates, or will translate, its user-facing text.
   - **Version.** The latest release tag (the default) or `main`. If the source has no release tags yet, say so and offer `main`.
   - **Location** (personal mode only). Where the clone goes (default `~/coding-rules`), or where their existing clone is.
   - **Cowork** (personal mode only, when Claude Code is among the tools). Whether they work in Cowork sessions on the desktop.
   - **Tooling** (only when you are working in a project). Whether to look at the project's linter, formatter, type checker and tests, propose what is missing, and wire agent hooks that run them after each edit. See [Set up tooling](#set-up-tooling).
2. **Get the source.**
   - Personal: clone the source into the chosen folder, or use the existing clone, and check out the chosen version. Add nothing to the clone except `manifest.json`, which the repository ignores.
   - Project: fetch the chosen version into a temporary folder outside the project. Copy `rules/`, `checklists/`, `docs/`, `INSTALL.md` and `CHANGELOG.md` into `<project root>/coding-rules/`. If `coding-rules/` already exists without a manifest, stop and ask the user.
3. **Wire every rule** in the table for each chosen tool: at user level in personal mode, at project level in project mode.
4. **Write the managed block** into each instructions file.
5. **Write the manifest.** Record in `declined` each detected tool the user didn't choose, a no to i18n (with the files matching its globs at the time, or none), and a no to Cowork.
6. **Verify:**
   - every wiring file contains only metadata and a reference (a symlink to the rule file counts as a reference);
   - every reference points to a file that exists;
   - where your tool can list the rules or instructions it has loaded, the **always** rules appear. In Claude Code, run `claude -p "/context"` in the project directory, which starts a fresh session, and look for them among the memory files it lists;
   - in project mode, `git check-ignore` reports none of the rules folder, the wiring files, the instructions file, the hook scripts or the settings files in `hooks` as ignored.
7. **Set up tooling** if the user agreed, following [Set up tooling](#set-up-tooling).
8. **Report:**
   - the mode and the version;
   - the files you created, replaced or skipped;
   - which rules use a fallback line;
   - the tools added and hooks wired, or that the user declined;
   - that the user should start a new session before relying on the rules: always rules load only when a session starts, and some tools, Claude Code among them, don't see agent or skill folders created during a session;
   - anything that needs the user's attention.
   
   In project mode, remind the user to commit the changes.

## Set up tooling

Run this during Install when the user agreed, when a changelog Action asks for it, when `rules/tooling.md` sends you here, or when the user asks ("Set up the coding-rules tooling for this project"). It works on one project, in either mode, and `rules/tooling.md` applies throughout.

1. **Look at what the project has:** its linter, formatter, type checker, test runner and git hooks, and the scripts that run them.
2. **Propose**, in one message:
   - each missing kind of tool, with one recommendation from "Choosing tools" in `docs/tooling.md` and the reason it fits;
   - the agent hooks below, naming the settings file each one goes in;
   - a git pre-commit hook, if the project has none.

   Skip the agent hooks when `declined` has `hooks:<project root>`, unless the user asked for this setup. Add only what the user accepts. If they turn down the agent hooks, record `hooks:<project root>`.
3. **Add the tools** the user accepted: dev dependencies, configuration, and the project scripts `rules/tooling.md` asks for. Run each script once to see that it works.
4. **Wire the agent hooks** for each tool in the manifest's `tools` that documents hooks (hard rule 4):
   - **After each file edit:** run the project's format script, then its lint script with auto-fix, on the edited file only, and skip files those tools don't handle. When lint errors remain, hand them back to the agent as a failure, so it fixes them before going on.
   - **When the agent finishes** (optional; ask): run the type checker and the affected tests, and hand failures back the same way. Make sure the hook cannot loop forever when a failure can't be fixed.

   Put each hook's logic in a script named by hard rule 2, such as `.claude/hooks/coding-rules-post-edit.sh`, and keep the entry in the settings file to a single call of that script. The settings file:
   - project mode: the tool's project settings file that is committed, so the hooks run for everyone;
   - personal mode: the tool's project settings file that is not committed (in Claude Code, `.claude/settings.local.json`). Add each script, and the settings file if Git doesn't already ignore it, to `.git/info/exclude`. Never use user-level settings: the commands differ per project.

   In Claude Code, the after-edit hook is a `PostToolUse` hook matching the file-editing tools, the finish hook is a `Stop` hook, the hook reads the edited file's path from the JSON on its standard input, and exit code 2 hands its standard error back to Claude. Check the hooks documentation for the current tool names and input fields.

   For a tool without documented hooks, add a fallback line to the managed block: "Unless your tool already runs it: after editing a file, run `<command>` on it and fix what it reports."
5. **Add the git pre-commit hook** if the user accepted it, using the project's hook manager. Like the tools, it belongs to the project.
6. **Verify:** run each hook script with the input its tool would send, on a temporary file that breaks a format rule and a lint rule. Check that it fixes the formatting and hands back the lint error, then delete the file. If the tool loads hooks only when a session starts, tell the user that the hooks run from their next session.
7. **Record** each hook entry in the manifest's `hooks`, each script in `files`, and each directory you created in `directories`. Then verify the ignore rules as in Install step 6.
8. **Report** the tools you added, the scripts and hooks you wired, any fallback lines, and the files the user should commit.

## Update

1. Read the manifest. If there is none, do an Install instead.
2. Fetch the source, without changing any installed file yet:
   - Personal: run `git fetch --tags` in the clone. If the clone has local changes, stop and ask.
   - Project: clone the source into a temporary folder outside the project, with enough history to include the manifest's `commit` (a full clone is simplest).
   
   This checkout is the source repository for steps 3 to 5. Run every git command in those steps there, never in the project.
3. Pick the target version: the latest release tag, unless the user names one. If the install tracks `main`, the target is the newest commit on the fetched remote branch (`origin/main`), not a local `main` branch, which a fetch does not move. Compare the manifest's `commit` with the target's commit; if they are the same, say so and stop.
4. Read the changelog entries the update brings in, and note each entry's **Action**. For a release target, read every entry newer than the installed version. When either version is `main`, read every line added to `CHANGELOG.md` between the installed commit and the target (`git diff <installed commit> <target commit> -- CHANGELOG.md`).
5. Get the target version.
   - Personal: check out the target commit in the clone.
   - Project: check out the target in the temporary clone, then copy fresh files from it as in Install step 2. First compare the current files with the manifest hashes, and ask before overwriting any file the user changed.
   
   Then read the target version's `INSTALL.md`, and follow its Update section from step 6 on, so the update uses the procedure it installs.
6. Carry out every **manual** action. Ask when an action needs a decision.
7. Reconcile the wiring with the table in the target version's `INSTALL.md`. Wiring that already matches the table stays as it is, even when the manifest's version predates it; if the manifest doesn't list it, add it in step 8:
   - create wiring that is missing, including wiring for a rule that used a fallback line and that your tool can now wire natively;
   - replace wiring that changed (hard rule 5 applies);
   - delete manifest-listed wiring that the target table no longer calls for, whether its rule was removed or its class changed;
   - in project mode, delete manifest-listed copied files that the target version no longer ships, such as a removed or renamed rule (hard rule 5 applies);
   - delete any directory in `directories` that this leaves empty.
8. Rewrite the managed block and the manifest, then verify as in Install step 6. If the manifest lacks a field that the [manifest](#the-manifest) section defines, fill it in from the existing wiring, and ask the user what the wiring can't tell you.
9. Run [Check](#check).
10. Report:
   - the old and new versions;
   - a short summary of the changelog entries that change how the agent should work;
   - the files you changed;
   - what Check found and what you changed because of it;
   - when the update changes rule files, that changed rules may make existing code non-compliant. The rules apply to code as it is touched, so name any spot you noticed as a possible follow-up, and don't change it as part of the update;
   - that the user should start a new session, as in Install step 8, so the updated rules and wiring load.
   
   In project mode, remind the user to commit the changes.

## Check

Install makes decisions from the project and the user's setup as they are that day, and later changes can make them wrong. Check finds those cases. Update runs it every time, and the user can run it alone ("Check the coding rules"). Ask before changing anything, and don't ask again about anything in `declined` unless what you knew then has changed.

1. **Verify** as in Install step 6.
2. **Shadowed instructions files.** For each `AGENTS.md` that holds the managed block, look for a `CLAUDE.md`, `.claude/CLAUDE.md` or `CLAUDE.local.md` in that folder or above it (see [Terms](#terms)). When one stops Claude Code from reading the block and the user uses Claude Code, show the user and offer a fix: an `@AGENTS.md` import in that `CLAUDE.md`, or the managed block in it as well. The file is theirs, so change it only with their agreement. If they decline, record `shadow:<path>`.
3. **New tools.** Detect agent tools as in Install step 1. For each one in neither `tools` nor `declined`, ask whether to wire it, and if so, wire it as in Install steps 3 to 5.
4. **Declined opt-ins.** For each opt-in rule in `declined`, look for signs the project needs it, and ask again only if they weren't there when the user said no. For i18n, the signs are files matching its globs.
   - Project mode: compare with the `declined` value, and update it with what you found.
   - Personal mode: look only in the project you are working in, if any. Ask when it has such files and `declined` has no `i18n:<project root>`, and say that a yes wires the rule for every project. If the user says no, record `i18n:<project root>`.
5. **Always wiring.**
   - Project mode, for each tool whose `alwaysWiring` is `link`: links arrive as plain files in checkouts without symlink support (Git on Windows with `core.symlinks=false`). If the managed block lacks fallback lines for the **always** rules and `declined` has no `fallback-lines`, tell the user and offer to add them.
   - Personal mode, when `cowork` is `false`, Claude Code is in `tools` and `declined` has no `cowork`: ask whether the user works in Cowork now, and if so, add the fallback lines.
6. **Hooks.** For each entry in `hooks`: it is still in its settings file and still matches the manifest (hard rule 5); its script exists and matches its hash; and the project scripts it calls still exist and still run the project's current tools. Offer to fix what doesn't hold, following [Set up tooling](#set-up-tooling).
7. **Record** what changed in the manifest, including each offer the user turned down in `declined`, and **report** what you found and what you changed.

Every install decision, and what can make it wrong later:

| Decision | Can become wrong when | Caught by |
|---|---|---|
| Version | a new release comes out | Update |
| Mode, location | the user moves the clone, which breaks every reference | Check step 1 |
| Instructions file | someone adds a `CLAUDE.md` next to an `AGENTS.md` | Check step 2 |
| Tools | the user starts using another agent tool | Check step 3 |
| i18n | the project starts translating | Check step 4 |
| Links or fallback lines | someone checks the project out without symlink support | Check step 5 |
| Cowork | the user starts working in Cowork | Check step 5 |
| Ignore rules | someone ignores the rules folder, wiring, instructions file, hook scripts or settings file | Check step 1 |
| Hooks | the project changes its tools or scripts, or someone edits the settings file | Check step 6 |

## Uninstall

1. Remove each entry in `hooks` from its settings file, and its `exclude` lines from `.git/info/exclude` (hard rule 5 applies). If you created the settings file and nothing else is left in it, delete it. If the user keeps an edited entry, keep the script it calls as well. Leave the project's tools, scripts and git hooks: they belong to the project. In personal mode, the entries can be in several projects.
2. Delete every file the manifest lists, except instructions files that existed before the install and scripts kept in step 1 (hard rule 5 applies). For a symlink, delete the link, never its target. Then delete each directory in `directories` that is now empty, in the order listed.
3. Remove the managed block from each instructions file.
4. Project mode: delete `coding-rules/manifest.json`, then delete the `coding-rules/` folder only if it is now empty. If anything is left in it (files the user added, or edited files they chose to keep), list it and ask before deleting it. Personal mode: delete `manifest.json` from the clone, then ask whether to delete the clone itself.
5. Report what was removed. In project mode, remind the user to commit the changes.
