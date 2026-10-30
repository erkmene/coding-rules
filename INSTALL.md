# Installing coding-rules

These instructions are for a coding agent. A person starts an install, update or removal by asking their agent, for example:

> Install the coding rules from https://github.com/erkmene/coding-rules. Follow its INSTALL.md.

Read this whole file before acting, then follow the section that matches the request: [Install](#install), [Update](#update), or [Uninstall](#uninstall).

## Terms

- **Source**: this repository, at one release tag (`vX.Y.Z`) or at a commit on `main`.
- **Rules folder**: the folder your tools read the rules from. In personal mode it is the user's clone of the source. In project mode it is `coding-rules/` in the project root, holding a copy of `rules/`, `checklists/`, `INSTALL.md` and `CHANGELOG.md`.
- **Wiring**: the files you create in a tool's own configuration so that each rule loads at the right time.
- **Instructions file**: the plain-text instructions file your tool reads at the start of every session, such as `AGENTS.md` or your tool's own equivalent. In personal mode, use the user-level instructions file. In project mode, use the file in the project root.
- **Manifest**: `manifest.json` in the rules folder. It records what was installed.

## Hard rules

1. A wiring file contains activation metadata and a reference to its rule file, nothing else. Never copy, summarise or paraphrase rule text into a wiring file or an instructions file. Copies drift from the source, and preventing that drift is the point of this repository.
2. Name every wiring file `coding-rules-<rule>`, using the extension your tool expects, e.g. `coding-rules-git.md`. When your tool needs one folder per item, name the folder that way.
3. Create, change or delete only:
   - the rules folder;
   - `coding-rules-*` files and folders that the manifest lists or that you are creating now;
   - the text between `<!-- coding-rules:begin -->` and `<!-- coding-rules:end -->` in an instructions file;
   - an instructions file that does not exist yet, and the parent directories that wiring needs. Record both in the manifest.
   
   If anything else is in the way, stop and ask the user.
4. Use only mechanisms your tool documents. If you are not sure your tool supports a mechanism, check its documentation. If you still cannot confirm it, use the fallback for that class. Never guess at a configuration format.
5. Before you replace or delete a file whose hash differs from the one in the manifest, the user has edited it. Show them the difference and ask what to do.

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
| `rules/javascript.md` | paths | `**/*.{js,jsx,mjs,cjs,ts,tsx,mts,cts}` |
| `rules/typescript.md` | paths | `**/*.{ts,tsx,mts,cts}` |
| `rules/python.md` | paths | `**/*.py` |
| `rules/new-project-python.md` | activity | creating a Python project, or changing its packaging, dependency or tooling setup |
| `rules/react.md` | paths | `**/*.{jsx,tsx}`, `**/use[A-Z]*.{ts,js}`, `**/hooks/**/*.{ts,js}` |
| `rules/testing.md` | activity + paths | writing or changing tests in any language; files matching any of `**/*.{test,spec}.{js,jsx,mjs,cjs,ts,tsx,mts,cts}`, `**/__tests__/**`, `**/test_*.py`, `**/*_test.py`, `**/{test,tests}/**/*.py`, `**/conftest.py`, `**/tests.py` |
| `rules/testing-js.md` | paths | `**/*.{test,spec}.{js,jsx,mjs,cjs,ts,tsx,mts,cts}`, `**/__tests__/**` |
| `rules/testing-python.md` | paths | `**/test_*.py`, `**/*_test.py`, `**/{test,tests}/**/*.py`, `**/conftest.py`, `**/tests.py` |
| `checklists/review.md` | review | before handing work off |

How to wire each class:

- **always**: use your tool's always-on mechanism. If that mechanism can include a file by reference, reference the rule file. Otherwise, add a fallback line to the managed block: "Read `<path>` at the start of every task."
- **paths**: use your tool's path-scoped rules with the globs above, referencing the rule file. If your tool cannot scope by path, add a fallback line: "When working on files matching `<globs>`, read `<path>`."
- **activity**: use your tool's on-demand mechanism (for example a skill, or a rule the agent pulls in by its description). Use the "Load when" text as the description and reference the rule file. If there is none, add a fallback line: "When `<activity>`, read `<path>`."
- **activity + paths**: wire the activity and the paths as two separate pieces of wiring: the on-demand mechanism without any path restriction, plus a path-scoped rule. Do not combine them into one item when your tool's path field restricts it to matching files only (in Claude Code, a skill with `paths` loads only for matching files and is no longer offered for the activity). Name the two pieces so they don't collide, e.g. `coding-rules-data` for the on-demand item and `coding-rules-data-paths` for the path-scoped rule.
- **opt-in**: wire this rule only if the user said yes during install, then wire it by its other classes.
- **review**: if your tool supports subagents, create one named `coding-rules-reviewer` with these instructions: read `<path to checklists/review.md>`, then review the current diff against the checklist and the rule files whose paths match the changed files, and report findings without editing. In every case, add a review line to the managed block (see below).

Write references as paths your tool resolves:
- project mode: paths relative to the project root, e.g. `coding-rules/rules/git.md`;
- personal mode: absolute paths into the clone.

## The managed block

Put this block in each instructions file you wire. Fill in the angle-bracket parts, and keep everything else exactly as written. Use the first line that matches the mode:

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
- `installedAt`: the date, as `YYYY-MM-DD`.
- `mode`: `personal` or `project`.
- `optIn`: the opt-in rules that were installed, e.g. `["i18n"]`.
- `directories`: every directory you created, deepest first, e.g. `[".claude/skills/coding-rules-git", ".claude/skills"]` in project mode. Do not list a directory that already existed.
- `files`: an object mapping the path of every file you created or manage to its SHA-256 hash. Include:
  - wiring files;
  - instructions files you created (record `null` for an instructions file that already existed, since only its block is yours);
  - in project mode, each copied file: rules, checklists, `INSTALL.md` and `CHANGELOG.md`.

## Install

1. **Ask the user**, in one message:
   - **Mode.** Personal: one clone serves all their projects on this machine, it is wired into their tools' user-level configuration, and updating it updates every project at once. Project: a copy is committed into this project, so it works for everyone who clones the project and in cloud or CI sessions, and each project is updated on its own. Recommend personal for someone working alone on one machine, and project for shared repositories or cloud sessions.
   - **Tools.** Which agent tools to wire. List the ones you detected from configuration folders in the project and in the user's home directory, plus yourself.
   - **i18n.** Whether the project translates, or will translate, its user-facing text.
   - **Version.** The latest release tag (the default) or `main`. If the source has no release tags yet, say so and offer `main`.
   - **Location** (personal mode only). Where the clone goes (default `~/coding-rules`), or where their existing clone is.
2. **Get the source.**
   - Personal: clone the source into the chosen folder, or use the existing clone, and check out the chosen version. Add nothing to the clone except `manifest.json`, which the repository ignores.
   - Project: fetch the chosen version into a temporary folder outside the project. Copy `rules/`, `checklists/`, `INSTALL.md` and `CHANGELOG.md` into `<project root>/coding-rules/`. If `coding-rules/` already exists without a manifest, stop and ask the user.
3. **Wire every rule** in the table for each chosen tool: at user level in personal mode, at project level in project mode.
4. **Write the managed block** into each instructions file.
5. **Write the manifest.**
6. **Verify:**
   - every wiring file contains only metadata and a reference;
   - every reference points to a file that exists;
   - where your tool can list the rules or instructions it has loaded, the **always** rules appear;
   - in project mode, `git check-ignore` reports none of the rules folder, the wiring files or the instructions file as ignored.
7. **Report:**
   - the mode and the version;
   - the files you created, replaced or skipped;
   - which rules use a fallback line;
   - anything that needs the user's attention.
   
   In project mode, remind the user to commit the changes.

## Update

1. Read the manifest. If there is none, do an Install instead.
2. Pick the target version: the latest release tag, unless the user names one. If the install tracks `main`, the target is the newest commit on `main`. Compare the manifest's `commit` with the target's commit; if they are the same, say so and stop.
3. Read the changelog entries the update brings in, and note each entry's **Action**. For a release target, read every entry newer than the installed version. When either version is `main`, read every line added to `CHANGELOG.md` between the installed commit and the target (`git diff <installed commit> <target commit> -- CHANGELOG.md`), including lines under `Unreleased`.
4. Get the target version.
   - Personal: in the clone, fetch and check out the target. If the clone has local changes, stop and ask.
   - Project: copy fresh files as in Install step 2. First compare the current files with the manifest hashes, and ask before overwriting any file the user changed.
5. Carry out every **manual** action. Ask when an action needs a decision.
6. Reconcile the wiring with the table in the target version's `INSTALL.md`:
   - create wiring that is missing;
   - replace wiring that changed (hard rule 5 applies);
   - delete manifest-listed wiring that the target table no longer calls for, whether its rule was removed or its class changed;
   - in project mode, delete manifest-listed copied files that the target version no longer ships, such as a removed or renamed rule (hard rule 5 applies);
   - delete any directory in `directories` that this leaves empty.
7. Rewrite the managed block and the manifest, then verify as in Install step 6.
8. Report:
   - the old and new versions;
   - a short summary of the changelog entries that change how the agent should work;
   - the files you changed.
   
   In project mode, remind the user to commit the changes.

## Uninstall

1. Read the manifest. Delete every file it lists, except instructions files that existed before the install (hard rule 5 applies). Then delete each directory in `directories` that is now empty, in the order listed.
2. Remove the managed block from each instructions file.
3. Project mode: delete `coding-rules/manifest.json`, then delete the `coding-rules/` folder only if it is now empty. If anything is left in it (files the user added, or edited files they chose to keep), list it and ask before deleting it. Personal mode: ask whether to delete the clone.
4. Report what was removed. In project mode, remind the user to commit the changes.
