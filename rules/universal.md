# Universal Principles

Language-agnostic rules that apply to every file in every project. Language-specific rules build on top of these; when they conflict, the more specific rule wins.

## Code is a story

Code is a step-by-step list of operations that ultimately serve a definite purpose, and it should read like a story of achieving that purpose.

- Each file should define what is necessary for its step of the story and read as both a chapter in the larger story and a story in itself.
- The story never takes detours to explain details inline. Details are extracted into smaller, modular parts and referenced — code is a hyperlinked story. Think of Little Red Riding Hood: the story covers the journey and the goal, not the weave of the basket. Anyone curious about the basket should be able to read the basket's own story separately.
- The entry file of a project is the table of contents: it executes the main steps needed to achieve the goal (or, for daemon-like projects, the initialization and setup) and delegates everything else. It never tells the whole story itself.
- The folder structure mirrors the story's hierarchy. Navigating the tree should feel like descending from chapters to scenes to sentences.

## Don't repeat yourself (DRY)

- Extract a shared piece on the third occurrence, or at the second when the copies encode the same rule and must change together. Code that merely looks alike may stay duplicated (see "Abstraction discipline").
- When shared code lives in a location that reflects only its original, narrower use, move it up to a level where all consumers can reference it naturally. Example: a utility in `queue/utils/map.ts` that `jobs/manager.ts` also needs moves to `utils/map.ts`, and both reference it there.

## Abstraction discipline — the counterweight to DRY

DRY removes retold stories; it does not license inventing stories nobody asked for.

- Prefer duplication over the wrong abstraction. If two call sites start forcing parameters, flags, or branches into a shared helper to serve their diverging needs, inline the helper back and let them diverge.
- YAGNI: build for the requirements that exist, not hypothetical futures. No plugin systems, generic engines, or configuration surfaces for a single concrete use case, and no extra module, package, or service for a hypothetical future consumer.
- Within code that is built and deployed together, keep no backward-compatibility shims: update every caller and delete the old path in the same change. Across a deploy boundary (separate services, shipped clients, persisted data, published packages and APIs) change compatibly instead, as the API design and data rules describe.

## Naming

We are telling a story, but not writing art open to interpretation. Be clear, explicit, and unambiguous.

- Names carry just enough information to be unique and descriptive — never too general, never redundant.
  - `JobQueue`, not `Queue` (too general: what is the queue for? collides with future queues) and not `JobQueueSystem` ("system" adds nothing).
  - `symbolCollection`, not `collection` (too general).

## Small, modular units

- Keep functions and files small enough to read in one sitting. Soft caps: ~50 lines per function, ~300 lines per file. When a unit exceeds the cap, split it: extract helpers, lift sub-parts into their own files, break orchestrators into smaller composed pieces.
- One module = one concern. A file that needs "and" to describe what it does is usually two files.

## Function and API design

A function's signature is a promise to the caller; design it from the caller's point of view.

- Keep parameters few — two or three positional parameters at most. Beyond that, take a named structure (options object, keyword arguments) so call sites are self-describing.
- No boolean flag parameters that fork a function into two behaviors (`render(data, true)`). Split into two well-named functions, or accept a named enum/option whose meaning is visible at the call site.
- Prefer separating commands from queries: a function either performs an effect or answers a question. When it must do both (pop, upsert, create-and-return-id), its name says so. Callers should never fear that asking a question changed something.
- Return consistent shapes. A function that returns a list returns an empty list — not `null` — when there is nothing; a lookup that can miss says so in its signature (optional/nullable type), not by surprise.
- Do not mutate arguments. Inputs are inputs; produce and return new values unless the function's stated purpose is in-place mutation.
- Make interfaces easy to use correctly and hard to misuse: pick defaults that are safe, and make the dangerous variant the one that requires explicit opt-in.
- Aim for deep modules: a small, simple surface hiding substantial functionality. Many shallow wrappers that each add one trivial step are indirection, not abstraction.

## No dead code

- When a feature is dropped, delete every layer of it — implementation, tests, fixtures, types, docs. Do not keep code around "in case we need it later."

## Constants over magic values

- A literal (string or number) with meaning that appears more than twice gets a named constant.
- Group related constants in a dedicated module or section so consumers reference one source of truth.

## Errors

- Never swallow errors silently.
- Handle an error where you can do something about it, or propagate it with added context. Log it once, where it is finally handled or at the top-level boundary, not at every layer it passes through.

## Logging tells the story

The story should be told not only in the code but in the logs, whether emitted to the console or a file.

- Each log line reflects when something happened, which part of the story it belongs to, and what was done.
- Namespace log output by code area so different parts of the story are distinguishable (child loggers, module-level loggers, or debug namespaces, depending on the stack).
- Logs may carry data, but always with context — never a bare value with no explanation.

## Comments

- Comments explain intent, trade-offs, and constraints the code cannot convey — the "why," not the "what." Comments that narrate what the code does are noise; delete them.

## Documentation

- Every project has a README that gets a newcomer from clone to running in minutes: what this is, how to set it up, how to run it, how to test it. Like the entry file, it is the table of contents of the project's story.
- Public APIs (anything consumed outside its own module) get doc comments (docstrings, TSDoc, etc.) when intent, edge cases, or failure behavior are not obvious from the name and types. Never restate the signature in prose.
- Documentation lives as close to the code it describes as possible and is updated in the same change as that code. Stale documentation is worse than none, because it is trusted.
- Record significant architectural decisions and their reasoning in a lightweight note (an ADR or a dated section in the docs) so future readers learn why, not just what.

## Boundaries

- Validate at system boundaries: user input, external APIs, files, environment. Inside those boundaries, trust your own code and types instead of re-validating defensively at every layer.

## Dates and money

- A calendar date ("2026-07-08", a birthday, a check-in day) is not a timestamp. Keep date-only values in date-only types; converting them through midnight-in-some-timezone invents bugs.
- Keep the currency with every money amount; an amount without its currency is meaningless data.

## Dependencies

- Prefer the standard library and existing project dependencies over adding a new package for something small.

## Editing existing code

- The project's established conventions win over these rules. Follow them even where they differ; consistency inside a codebase beats global preference.
- Where code you are already changing violates one of these rules and the violation is not a project convention (a swallowed error, a magic value), fix it within the lines you change and mention it. Never restyle untouched code.

## Scope of work

- Implement exactly what was asked. No drive-by features, refactors, or "improvements" outside the task's scope — propose them separately instead.
- When a task reveals a genuine problem outside its scope (a bug, a broken invariant), report it; do not silently fix or silently ignore it.
