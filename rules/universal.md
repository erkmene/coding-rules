# Universal Principles

Language-agnostic rules that apply to every file in every project. Language-specific rules build on top of these; when they conflict, the more specific rule wins.

## Code is a story

Code is a step-by-step list of operations that ultimately serve a definite purpose, and it should read like a story of achieving that purpose.

- Each file should define what is necessary for its step of the story and read as both a chapter in the larger story and a story in itself.
- The story never takes detours to explain details inline. Details are extracted into smaller, modular parts and referenced — code is a hyperlinked story. Think of Little Red Riding Hood: the story covers the journey and the goal, not the fabric of the girl's clothes or the weave of the basket. Anyone curious about the basket should be able to read the basket's own story separately.
- The entry file of a project is the table of contents: it executes the main steps needed to achieve the goal (or, for daemon-like projects, the initialization and setup) and delegates everything else. It never tells the whole story itself.
- The folder structure mirrors the story's hierarchy. Navigating the tree should feel like descending from chapters to scenes to sentences.

## Don't repeat yourself (DRY)

- Each part of the story is told in detail exactly once, then only referenced.
- If you catch yourself writing a similar story to one told before, go back to the earlier one, extend it to cover the new case, and reference it from both places.
- When shared code lives in a location that reflects only its original, narrower use, move it up to a level where all consumers can reference it naturally. Example: a utility in `queue/utils/map.ts` that `jobs/manager.ts` also needs moves to `utils/map.ts`, and both reference it there.
- Duplication across files is still duplication. Extract to a shared module rather than copy-pasting a block that already exists elsewhere.

## Abstraction discipline — the counterweight to DRY

DRY removes retold stories; it does not license inventing stories nobody asked for.

- Apply the rule of three: two occurrences of similar code may be coincidence — tolerate the duplication; the third occurrence proves the pattern — extract it then.
- Prefer duplication over the wrong abstraction. If two call sites start forcing parameters, flags, or branches into a shared helper to serve their diverging needs, inline the helper back and let them diverge.
- YAGNI: build for the requirements that exist, not hypothetical futures. No plugin systems, generic engines, or configuration surfaces for a single concrete use case.
- No backward-compatibility shims or translation layers inside a codebase you control. When something changes, update every caller and delete the old path in the same change.

## Naming

We are telling a story, but not writing art open to interpretation. Be clear, explicit, and unambiguous.

- Names carry just enough information to be unique and descriptive — never too general, never redundant.
  - `JobQueue`, not `Queue` (too general: what is the queue for? collides with future queues) and not `JobQueueSystem` ("system" adds nothing).
  - `symbolCollection`, not `collection` (too general).
- Functions are verbs or verb phrases (`loadUserProfile`, `mapRoomRates`); values and types are nouns (`userProfile`, `RoomRate`).
- Booleans read as predicates: `isReady`, `hasErrors`, `shouldRetry`.
- Do not encode types into names (no Hungarian notation) and do not abbreviate unless the abbreviation is universally understood (`id`, `url`, `max`).

## Small, modular units

- Keep functions and files small enough to read in one sitting. Soft caps: ~50 lines per function, ~300 lines per file. When a unit approaches the cap, split it: extract helpers, lift sub-parts into their own files, break orchestrators into smaller composed pieces.
- One module = one concern. A file that needs "and" to describe what it does is two files.
- Keep cognitive complexity low. Extract early-return branches into helpers, replace long `if/else if` chains with lookup maps, and keep side-effect orchestration out of pure transforms.
- Maximum one level of ternary/conditional-expression nesting. Two levels means extract a helper; three means use an explicit branch structure or lookup table.

## Function and API design

A function's signature is a promise to the caller; design it from the caller's point of view.

