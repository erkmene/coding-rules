# Git Guidelines

Apply to version-control activity — commits, branches, pull requests — in every project. A project's established workflow (branch naming, merge strategy, PR process) wins over these defaults.

## Commits

- Commits are atomic: one logical change per commit, and the build and tests pass at every commit.
- Reformatting, renames, and other mechanical changes are separate commits from logic changes — a diff that mixes both is unreviewable (universal "Editing existing code" rule, applied at the commit level).
- Nothing unrelated rides along; the staged diff is re-read before committing, per the universal Definition of done.

## Commit messages

- Subject line in the imperative mood, capitalized, no trailing period, aiming for ~50 characters and never past 72. The test: the subject completes the sentence "If applied, this commit will …".
- When the diff cannot explain *why*, add a body after a blank line that does. The what is visible in the diff; the why is not.
- Conventional Commits prefixes (`feat:`, `fix:`) are not required; if the project already uses them, follow suit.

## Branches

- Branches are short-lived and named by intent: `feature/*`, `fix/*`, or `chore/*` (or the project's established scheme).
- Your own unshared branch is yours to rebase and rewrite freely — until someone else has pulled it.

## Pull requests

- One concern per PR. A title that joins different kinds of change ("add X and reformat Y") is two PRs; listing several items of the same kind ("add A, B, and C") is still one.
- Large mechanical changes (renames, reformatting, generated code) go in their own PR so review attention lands on the real change.
- The description states the intent and how the change was verified — reviewers review the claim, not just the diff.

## History

- Never force-push a shared branch or rewrite published history.
- A secret that reaches a commit is compromised: rotate it immediately. Deleting the commit does not remove it from history, reflogs, or existing clones (universal Secrets rules).
