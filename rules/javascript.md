# JavaScript Guidelines

Apply to all JavaScript code (`.js`, `.mjs`, `.cjs`, `.jsx`) and, together with the TypeScript guidelines, to TypeScript code. Universal principles apply first.

## Paradigm

- Prefer functional programming over object-oriented programming: small pure functions composed together.
  - OOP is acceptable when it is truly the right fit — rare and well-justified, such as managing the state of well-defined entities (a queue system with `Job`, `Task`, `Worker`).
- Prefer pure functions over functions with side effects. Isolate side effects (I/O, mutation, network) at the edges; keep transforms pure so they are trivially testable.
- Prefer composition over inheritance. Inheritance is powerful but should be used sparingly and only when truly necessary; a class hierarchy more than one level deep is a design smell.
- Prefer immutability: `const` by default, `let` only when reassignment is required, never `var`. Produce new arrays/objects (spread, `map`, `filter`, `toSorted`) instead of mutating inputs.

## Asynchrony

- Prefer `async`/`await` over callbacks.
- Prefer `try`/`catch` blocks over promise `.then()`/`.catch()` chains.
- Never leave a promise floating. Every promise is awaited, returned, or explicitly marked as fire-and-forget (e.g. `void doThing()`), with errors handled either way.
- Run independent async work concurrently with `Promise.all` (or `allSettled` when partial failure is acceptable) instead of awaiting sequentially.
- Event handlers and other void-returning callbacks must not be `async` directly; wrap the async call so rejections are handled: `onClick={() => { void save(); }}`.

## Language usage

- Use strict equality (`===` / `!==`) always; the loose forms hide coercion bugs.
- Prefer destructuring over repeated property access on objects and arrays.
- Prefer optional chaining (`?.`) and nullish coalescing (`??`) over nested `if` blocks and `||` fallbacks (`||` misfires on `0`, `''`, `false`).
- Prefer template literals over string concatenation.
- Use ES modules (`import`/`export`) exclusively. No globals; everything a module offers is an explicit export.
- Use `for...of`, `map`, `filter`, `reduce` as appropriate; avoid index-based `for` loops unless the index itself matters.
- Default parameter values over in-body `x = x || default` patterns.

## Errors

- Throw `Error` instances (or subclasses), never strings or plain objects.
- Give errors messages with context: what was being attempted, with which key inputs.
- Custom error classes are justified when callers need to branch on the error kind.

## Console and logging

- No stray `console.log` in committed code. Use the project's logger; where only `console` exists, use the appropriate level (`console.error` in catches, `console.warn` for recoverable anomalies, `console.debug` for diagnostics).
- Follow the universal logging rules: namespaced, contextual, story-telling logs (`debug` namespaces or `pino` child loggers are good models).

## Formatting and linting

- The project's formatter (e.g. Prettier) and linter (e.g. ESLint) are the authority on style; never fight them or disable rules inline without a stated reason.
- An `eslint-disable` comment requires a justification comment on the same or preceding line.