- Handle edge cases first with guard clauses and early returns; the happy path reads straight down at minimal indentation. Deep nesting is a smell.
- Keep parameters few — two or three positional parameters at most. Beyond that, take a named structure (options object, keyword arguments) so call sites are self-describing.
- No boolean flag parameters that fork a function into two behaviors (`render(data, true)`). Split into two well-named functions, or accept a named enum/option whose meaning is visible at the call site.
- Separate commands from queries: a function either performs an effect or answers a question, not both. Callers should never fear that asking a question changed something.
- Return consistent shapes. A function that returns a list returns an empty list — not `null` — when there is nothing; a lookup that can miss says so in its signature (optional/nullable type), not by surprise.
- Do not mutate arguments. Inputs are inputs; produce and return new values unless the function's stated purpose is in-place mutation.
- Make interfaces easy to use correctly and hard to misuse: pick defaults that are safe, and make the dangerous variant the one that requires explicit opt-in.
- Aim for deep modules: a small, simple surface hiding substantial functionality. Many shallow wrappers that each add one trivial step are indirection, not abstraction.

## No dead code

- Never leave commented-out code in a commit. Version control history is the archive.
- Remove unused variables, parameters, imports, helpers, branches, and unreachable code.
- When a feature is dropped, delete every layer of it — implementation, tests, fixtures, types, docs. Do not keep code around "in case we need it later."

## Constants over magic values

- A literal (string or number) with meaning that appears more than twice gets a named constant.
- Group related constants in a dedicated module or section so consumers reference one source of truth.

## Errors

- Never swallow errors. An empty `catch`/`except` block (or one containing only a comment) is forbidden.
- At minimum, log the error with context; ideally, handle it meaningfully or rethrow/propagate it.
- Catch specific error types where the language allows it, and only catch where you can actually do something about the failure.
- Fail fast on programmer errors (broken invariants, impossible states); handle expected runtime failures (network, user input, filesystem) gracefully.

## Logging tells the story

The story should be told not only in the code but in the logs, whether emitted to the console or a file.

- Each log line reflects when something happened, which part of the story it belongs to, and what was done.
- Namespace log output by code area so different parts of the story are distinguishable (child loggers, module-level loggers, or debug namespaces, depending on the stack).
- Logs may carry data, but always with context — never a bare value with no explanation.
- Never log secrets, tokens, passwords, session identifiers, or personal data. When a sensitive value is needed for correlation, log a stable hash or last-four fragment instead.
- Use levels appropriately: errors for failures needing attention, warnings for recoverable anomalies, info for the main story beats, debug for the fine detail.
- Keep logging clean; no leftover ad-hoc print/log statements from debugging sessions.

## Comments

- Code should explain itself through naming and structure. Comments explain intent, trade-offs, and constraints the code cannot convey — the "why," not the "what."
- Comments that narrate what the code does are noise; delete them.
- Keep comments adjacent to the code they describe and update or remove them when the code changes.

## Documentation

- Every project has a README that gets a newcomer from clone to running in minutes: what this is, how to set it up, how to run it, how to test it. Like the entry file, it is the table of contents of the project's story.
- Public APIs — anything consumed outside its own module — get doc comments (docstrings, TSDoc, etc.) covering intent, non-obvious edge cases, and failure behavior. Never restate the signature in prose.
- Documentation lives as close to the code it describes as possible and is updated in the same change as that code. Stale documentation is worse than none, because it is trusted.
- Record significant architectural decisions and their reasoning in a lightweight note (an ADR or a dated section in the docs) so future readers learn why, not just what.

## Correctness and boundaries

- Validate at system boundaries: user input, external APIs, files, environment. Inside those boundaries, trust your own code and types instead of re-validating defensively at every layer.
- Never build queries, commands, paths, or markup by concatenating untrusted input. Use parameterized/escaping APIs: parameterized queries for SQL/NoSQL, safe path resolution (reject `..` and absolute paths against an allowed root), framework escaping for HTML.
- Never pass user-controlled data to code-execution sinks (`eval`-like APIs, shell strings, dynamic imports).
- Use cryptographically secure randomness for anything security-related; ordinary PRNGs are for everything else.

## Dates, times, and money

