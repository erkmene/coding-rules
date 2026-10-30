# JavaScript Guidelines

Apply to all JavaScript code and, together with the TypeScript guidelines, to TypeScript code. Universal principles apply first.

## Paradigm

- Prefer functional programming over object-oriented programming: small pure functions composed together.
  - OOP is acceptable when it is truly the right fit — rare and well-justified, such as managing the state of well-defined entities (a queue system with `Job`, `Task`, `Worker`).
- Prefer composition over inheritance. Inheritance is powerful but should be used sparingly and only when truly necessary; a class hierarchy more than one level deep is a design smell.
- Produce new arrays/objects (spread, `map`, `filter`, `toSorted`) instead of mutating inputs.

## Asynchrony

- Prefer `try`/`catch` blocks over promise `.then()`/`.catch()` chains. A `.catch()` is fine for deliberate fire-and-forget calls.
- Run independent async work concurrently with `Promise.all` (or `allSettled` when partial failure is acceptable) instead of awaiting sequentially.

## Language usage

- Use `??` rather than `||` for defaults; `||` misfires on `0`, `''`, and `false`.

## Errors

- Give errors messages with context: what was being attempted, with which key inputs.
