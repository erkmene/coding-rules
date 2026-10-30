# Review Checklist

Go through this before handing work off, ideally as a separate review pass with fresh context. Report each item that fails.

Work is finished when it would pass the review of a demanding colleague, not when it merely runs.

- Re-read the full diff before handing it off, as a reviewer would. Every changed line is intentional; nothing unrelated rode along.
- The formatter, linter, and type checker pass with no new suppressions.
- Tests pass — including the new tests this change needed. Changed behavior without a changed test is unfinished work.
- Documentation, comments, and log messages touched by the change are updated with it.
- Leftover scaffolding is gone: debug output, temporary files, TODO markers for things this change was supposed to do.

## Working with AI assistance

- Never invent APIs, options, or behaviors. If unsure whether a function, flag, or field exists, read the source or documentation and confirm before using it.
- Before writing new code, look at how the codebase already solves similar problems and follow that pattern; do not introduce a second convention alongside an existing one.
- Verify claims by running things — the test suite, the type checker, the actual command — rather than asserting from memory that they work.
- Reformatting is not mixed with logic changes; a diff that does both is unreviewable.