- Store and transmit timestamps in UTC (ISO 8601 with offset, or epoch); convert to a timezone only at the display layer.
- Never do arithmetic on local wall-clock times — DST transitions and offset changes will corrupt it. Compute in UTC or with a timezone-aware library, then format.
- A calendar date ("2026-07-08", a birthday, a check-in day) is not a timestamp. Keep date-only values in date-only types; converting them through midnight-in-some-timezone invents bugs.
- Represent money in integer minor units (cents) or a decimal type — never binary floating point. `0.1 + 0.2` is not `0.3`.
- Keep the currency with the amount; an amount without its currency is meaningless data.
- Format dates, times, numbers, and currency through locale-aware APIs at display time; never hand-assemble them with string concatenation.

## User-facing text and internationalization

Applies to projects that translate (or will translate) their user-facing text.

- Every user-facing string comes from the translation system via a key; no hardcoded display text in code.
- Never concatenate translated fragments to build a sentence — word order differs across languages. Use one template key with placeholders (`"{0} guest limit"`, `"This reservation has been {0}"`) and substitute at render time, so translators control the full sentence shape.
- When part of a sentence needs styling (bold, a link), keep the sentence as a single template and inject the styled piece as a placeholder value; do not split the sentence across keys to match the markup.
- Name keys by feature namespace, lowercase and dot-separated (`booking.summary.cta.confirm`); never reuse one key for two different meanings, even if the source-language text happens to match.
- Do not assume pluralization is "add an s" — use the translation system's plural rules.

## Performance

- Correct and clear first; optimize only what measurement shows to be slow, and keep the measurement.
- Some things need no profiler — avoid them by construction: N+1 query patterns, network or filesystem calls inside loops that could be batched, linear scans where a keyed lookup (map/set/index) fits, loading entire datasets to use one field.
- Choose the right data structure for the access pattern; that decision usually dominates micro-optimizations.
- Do not trade readability for speculative speed. An "optimization" without a measurement behind it is just obfuscation.

## Secrets

- Never commit secrets: keys, certificates, tokens, credential-bearing URLs — even expired ones, even in test fixtures.
- When a test needs a credential-shaped string, use an obvious dummy (`EXAMPLE_API_KEY`, `test-token`), never a realistic-looking value.
- Configuration that varies by environment (including secrets) comes from the environment, not from source code.

## Dependencies

- Prefer the standard library and existing project dependencies over adding a new package for something small.
- When adding a dependency, prefer actively maintained, widely adopted packages, and add it through the project's package manager so the version is recorded in the manifest and lockfile.

## Editing existing code

- Follow the conventions already established in the file and project, even when they differ from your defaults; consistency inside a codebase beats global preference.
- Fix deviations from these rules on touch — when you edit code that violates a rule, bring it into line rather than replicating the violation.
- Do not mix reformatting with logic changes; a diff that does both is unreviewable.

## Definition of done

Work is finished when it would pass the review of a demanding colleague, not when it merely runs.

- Re-read the full diff before handing it off, as a reviewer would. Every changed line is intentional; nothing unrelated rode along.
- The formatter, linter, and type checker pass with no new suppressions.
- Tests pass — including the new tests this change needed. Changed behavior without a changed test is unfinished work.
- Documentation, comments, and log messages touched by the change are updated with it.
- Leftover scaffolding is gone: debug output, temporary files, TODO markers for things this change was supposed to do.

## Working with AI assistance

Rules for AI agents (and humans pairing with them) working in a codebase.

- Never invent APIs, options, or behaviors. If unsure whether a function, flag, or field exists, read the source or documentation and confirm before using it.
- Implement exactly what was asked. No drive-by features, refactors, or "improvements" outside the task's scope — propose them separately instead. (Bringing a line you are already editing into compliance with these rules, per "Editing existing code," is in scope; rewriting untouched code is not.)
- Before writing new code, look at how the codebase already solves similar problems and follow that pattern; do not introduce a second convention alongside an existing one.
- Verify claims by running things — the test suite, the type checker, the actual command — rather than asserting from memory that they work.
- When a task reveals a genuine problem outside its scope (a bug, a broken invariant), report it; do not silently fix or silently ignore it.
